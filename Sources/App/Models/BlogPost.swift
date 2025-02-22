//
//  BlogPost.swift
//  Jandy
//
//  Created by Jack Anderson on 1/1/25.
//
import Fluent
import Vapor
import Ink

final class BlogPost: Model, Content {
    static let schema = "blog_posts" // Table name in the database

    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "body")
    var body: String

    @Field(key: "tags")
    var tags: String
    
    @Field(key: "imageData")
    var imageData: [String]?
    
    // Computed property to render Markdown as HTML
    var htmlBody: String {
        let markdownParser = MarkdownParser()
        let result = markdownParser.parse(body)
        let html = result.html
        return html
    }

    init() { }

    init(id: UUID? = nil, body: String, tags: String, imageData: [String]?) {
        self.id = id
        self.body = body
        self.tags = tags
        self.imageData = imageData
    }
}

struct CreateBlogPost: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("blog_posts")
            .id()
            .field("body", .string, .required)
            .field("tags", .string, .required)
            .field("imageData", .array(of: .string)) // Now stores multiple image filenames
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("blog_posts").delete()
    }
}
