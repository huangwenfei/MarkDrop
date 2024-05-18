//
//  DropRule+LargeTag.swift
//  MarkDrop
//
//  Created by windy on 2024/5/10.
//

import Foundation

public final class DropRuleLargeTag {
    
    // MARK: Types
    public typealias RenderDict = [DropLargeTagRenderType: DropMarkRenderMode]
    
    // MARK: Properties
    public internal(set) var state: DropContentLargeTagRuleState = .idle
    
    public internal(set) var tag: DropLargeTagSet = .init()
    
    public internal(set) var render: RenderDict = .init()
    
    public enum CaptureIndex: Int {
        case open
    }
    
    public let captureMaxCount: Int = 1
    
    public internal(set) var tagOpenCapture: String = ""
    
    public internal(set) var captures: [String] = []
    
    public internal(set) var previousVaildHeadList: [Bool] = []
    
    public internal(set) var isOpenDone: Bool = false
    
    public var contents: [String] {
        /// tag.string + capture + tag.string + capture + tag.string ...
        
        let openTag: String
        
        switch render[.open] {
        case .keepItAsIs:
            openTag = tagOpenCapture
            
        case .remove:
            openTag = ""
            
        case .replace(let new):
            openTag = new
            
        case .none:
            openTag = tagOpenCapture
        }
        
        let closeTag: String
        
        switch render[.close] {
        case .keepItAsIs:
            closeTag = tag.closeTag
            
        case .remove:
            closeTag = ""
            
        case .replace(let new):
            closeTag = new
            
        case .none:
            closeTag = tag.closeTag
        }
        
        return [openTag] + captures + [closeTag]
    }
    
    public var contentOffsets: [Int] {
        /// tag.string + capture + tag.string + capture + tag.string ...
        
        let openOffset: Int
        
        switch render[.open] {
        case .keepItAsIs:
            openOffset = 0
            
        case .remove:
            openOffset = -tagOpenCapture.count
            
        case .replace(let new):
            openOffset = new.count - tagOpenCapture.count
            
        case .none:
            openOffset = 0
        }
        
        let closeOffset: Int
        
        switch render[.close] {
        case .keepItAsIs:
            closeOffset = 0
            
        case .remove:
            closeOffset = -tag.closeTag.count
            
        case .replace(let new):
            closeOffset = new.count - tag.closeTag.count
            
        case .none:
            closeOffset = 0
        }
        
        return [openOffset] + [0] + [closeOffset]
    }
    
    public var rawContents: [String] {
        [tagOpenCapture] + captures + [tag.closeTag]
    }
    
    public var contentIndices: [Int] {
        [1]
    }
    
    // MARK: Init
    public init(state: DropContentLargeTagRuleState) {
        self.state = state
    }
    
    public init(other: DropRuleLargeTag) {
        self.state = other.state
        self.tag = other.tag
        self.tagOpenCapture = other.tagOpenCapture
        self.captures = other.captures
        self.previousVaildHeadList = other.previousVaildHeadList
        self.isOpenDone = other.isOpenDone
    }
    
    // MARK: Process
    public func append(tag: DropLargeTagSet, render: RenderDict, content: Character, previousContent: String, isFirstChar: Bool, isEndChar: Bool) {
        
        self.tag = tag
        self.render = render
        
        switch state {
        case .idle:
            if
                tag.openTag.count == 1 &&
                tag.openTag.first?.contains(String(content)) == true
            {
                
                if isEndChar {
                    state = .idle
                    tagOpenCapture = ""
                } else {
                    state = .openCapture
                    captures = .init(repeating: "", count: captureMaxCount)
                    tagOpenCapture = String(content)
                }
                
            }
            else
            if tag.openTag.first?.contains(String(content)) == true {
                var open: [String] = .init(
                    repeating: "", count: tag.openTag.count
                )
                open[0] = String(content)
                
                if isEndChar {
                    state = .idle
                    tagOpenCapture = ""
                } else {
                    state = .open(tag: open, index: 0)
                    tagOpenCapture = open[0]
                }
                
            }
            else {
                state = .idle
                tagOpenCapture = ""
            }
            
        case .open(var _tag, let index):
            
            let next = index + 1
            let start = tag.openTag.startIndex
            let strIndex = tag.openTag.index(start, offsetBy: next)
            let nextChar = tag.openTag[strIndex]
            if nextChar.contains(String(content)) {
                _tag[next] = String(content)
                
                if _tag.enumerated().filter({ tag.openTag[$0].contains($1) }).count == tag.openTag.count {
                    
                    if isEndChar {
                        state = .done(isCancled: true)
                        tagOpenCapture = ""
                    } else {
                        state = .openCapture
                        captures = .init(repeating: "", count: captureMaxCount)
                        tagOpenCapture = _tag.reduce("", { $0 + $1 })
                    }
                    
                } else {
                    if isEndChar {
                        state = .done(isCancled: true)
                        tagOpenCapture = ""
                    } else {
                        state = .open(tag: _tag, index: next)
                        tagOpenCapture = _tag.reduce("", { $0 + $1 })
                    }
                }
            } else {
                state = .done(isCancled: true)
                tagOpenCapture = ""
            }
            
        case .openCapture:
            
            if tag.closeTag == String(content) {
                
                state = .done(isCancled: false)
                
            }
            else
            if tag.closeTag.first == content {
                var close: [String] = .init(
                    repeating: "", count: tag.closeTag.count
                )
                close[0] = String(content)
                
                if isEndChar {
                    state = .done(isCancled: false)
                } else {
                    state = .close(tag: close, index: 0)
                }
                
            }
            else {
                captures[CaptureIndex.open.rawValue] += String(content)
                if isEndChar { state = .done(isCancled: true) }
            }
            
        case .close(var _tag, let index):
            
            let next = index + 1
            let source = tag.closeTag
            let start = source.startIndex
            let strIndex = source.index(start, offsetBy: next)
            let nextChar = source[strIndex]
            if nextChar == content {
                _tag[next] = String(content)
                
                if _tag.reduce("", { $0 + $1 }) == source {
                    
                    state = .done(isCancled: false)
                    
                } else {
                    if isEndChar {
                        state = .done(isCancled: true)
                    } else {
                        state = .close(tag: _tag, index: next)
                    }
                }
            } else {
                state = .done(isCancled: true)
            }
            
        case .done:
            break
        }
    }

    // MARK: Clear
    public func clear(isContainsHeadInfo: Bool) {
        state = .idle
        tagOpenCapture = ""
        captures = []
        isOpenDone = false
        if isContainsHeadInfo {
            previousVaildHeadList = []
        }
    }
    
}
