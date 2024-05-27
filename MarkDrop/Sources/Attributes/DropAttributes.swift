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

extension DropAttributes {
    
    public func attributes(_ type: DropRenderType) -> TextAttributes {
        switch type {
        case .text:                return text
        case .bulletListMark:      return bulletList.mark
        case .numberOrderListMark: return numberOrderList.mark
        case .letterOrderListMark: return letterOrderList.mark
        case .bulletListText:      return bulletList.text
        case .numberOrderListText: return numberOrderList.text
        case .letterOrderListText: return letterOrderList.text
        case .hashTag:             return hashTag
        case .mention:             return mention
        case .bold:                return bold
        case .italics:             return italics
        case .underline:           return underline
        case .highlight:           return highlight
        case .stroke:              return stroke
        case .tabIndent:           return tabIndent
        case .spaceIndent:         return spaceIndent
        }
    }
    
    public func markAttributes(_ type: DropRenderMarkType) -> TextAttributes {
        switch type {
        case .hashTag:   return hashTag
        case .mention:   return mention
        case .bold:      return bold
        case .italics:   return italics
        case .underline: return underline
        case .highlight: return highlight
        case .stroke:    return stroke
        }
    }
    
}
