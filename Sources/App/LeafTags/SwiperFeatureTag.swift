//
//  SwiperFeatureTag.swift
//  Jandy
//
//  Created by Jack Anderson on 1/23/25.
//

import Vapor
import Leaf

enum Chefm8Feature: String {
    case cookbook = "cookbook_page.png"
    case recipeInfo = "recipe_info_page.png"
    case addRecipe = "add_recipe_page.png"
    case shoppingCart = "shopping_cart_page.png"
    case map = "map_page.png"
    case recipeSearch = "recipe_search_page.png"

    var details: String {
        switch self {
        case .cookbook:
            return "Access your favorite recipes with ease in the interactive cookbook."
        case .recipeInfo:
            return "Detailed recipe information, including ingredients and instructions."
        case .addRecipe:
            return "Easily add new recipes to your collection and organize them."
        case .shoppingCart:
            return "Create a shopping list directly from your favorite recipes."
        case .map:
            return "Find nearby grocery stores and plan your shopping trip."
        case .recipeSearch:
            return "Search through thousands of recipes using powerful filters."
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
