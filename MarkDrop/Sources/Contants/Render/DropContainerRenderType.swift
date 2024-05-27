//
//  DropContainerRenderType.swift
//  MarkDrop
//
//  Created by windy on 2024/5/27.
//

import Foundation

public enum DropContainerRenderType: Int {
    case documant, bulletList, numberOrderList, letterOrderList ///,
//         heading, previousHeading,
//         codeBlock, quote,
//         html
    
    public init(type: DropContainerBlockType) {
        switch type {
        case .bulletList:      self = .bulletList
        case .numberOrderList: self = .numberOrderList
        case .letterOrderList: self = .letterOrderList
        }
    }
    
}
