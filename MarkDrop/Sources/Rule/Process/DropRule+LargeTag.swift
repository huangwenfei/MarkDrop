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
    
    public internal(set) var openRange: DropContants.IntRange? = nil
    public internal(set) var closeRange: DropContants.IntRange? = nil
    
    public internal(set) var previousVaildHeadList: [Bool] = []
    
    public internal(set) var isOpenDone: Bool = false
    
    // MARK: Init
    public init(state: DropContentLargeTagRuleState) {
        self.state = state
    }
    
    public init(other: DropRuleLargeTag) {
        self.state = other.state
        self.tag = other.tag
        self.openRange = other.openRange
        self.closeRange = other.closeRange
        self.previousVaildHeadList = other.previousVaildHeadList
        self.isOpenDone = other.isOpenDone
    }
    
    // MARK: Process
    public func append(tag: DropLargeTagSet, render: RenderDict, content: Character, previousContent: String?, offset: Int, isParagraphFirstChar: Bool, isParagraphEndChar: Bool, isDocFirstChar: Bool, isDocEndChar: Bool) {
        
        self.tag = tag
        self.render = render
        
        switch state {
        case .idle:
            if
                tag.openTag.count == 1 &&
                tag.openTag.first?.contains(String(content)) == true
            {
                
                if isDocEndChar {
                    state = .idle
                    openRange = nil
                }
                else if isParagraphEndChar {
                    state = .idle
                    openRange = nil
                } else {
                    state = .openCapture
                    openRange = .init(location: offset, length: 1)
                }
                
            }
            else
            if tag.openTag.first?.contains(String(content)) == true {
                var open: [String] = .init(
                    repeating: "", count: tag.openTag.count
                )
                open[0] = String(content)
                
                if isDocEndChar {
                    state = .idle
                    openRange = nil
                }
                else if isParagraphEndChar {
                    state = .idle
                    openRange = nil
                } else {
                    state = .open(tag: open, index: 0)
                    openRange = .init(location: offset, length: 1)
                }
                
            }
            else {
                state = .idle
                openRange = nil
            }
            
        case .open(var _tag, let index):
            
            let next = index + 1
            let start = tag.openTag.startIndex
            let strIndex = tag.openTag.index(start, offsetBy: next)
            let nextChar = tag.openTag[strIndex]
            if nextChar.contains(String(content)) {
                _tag[next] = String(content)
                
                if _tag.enumerated().filter({ tag.openTag[$0].contains($1) }).count == tag.openTag.count {
                    
                    if isDocEndChar {
                        state = .done(isCancled: true)
                        openRange = nil
                    }
                    else if isParagraphEndChar {
                        state = .done(isCancled: true)
                        openRange = nil
                    } else {
                        state = .openCapture
                        openRange?.length += 1
                    }
                    
                } else {
                    if isDocEndChar {
                        state = .done(isCancled: true)
                        openRange = nil
                    }
                    else if isParagraphEndChar {
                        state = .done(isCancled: true)
                        openRange = nil
                    } else {
                        state = .open(tag: _tag, index: next)
                        openRange?.length += 1
                    }
                }
            } else {
                state = .done(isCancled: true)
                openRange = nil
            }
            
        case .openCapture:
            
            if tag.closeTag == String(content) {
                
                state = .done(isCancled: false)
                closeRange = .init(location: offset, length: 1)
                
            }
            else
            if tag.closeTag.first == content {
                var close: [String] = .init(
                    repeating: "", count: tag.closeTag.count
                )
                close[0] = String(content)
                
                if isDocEndChar {
                    state = .done(isCancled: false)
                    closeRange = .init(location: offset, length: 1)
                }
                else if isParagraphEndChar {
                    state = .done(isCancled: false)
                    closeRange = .init(location: offset, length: 1)
                } else {
                    state = .close(tag: close, index: 0)
                    closeRange = .init(location: offset, length: 1)
                }
                
            }
            else {
                if isDocEndChar {
                    state = .done(isCancled: true)
                    openRange = nil
                }
                else if isParagraphEndChar {
                    state = .done(isCancled: true)
                    openRange = nil
                }
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
                    closeRange?.length += 1
                    
                } else {
                    if isParagraphEndChar {
                        state = .done(isCancled: true)
                        openRange = nil
                    } else {
                        state = .close(tag: _tag, index: next)
                        closeRange?.length += 1
                    }
                }
            } else {
                state = .done(isCancled: true)
                openRange = nil
            }
            
        case .done:
            break
        }
    }
    
    // MARK: Content
    public func contents(inDoc document: Document) -> [String] {
        
        guard let openRange, let closeRange else {
            return []
        }
        
        /// [tag.string] + capture
        
        let openTag: String
        
        switch render[.open] {
        case .keepItAsIs:
            openTag = document.content(in: openRange)
            
        case .remove:
            openTag = ""
            
        case .replace(let new):
            openTag = new
            
        case let .append(leading, trailing):
            openTag = leading + document.content(in: openRange) + trailing
            
        case .none:
            openTag = document.content(in: openRange)
        }
        
        let closeTag: String
        
        switch render[.close] {
        case .keepItAsIs:
            closeTag = tag.closeTag
            
        case .remove:
            closeTag = ""
            
        case .replace(let new):
            closeTag = new
            
        case let .append(leading, trailing):
            closeTag = leading + tag.closeTag + trailing
            
        case .none:
            closeTag = tag.closeTag
        }
        
        let openCapture = document.content(
            in: .init(
                location: openRange.maxLocation,
                length: closeRange.location - openRange.maxLocation
            )
        )
        
        return [openTag, openCapture, closeTag]
        
    }
    
    public func rawContents(inDoc document: Document) -> [String] {
        
        guard let openRange, let closeRange else {
            return []
        }
        
        /// [tag.string] + capture
        let openTag = document.content(in: openRange)
        
        let openCapture = document.content(
            in: .init(
                location: openRange.maxLocation,
                length: closeRange.location - openRange.maxLocation
            )
        )
        
        return [openTag, openCapture, tag.closeTag]
    }
    
    public var contentRange: DropContants.IntRange {
        
        let ranges = rawContentRanges
        
        guard ranges.isEmpty == false else {
            return .init()
        }
        
        if ranges.count == 1 {
            return ranges.first!
        } else {
            guard let first = ranges.first, let last = ranges.last else {
                return .init()
            }
            
            return .init(
                location: first.location,
                length: last.maxLocation - first.location
            )
        }
        
    }
    
    public var rawContentRanges: [DropContants.IntRange] {
        
        guard let openRange, let closeRange else {
            return []
        }
        
        /// openTag + capture + closeTag
        let openCapture = DropContants.IntRange(
            location: openRange.maxLocation,
            length: closeRange.location - openRange.maxLocation
        )
        
        return [openRange, openCapture, closeRange]
        
    }
    
    public var contentIndices: [Int] {
        /// [tag.string] + capture
        return [1]
    }

    // MARK: Clear
    public func clear(isContainsHeadInfo: Bool) {
        state = .idle
        openRange = nil
        closeRange = nil
        isOpenDone = false
        
        if isContainsHeadInfo {
            previousVaildHeadList = []
        }
    }
    
}
