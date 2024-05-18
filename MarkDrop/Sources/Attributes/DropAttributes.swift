//
//  DropAttributes.swift
//  MarkDrop
//
//  Created by windy on 2024/5/13.
//

import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct DropAttributes: Hashable {
    
    // MARK: Properties
    public var paragraph: ParagraphAttributes = .init()
    public var text: TextAttributes = .init()
    public var bulletList: ParagraphMarkTextAttributes = .init()
    public var numberOrderList: ParagraphMarkTextAttributes = .init()
    public var letterOrderList: ParagraphMarkTextAttributes = .init()
    public var hashTag: TextAttributes = .init()
    public var mention: TextAttributes = .init()
    public var bold: TextAttributes = .init()
    public var italics: TextAttributes = .init()
    public var underline: TextAttributes = .init()
    public var highlight: TextAttributes = .init()
    public var stroke: TextAttributes = .init()
    public var spaceIndent: TextAttributes = .init()
    public var tabIndent: TextAttributes = .init()
    
    // MARK: Init
    public init() { }
    
    // MARK: Methods
    public var paragraphText: ParagraphTextAttributes {
        .init(paragraph: paragraph, text: text)
    }
    
}
