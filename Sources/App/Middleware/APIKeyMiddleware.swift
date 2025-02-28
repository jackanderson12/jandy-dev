//
//  APIKeyMiddleware.swift
//  Jandy
//
//  Created by Jack Anderson on 1/10/25.
//
import Vapor

/// Middleware that checks for a valid API key in incoming requests.
struct APIKeyMiddleware: Middleware {
    /// Called for every request that passes through this middleware.
    ///
    /// - Parameters:
    ///   - request: The incoming HTTP request.
    ///   - next: The next responder in the chain.
    /// - Returns: A future containing the HTTP response.
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        // Retrieve the first value of the "X-API-Key" header from the request.
        let apiKey = request.headers["X-API-Key"].first
        
        // Compare the provided API key with the expected API key stored in the environment variable "API_KEY".
        if apiKey == Environment.get("API_KEY") {
            // If the API key matches, forward the request to the next responder in the middleware chain.
            return next.respond(to: request)
        } else {
            // If the API key is missing or doesn't match, fail the request with an unauthorized error.
            return request.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "Invalid API Key"))
        }
    }
}
