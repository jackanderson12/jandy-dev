//
//  PreviewImage.swift
//  Jandy
//
//  Created by Jack Anderson on 2/21/25.
//
import Vapor
import Leaf

enum PreviewImageError: Error {
    case noImageInPost
}

struct PreviewImage: LeafTag {
    func render(_ ctx: LeafContext) throws -> LeafData {
        // Expecting the parameter to be an array of strings
        if let imageArray = ctx.parameters.first?.array,
           let firstImageData = imageArray.first?.string {
            return LeafData.string(firstImageData)
        } else if let singleValue = ctx.parameters.first?.string {
            return LeafData.string(singleValue)
        }
        throw PreviewImageError.noImageInPost
    }
}

