//
//  File.swift
//  
//
//  Created by Jack Anderson on 11/29/23.
//

import Foundation
import Vapor

class HomeController {
    func index(req: Request) throws -> EventLoopFuture<View> {
        return req.view.render("home")
    }
}

