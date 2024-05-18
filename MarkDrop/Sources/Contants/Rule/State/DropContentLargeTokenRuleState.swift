//
//  DropContentLargeTokenRuleState.swift
//  MarkDrop
//
//  Created by windy on 2024/5/10.
//

import Foundation

public enum DropContentLargeTokenRuleState: Hashable {
    case idle
    case token(tag: [String], index: Int)
    case tokenCapture
    case done(isCancled: Bool, close: DropTokenClose?)
    
    
    public var isIdle: Bool {
        switch self {
        case .idle:                        return true
        case .token, .tokenCapture, .done: return false
        }
    }
    
    public var isOpen: Bool {
        switch self {
        case .token, .tokenCapture: return true
        case .idle, .done:          return false
        }
    }
    
    public var isCapture: Bool {
        switch self {
        case .tokenCapture:        return true
        case .idle, .token, .done: return false
        }
    }
    
    public var isDone: Bool {
        switch self {
        case .done(let isCancled, _):      return isCancled == false
        case .idle, .token, .tokenCapture: return false
        }
    }
    
    public var isCancled: Bool {
        switch self {
        case .done(let isCancled, _):      return isCancled == true
        case .idle, .token, .tokenCapture: return false
        }
    }
    
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch lhs {
        case .idle:
            switch rhs {
            case .idle:                        return true
            case .token, .tokenCapture, .done: return false
            }
            
        case .token(let lTag, let lIndex):
            switch rhs {
            case .token(let rTag, let rIndex): return lTag == rTag && lIndex == rIndex
            case .idle, .tokenCapture, .done:  return false
            }
            
        case .tokenCapture:
            switch rhs {
            case .tokenCapture:        return true
            case .idle, .token, .done: return false
            }
            
        case .done(let lIsCancled, let lClose):
            switch rhs {
            case .done(let rIsCancled, let rClose): return lIsCancled == rIsCancled && lClose == rClose
            case .token, .tokenCapture, .idle:      return false
            }
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .idle:
            hasher.combine(0)
            
        case .token(let tag, let index):
            hasher.combine(1)
            hasher.combine(tag)
            hasher.combine(index)
            
        case .tokenCapture:
            hasher.combine(2)
            
        case .done(let isCancled, let close):
            hasher.combine(3)
            hasher.combine(isCancled)
            hasher.combine(close)
        }
    }
}
