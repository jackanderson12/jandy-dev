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
}
