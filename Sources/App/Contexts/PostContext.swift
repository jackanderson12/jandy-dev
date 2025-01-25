//
//  PostContext.swift
//  Jandy
//
//  Created by Jack Anderson on 1/19/25.
//
import Vapor

struct PostContext: Encodable {
    let post: BlogPost
    let htmlBody: String
}
