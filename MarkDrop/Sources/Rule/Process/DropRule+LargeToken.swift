//
//  DropRule+LargeToken.swift
//  MarkDrop
//
//  Created by windy on 2024/5/10.
//

import Foundation

public final class DropRuleLargeToken {
    
    // MARK: Types
    public typealias RenderDict = [DropLargeTokenRenderType: DropMarkRenderMode]
    
    // MARK: Properties
    public internal(set) var state: DropContentLargeTokenRuleState = .idle
    
    public internal(set) var token: DropLargeTokenSet = .init()
    
    public internal(set) var render: RenderDict = .init()
    
    public internal(set) var openRange: DropContants.IntRange? = nil
    public internal(set) var closeRange: DropContants.IntRange? = nil
    
    public internal(set) var previousVaildHeadList: [Bool] = []
    
    public internal(set) var isOpenDone: Bool = false
    
    public private(set) var openString: String = ""
    
    // MARK: Init
    public init(state: DropContentLargeTokenRuleState) {
        self.state = state
    }
    
    public init(other: DropRuleLargeToken) {
        self.state = other.state
        self.token = other.token
        self.openRange = other.openRange
        self.closeRange = other.closeRange
        self.previousVaildHeadList = other.previousVaildHeadList
        self.isOpenDone = other.isOpenDone
    }
    
    // MARK: Process
    public func append(token: DropLargeTokenSet, render: RenderDict, content: Character, previousContent: String?, offset: Int, isParagraphFirstChar: Bool, isParagraphEndChar: Bool, isDocFirstChar: Bool, isDocEndChar: Bool) {
        
        self.token = token
        self.render = render
        
        switch state {
        case .idle:
            if token.isOnlyVaildOnHead, let previousContent {
                previousVaildHeadList.append(token.isVaildHead(previousContent))
            }
            
            if
                token.tokenCount == 1 &&
                token.token.first?.contains(content) == true
            {
                
                if token.isOnlyVaildOnHead {
                    if previousVaildHeadList.reduce(true, { $0 && $1 }) {
                        if isDocEndChar {
                            state = .done(isCancled: false, close: nil)
                            isOpenDone = true
                        }
                        else if isParagraphEndChar {
                            state = .done(isCancled: false, close: nil)
                            isOpenDone = true
                        } else {
                            state = token.shouldCapture ? .tokenCapture : .done(isCancled: false, close: nil)
                            isOpenDone = token.shouldCapture ? false : true
                        }
                    } else {
                        if isDocEndChar {
                            state = .done(isCancled: false, close: nil)
                            isOpenDone = true
                        }
                        else if isParagraphEndChar {
                            state = .done(isCancled: false, close: nil)
                            isOpenDone = true
                        } else {
                            state = .idle
                            isOpenDone = false
                        }
                    }
                } else {
                    if isDocEndChar {
                        state = .done(isCancled: false, close: nil)
                        isOpenDone = true
                    }
                    else if isParagraphEndChar {
                        state = .done(isCancled: false, close: nil)
                        isOpenDone = true
                    } else {
                        state = token.shouldCapture ? .tokenCapture : .done(isCancled: false, close: nil)
                        isOpenDone = token.shouldCapture ? false : true
                    }
                }
                
                if isOpenDone {
                    openRange = .init(location: offset, length: 1)
                    closeRange = .init(location: offset, length: 0)
                } else {
                    openRange = .init(location: offset, length: 1)
                }
                
            }
            else
            if token.token.first?.contains(content) == true {
                var open: [String] = .init(
                    repeating: "", count: token.tokenCount
                )
                open[0] = String(content)
                
                if token.isOnlyVaildOnHead {
                    if previousVaildHeadList.reduce(true, { $0 && $1 }) {
                        if isDocEndChar {
                            state = .idle
                            openRange = nil
                        }
                        else if isParagraphEndChar {
                            state = .idle
                            openRange = nil
                        } else {
                            state = .token(tag: open, index: 0)
                            openRange = .init(location: offset, length: 1)
                        }
                    } else {
                        state = .idle
                        openRange = nil
                    }
                } else {
                    if isDocEndChar {
                        state = .idle
                        openRange = nil
                    }
                    else if isParagraphEndChar {
                        state = .idle
                        openRange = nil
                    } else {
                        state = .token(tag: open, index: 0)
                        openRange = .init(location: offset, length: 1)
                    }
                }
            }
            else {
                state = .idle
                openRange = nil
            }
            
        case .token(tag: var tag, index: let index):
            
            if token.firstMaxRepeatCount > 1 {
                
                let theLastMarks = token.token.last
                
                if theLastMarks?.contains(content) == true {
                    
                    openRange?.length += 1
                    
                    if isDocEndChar {
                        state = .done(isCancled: false, close: nil)
                        closeRange = .init(location: offset, length: 0)
                    }
                    else if isParagraphEndChar {
                        state = .done(isCancled: false, close: nil)
                        closeRange = .init(location: offset, length: 0)
                    } else {
                        state = token.shouldCapture ? .tokenCapture : .done(isCancled: false, close: nil)
                        if token.shouldCapture == false {
                            closeRange = .init(location: offset, length: 0)
                        }
                    }
                    
                } else {
                    
                    let next = index + 1
                    let marks = token.marks(by: next)
                    
                    var isContains = marks.contains(content)
                    if isContains == false {
                        var nextNext = token.firstMaxRepeatCount
                        while nextNext < token.tokenCount, isContains == false {
                            isContains = token.marks(by: nextNext).contains(content)
                            nextNext += 1
                        }
                    }
                    
                    if isContains {
                        tag[next] = String(content)
                        
                        let breakPoint = token.firstMaxRepeatCount
                        var contains: [Bool] = .init(repeating: false, count: token.token.count)
                        
                        for (index, item) in tag.enumerated() {
                            let contain = token.marks(by: index).contains(item)
                            if index < breakPoint {
                                contains[0] = contains[0] || contain
                            } else {
                                contains[index - breakPoint + 1] = contain
                            }
                        }
                        
                        if contains.filter({ $0 }).count == token.token.count {
                            
                            openRange?.length += 1
                            
                            if isDocEndChar {
                                state = .done(isCancled: false, close: nil)
                                closeRange = .init(location: offset, length: 0)
                            }
                            else if isParagraphEndChar {
                                state = .done(isCancled: false, close: nil)
                                closeRange = .init(location: offset, length: 0)
                            } else {
                                state = token.shouldCapture ? .tokenCapture : .done(isCancled: false, close: nil)
                                if token.shouldCapture == false {
                                    closeRange = .init(location: offset, length: 0)
                                }
                            }
                            
                        } else {
                            if isDocEndChar {
                                state = .done(isCancled: true, close: nil)
                                openRange = nil
                            }
                            else if isParagraphEndChar {
                                state = .done(isCancled: true, close: nil)
                                openRange = nil
                            } else {
                                state = .token(tag: tag, index: next)
                                openRange?.length += 1
                            }
                        }
                    } else {
                        state = .done(isCancled: true, close: nil)
                        openRange = nil
                    }
                    
                }
                
            } else {
                
                let next = index + 1
                let start = token.token.startIndex
                let strIndex = token.token.index(start, offsetBy: next)
                let nextChar = token.token[strIndex]
                if nextChar.contains(content) {
                    tag[next] = String(content)
                    
                    if tag.enumerated().filter({ token.token[$0].contains($1) }).count == token.tokenCount {
                        
                        openRange?.length += 1
                        
                        if isDocEndChar {
                            state = .done(isCancled: false, close: nil)
                            closeRange = .init(location: offset, length: 0)
                        }
                        else if isParagraphEndChar {
                            state = .done(isCancled: false, close: nil)
                            closeRange = .init(location: offset, length: 0)
                        } else {
                            state = token.shouldCapture ? .tokenCapture : .done(isCancled: false, close: nil)
                            if token.shouldCapture == false {
                                closeRange = .init(location: offset, length: 0)
                            }
                        }
                        
                    } else {
                        if isDocEndChar {
                            state = .done(isCancled: true, close: nil)
                            openRange = nil
                        }
                        else if isParagraphEndChar {
                            state = .done(isCancled: true, close: nil)
                            openRange = nil
                        } else {
                            state = .token(tag: tag, index: next)
                            openRange?.length += 1
                        }
                    }
                } else {
                    state = .done(isCancled: true, close: nil)
                    openRange = nil
                }
                
            }
            
        case .tokenCapture:
            
            if isDocEndChar {
                let haveEof = token.closeRule.contains(.eof)
                if haveEof {
                    state = .done(isCancled: false, close: nil)
                    closeRange = .init(location: offset + 1, length: -1)
                } else {
                    state = .done(isCancled: true, close: nil)
                    openRange = nil
                }
            }
            else if isParagraphEndChar {
                state = .done(isCancled: false, close: nil)
                closeRange = .init(location: offset + 1, length: -1)
            } else {
                let isSpace = token.closeRule.contains(.space)
                let isNewline = token.closeRule.contains(.newline)
                if isSpace || isNewline {
                    
                    if isSpace, content.isWhitespace {
                        state = .done(isCancled: false, close: .space)
                        closeRange = .init(location: offset, length: 1)
                    }
                    
                    if isNewline, content.isNewline {
                        state = .done(isCancled: false, close: .newline)
                        closeRange = .init(location: offset, length: 1)
                    }
                    
                }
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
        
        let renderToken: String
        switch render[.open] {
        case .keepItAsIs:
            renderToken = document.content(in: openRange)
            
        case .remove:
            renderToken = ""
            
        case .replace(let new):
            renderToken = new
            
        case let .append(leading, trailing):
            renderToken = leading + document.content(in: openRange) + trailing
            
        case .none:
            renderToken = document.content(in: openRange)
        }
        
        openString = document.content(in: openRange)
        
        var capture = ""
        if token.shouldCapture {
            capture = document.content(
                in: .init(
                    location: openRange.maxLocation,
                    length: closeRange.location - openRange.maxLocation
                )
            )
        }
        
        var close: String? = (
            closeRange.location == openRange.vaildMaxLocation
                ? ""
                : document.content(in: closeRange)
        )
        
        switch render[.close] {
        case .keepItAsIs:
            break
            
        case .remove:
            close = ""
            
        case .replace(let new):
            close = new
            
        case let .append(leading, trailing):
            close = leading + close! + trailing
            
        case .none:
            break
        }
        
        close = closeRange.length <= 0 ? nil : (close?.isEmpty == true ? nil : close)
        
        let result = [renderToken] + (token.shouldCapture ? [capture] : []) + (close == nil ? [] : [close!])
        
        return result
    }
    
    public func rawContents(inDoc document: Document) -> [String] {
        
        guard let openRange, let closeRange else {
            return []
        }
        
        let renderToken = document.content(in: openRange)
        
        var capture = ""
        if token.shouldCapture {
            capture = document.content(
                in: .init(
                    location: openRange.maxLocation,
                    length: closeRange.location - openRange.maxLocation
                )
            )
        }
        
        var close: String? = (
            closeRange.location == openRange.vaildMaxLocation
                ? ""
                : document.content(in: closeRange)
        )
        
        close = closeRange.length <= 0 ? nil : (close?.isEmpty == true ? nil : close)
        
        /// token.string + capture + close
        let result = [renderToken] + (token.shouldCapture ? [capture] : []) + (close == nil ? [] : [close!])
        
        return result
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
        
        var capture: DropContants.IntRange? = nil
        if token.shouldCapture {
            
            if closeRange.location == openRange.vaildMaxLocation {
                capture = nil
            } else {
                capture = (
                    closeRange.length == -1
                        ? DropContants.IntRange(
                              location: openRange.maxLocation,
                              length: closeRange.location - openRange.maxLocation
                          )
                        : DropContants.IntRange(
                              location: openRange.maxLocation,
                              length: closeRange.maxLocation - openRange.maxLocation
                          )
                )
            }
            
        }
        
        let close = closeRange.length <= 0 ? nil : closeRange
        
        /// token.string + capture
        let result = [openRange] + (capture == nil ? [] : [capture!]) + (close == nil ? [] : [close!])
        
        return result
        
    }
    
    public var contentIndices: [Int] {
        /// [token.string] + capture
        let result = [token.shouldCapture ? 1 : 0]
        
        return result
    }
    
    // MARK: Clear
    public func clear(isContainsHeadInfo: Bool) {
        state = .idle
        openRange = nil
        closeRange = nil
        isOpenDone = false
        
        openString = ""
        
        if isContainsHeadInfo {
            previousVaildHeadList = []
        }
    }
    
}
