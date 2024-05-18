//
//  DropContentTagRuleState.swift
//  MarkDrop
//
//  Created by windy on 2024/5/6.
//

import Foundation

public enum DropContentTagRuleState: Hashable {
    case idle
    case open(tag: [String], index: Int)
    case openCapture
    case median(tag: [String], index: Int)
    case medianCapture
    case close(tag: [String], index: Int)
    case done(isCancled: Bool)
    
    
    public var isIdle: Bool {
        switch self {
        case .idle:                   return true
        case .open, .openCapture,
             .median, .medianCapture,
             .close, .done:           return false
        }
    }
    
    public var isOpen: Bool {
        switch self {
        case .open, .openCapture:     return true
        case .idle,
             .median, .medianCapture,
             .close, .done:           return false
        }
    }
    
    public var isCapture: Bool {
        switch self {
        case .openCapture, .medianCapture: return true
        case .idle,
             .open, .median,
             .close, .done:                return false
        }
    }
    
    public var isDone: Bool {
        switch self {
        case .done(let isCancled):    return isCancled == false
        case .idle,
             .open, .openCapture,
             .median, .medianCapture,
             .close:                  return false
        }
    }
    
    public var isCancled: Bool {
        switch self {
        case .done(let isCancled):    return isCancled == true
        case .idle,
             .open, .openCapture,
             .median, .medianCapture,
             .close:                  return false
        }
    }
    
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch lhs {
        case .idle:
            switch rhs {
            case .idle:                   return true
            case .open, .openCapture,
                 .median, .medianCapture,
                 .close, .done:           return false
            }
            
        case .open(let lTag, let lIndex):
            switch rhs {
            case .open(let rTag, let rIndex): return lTag == rTag && lIndex == rIndex
            case .idle,
                 .openCapture,
                 .median, .medianCapture,
                 .close, .done:               return false
            }
            
        case .openCapture:
            switch rhs {
            case .openCapture:            return true
            case .idle,
                 .open,
                 .median, .medianCapture,
                 .close, .done:           return false
            }
            
        case .median(let lTag, let lIndex):
            switch rhs {
            case .median(let rTag, let rIndex): return lTag == rTag && lIndex == rIndex
            case .idle,
                 .open, .openCapture,
                 .medianCapture,
                 .close, .done:                 return false
            }
            
        case .medianCapture:
            switch rhs {
            case .medianCapture:      return true
            case .idle,
                 .open, .openCapture,
                 .median,
                 .close, .done:       return false
            }
            
        case .close(let lTag, let lIndex):
            switch rhs {
            case .close(let rTag, let rIndex): return lTag == rTag && lIndex == rIndex
            case .idle,
                 .open, .openCapture,
                 .median, .medianCapture,
                 .done:                        return false
            }
        
        case .done(let lIsCancled):
            switch rhs {
            case .done(let rIsCancled):   return lIsCancled == rIsCancled
            case .idle,
                 .open, .openCapture,
                 .median, .medianCapture,
                 .close:                  return false
            }
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .idle: 
            hasher.combine(0)
            
        case .open(let tag, let index):
            hasher.combine(1)
            hasher.combine(tag)
            hasher.combine(index)
            
        case .openCapture:
            hasher.combine(2)
            
        case .median(let tag, let index):
            hasher.combine(3)
            hasher.combine(tag)
            hasher.combine(index)
            
        case .medianCapture:
            hasher.combine(4)
            
        case .close(let tag, let index):
            hasher.combine(5)
            hasher.combine(tag)
            hasher.combine(index)
            
        case .done(let isCancled):
            hasher.combine(6)
            hasher.combine(isCancled)
        }
    }
    
}
