//
//  DropContentRule.swift
//  MarkDrop
//
//  Created by windy on 2024/5/6.
//

import Foundation

public enum DropContentRule: Hashable {
    case token(rule: DropTokenSet, render: [DropTokenRenderType: DropMarkRenderMode])
    case largeToken(rule: DropLargeTokenSet, render: [DropLargeTokenRenderType: DropMarkRenderMode])
    case tag(rule: DropTagSet, render: [DropTagRenderType: DropMarkRenderMode])
    case largeTag(rule: DropLargeTagSet, render: [DropLargeTagRenderType: DropMarkRenderMode])
    
    public var isToken: Bool {
        switch self {
        case .token:      return true
        case .largeToken: return false
        case .tag:        return false
        case .largeTag:   return false
        }
    }
    
    public var isLargeToken: Bool {
        switch self {
        case .token:      return false
        case .largeToken: return true
        case .tag:        return false
        case .largeTag:   return false
        }
    }
    
    public var isTag: Bool {
        switch self {
        case .token:      return false
        case .largeToken: return false
        case .tag:        return true
        case .largeTag:   return false
        }
    }
    
    public var isLargeTag: Bool {
        switch self {
        case .token:      return false
        case .largeToken: return false
        case .tag:        return false
        case .largeTag:   return true
        }
    }
    
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch lhs {
        case .token(let lRule, let lRender):
            switch rhs {
            case .token(let rRule, let rRender): return lRule == rRule && lRender == rRender
            case .largeToken:                    return false
            case .tag:                           return false
            case .largeTag:                      return false
            }
            
        case .largeToken(let lRule, let lRender):
            switch rhs {
            case .largeToken(let rRule, let rRender): return lRule == rRule && lRender == rRender
            case .token:                              return false
            case .tag:                                return false
            case .largeTag:                           return false
            }
            
        case .tag(let lRule, let lRender):
            switch rhs {
            case .tag(let rRule, let rRender): return lRule == rRule && lRender == rRender
            case .token:                       return false
            case .largeToken:                  return false
            case .largeTag:                    return false
            }
            
        case .largeTag(let lRule, let lRender):
            switch rhs {
            case .largeTag(let rRule, let rRender): return lRule == rRule && lRender == rRender
            case .token:                            return false
            case .largeToken:                       return false
            case .tag:                              return false
            }
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .token(let rule, let render):
            hasher.combine(rule)
            hasher.combine(render)
        
        case .largeToken(let rule, let render):
            hasher.combine(rule)
            hasher.combine(render)
            
        case .tag(let rule, let render):
            hasher.combine(rule)
            hasher.combine(render)
            
        case .largeTag(let rule, let render):
            hasher.combine(rule)
            hasher.combine(render)
        }
    }
    
}
