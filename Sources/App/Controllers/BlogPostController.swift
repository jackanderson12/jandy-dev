//
//  BlogPostController.swift
//  Jandy
//
//  Created by Jack Anderson on 1/1/25.
//
import Vapor
import Fluent

class BlogPostController {
    // Handle getting all blog posts from the db and display them using blog_posts.leaf
    func index(req: Request) throws -> EventLoopFuture<View> {
        return BlogPost.query(on: req.db).all().flatMap { posts in
            let context = ["posts": posts] // Passing data to the Leaf template
            return req.view.render("blog_posts", context)
        }
    }
    // Handle creating a new blog post (POST request)
    func create(req: Request) throws -> EventLoopFuture<BlogPost> {
        let post = try req.content.decode(BlogPost.self)
        return post.save(on: req.db).map { post }
    }

    // Handle deleting a blog post (DELETE request)
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return BlogPost.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
