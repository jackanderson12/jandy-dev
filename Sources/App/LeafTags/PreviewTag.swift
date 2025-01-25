//
//  PreviewTag.swift
//  Jandy
//
//  Created by Jack Anderson on 1/14/25.
//

import Vapor
import Leaf

enum PreviewTagError: Error {
    case noPostBody
}

struct PreviewTag: UnsafeUnescapedLeafTag {
    func render(_ ctx: LeafContext) throws -> LeafData {
        // Ensure we have at least one argument
        guard let first = ctx.parameters.first?.string else {
            throw PreviewTagError.noPostBody
        }

        // Limit the body to 300 characters and append "..." if needed
        let previewText = first.prefix(300) + (first.count > 300 ? "..." : "")
        
        return LeafData.string("\(previewText)")
    }
}
