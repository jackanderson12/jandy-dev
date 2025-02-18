import Leaf
import Vapor
import Fluent
import FluentSQLiteDriver
import FluentPostgresDriver

// Configures your application
public func configure(_ app: Application) async throws {
    // Load environment variables
    app.environment = try .detect()
    
    if let apiKey = Environment.get("API_KEY") {
        print("API Key Loaded")
    } else {
        print("Warning: API_KEY not found")
    }
    
    if let webFormAPIKey = Environment.get("WEB_FORM_API_KEY") {
        print("Web form key loaded")
    } else {
        print("Failed to load the web form api key")
    }
    
    // Increase the maximum request body size (e.g., 50MB)
    app.routes.defaultMaxBodySize = "50mb"
    
    // Serve files from both directories
    app.middleware
        .use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Use Leaf for views
    app.views.use(.leaf)
    app.leaf.tags["preview"] = PreviewTag()
    app.leaf.tags["feature"] = SwiperFeatureTag()
    
    // Use PostgreSQL for production
    if let unixSocket = Environment.get("INSTANCE_UNIX_SOCKET"),
       let username = Environment.get("DB_USER"),
       let password = Environment.get("DB_PASS"),
       let databaseName = Environment.get("DB_NAME")
    {
        // Construct the connection string.
        // Note: When connecting via Unix socket, there is no hostname before the slash.
        let connectionString = "postgres://\(username):\(password)@/\(databaseName)?host=\(unixSocket)&sslmode=disable"

        guard let url = URL(string: connectionString),
              let config = try? SQLPostgresConfiguration(url: url)
        else {
            return
        }

        app.databases.use(.postgres(configuration: config), as: .psql)
    } else {
        let databaseDir = app.directory.workingDirectory + "Database/"

        // Ensure the Database directory exists
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: databaseDir) {
            try fileManager.createDirectory(atPath: databaseDir, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Use SQLite for development
        let databasePath = app.directory.workingDirectory + "Database/db.sqlite"
        app.databases.use(.sqlite(.file(databasePath)), as: .sqlite)
    }

    
    // Migration for the Blog
    app.migrations.add(CreateBlogPost())

    // Run migrations automatically
    try await app.autoMigrate()
    
    // Register routes
    try routes(app)
}
