import Leaf
import Vapor
import Fluent
import FluentSQLiteDriver

// Configures your application
public func configure(_ app: Application) async throws {
    // Serve files from the /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Use Leaf for views
    app.views.use(.leaf)
    
    // Configure SQLite database with a file
    app.databases.use(.sqlite(.file("Database/db.sqlite")), as: .sqlite)
    
    // Run migrations
    app.migrations.add(CreateBlogPost())

    // Run migrations automatically
    try await app.autoMigrate()
    
    // Register routes
    try routes(app)
}
