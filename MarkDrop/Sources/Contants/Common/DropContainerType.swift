//
//  DropContainerType.swift
//  MarkDrop
//
//  Created by windy on 2024/5/3.
//

import Foundation

public enum DropContainerType: Hashable {
    /// 所有内容
    case document
    /// 块内容，是 >= 1 paragraph 组合
    case block(child: DropContainerBlockType)
    /// 一个段落，纯文本 Or 格式化内容 Or 它们的组合
    case paragraph
    /// CRLF (换行) Or 空行，特殊段
    case `break`
    
    // MARK: Methods
    public var isBlock: Bool {
        switch self {
        case .document, .paragraph, .break:
            return false
            
        case .block:
            return true
        }
    }
    
    public var child: DropContainerBlockType? {
        switch self {
        case .document, .paragraph, .break:
            return nil
            
        case .block(let child):
            return child
        }
    }
    
    // MARK: Hashable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch lhs {
        case .document:
            switch rhs {
            case .document:                  return true
            case .block, .paragraph, .break: return false
            }
            
        case .block(let lChild):
            switch rhs {
            case .block(let rChild):            return lChild == rChild
            case .document, .paragraph, .break: return false
            }
            
        case .paragraph:
            switch rhs {
            case .paragraph:                return true
            case .document, .block, .break: return false
            }
            
        case .break:
            switch rhs {
            case .break:                        return true
            case .document, .block, .paragraph: return false
            }
        }
    }
    
    private enum DropContainerRaw: Int {
        case document, block, paragraph, `break`
    }
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .document:
            hasher.combine(DropContainerRaw.document.rawValue)
            
        case .block(let child):
            hasher.combine(DropContainerRaw.block.rawValue)
            hasher.combine(child)
            
        case .paragraph: 
            hasher.combine(DropContainerRaw.paragraph.rawValue)
            
        case .break: 
            hasher.combine(DropContainerRaw.break.rawValue)
        }
    }
    
}

public enum DropContainerBlockType: Int {
    case bulletList, numberOrderList, letterOrderList ///,
//         heading, previousHeading,
//         codeBlock, quote,
//         html
}

public enum DropParagraphType: Int {
    case document,
         bulletList, numberOrderList, letterOrderList,
         text,
         `break`
//         , code, headingDescription, html, splitLine, table
    
    public var isList: Bool {
        switch self {
        case .document: 
            return false
            
        case .bulletList,
             .numberOrderList,
             .letterOrderList:
            return true
            
        case .text, .break:
            return false
        }
    }
}
