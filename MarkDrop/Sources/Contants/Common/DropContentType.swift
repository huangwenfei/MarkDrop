//
//  DropContentType.swift
//  MarkDrop
//
//  Created by windy on 2024/5/3.
//

import Foundation

public enum DropContentType: Int {
    /// - Tag: Normal
    /// 无格式文本，叶子结点
    case text
    
    /// - Tag: Block
    /// 子弹列表
    case bulletList
    /// 数字列表
    case numberOrderList
    /// 字母列表
    case letterOrderList
    
//    case heading1
//    case heading2
//    case heading3
//    case heading4
//    case heading5
//    case heading6
//    
//    case inlinecode
//    case code
//    
//    case blockQuotes
//    
//    case link
//    
//    case image
    
    /// - Tag: Inline
    /// 标签
    case hashTag
    /// 关联 [内容]
    case mention
    
    /// 加粗 [文字]
    case bold
    /// 斜体 [文字]
    case italics
    /// 下划线 [文字]
    case underline
    /// 高亮 [文字]
    case highlight
    /// 描边 [文字]
    case stroke
    
    /// - Tag: Other
    /// 缩进 ( 4 个空格 Or \t)
    case spaceIndent
    case tabIndent
    
    public var isListMark: Bool {
        switch self {
        case .text: 
            return false
            
        case .bulletList, .numberOrderList, .letterOrderList:
            return true
            
        case .hashTag, .mention,
             .bold, .italics, .underline,
             .highlight, .stroke,
             .spaceIndent, .tabIndent:
            return false
        }
    }
    
    public var isIndent: Bool {
        switch self {
        case .text,
             .bulletList, .numberOrderList, .letterOrderList,
             .hashTag, .mention,
             .bold, .italics, .underline,
             .highlight, .stroke:
            return false
            
        case .spaceIndent, .tabIndent:
            return true
        }
    }
}

extension DropContentType {
    
    public var blocks: [Self] {
        [.bulletList, .numberOrderList, .letterOrderList]
    }
    
    public var indents: [Self] {
        [.spaceIndent, .tabIndent]
    }
    
}

extension DropContentType {
    
    public var mark: DropContentMarkType {
        switch self {
        case .text:            return .none
        case .bulletList:      return .bulletOrder
        case .numberOrderList: return .numberOrder
        case .letterOrderList: return .letterOrder
        case .hashTag:         return .hashTag
        case .mention:         return .mention
        case .bold:            return .bold
        case .italics:         return .italics
        case .underline:       return .underline
        case .highlight:       return .highlight
        case .stroke:          return .stroke
        case .spaceIndent:     return .indent
        case .tabIndent:       return .indent
        }
    }
    
}

extension DropContentType {
    
    public var render: DropRenderMarkType? {
        switch self {
        case .text:            return nil
        case .bulletList:      return nil
        case .numberOrderList: return nil
        case .letterOrderList: return nil
        case .hashTag:         return .hashTag
        case .mention:         return .mention
        case .bold:            return .bold
        case .italics:         return .italics
        case .underline:       return .underline
        case .highlight:       return .highlight
        case .stroke:          return .stroke
        case .spaceIndent:     return nil
        case .tabIndent:       return nil
        }
    }
    
}
