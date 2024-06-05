//
//  DropContentMarkType.swift
//  MarkDrop
//
//  Created by windy on 2024/5/14.
//

import Foundation

public enum DropContentMarkType: Int {
    case none
    
    case text
    
    /// - Tag: Block
    case bulletOrder
    case numberOrder
    case letterOrder
    
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
    case hashTag
    case mention
    
    case bold
    case italics
    case underline
    case highlight
    case stroke
    
    /// - Tag: Other
    case indent
    
    public var isListMark: Bool {
        switch self {
        case .none, .text:
            return false
            
        case .bulletOrder, .numberOrder, .letterOrder:
            return true
            
        case .hashTag, .mention,
             .bold, .italics, .underline,
             .highlight, .stroke,
             .indent:
            return false
        }
    }
}
