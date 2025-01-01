import Vapor

func routes(_ app: Application) throws {
    let homeController = HomeController()
    let blogPostController = BlogPostController()
    
    // Home page
    app.get(use: homeController.index)
    
    // Blog posts
    app.get("blog_posts", use: blogPostController.index) // Render blog posts view
    app.post("blog_posts", use: blogPostController.create) // Handle POST request
    app.delete("blog_posts", ":id", use: blogPostController.delete) // Handle DELETE request

    // About page
    app.get("about") { req in
        return "About Me!"
    }
}

