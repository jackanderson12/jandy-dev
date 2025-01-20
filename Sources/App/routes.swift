import Vapor

func routes(_ app: Application) throws {
    let homeController = HomeController()
    let blogPostController = BlogPostController()
    let aboutController = AboutController()
    let appController = AppController()
    
    // Home page
    app.get(use: homeController.index)
    
    // Blog posts
    app.get("blog_posts", use: blogPostController.index) // Render blog posts view
    app.get("blog_posts", "view_post", ":id", use: blogPostController.viewPost)
    app.get("blog_posts", "search", use: blogPostController.search)
    app.grouped(APIKeyMiddleware()).post("blog_posts", use: blogPostController.create) //API Key protected
    app.grouped(APIKeyMiddleware()).delete("blog_posts", ":id", use: blogPostController.delete) //API Key protected
    
    app.get("blog_posts", "tech", use: blogPostController.techIndex) // Render blog posts view
    app.get("blog_posts", "tech", ":subcategory", use: blogPostController.techIndex) // Tech posts by subcategory

    app.get("blog_posts", "lifestyle", use: blogPostController.lifestyleIndex) // Render blog posts view
    app.get("blog_posts", "lifestyle", ":subcategory", use: blogPostController.lifestyleIndex) // Lifestyle posts by subcategory


    // About page
    app.get("about", use: aboutController.index)
    // Success page
        app.get("about", "contact_success") { req in
            return req.view.render("contact_success")
        }
    
    // App Page
    app.get("app", ":id", use: appController.index)
}

