//
//  AboutController.swift
//  Jandy
//
//  Created by Jack Anderson on 1/10/25.
//

import Vapor
import Foundation

class AboutController {
    func index(req: Request) throws -> EventLoopFuture<View> {
        let webFormAPIKey = Environment.get("WEB_FORM_API_KEY") ?? ""
        let context = ["webFormAPIKey": webFormAPIKey]
        return req.view.render("about", context)
    }
}
