//
//  DropVaildHead.swift
//  MarkDrop
//
//  Created by windy on 2024/5/10.
//

import Foundation

public enum DropVaildHead: Hashable {
    case leadingHead, space, newline,
         value(String)
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch lhs {
        case .leadingHead:
            switch rhs {
            case .leadingHead:             return true
            case .space, .newline, .value: return false
            }
            
        case .space:
            switch rhs {
            case .space:                         return true
            case .leadingHead, .newline, .value: return false
            }
            
        case .newline:
            switch rhs {
            case .newline:                     return true
            case .leadingHead, .space, .value: return false
            }
            
        case .value(let lString):
            switch rhs {
            case .value(let rString):            return lString == rString
            case .leadingHead, .newline, .space: return false
            }
        }
    }
}
