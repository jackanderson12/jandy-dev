//
//  ImageController.swift
//
//
//  Created by Jack Anderson on 2/5/2025.
//
import Vapor
import GoogleCloudKit

class ImageController {
    func getSignedImageURL(req: Request) async throws -> Response {
        let storage = try req.application.googleCloudStorage()
        let bucketName = "your-bucket-name"
        
        // Get the filename dynamically from the URL parameter
        guard let objectName = req.parameters.get("filename") else {
            throw Abort(.badRequest, reason: "Filename is required")
        }

        // Generate a signed URL
        let signedURL = try await storage.signURL(
            bucket: bucketName,
            object: objectName,
            method: .GET,
            expiration: .hours(1)
        )

        // Return JSON response with the signed URL
        return Response(status: .ok, body: .init(string: signedURL.absoluteString))
    }
}
