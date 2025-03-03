//
//  SwiperFeatureTag.swift
//  Jandy
//
//  Created by Jack Anderson on 1/23/25.
//

import Vapor
import Leaf

enum Chefm8Feature: String {
    case authentication = "authentication_page.png"
    case cookbook = "cookbook_page.png"
    case recipeInfo = "recipe_info_page.png"
    case addRecipe = "add_recipe_page.png"
    case textScanner = "text_scanner.png"
    case barcodeScanner = "barcode_scanner.png"
    case shoppingCart = "shopping_cart_page.png"
    case share = "share_fuctionality.png"
    case shareText = "share_text_message.PNG"
    case map = "map_page.PNG"
    case lookAroundPreview = "map_lookaround_preview.PNG"
    case recipeSearch = "recipe_search.jpeg"

    var details: String {
        switch self {
        case .authentication:
            return "Create and sign in anonymously, using an email, google, or apple. Created using Google Firebase Authentication."
        case .cookbook:
            return "Access your favorite recipes with ease in the interactive cookbook. Recipes are stored on device, utilizing CoreData to save all recipe information."
        case .recipeInfo:
            return "Detailed recipe information, including ingredients, instructions, and cookware needed to bring the recipe to life."
        case .addRecipe:
            return "Easily add new recipes to your collection and organize them. You can chose to scan in recipe text from your favorite cookbook or hand-written recipes when you click the camera icon at the top of the page. Another unique feature of this page uses Spoonacular API's recipe extraction endpoint, you can take a recipe from your favorite website through providing the URL and wait for it to fill out all the information in the add recipe page. Provide a link to the photo of the recipe or upload straight from your camera roll. Click the barcode icon to easily in barcodes of ingredients."
        case .textScanner:
            return "Scan in recipe text from your favorite cookbook or hand-written recipes. Utilizing VisionKit to analyze text."
        case .barcodeScanner:
            return "Easily scan barcodes to recieve information about products to add to your ingredients list. Developed with VisionKit, AVKit, and the Spoonacular API's grocery search by UPC functionality."
        case .shoppingCart:
            return "Create a shopping list directly from your favorite recipes, simply click the cart button on the recipe info page to add this recipe to your shopping cart."
        case .share:
            return "Share your cart or a recipe with a friend over a variety of mediums. "
        case .shareText:
            return "Sharing formats the grocery list or recipe objects into easily readable information to whoever you maybe sharing with."
        case .map:
            return "Find nearby grocery stores, restaurants, breweries, and plan your next culinary adventure. Uses MapKit to display current location and map points of interest."
        case .lookAroundPreview:
            return "Familiarize yourself with the area around the selected point of interest. Built utilizing MapKit and its LookAroundPreview feature."
        case .recipeSearch:
            return "Search through thousands of recipes using powerful filters. Utilizing the Spoonaccular API's recipe search to build a list of relevant recipes to your search parameters."
        }
    }
    
    init?(fileName: String) {
        guard let feature = Chefm8Feature(rawValue: fileName) else {
            return nil
        }
        self = feature
    }
}

enum GamblitFeature: String {
    case feed = "feed_page.png"
    case event = "event_page.png"
    case historical = "historical_page.png"

    var details: String {
        switch self {
        case .feed:
            return "Stay updated with the latest bets and sports news in your feed."
        case .event:
            return "Browse upcoming sports events and place your bets."
        case .historical:
            return "Analyze past betting trends and improve your strategy."
        }
    }
    
    init?(fileName: String) {
        guard let feature = GamblitFeature(rawValue: fileName) else {
            return nil
        }
        self = feature
    }
}

enum RoeblingFeature: String {
    case home = "home_page.png"
    case dashboard = "dashboard_page.png"
    case form = "form_page.png"

    var details: String {
        switch self {
        case .home:
            return "Overview of financial opportunities for small businesses."
        case .dashboard:
            return "Track financial applications and monitor loan statuses."
        case .form:
            return "Easily apply for financial assistance with an intuitive form."
        }
    }
    
    init?(fileName: String) {
        guard let feature = RoeblingFeature(rawValue: fileName) else {
            return nil
        }
        self = feature
    }
}

enum SwiperFeatureTagError: Error {
    case noFeature
}

struct SwiperFeatureTag: LeafTag {
    func render(_ ctx: LeafKit.LeafContext) throws -> LeafKit.LeafData {
        guard let feature = ctx.parameters.first?.string else {
            throw SwiperFeatureTagError.noFeature
        }
        
        print("DEBUG: Received feature name: \(feature)") // Add logging for debugging
        
        let featureText: String
        if let chefm8Feature = Chefm8Feature(rawValue: feature) {
            featureText = chefm8Feature.details
        } else if let gamblitFeature = GamblitFeature(rawValue: feature) {
            featureText = gamblitFeature.details
        } else if let roeblingFeature = RoeblingFeature(rawValue: feature) {
            featureText = roeblingFeature.details
        } else {
            print("DEBUG: No matching feature found for: \(feature)") // Add logging
            featureText = "Feature information not found."
        }
        
        return .string(featureText)
    }
}
