//
//  BlogContext.swift
//  Jandy
//
//  Created by Jack Anderson on 1/10/25.
//

import Vapor

struct BlogContext: Encodable {
    let posts: [BlogPost]
    let subcategory: String
    let searchQuery: String?
}



