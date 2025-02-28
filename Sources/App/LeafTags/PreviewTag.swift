//
//  PreviewTag.swift
//  Jandy
//
//  Created by Jack Anderson on 1/14/25.
//

import Vapor
import Leaf

/// An error type for the PreviewTag, used when the required argument is missing.
enum PreviewTagError: Error {
    case noPostBody
}

/// A custom Leaf tag that generates a preview of a blog post's body text.
/// This tag is declared as "unsafe unescaped" so that the output is rendered as raw HTML.
struct PreviewTag: UnsafeUnescapedLeafTag {
    
    /// Renders the tag based on the provided context.
    ///
    /// The function expects the first parameter in the context to be a string (typically the blog post's body).
    /// It then limits the string to 300 characters and appends "..." if the original text is longer.
    ///
    /// - Parameter ctx: The LeafContext that contains parameters passed to this tag.
    /// - Returns: A LeafData.string containing the preview text.
    /// - Throws: `PreviewTagError.noPostBody` if no string parameter is provided.
    func render(_ ctx: LeafContext) throws -> LeafData {
        // Retrieve the first parameter as a string.
        // If no parameter is present, throw an error indicating that the post body is missing.
        guard let first = ctx.parameters.first?.string else {
            throw PreviewTagError.noPostBody
        }
        
        // Create a preview by taking the first 300 characters of the input string.
        // If the original text is longer than 300 characters, append "..." to indicate truncation.
        let previewText = first.prefix(300) + (first.count > 300 ? "..." : "")
        
        // Return the preview text as LeafData.
        // Using UnsafeUnescapedLeafTag means that the string will not be HTML-escaped, and thus
        // any HTML in the previewText will be rendered as-is.
        return LeafData.string("\(previewText)")
    }
}
