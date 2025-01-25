import Leaf
import Vapor
import Fluent
import FluentSQLiteDriver

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
    
    // Serve files from the /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

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
    
    // Configure SQLite database with a file
    app.databases.use(.sqlite(.file(databasePath)), as: .sqlite)
    

    
    // Run migrations
    app.migrations.add(CreateBlogPost())

    // Run migrations automatically
    try await app.autoMigrate()
    
    // Register routes
    try routes(app)
}
