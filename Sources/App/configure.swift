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
    
    let databaseDir = app.directory.workingDirectory + "Database/"
    let databasePath = databaseDir + "db.sqlite"

    // Ensure the Database directory exists
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: databaseDir) {
        try fileManager.createDirectory(atPath: databaseDir, withIntermediateDirectories: true, attributes: nil)
    }
    
    // Database configuration based on environment
    if Environment.get("ENVIRONMENT") ==  "development" {
        // Use SQLite for development
        let databasePath = app.directory.workingDirectory + "Database/db.sqlite"
        app.databases.use(.sqlite(.file(databasePath)), as: .sqlite)
        print("Running in development mode with SQLite database.")
    } else {
        // Use PostgreSQL for production
        guard
            let hostname = Environment.get("DATABASE_HOST"),
            let username = Environment.get("DATABASE_USERNAME"),
            let password = Environment.get("DATABASE_PASSWORD"),
            let databaseName = Environment.get("DATABASE_NAME")
        else {
            fatalError("Missing production database configuration.")
        }
        app.databases.use(
            .postgres(
                configuration: .init(
                    hostname: hostname,
                    username: username,
                    password: password,
                    database: databaseName,
                    tls: .disable
                )
            ),
            as: .psql
        )
        print("Production database configuration loaded.")
    }
    
    // Migration for the Blog
    app.migrations.add(CreateBlogPost())

    // Run migrations automatically
    try await app.autoMigrate()
    
    // Register routes
    try routes(app)
}
