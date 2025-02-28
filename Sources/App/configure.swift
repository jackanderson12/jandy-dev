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
    
    // Increase the maximum request body size (200MB)
    app.routes.defaultMaxBodySize = "200mb"
    
    // Serve files from both directories
    app.middleware
        .use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Use Leaf for views
    app.views.use(.leaf)
    app.leaf.tags["preview"] = PreviewTag()
    app.leaf.tags["imagePreview"] = PreviewImage()
    app.leaf.tags["feature"] = SwiperFeatureTag()
    
    // Use PostgreSQL for production
    guard
        let username = Environment.get("DB_USER"),
        let password = Environment.get("DB_PASS"),
        let databaseName = Environment.get("DB_NAME")
    else {
        fatalError("Missing required environment variables")
    }

    // Use PostgreSQL for production via Unix socket, use only on Google CLoud
    if let unixSocket = Environment.get("INSTANCE_UNIX_SOCKET") {
        app.databases.use(
            .postgres(
                configuration: .init(
                    unixDomainSocketPath: "\(unixSocket)/.s.PGSQL.5432",
                    username: username,
                    password: password,
                    database: databaseName
                )
            ),
            as: .psql
        )
        print("Production Database Loaded via Unix Socket.")
    } else {
        app.databases.use(.sqlite(.file("./Database/db.sqlite")), as: .sqlite)
        print("Using SQLite Database in Development Mode.")
    }
    
    // Migration for the Blog
    app.migrations.add(CreateBlogPost())

    // Run migrations automatically
    try await app.autoMigrate()
    
    // Register routes
    try routes(app)
}
