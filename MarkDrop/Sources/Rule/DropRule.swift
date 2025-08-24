//
//  DropRule.swift
//  MarkDrop
//
//  Created by windy on 2024/5/3.
//

import Foundation

open class DropRule: Hashable, CustomStringConvertible {
    
    // MARK: Types
    public typealias MarkRuleDict<Set: Hashable> = [Set : DropMarkRenderMode]
    
    // MARK: Properties
    internal weak var document: Document? = nil
    
    public let rule: DropContentRule
    public let type: DropContentType
    
    open private(set) lazy var tokenProcess: DropRuleToken = .init(state: .idle)
    open private(set) lazy var largeTokenProcess: DropRuleLargeToken = .init(state: .idle)
    open private(set) lazy var tagProcess: DropRuleTag = .init(state: .idle)
    open private(set) lazy var largeTagProcess: DropRuleLargeTag = .init(state: .idle)
    
    open private(set) var previousVaildHeadList: [Bool] {
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
    
    open private(set) var isOpenDone: Bool {
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
    
    open private(set) var totalContent: String = ""
    
    open var description: String {
        switch rule {
        case .token(let rule, let render):
            return "{ rule: \(rule), render: \(render), type: \(type), state: \(tokenProcess.state) }"
        case .largeToken(let rule, let render):
            return "{ rule: \(rule), render: \(render), type: \(type), state: \(largeTokenProcess.state) }"
        case .tag(let rule, let render):
            return "{ rule: \(rule), render: \(render), type: \(type), state: \(tagProcess.state) }"
        case .largeTag(let rule, let render):
            return "{ rule: \(rule), render: \(render), type: \(type), state: \(largeTagProcess.state) }"
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
    open var isIdle: Bool {
        switch rule {
        case .token:      return tokenProcess.state.isIdle
        case .largeToken: return largeTokenProcess.state.isIdle
        case .tag:        return tagProcess.state.isIdle
        case .largeTag:   return largeTagProcess.state.isIdle
        }
    }
    
    open var isOpen: Bool {
        switch rule {
        case .token:      return tokenProcess.state.isOpen
        case .largeToken: return largeTokenProcess.state.isOpen
        case .tag:        return tagProcess.state.isOpen
        case .largeTag:   return largeTagProcess.state.isOpen
        }
    }
    
    open var isCapture: Bool {
        switch rule {
        case .token:      return tokenProcess.state.isCapture
        case .largeToken: return largeTokenProcess.state.isCapture
        case .tag:        return tagProcess.state.isCapture
        case .largeTag:   return largeTagProcess.state.isCapture
        }
    }
    
    open var isDone: Bool {
        switch rule {
        case .token:      return tokenProcess.state.isDone
        case .largeToken: return largeTokenProcess.state.isDone
        case .tag:        return tagProcess.state.isDone
        case .largeTag:   return largeTagProcess.state.isDone
        }
    }
    
    open var isCancled: Bool {
        switch rule {
        case .token:      return tokenProcess.state.isCancled
        case .largeToken: return largeTokenProcess.state.isCancled
        case .tag:        return tagProcess.state.isCancled
        case .largeTag:   return largeTagProcess.state.isCancled
        }
    }
    
    // MARK: State Capture
    open func contents(isRenderMode: Bool) -> [String] {
        isRenderMode ? contents : rawContents
    }
    
    open var contents: [String] {
        guard let document else { return [] }
        
        switch rule {
        case .token:      return tokenProcess.contents(inDoc: document)
        case .largeToken: return largeTokenProcess.contents(inDoc: document)
        case .tag:        return tagProcess.contents(inDoc: document)
        case .largeTag:   return largeTagProcess.contents(inDoc: document)
        }
    }
    
    open var rawContents: [String] {
        guard let document else { return [] }
        
        switch rule {
        case .token:      return tokenProcess.rawContents(inDoc: document)
        case .largeToken: return largeTokenProcess.rawContents(inDoc: document)
        case .tag:        return tagProcess.rawContents(inDoc: document)
        case .largeTag:   return largeTagProcess.rawContents(inDoc: document)
        }
    }
    
    open var contentRange: DropContants.IntRange {
        guard document != nil else { return .init() }
        
        switch rule {
        case .token:      return tokenProcess.contentRange
        case .largeToken: return largeTokenProcess.contentRange
        case .tag:        return tagProcess.contentRange
        case .largeTag:   return largeTagProcess.contentRange
        }
    }
    
    open var rawContentRanges: [DropContants.IntRange] {
        guard document != nil else { return [] }
        
        switch rule {
        case .token:      return tokenProcess.rawContentRanges
        case .largeToken: return largeTokenProcess.rawContentRanges
        case .tag:        return tagProcess.rawContentRanges
        case .largeTag:   return largeTagProcess.rawContentRanges
        }
    }
    
    open var contentIndices: [Int] {
        guard document != nil else { return [] }
        
        switch rule {
        case .token:      return tokenProcess.contentIndices
        case .largeToken: return largeTokenProcess.contentIndices
        case .tag:        return tagProcess.contentIndices
        case .largeTag:   return largeTagProcess.contentIndices
        }
    }
    
    // MARK: Append
    open func append(content: Character, previousContent: String?, offset: Int, isParagraphFirstChar: Bool, isParagraphEndChar: Bool, isDocFirstChar: Bool, isDocEndChar: Bool) {
        
        switch rule {
        case .token(let rule, let render):
            tokenProcess.append(
                token: rule,
                render: render,
                content: content,
                previousContent: previousContent,
                offset: offset,
                isParagraphFirstChar: isParagraphFirstChar,
                isParagraphEndChar: isParagraphEndChar,
                isDocFirstChar: isDocFirstChar,
                isDocEndChar: isDocEndChar
            )
            
        case .largeToken(let rule, let render):
            largeTokenProcess.append(
                token: rule,
                render: render,
                content: content,
                previousContent: previousContent,
                offset: offset,
                isParagraphFirstChar: isParagraphFirstChar,
                isParagraphEndChar: isParagraphEndChar,
                isDocFirstChar: isDocFirstChar,
                isDocEndChar: isDocEndChar
            )
            
        case .tag(let rule, let render):
            tagProcess.append(
                tag: rule,
                render: render,
                content: content,
                previousContent: previousContent,
                offset: offset,
                isParagraphFirstChar: isParagraphFirstChar,
                isParagraphEndChar: isParagraphEndChar,
                isDocFirstChar: isDocFirstChar,
                isDocEndChar: isDocEndChar
            )
            
        case .largeTag(let rule, let render):
            largeTagProcess.append(
                tag: rule,
                render: render,
                content: content,
                previousContent: previousContent,
                offset: offset,
                isParagraphFirstChar: isParagraphFirstChar,
                isParagraphEndChar: isParagraphEndChar,
                isDocFirstChar: isDocFirstChar,
                isDocEndChar: isDocEndChar
            )
        }
        
        if isIdle == false {
            totalContent += String(content)
        }
    }
    
    // MARK: Clear
    
    open func clear(isContainsHeadInfo: Bool) {
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
    
    open func hash(into hasher: inout Hasher) {
        hasher.combine(rule)
        hasher.combine(type)
        hasher.combine(tokenProcess.state)
        hasher.combine(largeTokenProcess.state)
        hasher.combine(tagProcess.state)
        hasher.combine(largeTagProcess.state)
    }
    
}

