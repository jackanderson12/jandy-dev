//
//  BlogPostController.swift
//  Jandy
//
//  Created by Jack Anderson on 1/1/25.
//
import Vapor
import Fluent
import Ink

/// Controller responsible for handling blog post operations:
/// - Listing all blog posts
/// - Displaying a single blog post (with Markdown-to-HTML conversion)
/// - Creating new blog posts (with image uploads and Markdown processing)
/// - Deleting posts and searching posts
class BlogPostController {
    /// Retrieves all blog posts from the database and renders the "blog_posts" Leaf template.
    ///
    /// - Parameter req: The incoming request.
    /// - Returns: A future view that displays all blog posts.
    func index(req: Request) throws -> EventLoopFuture<View> {
        return BlogPost.query(on: req.db).all().flatMap { posts in
            let context = ["posts": posts] // Passing data to the Leaf template
            return req.view.render("blog_posts", context)
        }
    }
    
    /// Retrieves a single blog post by its UUID and renders the "view_post" Leaf template.
    ///
    /// - Parameter req: The incoming request.
    /// - Returns: A future view that displays a single blog post.
    func viewPost(req: Request) throws -> EventLoopFuture<View> {
        guard let postID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid post ID format")
        }
        
        return BlogPost.find(postID, on: req.db)
            .unwrap(or: Abort(.notFound, reason: "Blog post not found"))
            .flatMap { post in
                let context = PostContext(
                    post: post,
                    htmlBody: post.htmlBody
                )
                return req.view.render("view_post", context)
            }
    }
    
    /// Creates a new blog post.
    ///
    /// The function expects the request to include:
    /// - Markdown text in the `body`
    /// - A string of tags in `tags`
    /// - Zero or more uploaded image files in `files`
    ///
    /// - Parameter req: The incoming request.
    /// - Returns: A future BlogPost after saving it to the database.
    func create(req: Request) throws -> EventLoopFuture<BlogPost> {
        let apiKey = req.headers["X-API-Key"].first
        
        guard apiKey == Environment.get("API_KEY") else {
            throw Abort(.unauthorized, reason: "Invalid API Key")
        }
        
        struct Input: Content {
            var body: String // This contains markdown text
            var tags: String
            var files: [File]   // Accepts multiple images
        }
        
        let input = try req.content.decode(Input.self)
        
        // Upload images and store filenames
        return imageUpload(req: req, files: input.files).flatMap { storedFilenames in
            let updatedHTML = self.replaceImageReferences(in: input.body, with: storedFilenames)

            let blogPost = BlogPost(
                body: updatedHTML, // Now storing converted HTML instead of Markdown
                tags: input.tags,
                imageData: storedFilenames
            )
            return blogPost.save(on: req.db).map { blogPost }
        }
    }
    
    /// Handles uploading image files from the request.
    ///
    /// This function saves each file to the "Public/Images/" directory and collects the new filenames.
    ///
    /// - Parameters:
    ///   - req: The incoming request.
    ///   - files: An array of File objects to upload.
    /// - Returns: A future array of strings containing the new filenames.
    private func imageUpload(req: Request, files: [File]) -> EventLoopFuture<[String]> {
        let directory = "Public/jandy-dev-images/"
        let allowedExtensions = ["png", "jpeg", "jpg", "gif"]
        var storedFilenames: [String] = []
        
        let fileSaveFutures = files.compactMap { file -> EventLoopFuture<Void>? in
            guard file.data.readableBytes > 0,
                  let fileExtension = file.extension?.lowercased(),
                  allowedExtensions.contains(fileExtension) else {
                return nil
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "y-MM-dd-HH-mm-ss-"
            let fileName = formatter.string(from: .init()) + file.filename
            let filePath = directory + fileName
            
            storedFilenames.append(fileName)
            
            return req.application.fileio.openFile(path: filePath,
                                                   mode: .write,
                                                   flags: .allowFileCreation(posixMode: 0x744),
                                                   eventLoop: req.eventLoop)
            .flatMap { handle in
                req.application.fileio.write(fileHandle: handle,
                                             buffer: file.data,
                                             eventLoop: req.eventLoop)
                .flatMapThrowing { _ in
                    try handle.close()
                }
            }
        }
        
        return EventLoopFuture.andAllSucceed(fileSaveFutures, on: req.eventLoop).map { storedFilenames }
    }
    
    /// Replaces Markdown image references with new filenames.
    ///
    /// This function uses the Ink Markdown parser to modify image references. It looks for Markdown image syntax,
    /// then replaces the image URL with the new filename from the stored filenames array.
    ///
    /// - Parameters:
    ///   - markdown: The original Markdown text.
    ///   - filenames: An array of new filenames from the image upload process.
    /// - Returns: The updated HTML string with new image references.
    private func replaceImageReferences(in markdown: String, with filenames: [String]) -> String {
        var filenameIndex = 0
        
        var parser = MarkdownParser()
        
        parser.addModifier(.init(target: .images) { html, markdown in
            guard filenameIndex < filenames.count else { return html } // Ensure we don't exceed filenames
            
            let newFilename = filenames[filenameIndex]
            filenameIndex += 1
            
            // Change the image path to the correct location on the server
            return "<img src=\"/jandy-dev-images/\(newFilename)\">"
        })
        
        // Convert Markdown to HTML with updated image references
        let updatedHTML = parser.html(from: markdown)
        
        return updatedHTML
    }
    
    /// Deletes a blog post given its ID.
    ///
    /// - Parameter req: The incoming request.
    /// - Returns: A future HTTPStatus indicating success.
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return BlogPost.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
    
    /// Searches for blog posts that match the given query in their tags or body.
    ///
    /// - Parameter req: The incoming request.
    /// - Returns: A future view with the search results rendered using the "blogs" Leaf template.
    func search(req: Request) throws -> EventLoopFuture<View> {
        guard let query = req.query[String.self, at: "query"] else {
            throw Abort(.badRequest, reason: "Missing search query")
        }
        
        return BlogPost.query(on: req.db)
            .group(.or) { group in
                group.filter(\.$tags ~~ query)
                group.filter(\.$body ~~ query)
            }
            .all()
            .flatMap { posts in
                let context = ["posts": posts]
                return req.view.render("blog_posts", context)
            }
    }
    
    // Fetch blog posts for the "tech" category
    func techIndex(req: Request) throws -> EventLoopFuture<View> {
        let subcategory = req.parameters.get("subcategory") ?? "all"
        let query = req.query[String.self, at: "query"] ?? "" // Get the search query from the query string
        
        return BlogPost.query(on: req.db)
            .group(.and) { mainQuery in
                mainQuery.filter(\.$tags ~~ "tech") // Primary tech category
                if subcategory != "all" {
                    mainQuery.filter(\.$tags ~~ subcategory) // Additional filtering by subcategory
                }
                if !query.isEmpty {
                    // Apply search query filtering
                    mainQuery.group(.or) { searchGroup in
                        searchGroup.filter(\.$body ~~ query)
                        searchGroup.filter(\.$tags ~~ query)
                    }
                }
            }
            .all()
            .flatMap { posts in
                let context = BlogContext(posts: posts, subcategory: subcategory, searchQuery: query)
                return req.view.render("tech_blog", context)
            }
    }
    
    // Fetch blog posts for the "lifestyle" category
    func lifestyleIndex(req: Request) throws -> EventLoopFuture<View> {
        let subcategory = req.parameters.get("subcategory") ?? "all"
        let query = req.query[String.self, at: "query"] ?? "" // Get the search query from the query string
        
        return BlogPost.query(on: req.db)
            .group(.and) { mainQuery in
                mainQuery.filter(\.$tags ~~ "lifestyle") // Primary tech category
                if subcategory != "all" {
                    mainQuery.filter(\.$tags ~~ subcategory) // Additional filtering by subcategory
                }
                if !query.isEmpty {
                    // Apply search query filtering
                    mainQuery.group(.or) { searchGroup in
                        searchGroup.filter(\.$body ~~ query)
                        searchGroup.filter(\.$tags ~~ query)
                    }
                }
            }
            .all()
            .flatMap { posts in
                let context = BlogContext(posts: posts, subcategory: subcategory, searchQuery: query)
                return req.view.render("lifestyle_blog", context)
            }
    }
}
