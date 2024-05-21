//
//  DropAttributeType.swift
//  MarkDrop
//
//  Created by windy on 2024/5/18.
//

import Foundation

public enum DropAttributeType: Int, Hashable {
    case text
    
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

extension DropAttributeType {
    
    public var render: DropRenderMarkType? {
        switch self {
        case .text:            return nil
        case .hashTag:         return .hashTag
        case .mention:         return .mention
        case .bold:            return .bold
        case .italics:         return .italics
        case .underline:       return .underline
        case .highlight:       return .highlight
        case .stroke:          return .stroke
        }
    }
    
}
