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
        struct Input: Content {
            var subject: String
            var body: String
            var tags: String
            var files: [File]  // Accepts multiple images
        }

        let input = try req.content.decode(Input.self)

        // Upload images and store filenames
        return imageUpload(req: req, files: input.files).flatMap { storedFilenames in
            let blogPost = BlogPost(
                subject: input.subject,
                body: input.body,
                tags: input.tags,
                imageData: storedFilenames
            )
            return blogPost.save(on: req.db).map { blogPost }
        }
    }

    // Function to handle image upload separately
    private func imageUpload(req: Request, files: [File]) -> EventLoopFuture<[String]> {
        let directory = req.application.directory.publicDirectory + "Images/"
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

    // Handle deleting a blog post (DELETE request)
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return BlogPost.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }

    // Fetch blog posts for the "tech" category
    func techIndex(req: Request) throws -> EventLoopFuture<View> {
        return BlogPost.query(on: req.db)
            .filter(\.$tags ~~ "tech") // Assuming 'tags' contains the category
            .all()
            .flatMap { posts in
                let context = ["posts": posts]
                return req.view.render("blog_posts", context)
            }
    }

    // Fetch blog posts for the "lifestyle" category
    func lifestyleIndex(req: Request) throws -> EventLoopFuture<View> {
        return BlogPost.query(on: req.db)
            .filter(\.$tags ~~ "lifestyle") // Assuming 'tags' contains the category
            .all()
            .flatMap { posts in
                let context = ["posts": posts]
                return req.view.render("blog_posts", context)
            }
    }
}
