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
    
    public enum CaptureIndex: Int {
        case open
    }
    
    public let captureMaxCount: Int = 1
    
    public internal(set) var tokenOpenCapture: String = ""
    
    public internal(set) var captures: [String] = []
    
    public internal(set) var previousVaildHeadList: [Bool] = []
    
    public internal(set) var isOpenDone: Bool = false
    
    public var contents: [String] {
        /// token.string.count + capture
        let renderToken: String
        
        switch render[.open] {
        case .keepItAsIs:
            renderToken = tokenOpenCapture
            
        case .remove:
            renderToken = ""
            
        case .replace(let new):
            renderToken = new
            
        case .none:
            renderToken = tokenOpenCapture
        }
        
        return [renderToken] + (token.shouldCapture ? captures : [])
    }
    
    public var contentOffsets: [Int] {
        /// token.string.count + capture
        let offset: Int
        
        switch render[.open] {
        case .keepItAsIs:
            offset = 0
            
        case .remove:
            offset = -tokenOpenCapture.count
            
        case .replace(let new):
            offset = new.count - tokenOpenCapture.count
            
        case .none:
            offset = 0
        }
        
        return [offset, 0]
    }
    
    public var rawContents: [String] {
        /// token.string.count + capture
        [tokenOpenCapture] + (token.shouldCapture ? captures : [])
    }
    
    public var contentIndices: [Int] {
        /// token.string.count + capture
        [token.shouldCapture ? 1 : 0]
    }
    
    
    // MARK: Init
    public init(state: DropContentLargeTokenRuleState) {
        self.state = state
    }
    
    public init(other: DropRuleLargeToken) {
        self.state = other.state
        self.token = other.token
        self.tokenOpenCapture = other.tokenOpenCapture
        self.captures = other.captures
        self.previousVaildHeadList = other.previousVaildHeadList
        self.isOpenDone = other.isOpenDone
    }
    
    // MARK: Process
    public func append(token: DropLargeTokenSet, render: RenderDict, content: Character, previousContent: String, isFirstChar: Bool, isEndChar: Bool) {
        
        self.token = token
        self.render = render
        
        switch state {
        case .idle:
            if token.isOnlyVaildOnHead {
                previousVaildHeadList.append(token.isVaildHead(previousContent))
            }
            
            if
                token.tokenCount == 1 &&
                token.token.first?.contains(content) == true
            {
                
                if token.isOnlyVaildOnHead {
                    if previousVaildHeadList.reduce(true, { $0 && $1 }) {
                        if isEndChar {
                            state = .done(isCancled: false, close: nil)
                            isOpenDone = true
                            tokenOpenCapture = String(content)
                        } else {
                            state = token.shouldCapture ? .tokenCapture : .done(isCancled: false, close: nil)
                            isOpenDone = token.shouldCapture ? false : true
                            captures = .init(repeating: "", count: captureMaxCount)
                            tokenOpenCapture = String(content)
                        }
                    } else {
                        if isEndChar {
                            state = .done(isCancled: false, close: nil)
                            isOpenDone = true
                            tokenOpenCapture = String(content)
                        } else {
                            state = .idle
                            tokenOpenCapture = ""
                        }
                    }
                } else {
                    if isEndChar {
                        state = .done(isCancled: false, close: nil)
                        isOpenDone = true
                        tokenOpenCapture = String(content)
                    } else {
                        state = token.shouldCapture ? .tokenCapture : .done(isCancled: false, close: nil)
                        isOpenDone = token.shouldCapture ? false : true
                        captures = .init(repeating: "", count: captureMaxCount)
                        tokenOpenCapture = String(content)
                    }
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
                        if isEndChar {
                            state = .idle
                            tokenOpenCapture = ""
                        } else {
                            state = .token(tag: open, index: 0)
                            tokenOpenCapture = open[0]
                        }
                    } else {
                        state = .idle
                        tokenOpenCapture = ""
                    }
                } else {
                    if isEndChar {
                        state = .idle
                        tokenOpenCapture = ""
                    } else {
                        state = .token(tag: open, index: 0)
                        tokenOpenCapture = open[0]
                    }
                }
            }
            else {
                state = .idle
                tokenOpenCapture = ""
            }
            
        case .token(tag: var tag, index: let index):
            
            if token.firstMaxRepeatCount > 1 {
                
                let theLastMarks = token.token.last
                
                if theLastMarks?.contains(content) == true {
                    
                    if isEndChar {
                        state = .done(isCancled: false, close: nil)
                        tokenOpenCapture = tag.reduce("", { $0 + $1 }) + String(content)
                    } else {
                        state = token.shouldCapture ? .tokenCapture : .done(isCancled: false, close: nil)
                        captures = .init(repeating: "", count: captureMaxCount)
                        tokenOpenCapture = tag.reduce("", { $0 + $1 }) + String(content)
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
                            
                            if isEndChar {
                                state = .done(isCancled: false, close: nil)
                                tokenOpenCapture = tag.reduce("", { $0 + $1 })
                            } else {
                                state = token.shouldCapture ? .tokenCapture : .done(isCancled: false, close: nil)
                                captures = .init(repeating: "", count: captureMaxCount)
                                tokenOpenCapture = tag.reduce("", { $0 + $1 })
                            }
                            
                        } else {
                            if isEndChar {
                                state = .done(isCancled: true, close: nil)
                                tokenOpenCapture = ""
                            } else {
                                state = .token(tag: tag, index: next)
                                tokenOpenCapture = tag.reduce("", { $0 + $1 })
                            }
                        }
                    } else {
                        state = .done(isCancled: true, close: nil)
                        tokenOpenCapture = ""
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
                        
                        if isEndChar {
                            state = .done(isCancled: false, close: nil)
                            tokenOpenCapture = tag.reduce("", { $0 + $1 })
                        } else {
                            state = token.shouldCapture ? .tokenCapture : .done(isCancled: false, close: nil)
                            captures = .init(repeating: "", count: captureMaxCount)
                            tokenOpenCapture = tag.reduce("", { $0 + $1 })
                        }
                        
                    } else {
                        if isEndChar {
                            state = .done(isCancled: true, close: nil)
                            tokenOpenCapture = ""
                        } else {
                            state = .token(tag: tag, index: next)
                            tokenOpenCapture = tag.reduce("", { $0 + $1 })
                        }
                    }
                } else {
                    state = .done(isCancled: true, close: nil)
                    tokenOpenCapture = ""
                }
                
            }
            
        case .tokenCapture:
            
            if isEndChar {
                let haveEof = token.closeRule.contains(.eof)
                state = .done(isCancled: haveEof == false, close: haveEof ? .eof : nil)
                captures[CaptureIndex.open.rawValue] += String(content)
            } else {
                let isSpace = token.closeRule.contains(.space)
                let isNewline = token.closeRule.contains(.newline)
                if isSpace || isNewline {
                    if isSpace, content.isWhitespace {
                        state = .done(isCancled: false, close: .space)
                        captures[CaptureIndex.open.rawValue] += String(content)
                    }
                    else
                    if isNewline, content.isNewline {
                        state = .done(isCancled: false, close: .newline)
//                        captures[CaptureIndex.open.rawValue] += String(content)
                    }
                    else {
                        captures[CaptureIndex.open.rawValue] += String(content)
                    }
                } else {
                    captures[CaptureIndex.open.rawValue] += String(content)
                }
            }
            
        case .done:
            break
        }
    }
    
    // MARK: Clear
    public func clear(isContainsHeadInfo: Bool) {
        state = .idle
        tokenOpenCapture = ""
        captures = []
        isOpenDone = false
        if isContainsHeadInfo {
            previousVaildHeadList = []
        }
    }
    
}
