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

struct PreviewImage: UnsafeUnescapedLeafTag {
    func render(_ ctx: LeafContext) throws -> LeafData {
        // Ensure we have at least one Image
        guard let first = ctx.parameters.first?.string else {
            throw PreviewImageError.noImageInPost
        }

        // Set the first image to what we want to return
        let previewImageUrl = first
        
        return LeafData.string("\(previewImageUrl)")
    }
}

