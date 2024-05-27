//
//  DropRule+Token.swift
//  MarkDrop
//
//  Created by windy on 2024/5/10.
//

import Foundation

public final class DropRuleToken {
    
    // MARK: Types
    public typealias RenderDict = [DropTokenRenderType: DropMarkRenderMode]
    
    // MARK: Properties
    public internal(set) var state: DropContentTokenRuleState = .idle
    
    public internal(set) var token: DropTokenSet = .init()
    
    public internal(set) var render: RenderDict = .init()
    
    public internal(set) var openRange: DropContants.IntRange? = nil
    public internal(set) var closeRange: DropContants.IntRange? = nil

    public internal(set) var previousVaildHeadList: [Bool] = []
    
    public internal(set) var isOpenDone: Bool = false
    
    // MARK: Init
    public init(state: DropContentTokenRuleState) {
        self.state = state
    }
    
    public init(other: DropRuleToken) {
        self.state = other.state
        self.token = other.token
        self.openRange = other.openRange
        self.closeRange = other.closeRange
        self.previousVaildHeadList = other.previousVaildHeadList
        self.isOpenDone = other.isOpenDone
    }
    
    // MARK: Process
    public func append(token: DropTokenSet, render: RenderDict, content: Character, previousContent: String?, offset: Int, isParagraphFirstChar: Bool, isParagraphEndChar: Bool, isDocFirstChar: Bool, isDocEndChar: Bool) {
        
        self.token = token
        self.render = render
        
        switch state {
        /// 能否进入 open 态
        case .idle:
            if token.isOnlyVaildOnHead, let previousContent {
                previousVaildHeadList.append(token.isVaildHead(previousContent))
            }
            
            if token.token == String(content) {
                
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
                }
                else {
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
            if token.token.first == content {
                var open: [String] = .init(
                    repeating: "", count: token.token.count
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
            
        /// open 态能否正常完成，并切换到下一个状态
        case .token(tag: var tag, index: let index):
            
            let next = index + 1
            let start = token.token.startIndex
            let strIndex = token.token.index(start, offsetBy: next)
            let nextChar = token.token[strIndex]
            if nextChar == content {
                tag[next] = String(content)
                
                if tag.reduce("", { $0 + $1 }) == token.token {
                    
                    openRange?.length += 1
                    
                    if isDocEndChar {
                        state = .done(isCancled: false, close: nil)
                        closeRange = .init(location: offset, length: 0)
                    }
                    else if isParagraphEndChar {
                        state = .done(isCancled: false, close: nil)
                        closeRange = .init(location: offset, length: 0)
                    }
                    else {
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
        
        /// 捕获 open 到 close 间的内容，能否切换到 close 态，正常结束
        case .tokenCapture:
            
            if isDocEndChar {
                let haveEof = token.closeRule.contains(.eof)
                if haveEof {
                    if token.isInvalidCaptureOn, token.invaildCaptureSet.contains(content) {
                        state = .done(isCancled: true, close: nil)
                        openRange = nil
                    } else {
                        state = .done(isCancled: false, close: nil)
                        closeRange = .init(location: offset + 1, length: -1)
                    }
                } else {
                    state = .done(isCancled: true, close: nil)
                    openRange = nil
                }
            }
            else if isParagraphEndChar {
                if token.isInvalidCaptureOn, token.invaildCaptureSet.contains(content) {
                    state = .done(isCancled: true, close: nil)
                    openRange = nil
                } else {
                    state = .done(isCancled: false, close: nil)
                    closeRange = .init(location: offset + 1, length: -1)
                }
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
                    
                } else {
                    if token.isInvalidCaptureOn, token.invaildCaptureSet.contains(content) {
                        state = .done(isCancled: true, close: nil)
                        openRange = nil
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
            renderToken = token.token
            
        case .remove:
            renderToken = ""
            
        case .replace(let new):
            renderToken = new
            
        case let .append(leading, trailing):
            renderToken = leading + token.token + trailing
            
        case .none:
            renderToken = token.token
        }
        
        var capture = ""
        if token.shouldCapture {
            capture = document.content(
                in: .init(
                    location: openRange.maxLocation,
                    length: closeRange.location - openRange.maxLocation
                )
            )
            
            let close = (
                closeRange.location == openRange.vaildMaxLocation
                    ? ""
                    : document.content(in: closeRange)
            )
            
            switch render[.close] {
            case .keepItAsIs:
                capture += close
                
            case .remove:
                break
                
            case .replace(let new):
                capture += new
                
            case let .append(leading, trailing):
                capture = leading + capture + close + trailing
                
            case .none:
                capture += close
            }
        }
        
        let result = [renderToken] + (token.shouldCapture ? [capture] : [])
        
        return self.token.isCombineContents ? [result.reduce("", { $0 + $1 })] : result
    }
    
    public func rawContents(inDoc document: Document) -> [String] {
        
        guard let openRange, let closeRange else {
            return []
        }
        
        let renderToken = token.token
        
        var close = ""
        if token.shouldCapture {
            let capture = document.content(
                in: .init(
                    location: openRange.maxLocation,
                    length: closeRange.location - openRange.maxLocation
                )
            )
            
            close = capture + (
                closeRange.location == openRange.vaildMaxLocation
                    ? ""
                    : document.content(in: closeRange)
            )
        }
        
        /// token.string + capture
        let result = [renderToken] + (token.shouldCapture ? [close] : [])
        
        return token.isCombineContents ? [result.reduce("", { $0 + $1 })] : result
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
        
        /// token.string + capture
        if let capture {
            let result = [openRange, capture]
            return token.isCombineContents
                ? [.init(location: openRange.location, length: capture.maxLocation - openRange.location)]
                : result
        } else {
            return [openRange]
        }
        
    }
    
    public var contentIndices: [Int] {
        /// token.string + capture
        let result = [token.shouldCapture ? 1 : 0]
        
        return token.isCombineContents ? [0] : result
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
