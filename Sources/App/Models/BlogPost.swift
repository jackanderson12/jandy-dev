//
//  BlogPost.swift
//  Jandy
//
//  Created by Jack Anderson on 1/1/25.
//
import Fluent
import Vapor

final class BlogPost: Model, Content {
    static let schema = "blog_posts" // Table name in the database

    @ID(key: .id)
    var id: UUID?

    @Field(key: "subject")
    var subject: String

    @Field(key: "body")
    var body: String

    @Field(key: "tags")
    var tags: String

    init() { }

    init(id: UUID? = nil, subject: String, body: String, tags: String) {
        self.id = id
        self.subject = subject
        self.body = body
        self.tags = tags
    }
}

struct CreateBlogPost: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("blog_posts")
            .id()
            .field("subject", .string, .required)
            .field("body", .string, .required)
            .field("tags", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("blog_posts").delete()
    }
}
