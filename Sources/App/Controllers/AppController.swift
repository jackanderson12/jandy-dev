//
//  AppController.swift
//  Jandy
//
//  Created by Jack Anderson on 1/10/25.
//
import Foundation
import Vapor

class AppController {
    func index(req: Request) throws -> EventLoopFuture<View> {
        let id = req.parameters.get("id") ?? "chefm8"
        
        return req.view.render("app", ["id": id]) // Pass dictionary instead of string
    }
    
    func getFeatureText(req: Request) throws -> String {
        guard let imageName = req.parameters.get("imageName") else {
            req.logger.warning("No image name provided in feature text request")
            return "Feature not found"
        }
        
        // Log the incoming request for debugging purposes
        req.logger.info("Fetching feature text for image: \(imageName)")
        
        let featureText: String
        if let chefm8Feature = Chefm8Feature(rawValue: imageName) {
            featureText = chefm8Feature.details
        } else if let gamblitFeature = GamblitFeature(rawValue: imageName) {
            featureText = gamblitFeature.details
        } else if let roeblingFeature = RoeblingFeature(rawValue: imageName) {
            featureText = roeblingFeature.details
        } else {
            req.logger.warning("No matching feature found for image: \(imageName)")
            featureText = "Feature information not found"
        }
        
        return featureText
    }
}
