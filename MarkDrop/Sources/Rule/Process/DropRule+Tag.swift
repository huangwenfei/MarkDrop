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
    
    public internal(set) var openRange: DropContants.IntRange? = nil
    public internal(set) var medianRange: DropContants.IntRange? = nil
    public internal(set) var closeRange: DropContants.IntRange? = nil
    
    public internal(set) var isOpenDone: Bool = false
    
    public internal(set) var previousVaildHeadList: [Bool] = []
    
    private var looseCapturePreviousState: DropContentTagRuleState = .idle
    
    // MARK: Init
    public init(state: DropContentTagRuleState) {
        self.state = state
    }
    
    public init(other: DropRuleTag) {
        self.state = other.state
        self.tag = other.tag
        self.openRange = other.openRange
        self.medianRange = other.medianRange
        self.closeRange = other.closeRange
        self.previousVaildHeadList = other.previousVaildHeadList
        self.isOpenDone = other.isOpenDone
    }
    
    // MARK: Process
    public func append(tag: DropTagSet, render: RenderDict, content: Character, previousContent: String?, offset: Int, isParagraphFirstChar: Bool, isParagraphEndChar: Bool, isDocFirstChar: Bool, isDocEndChar: Bool) {
        
        if tag.isLooseModeOn {
            appendLoose(
                tag: tag,
                render: render,
                content: content,
                previousContent: previousContent,
                offset: offset,
                isParagraphFirstChar: isParagraphFirstChar,
                isParagraphEndChar: isParagraphEndChar,
                isDocFirstChar: isDocFirstChar,
                isDocEndChar: isDocEndChar,
                canIdleCancle: false
            )
        } else {
            appendNormal(
                tag: tag,
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
        
    }
    
    public func appendLoose(tag: DropTagSet, render: RenderDict, content: Character, previousContent: String?, offset: Int, isParagraphFirstChar: Bool, isParagraphEndChar: Bool, isDocFirstChar: Bool, isDocEndChar: Bool, canIdleCancle: Bool) {
        
        self.tag = tag
        self.render = render
        
        switch state {
        case .idle:
            if tag.openTag == String(content) {
                
                if isDocEndChar {
                    state = canIdleCancle ? .done(isCancled: true) : .idle
                    openRange = nil
                }
                else if isParagraphEndChar {
                    state = canIdleCancle ? .done(isCancled: true) : .idle
                    openRange = nil
                } else {
                    state = .openCapture
                    openRange = .init(location: offset, length: 1)
                }
                
            }
            else
            if tag.openTag.first == content {
                var open: [String] = .init(
                    repeating: "", count: tag.openTag.count
                )
                open[0] = String(content)
                
                if isDocEndChar {
                    state = canIdleCancle ? .done(isCancled: true) : .idle
                    openRange = nil
                }
                else if isParagraphEndChar {
                    state = canIdleCancle ? .done(isCancled: true) : .idle
                    openRange = nil
                } else {
                    state = .open(tag: open, index: 0)
                    openRange = .init(location: offset, length: 1)
                }
                
            }
            else {
                state = canIdleCancle ? .done(isCancled: true) : .idle
                openRange = nil
            }
            
        case .open(var _tag, let index):
            
            func reback() {
                /// 回退状态
                state = .idle
                /// 无法继续开启的时候，使用当前字符看是否可以重开
                appendLoose(
                    tag: tag,
                    render: render,
                    content: content,
                    previousContent: previousContent,
                    offset: offset,
                    isParagraphFirstChar: isParagraphFirstChar,
                    isParagraphEndChar: isParagraphEndChar,
                    isDocFirstChar: isDocFirstChar,
                    isDocEndChar: isDocEndChar,
                    canIdleCancle: true
                )
            }
            
            let next = index + 1
            let start = tag.openTag.startIndex
            let strIndex = tag.openTag.index(start, offsetBy: next)
            let nextChar = tag.openTag[strIndex]
            if nextChar == content {
                _tag[next] = String(content)
                
                /// _tag.count == source.count
                if _tag.reduce("", { $0 + $1 }) == tag.openTag {
                    
                    if isDocEndChar {
                        state = .done(isCancled: true)
                        openRange = nil
                    }
                    else if isParagraphEndChar {
                        if tag.looseCanSpanParagraphs {
                            /// continue
                            reback()
                        } else {
                            state = .done(isCancled: true)
                            openRange = nil
                        }
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
                        if tag.looseCanSpanParagraphs {
                            /// continue
                            reback()
                        } else {
                            state = .done(isCancled: true)
                            openRange = nil
                        }
                    } else {
                        state = .open(tag: _tag, index: next)
                        openRange?.length += 1
                    }
                }
            } else {
                
                if isDocEndChar {
                    state = .done(isCancled: true)
                    openRange = nil
                }
                else if isParagraphEndChar {
                    if tag.looseCanSpanParagraphs {
                        /// continue
                        reback()
                    } else {
                        state = .done(isCancled: true)
                        openRange = nil
                    }
                }
                else {
                    reback()
                }
                
            }
            
        case .openCapture:
    
            /// loose point 1
            
            if let medianTag = tag.meidanTag {
                
                if medianTag == String(content) {
                    
                    if isDocEndChar {
                        state = .done(isCancled: true)
                        openRange = nil
                    }
                    else if isParagraphEndChar {
                        if tag.looseCanSpanParagraphs {
                            /// continue
                        } else {
                            state = .done(isCancled: true)
                            openRange = nil
                        }
                    } else {
                        state = .medianCapture
                        medianRange = .init(location: offset, length: 1)
                    }
                    
                }
                else
                if medianTag.first == content {
                    
                    var median: [String] = .init(
                        repeating: "", count: medianTag.count
                    )
                    median[0] = String(content)
                    
                    if isDocEndChar {
                        state = .done(isCancled: true)
                        openRange = nil
                    }
                    else if isParagraphEndChar {
                        if tag.looseCanSpanParagraphs {
                            /// continue
                        } else {
                            state = .done(isCancled: true)
                            openRange = nil
                        }
                    } else {
                        looseCapturePreviousState = state
                        state = .median(tag: median, index: 0)
                        medianRange = .init(location: offset, length: 1)
                    }
                    
                }
                else {
                    if isDocEndChar {
                        state = .done(isCancled: true)
                        openRange = nil
                    }
                    else if isParagraphEndChar {
                        if tag.looseCanSpanParagraphs {
                            /// continue
                        } else {
                            state = .done(isCancled: true)
                            openRange = nil
                        }
                    }
                }
                
            }
            
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
                    state = .done(isCancled: true)
                    openRange = nil
                }
                else if isParagraphEndChar {
                    if tag.looseCanSpanParagraphs {
                        /// continue
                    } else {
                        state = .done(isCancled: true)
                        openRange = nil
                    }
                } else {
                    looseCapturePreviousState = state
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
                    if tag.looseCanSpanParagraphs {
                        /// continue
                    } else {
                        state = .done(isCancled: true)
                        openRange = nil
                    }
                }
            }
            
        case .median(var _tag, let index):
            
            guard let source = tag.meidanTag else { break }
            
            func reback() {
                /// 回退状态
                state = looseCapturePreviousState
                looseCapturePreviousState = .idle
                medianRange = nil
                
                /// 无法继续取中间标记的时候，使用当前字符看是否可以重新进入中间态
                appendLoose(
                    tag: tag,
                    render: render,
                    content: content,
                    previousContent: previousContent,
                    offset: offset,
                    isParagraphFirstChar: isParagraphFirstChar,
                    isParagraphEndChar: isParagraphEndChar,
                    isDocFirstChar: isDocFirstChar,
                    isDocEndChar: isDocEndChar,
                    canIdleCancle: true
                )
            }
            
            let next = index + 1
            let start = source.startIndex
            let strIndex = source.index(start, offsetBy: next)
            let nextChar = source[strIndex]
            if nextChar == content {
                _tag[next] = String(content)
                
                /// _tag.count == source.count
                if _tag.reduce("", { $0 + $1 }) == source {
                    
                    if isDocEndChar {
                        state = .done(isCancled: true)
                        openRange = nil
                        medianRange = nil
                    }
                    else if isParagraphEndChar {
                        if tag.looseCanSpanParagraphs {
                            /// continue
                            reback()
                        } else {
                            state = .done(isCancled: true)
                            openRange = nil
                            medianRange = nil
                        }
                    } else {
                        state = .medianCapture
                        medianRange?.length += 1
                    }
                    
                } else {
                    if isDocEndChar {
                        state = .done(isCancled: true)
                        openRange = nil
                        medianRange = nil
                    }
                    else if isParagraphEndChar {
                        if tag.looseCanSpanParagraphs {
                            /// continue
                            reback()
                        } else {
                            state = .done(isCancled: true)
                            openRange = nil
                            medianRange = nil
                        }
                    } else {
                        state = .median(tag: _tag, index: next)
                        medianRange?.length += 1
                    }
                }
            } else {
                
                if isDocEndChar {
                    state = .done(isCancled: true)
                    openRange = nil
                    medianRange = nil
                }
                else if isParagraphEndChar {
                    if tag.looseCanSpanParagraphs {
                        /// continue
                        reback()
                    } else {
                        state = .done(isCancled: true)
                        openRange = nil
                        medianRange = nil
                    }
                }
                else {
                    reback()
                }
                
            }
            
            
        case .medianCapture:
            
            /// loose point 2
            
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
                    openRange = nil
                    medianRange = nil
                }
                else if isParagraphEndChar {
                    if tag.looseCanSpanParagraphs {
                        /// continue
                    } else {
                        state = .done(isCancled: false)
                        openRange = nil
                        medianRange = nil
                    }
                } else {
                    state = .close(tag: close, index: 0)
                    closeRange = .init(location: offset, length: 1)
                }
                
            }
            else {
                if isDocEndChar {
                    state = .done(isCancled: true)
                    openRange = nil
                    medianRange = nil
                }
                else if isParagraphEndChar {
                    if tag.looseCanSpanParagraphs {
                        /// continue
                    } else {
                        state = .done(isCancled: true)
                        openRange = nil
                        medianRange = nil
                    }
                }
            }
            
        case .close(var _tag, let index):
            
            func reback() {
                /// 回退状态
                state = looseCapturePreviousState
                looseCapturePreviousState = .idle
                
                switch state {
                case .idle: break
                    
                case .open:
                    medianRange = nil
                    
                case .openCapture:
                    medianRange = nil
                    
                case .median, .medianCapture,
                        .close,
                        .done:
                    
                    break
                }
                
                closeRange = nil
                
                /// 无法继续关闭的时候，使用当前字符看是否可以重关
                appendLoose(
                    tag: tag,
                    render: render,
                    content: content,
                    previousContent: previousContent,
                    offset: offset,
                    isParagraphFirstChar: isParagraphFirstChar,
                    isParagraphEndChar: isParagraphEndChar,
                    isDocFirstChar: isDocFirstChar,
                    isDocEndChar: isDocEndChar,
                    canIdleCancle: true
                )
            }
            
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
                    closeRange?.length += 1
                    
                } else {
                    if isDocEndChar {
                        state = .done(isCancled: true)
                        openRange = nil
                        medianRange = nil
                        closeRange = nil
                    }
                    else if isParagraphEndChar {
                        if tag.looseCanSpanParagraphs {
                            /// continue
                            reback()
                        } else {
                            state = .done(isCancled: true)
                            openRange = nil
                            medianRange = nil
                            closeRange = nil
                        }
                    } else {
                        state = .close(tag: _tag, index: next)
                        closeRange?.length += 1
                    }
                }
            } else {
                
                if isDocEndChar {
                    state = .done(isCancled: true)
                    openRange = nil
                    medianRange = nil
                    closeRange = nil
                }
                else if isParagraphEndChar {
                    if tag.looseCanSpanParagraphs {
                        /// continue
                        reback()
                    } else {
                        state = .done(isCancled: true)
                        openRange = nil
                        medianRange = nil
                        closeRange = nil
                    }
                }
                else {
                    reback()
                }
            }
            
        case .done:
            break
        }
    }
    
    public func appendNormal(tag: DropTagSet, render: RenderDict, content: Character, previousContent: String?, offset: Int, isParagraphFirstChar: Bool, isParagraphEndChar: Bool, isDocFirstChar: Bool, isDocEndChar: Bool) {
        
        self.tag = tag
        self.render = render
        
        switch state {
        case .idle:
            if tag.openTag == String(content) {
                
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
            if tag.openTag.first == content {
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
            if nextChar == content {
                _tag[next] = String(content)
                
                /// _tag.count == source.count
                if _tag.reduce("", { $0 + $1 }) == tag.openTag {
                    
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
    
            if let medianTag = tag.meidanTag {
                
                if medianTag == String(content) {
                    
                    if isDocEndChar {
                        state = .done(isCancled: true)
                        openRange = nil
                    }
                    else if isParagraphEndChar {
                        state = .done(isCancled: true)
                        openRange = nil
                    } else {
                        state = .medianCapture
                        medianRange = .init(location: offset, length: 1)
                    }
                    
                }
                else
                if medianTag.first == content {
                    
                    var median: [String] = .init(
                        repeating: "", count: medianTag.count
                    )
                    median[0] = String(content)
                    
                    if isDocEndChar {
                        state = .done(isCancled: true)
                        openRange = nil
                    }
                    else if isParagraphEndChar {
                        state = .done(isCancled: true)
                        openRange = nil
                    } else {
                        state = .median(tag: median, index: 0)
                        medianRange = .init(location: offset, length: 1)
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
                
            }
            
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
                    state = .done(isCancled: true)
                    openRange = nil
                }
                else if isParagraphEndChar {
                    state = .done(isCancled: true)
                    openRange = nil
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
                    
                    if isDocEndChar {
                        state = .done(isCancled: true)
                        openRange = nil
                        medianRange = nil
                    }
                    else if isParagraphEndChar {
                        state = .done(isCancled: true)
                        openRange = nil
                        medianRange = nil
                    } else {
                        state = .medianCapture
                        medianRange?.length += 1
                    }
                    
                } else {
                    if isDocEndChar {
                        state = .done(isCancled: true)
                        openRange = nil
                        medianRange = nil
                    }
                    else if isParagraphEndChar {
                        state = .done(isCancled: true)
                        openRange = nil
                        medianRange = nil
                    } else {
                        state = .median(tag: _tag, index: next)
                        medianRange?.length += 1
                    }
                }
            } else {
                state = .done(isCancled: true)
                openRange = nil
                medianRange = nil
            }
            
            
        case .medianCapture:
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
                    openRange = nil
                    medianRange = nil
                }
                else if isParagraphEndChar {
                    state = .done(isCancled: false)
                    openRange = nil
                    medianRange = nil
                } else {
                    state = .close(tag: close, index: 0)
                    closeRange = .init(location: offset, length: 1)
                }
                
            }
            else {
                if isDocEndChar {
                    state = .done(isCancled: true)
                    openRange = nil
                    medianRange = nil
                }
                else if isParagraphEndChar {
                    state = .done(isCancled: true)
                    openRange = nil
                    medianRange = nil
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
                
                /// _tag.count == source.count
                if _tag.reduce("", { $0 + $1 }) == source {
                    
                    state = .done(isCancled: false)
                    closeRange?.length += 1
                    
                } else {
                    if isDocEndChar {
                        state = .done(isCancled: true)
                        openRange = nil
                        medianRange = nil
                        closeRange = nil
                    }
                    else if isParagraphEndChar {
                        state = .done(isCancled: true)
                        openRange = nil
                        medianRange = nil
                        closeRange = nil
                    } else {
                        state = .close(tag: _tag, index: next)
                        closeRange?.length += 1
                    }
                }
            } else {
                state = .done(isCancled: true)
                openRange = nil
                medianRange = nil
                closeRange = nil
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
        
        /// openTag + capture + medianTag + capture + closeTag
        
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
            
            guard let medianRange else {
                return []
            }
            
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
            
            let openCapture = document.content(
                in: .init(
                    location: openRange.maxLocation,
                    length: medianRange.location - openRange.maxLocation
                )
            )
            
            let medianCapture = document.content(
                in: .init(
                    location: medianRange.maxLocation,
                    length: closeRange.location - medianRange.maxLocation
                )
            )
            
            return [openTag, openCapture, medianTag, medianCapture, closeTag]
            
        } else {
            
            /// openTag + capture + closeTag
            let openCapture = document.content(
                in: .init(
                    location: openRange.maxLocation,
                    length: closeRange.location - openRange.maxLocation
                )
            )
            
            return [openTag, openCapture, closeTag]
        }
        
        
    }
    
    public func rawContents(inDoc document: Document) -> [String] {
        
        guard let openRange, let closeRange else {
            return []
        }
        
        /// openTag + capture + medianTag + capture + closeTag
        if let median = tag.meidanTag {
            
            guard let medianRange else {
                return []
            }
            
            let openCapture = document.content(
                in: .init(
                    location: openRange.maxLocation,
                    length: medianRange.location - openRange.maxLocation
                )
            )
            
            let medianCapture = document.content(
                in: .init(
                    location: medianRange.maxLocation,
                    length: closeRange.location - medianRange.maxLocation
                )
            )
            
            return [tag.openTag, openCapture, median, medianCapture, tag.closeTag]
            
        } else {
            
            /// openTag + capture + closeTag
            let openCapture = document.content(
                in: .init(
                    location: openRange.maxLocation,
                    length: closeRange.location - openRange.maxLocation
                )
            )
            
            return [tag.openTag, openCapture, tag.closeTag]
        }
    }
    
    public var contentRange: DropContants.IntRange {
        
        guard let openRange, let closeRange else {
            return .init()
        }
        
        return .init(
            location: openRange.location,
            length: closeRange.maxLocation - openRange.location
        )
    }
    
    public var rawContentRanges: [DropContants.IntRange] {
        
        guard let openRange, let closeRange else {
            return []
        }
        
        /// openTag + capture + medianTag + capture + closeTag
        if let medianRange = medianRange {
            
            let openCapture = DropContants.IntRange(
                location: openRange.maxLocation,
                length: medianRange.location - openRange.maxLocation
            )
            
            let medianCapture = DropContants.IntRange(
                location: medianRange.maxLocation,
                length: closeRange.location - medianRange.maxLocation
            )
            
            return [openRange, openCapture, medianRange, medianCapture, closeRange]
            
        } else {
            
            /// openTag + capture + closeTag
            let openCapture = DropContants.IntRange(
                location: openRange.maxLocation,
                length: closeRange.location - openRange.maxLocation
            )
            
            return [openRange, openCapture, closeRange]
        }
        
    }
    
    public var contentIndices: [Int] {
        /// openTag + capture + medianTag + capture + closeTag
        if tag.meidanTag != nil {
            return [1, 3]
        } else {
            /// openTag + capture + closeTag
            return [1]
        }
    }
    
    // MARK: Clear
    public func clear(isContainsHeadInfo: Bool) {
        state = .idle
        openRange = nil
        medianRange = nil
        closeRange = nil
        isOpenDone = false
        
        if isContainsHeadInfo {
            previousVaildHeadList = []
        }
    }
    
}
