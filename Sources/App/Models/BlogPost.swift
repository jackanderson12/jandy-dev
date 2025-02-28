//
//  BlogPost.swift
//  Jandy
//
//  Created by Jack Anderson on 1/1/25.
//
import Fluent
import Vapor
import Ink

/// A model representing a blog post.
/// This model is stored in the database table named "blogs".
final class BlogPost: Model, Content {
    // Specifies the database table name for this model.
    static let schema = "blogs"

    /// The unique identifier for each blog post.
    @ID(key: .id)
    var id: UUID?

    /// The body of the blog post in Markdown format.
    @Field(key: "body")
    var body: String

    /// A string containing tags for the blog post (e.g., comma-separated tags).
    @Field(key: "tags")
    var tags: String

    /// An optional array of strings representing image filenames or URLs associated with the blog post.
    @Field(key: "imageData")
    var imageData: [String]?

    /// A computed property that converts the Markdown content in `body` into HTML.
    /// This is done using the Ink Markdown parser.
    var htmlBody: String {
        // Create a new MarkdownParser instance.
        let markdownParser = MarkdownParser()
        // Parse the Markdown text stored in `body`.
        let result = markdownParser.parse(body)
        // Extract the generated HTML from the parse result.
        let html = result.html
        // Return the HTML string.
        return html
    }

    /// Default initializer required by Fluent.
    init() { }

    /// A custom initializer to create a new BlogPost instance.
    ///
    /// - Parameters:
    ///   - id: Optional UUID for the blog post.
    ///   - body: The Markdown content of the post.
    ///   - tags: The tags associated with the post.
    ///   - imageData: An optional array of image filenames or URLs.
    init(id: UUID? = nil, body: String, tags: String, imageData: [String]?) {
        self.id = id
        self.body = body
        self.tags = tags
        self.imageData = imageData
    }
}

/// A migration to create the "blogs" table for storing blog posts.
struct CreateBlogPost: Migration {
    /// The prepare function runs when the migration is applied.
    /// It defines the schema (table structure) for the "blogs" table.
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("blogs")
            .id()  // Creates a primary key column "id" of type UUID.
            .field("body", .string, .required)  // Adds a required string column "body" for the Markdown content.
            .field("tags", .string, .required)  // Adds a required string column "tags" for storing tags.
            .field("imageData", .array(of: .string))  // Adds an optional array column "imageData" to store image filenames/URLs.
            .create()  // Creates the table in the database.
    }

    /// The revert function runs if the migration is rolled back.
    /// It deletes the "blogs" table.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("blog_posts").delete()
    }
}
