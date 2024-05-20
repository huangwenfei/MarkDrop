//
//  DropRenderExpandType.swift
//  MarkDrop
//
//  Created by windy on 2024/5/20.
//

import Foundation

public enum DropRenderExpandType: Int, Hashable, CaseIterable {
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
