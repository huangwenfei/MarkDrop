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
    
    public enum CaptureIndex: Int {
        case open
    }
    
    public let captureMaxCount: Int = 1
    
    public internal(set) var captures: [String] = []
    
    public internal(set) var previousVaildHeadList: [Bool] = []
    
    public internal(set) var isOpenDone: Bool = false
    
    public var contents: [String] {
        /// token.string + capture
        let renderToken: String
        
        switch render[.open] {
        case .keepItAsIs:
            renderToken = token.token
            
        case .remove:
            renderToken = ""
            
        case .replace(let new):
            renderToken = new
            
        case .none:
            renderToken = token.token
        }
        
        let result = [renderToken] + (token.shouldCapture ? captures : [])
        
        return token.isCombineContents ? [result.reduce("", { $0 + $1 })] : result
    }
    
    public var contentOffsets: [Int] {
        /// token.string + capture
        let offset: Int
        
        switch render[.open] {
        case .keepItAsIs:
            offset = 0
            
        case .remove:
            offset = -token.token.count
            
        case .replace(let new):
            offset = new.count - token.token.count
            
        case .none:
            offset = 0
        }
        
        let result = [offset, 0]
        
        return token.isCombineContents ? [result.reduce(0, { $0 + $1 })] : result
    }
    
    public var rawContents: [String] {
        /// token.string + capture
        let result = [token.token] + (token.shouldCapture ? captures : [])
        
        return token.isCombineContents ? [result.reduce("", { $0 + $1 })] : result
    }
    
    public var contentIndices: [Int] {
        /// token.string + capture
        let result = [token.shouldCapture ? 1 : 0]
        
        return token.isCombineContents ? [0] : result
    }
    
    // MARK: Init
    public init(state: DropContentTokenRuleState) {
        self.state = state
    }
    
    public init(other: DropRuleToken) {
        self.state = other.state
        self.token = other.token
        self.captures = other.captures
        self.previousVaildHeadList = other.previousVaildHeadList
        self.isOpenDone = other.isOpenDone
    }
    
    // MARK: Process
    public func append(token: DropTokenSet, render: RenderDict, content: Character, previousContent: String, isFirstChar: Bool, isEndChar: Bool) {
        
        self.token = token
        self.render = render
        
        switch state {
        case .idle:
            if token.isOnlyVaildOnHead {
                previousVaildHeadList.append(token.isVaildHead(previousContent))
            }
            
            if token.token == String(content) {
                
                if token.isOnlyVaildOnHead {
                    if previousVaildHeadList.reduce(true, { $0 && $1 }) {
                        if isEndChar {
                            state = .done(isCancled: false, close: nil)
                            isOpenDone = true
                        } else {
                            state = token.shouldCapture ? .tokenCapture : .done(isCancled: false, close: nil)
                            isOpenDone = token.shouldCapture ? false : true
                            captures = .init(repeating: "", count: captureMaxCount)
                        }
                    } else {
                        if isEndChar {
                            state = .done(isCancled: false, close: nil)
                            isOpenDone = true
                        } else {
                            state = .idle
                        }
                    }
                } 
                else {
                    if isEndChar {
                        state = .done(isCancled: false, close: nil)
                        isOpenDone = true
                    } else {
                        state = token.shouldCapture ? .tokenCapture : .done(isCancled: false, close: nil)
                        isOpenDone = token.shouldCapture ? false : true
                        captures = .init(repeating: "", count: captureMaxCount)
                    }
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
                        if isEndChar {
                            state = .idle
                        } else {
                            state = .token(tag: open, index: 0)
                        }
                    } else {
                        state = .idle
                    }
                } else {
                    if isEndChar {
                        state = .idle
                    } else {
                        state = .token(tag: open, index: 0)
                    }
                }
            }
            else {
                state = .idle
            }
            
        case .token(tag: var tag, index: let index):
            
            let next = index + 1
            let start = token.token.startIndex
            let strIndex = token.token.index(start, offsetBy: next)
            let nextChar = token.token[strIndex]
            if nextChar == content {
                tag[next] = String(content)
                
                if tag.reduce("", { $0 + $1 }) == token.token {
                    
                    if isEndChar {
                        state = .done(isCancled: false, close: nil)
                    } else {
                        state = token.shouldCapture ? .tokenCapture : .done(isCancled: false, close: nil)
                        captures = .init(repeating: "", count: captureMaxCount)
                    }
                    
                } else {
                    if isEndChar {
                        state = .done(isCancled: true, close: nil)
                    } else {
                        state = .token(tag: tag, index: next)
                    }
                }
            } else {
                state = .done(isCancled: true, close: nil)
            }
            
        case .tokenCapture:
            
            if isEndChar {
                if token.isInvalidCaptureOn, token.invaildCaptureSet.contains(content) {
                    state = .done(isCancled: true, close: nil)
                } else {
                    let haveEof = token.closeRule.contains(.eof)
                    state = .done(isCancled: haveEof == false, close: haveEof ? .eof : nil)
                    captures[CaptureIndex.open.rawValue] += String(content)
                }
            } else {
                let isSpace = token.closeRule.contains(.space)
                let isNewline = token.closeRule.contains(.newline)
                if isSpace || isNewline {
                    if isSpace, content.isWhitespace {
                        state = .done(isCancled: false, close: .space)
                        if token.isCaptureCloseContent {
                            captures[CaptureIndex.open.rawValue] += String(content)
                        }
                    }
                    else
                    if isNewline, content.isNewline {
                        state = .done(isCancled: false, close: .newline)
//                        captures[CaptureIndex.open.rawValue] += String(content)
                    }
                    else {
                        if token.isInvalidCaptureOn, token.invaildCaptureSet.contains(content) {
                            state = .done(isCancled: true, close: nil)
                        } else {
                            captures[CaptureIndex.open.rawValue] += String(content)
                        }
                    }
                } else {
                    if token.isInvalidCaptureOn, token.invaildCaptureSet.contains(content) {
                        state = .done(isCancled: true, close: nil)
                    } else {
                        captures[CaptureIndex.open.rawValue] += String(content)
                    }
                }
            }
            
        case .done:
            break
        }
    }
    
    // MARK: Clear
    public func clear(isContainsHeadInfo: Bool) {
        state = .idle
        captures = []
        isOpenDone = false
        
        if isContainsHeadInfo {
            previousVaildHeadList = []
        }
    }
    
}
