//
//  ImageUploadResponse.swift
//  Jandy
//
//  Created by Jack Anderson on 1/6/25.
//
import Vapor

struct ImageUploadResponse: Content {
    let filename: String
    let url: String
}
