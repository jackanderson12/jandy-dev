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
        return req.view.render("about")
    }
}
