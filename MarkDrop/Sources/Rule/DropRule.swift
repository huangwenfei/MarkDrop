//
//  DropRule.swift
//  MarkDrop
//
//  Created by windy on 2024/5/3.
//

import Foundation

public class DropRule: Hashable, CustomStringConvertible {
    
    // MARK: Types
    public typealias MarkRuleDict<Set: Hashable> = [Set : DropMarkRenderMode]
    
    // MARK: Properties
    public let rule: DropContentRule
    public let type: DropContentType
    
    public var renderExpandWidthMode: DropDiretionExpandWidthMode = .none
    
    public private(set) lazy var tokenProcess: DropRuleToken = .init(state: .idle)
    public private(set) lazy var largeTokenProcess: DropRuleLargeToken = .init(state: .idle)
    public private(set) lazy var tagProcess: DropRuleTag = .init(state: .idle)
    public private(set) lazy var largeTagProcess: DropRuleLargeTag = .init(state: .idle)
    
    public var isCaptureCloseContent: Bool {
        switch rule {
        case .token(let rule,_):      return rule.isCaptureCloseContent
        case .largeToken(let rule,_): return rule.isCaptureCloseContent
        case .tag:                    return true
        case .largeTag:               return true
        }
    }
    
    public private(set) var captures: [String] {
        get {
            switch rule {
            case .token:      return tokenProcess.captures
            case .largeToken: return largeTokenProcess.captures
            case .tag:        return tagProcess.captures
            case .largeTag:   return largeTagProcess.captures
            }
        }
        set {
            switch rule {
            case .token:      tokenProcess.captures = newValue
            case .largeToken: largeTokenProcess.captures = newValue
            case .tag:        tagProcess.captures = newValue
            case .largeTag:   largeTagProcess.captures = newValue
            }
        }
    }
    
    public private(set) var previousVaildHeadList: [Bool] {
        get {
            switch rule {
            case .token:      return tokenProcess.previousVaildHeadList
            case .largeToken: return largeTokenProcess.previousVaildHeadList
            case .tag:        return tagProcess.previousVaildHeadList
            case .largeTag:   return largeTagProcess.previousVaildHeadList
            }
        }
        set {
            switch rule {
            case .token:      tokenProcess.previousVaildHeadList = newValue
            case .largeToken: largeTokenProcess.previousVaildHeadList = newValue
            case .tag:        tagProcess.previousVaildHeadList = newValue
            case .largeTag:   largeTagProcess.previousVaildHeadList = newValue
            }
        }
    }
    
    public private(set) var isOpenDone: Bool {
        get {
            switch rule {
            case .token:      return tokenProcess.isOpenDone
            case .largeToken: return largeTokenProcess.isOpenDone
            case .tag:        return tagProcess.isOpenDone
            case .largeTag:   return largeTagProcess.isOpenDone
            }
        }
        set {
            switch rule {
            case .token:      tokenProcess.isOpenDone = newValue
            case .largeToken: largeTokenProcess.isOpenDone = newValue
            case .tag:        tagProcess.isOpenDone = newValue
            case .largeTag:   largeTagProcess.isOpenDone = newValue
            }
        }
    }
    
    public private(set) var totalContent: String = ""
    
    public var description: String {
        switch rule {
        case .token(let rule, let render):
            return "{ rule: \(rule), render: \(render), type: \(type), state: \(tokenProcess.state), captures: \(captures) }"
        case .largeToken(let rule, let render):
            return "{ rule: \(rule), render: \(render), type: \(type), state: \(largeTokenProcess.state), captures: \(captures) }"
        case .tag(let rule, let render):
            return "{ rule: \(rule), render: \(render), type: \(type), state: \(tagProcess.state), captures: \(captures) }"
        case .largeTag(let rule, let render):
            return "{ rule: \(rule), render: \(render), type: \(type), state: \(largeTagProcess.state), captures: \(captures) }"
        }
    }
    
    // MARK: Init
    public init(rule: DropContentRule, type: DropContentType) {
        self.rule = rule
        self.type = type
    }
    
    public init(other: DropRule) {
        self.rule = other.rule
        self.type = other.type
        
        self.tokenProcess = .init(other: other.tokenProcess)
        self.largeTokenProcess = .init(other: other.largeTokenProcess)
        self.tagProcess = .init(other: other.tagProcess)
        self.largeTagProcess = .init(other: other.largeTagProcess)
    }
    
    // MARK: State
    public var isIdle: Bool {
        switch rule {
        case .token:      return tokenProcess.state.isIdle
        case .largeToken: return largeTokenProcess.state.isIdle
        case .tag:        return tagProcess.state.isIdle
        case .largeTag:   return largeTagProcess.state.isIdle
        }
    }
    
    public var isOpen: Bool {
        switch rule {
        case .token:      return tokenProcess.state.isOpen
        case .largeToken: return largeTokenProcess.state.isOpen
        case .tag:        return tagProcess.state.isOpen
        case .largeTag:   return largeTagProcess.state.isOpen
        }
    }
    
    public var isCapture: Bool {
        switch rule {
        case .token:      return tokenProcess.state.isCapture
        case .largeToken: return largeTokenProcess.state.isCapture
        case .tag:        return tagProcess.state.isCapture
        case .largeTag:   return largeTagProcess.state.isCapture
        }
    }
    
    public var isDone: Bool {
        switch rule {
        case .token:      return tokenProcess.state.isDone
        case .largeToken: return largeTokenProcess.state.isDone
        case .tag:        return tagProcess.state.isDone
        case .largeTag:   return largeTagProcess.state.isDone
        }
    }
    
    public var isCancled: Bool {
        switch rule {
        case .token:      return tokenProcess.state.isCancled
        case .largeToken: return largeTokenProcess.state.isCancled
        case .tag:        return tagProcess.state.isCancled
        case .largeTag:   return largeTagProcess.state.isCancled
        }
    }
    
    // MARK: State Capture
    public func contents(isRenderMode: Bool) -> [String] {
        if isRenderMode {
            switch rule {
            case .token:      return tokenProcess.contents
            case .largeToken: return largeTokenProcess.contents
            case .tag:        return tagProcess.contents
            case .largeTag:   return largeTagProcess.contents
            }
        } else {
            switch rule {
            case .token:      return tokenProcess.rawContents
            case .largeToken: return largeTokenProcess.rawContents
            case .tag:        return tagProcess.rawContents
            case .largeTag:   return largeTagProcess.rawContents
            }
        }
    }
    
    public var contents: [String] {
        switch rule {
        case .token:      return tokenProcess.contents
        case .largeToken: return largeTokenProcess.contents
        case .tag:        return tagProcess.contents
        case .largeTag:   return largeTagProcess.contents
        }
    }
    
    public var contentOffsets: [Int] {
        switch rule {
        case .token:      return tokenProcess.contentOffsets
        case .largeToken: return largeTokenProcess.contentOffsets
        case .tag:        return tagProcess.contentOffsets
        case .largeTag:   return largeTagProcess.contentOffsets
        }
    }
    
    public var rawContents: [String] {
        switch rule {
        case .token:      return tokenProcess.rawContents
        case .largeToken: return largeTokenProcess.rawContents
        case .tag:        return tagProcess.rawContents
        case .largeTag:   return largeTagProcess.rawContents
        }
    }
    
    public var contentIndices: [Int] {
        switch rule {
        case .token:      return tokenProcess.contentIndices
        case .largeToken: return largeTokenProcess.contentIndices
        case .tag:        return tagProcess.contentIndices
        case .largeTag:   return largeTagProcess.contentIndices
        }
    }
    
    // MARK: Append
    public func append(content: Character, previousContent: String, isFirstChar: Bool, isEndChar: Bool) {
        switch rule {
        case .token(let rule, let render):
            tokenProcess.append(
                token: rule,
                render: render,
                content: content,
                previousContent: previousContent,
                isFirstChar: isFirstChar,
                isEndChar: isEndChar
            )
            
        case .largeToken(let rule, let render):
            largeTokenProcess.append(
                token: rule,
                render: render,
                content: content,
                previousContent: previousContent,
                isFirstChar: isFirstChar,
                isEndChar: isEndChar
            )
            
        case .tag(let rule, let render):
            tagProcess.append(
                tag: rule,
                render: render,
                content: content,
                previousContent: previousContent,
                isFirstChar: isFirstChar,
                isEndChar: isEndChar
            )
            
        case .largeTag(let rule, let render):
            largeTagProcess.append(
                tag: rule,
                render: render,
                content: content,
                previousContent: previousContent,
                isFirstChar: isFirstChar,
                isEndChar: isEndChar
            )
        }
        
        if isIdle == false {
            totalContent += String(content)
        }
    }
    
    // MARK: Clear
    
    public func clear(isContainsHeadInfo: Bool) {
        tokenProcess.clear(isContainsHeadInfo: isContainsHeadInfo)
        largeTokenProcess.clear(isContainsHeadInfo: isContainsHeadInfo)
        tagProcess.clear(isContainsHeadInfo: isContainsHeadInfo)
        largeTagProcess.clear(isContainsHeadInfo: isContainsHeadInfo)
        totalContent = ""
    }
    
    // MARK: Hashable
    public static func == (lhs: DropRule, rhs: DropRule) -> Bool {
        lhs.rule == rhs.rule &&
        lhs.type == rhs.type &&
        lhs.tokenProcess.state == rhs.tokenProcess.state &&
        lhs.largeTokenProcess.state == rhs.largeTokenProcess.state &&
        lhs.tagProcess.state == rhs.tagProcess.state &&
        lhs.largeTagProcess.state == rhs.largeTagProcess.state
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rule)
        hasher.combine(type)
        hasher.combine(tokenProcess.state)
        hasher.combine(largeTokenProcess.state)
        hasher.combine(tagProcess.state)
        hasher.combine(largeTagProcess.state)
    }
    
}

