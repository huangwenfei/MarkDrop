//
//  ParagraphTextAttributes.swift
//  MarkDrop
//
//  Created by windy on 2024/5/17.
//

import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct ParagraphTextAttributes: Hashable {
    
    // MARK: Properties
    public var paragraph: ParagraphAttributes
    public var text: TextAttributes
    
    // MARK: Init
    public init(
        paragraph: ParagraphAttributes = .init(),
        text: TextAttributes = .init()
    ) {
        self.paragraph = paragraph
        self.text = text
    }
    
}
