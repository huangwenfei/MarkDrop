//
//  ParagraphMarkTextAttributes.swift
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

public struct ParagraphMarkTextAttributes: Hashable {
    
    // MARK: Properties
    public var paragraph: ParagraphAttributes
    public var mark: TextAttributes
    public var text: TextAttributes
    
    // MARK: Init
    public init(
        paragraph: ParagraphAttributes = .init(),
        mark: TextAttributes = .init(),
        text: TextAttributes = .init()
    ) {
        self.paragraph = paragraph
        self.mark = mark
        self.text = text
    }
    
    // MARK: Methods
    public var paragraphText: ParagraphTextAttributes {
        .init(paragraph: paragraph, text: text)
    }
    
}
