//
//  APIKeyMiddleware.swift
//  Jandy
//
//  Created by Jack Anderson on 1/10/25.
//
import Vapor

struct APIKeyMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        let apiKey = request.headers["X-API-Key"].first

        if apiKey == Environment.get("API_KEY") {
            return next.respond(to: request)
        } else {
            return request.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "Invalid API Key"))
        }
    }
}
