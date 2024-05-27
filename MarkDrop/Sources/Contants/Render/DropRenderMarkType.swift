//
//  DropRenderExpandType.swift
//  MarkDrop
//
//  Created by windy on 2024/5/20.
//

import Foundation

public enum DropRenderMarkType: Int, Hashable, CaseIterable {
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
}

public enum DropRenderType: Int, Hashable, CaseIterable {
    /// 文本
    case text
    
    /// 子弹列表 mark, '- '
    case bulletListMark
    /// 数字列表 mark, '1. '
    case numberOrderListMark
    /// 字母列表 mark, 'a. '
    case letterOrderListMark
    
    /// 子弹列表
    case bulletListText
    /// 数字列表
    case numberOrderListText
    /// 字母列表
    case letterOrderListText
    
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
    
    /// Tab 缩进
    case tabIndent
    /// 空格缩进
    case spaceIndent
    
    public init(type: DropContentType, mark: DropContentMarkType) {
        switch type {
        case .text:            self = .text
        case .bulletList:      self = (mark == .text ? .bulletListText : .bulletListMark)
        case .numberOrderList: self = (mark == .text ? .numberOrderListText : .numberOrderListMark)
        case .letterOrderList: self = (mark == .text ? .letterOrderListText : .letterOrderListMark)
        case .hashTag:         self = .hashTag
        case .mention:         self = .mention
        case .bold:            self = .bold
        case .italics:         self = .italics
        case .underline:       self = .underline
        case .highlight:       self = .highlight
        case .stroke:          self = .stroke
        case .spaceIndent:     self = .spaceIndent
        case .tabIndent:       self = .tabIndent
        }
    }
}
