//
//  DropRule+Tag.swift
//  MarkDrop
//
//  Created by windy on 2024/5/10.
//

import Foundation

public final class DropRuleTag {
    
    // MARK: Types
    public typealias RenderDict = [DropTagRenderType: DropMarkRenderMode]
    
    // MARK: Properties
    public internal(set) var state: DropContentTagRuleState = .idle
    
    public internal(set) var tag: DropTagSet = .init()
    
    public internal(set) var render: RenderDict = .init()
    
    public enum CaptureIndex: Int {
        case open, median
    }
    
    public let captureMaxCount: Int = 2
    
    public internal(set) var captures: [String] = []
    
    public internal(set) var previousVaildHeadList: [Bool] = []
    
    public internal(set) var isOpenDone: Bool = false
    
    public var openCapture: String {
        if captures.indices.contains(CaptureIndex.open.rawValue) {
            return  captures[CaptureIndex.open.rawValue]
        } else {
            return ""
        }
    }
    
    public var medianCapture: String {
        if captures.indices.contains(CaptureIndex.median.rawValue) {
            return  captures[CaptureIndex.median.rawValue]
        } else {
            return ""
        }
    }
    
    public var contents: [String] {
        /// tag.string + capture + tag.string + capture + tag.string ...
        
        let openTag: String
        
        switch render[.open] {
        case .keepItAsIs:
            openTag = tag.openTag
            
        case .remove:
            openTag = ""
            
        case .replace(let new):
            openTag = new
            
        case .none:
            openTag = tag.openTag
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
        
        if let median = tag.meidanTag {
            
            let medianTag: String
            
            switch render[.median] {
            case .keepItAsIs:
                medianTag = median
                
            case .remove:
                medianTag = ""
                
            case .replace(let new):
                medianTag = new
                
            case .none:
                medianTag = median
            }
            
            return [openTag, openCapture, medianTag, medianCapture, closeTag]
        } else {
            return [openTag, openCapture, closeTag]
        }
    }
    
    public var contentOffsets: [Int] {
        /// tag.string + capture + tag.string + capture + tag.string ...
        
        let openOffset: Int
        
        switch render[.open] {
        case .keepItAsIs:
            openOffset = 0
            
        case .remove:
            openOffset = -tag.openTag.count
            
        case .replace(let new):
            openOffset = new.count - tag.openTag.count
            
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
        
        if let median = tag.meidanTag {
            
            let medianOffset: Int
            
            switch render[.median] {
            case .keepItAsIs:
                medianOffset = 0
                
            case .remove:
                medianOffset = -median.count
                
            case .replace(let new):
                medianOffset = new.count - median.count
                
            case .none:
                medianOffset = 0
            }
            
            return [openOffset, 0, medianOffset, 0, closeOffset]
        } else {
            return [openOffset, 0, closeOffset]
        }
    }
    
    public var rawContents: [String] {
        /// tag.string + capture + tag.string + capture + tag.string ...
        if let median = tag.meidanTag {
            return [tag.openTag, openCapture, median, medianCapture, tag.closeTag]
        } else {
            return [tag.openTag, openCapture, tag.closeTag]
        }
    }
    
    public var contentIndices: [Int] {
        /// tag.string + capture + tag.string + capture + tag.string ...
        if tag.meidanTag != nil {
            return [1, 3]
        } else {
            return [1]
        }
    }
    
    // MARK: Init
    public init(state: DropContentTagRuleState) {
        self.state = state
    }
    
    public init(other: DropRuleTag) {
        self.state = other.state
        self.tag = other.tag
        self.captures = other.captures
        self.previousVaildHeadList = other.previousVaildHeadList
        self.isOpenDone = other.isOpenDone
    }
    
    // MARK: Process
    public func append(tag: DropTagSet, render: RenderDict, content: Character, previousContent: String, isFirstChar: Bool, isEndChar: Bool) {
        
        self.tag = tag
        self.render = render
        
        switch state {
        case .idle:
            if tag.openTag == String(content) {
                
                if isEndChar {
                    state = .idle
                } else {
                    state = .openCapture
                    captures = .init(repeating: "", count: captureMaxCount)
                }
                
            }
            else
            if tag.openTag.first == content {
                var open: [String] = .init(
                    repeating: "", count: tag.openTag.count
                )
                open[0] = String(content)
                
                if isEndChar {
                    state = .idle
                } else {
                    state = .open(tag: open, index: 0)
                }
                
            }
            else {
                state = .idle
            }
            
        case .open(var _tag, let index):
            
            let next = index + 1
            let start = tag.openTag.startIndex
            let strIndex = tag.openTag.index(start, offsetBy: next)
            let nextChar = tag.openTag[strIndex]
            if nextChar == content {
                _tag[next] = String(content)
                
                /// _tag.count == source.count
                if _tag.reduce("", { $0 + $1 }) == tag.openTag {
                    
                    if isEndChar {
                        state = .done(isCancled: true)
                    } else {
                        state = .openCapture
                        captures = .init(repeating: "", count: captureMaxCount)
                    }
                    
                } else {
                    if isEndChar {
                        state = .done(isCancled: true)
                    } else {
                        state = .open(tag: _tag, index: next)
                    }
                }
            } else {
                state = .done(isCancled: true)
            }
            
        case .openCapture:
    
            if let medianTag = tag.meidanTag {
                
                if medianTag == String(content) {
                    
                    if isEndChar {
                        state = .done(isCancled: true)
                    } else {
                        state = .medianCapture
                    }
                    
                }
                else
                if medianTag.first == content {
                    
                    var median: [String] = .init(
                        repeating: "", count: medianTag.count
                    )
                    median[0] = String(content)
                    
                    if isEndChar {
                        state = .done(isCancled: true)
                    } else {
                        state = .median(tag: median, index: 0)
                    }
                    
                }
                else {
                    state = .done(isCancled: true)
                }
                
            }
            
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
            
        case .median(var _tag, let index):
            
            guard let source = tag.meidanTag else { break }
            
            let next = index + 1
            let start = source.startIndex
            let strIndex = source.index(start, offsetBy: next)
            let nextChar = source[strIndex]
            if nextChar == content {
                _tag[next] = String(content)
                
                /// _tag.count == source.count
                if _tag.reduce("", { $0 + $1 }) == source {
                    
                    if isEndChar {
                        state = .done(isCancled: true)
                    } else {
                        state = .medianCapture
                    }
                    
                } else {
                    if isEndChar {
                        state = .done(isCancled: true)
                    } else {
                        state = .median(tag: _tag, index: next)
                    }
                }
            } else {
                state = .done(isCancled: true)
            }
            
            
        case .medianCapture:
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
                captures[CaptureIndex.median.rawValue] += String(content)
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
                
                /// _tag.count == source.count
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
        captures = []
        isOpenDone = false
        if isContainsHeadInfo {
            previousVaildHeadList = []
        }
    }
    
}
