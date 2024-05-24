//
//  Dropper.swift
//  MarkDrop
//
//  Created by windy on 2024/5/3.
//

import Foundation

public final class Dropper {
    
    // MARK: Properties
    public var document: Document
    public var tree: DropTree? = nil
    
    // MARK: Init
    public init(string raw: String) {
        document = .init(raw: raw)
    }
    
    public init(document: Document) {
        self.document = document
    }
    
    // MARK: Process AST
    @discardableResult
    public func process(using rules: [DropRule] = []) -> DropTree {
        let tree = DropTree(document: document)
        
        /// - Tag: Paragraph
        let paragraphs = document.raw.components(separatedBy: .newlines)
        
        /// - Tag: Process
        processContainer(paragraphs, in: tree, using: rules)
        rules.forEach({ $0.clear(isContainsHeadInfo: true) })
        
        self.tree = tree
        
        return tree
    }
    
    private func processContainer(_ paragraphs: [String], in tree: DropTree, using rules: [DropRule]) {
        
        let containerRules = rules.isEmpty ? createBlockRules() : rules.map({ .init($0) })
        
        var offset = document.raw.startIndex
        var intOffset = 0
        
        var lineOffset: Int = 0

        for paragraph in paragraphs {
            
            /// - Tag: Clear
            containerRules.forEach({
                $0.clear(isContainsHeadInfo: true)
            })
            
            /// - Tag: Node
            let count = paragraph.count
            
            let start = offset
            let end = document.offset(current: start, offset: count)
            let range = start ... end
            
            let intRange: DropContants.IntRange = .init(
                location: intOffset, length: count
            )
            
            let paragraphNode = self.container(
                .break,
                paragraph: paragraph,
                range: range,
                intRange: intRange
            )
            paragraphNode.lineIndex = lineOffset
            paragraphNode.lineCount = paragraphs.count
            
            /// - Tag: Process
            processParagrph(paragraphNode, using: containerRules)
            
            /// - Tag: Newline Text Node
            if paragraphNode.isLastLine == false {
                let newlineText = self.content(.text)
                newlineText.contents = ["\n"]
                newlineText.rawContentIndices = [0]
                newlineText.renderContents = ["\n"]
                newlineText.renderContentOffsets = [0]
                newlineText.range = end ... end
                newlineText.intRange = .init(location: count, length: 1)
                newlineText.documentRange = .init(
                    location: newlineText.intRange.location + paragraphNode.intRange.location,
                    length: newlineText.intRange.length
                )
                paragraphNode.append(newlineText)
            }
            
            /// - Tag: Judge Type
            let types = paragraphNode.children.map({ ($0 as! DropContentNode).type })
            
            var containerType = DropContainerType.paragraph
            
            var isBreak = true
            
            for (index, type) in types.enumerated() {
                
                if type == .bulletList {
                    containerType = .block(child: .bulletList)
                    isBreak = false
                    break
                }
                else if type == .numberOrderList {
                    containerType = .block(child: .numberOrderList)
                    isBreak = false
                    break
                }
                else if type == .letterOrderList {
                    containerType = .block(child: .letterOrderList)
                    isBreak = false
                    break
                }
                else {
                    isBreak = isBreak && (
                        type == .spaceIndent ||
                        type == .tabIndent ||
                        (type == .text && paragraphNode.children[index].rawContent.isEmpty)
                    )
                }
                
            }
            
            if isBreak { containerType = .break }
            
            /// - Tag: Dealing
            switch containerType {
            /// never in ...
            case .document:
                break
                
            case .block:
                if
                    let previousContainer = tree.lastContainer(),
                    previousContainer.type.isBlock,
                    previousContainer.type == containerType
                {
                    paragraphNode.type = .paragraph
                    previousContainer.append(paragraphNode)
                    
                } else {
                    
                    let container = self.container(containerType)
                    container.lineIndex = lineOffset
                    container.lineCount = paragraphs.count
                    
                    paragraphNode.type = .paragraph
                    container.append(paragraphNode)
                    
                    tree.addChild(container)
                }
                
            case .paragraph, .break:
                paragraphNode.type = containerType
                tree.addChild(paragraphNode)
            }
            
            /// - Tag: Increase
            offset = document.offset(
                current: end,
                /// 最后一行没有 "\n"
                offset: (paragraphs.count != 0 ? 1 /* \n skip */ : 0)
            )
            
            intOffset += (count + (paragraphs.count != 0 ? 1 /* \n skip */ : 0))
            
            lineOffset += 1
            
//            print(#function, #line, containerType, paragraph, (paragraphNode.parentNode as? DropContainerNode)?.type ?? "None Parent", paragraphNode.children.count)
            
        }
        
    }
    
    private func processParagrph(_ paragraph: DropContainerNode, using rules: [ProcessRule]) {
        
        rules.forEach({
            $0.clear(isContainsHeadInfo: true)
        })
        
        var openRules: [ProcessRule] = []
        
        var markTexts: [DropContentMarkNode] = []
        var marks: [DropContentMarkNode] = []
        
        var offset = paragraph.rawContent.startIndex
        var intOffset = 0
        
        var previousUnicodes: String = ""
        
        for unicode in paragraph.rawContent {
            
//            print(unicode)
            
            // MARK: Batch judge
            var dones:   [ProcessRule] = []
            var cancles: [ProcessRule] = []
            var opens:   [ProcessRule] = []
            
            rules.forEach({
                $0.source.append(
                    content: unicode,
                    previousContent: previousUnicodes,
                    isFirstChar: intOffset == 0,
                    isEndChar: intOffset == paragraph.rawContent.count - 1
                )
                
                if $0.source.isDone    { dones.append($0)   }
                if $0.source.isCancled { cancles.append($0) }
                if $0.source.isOpen    { opens.append($0)   }
            })
            
            // MARK: Open rules
            for rule in opens {
                
//                print(#function, #line, "open block: ", rule.source.type)
                
                guard rule.isWorking == false else { continue }
                rule.isWorking = true
                
                if let currentOpen = openRules.last {
                    
                    let currentNode = self.content(rule.source.type)
                    currentNode.range = offset ... offset
                    currentNode.intRange = .init(location: intOffset, length: 0)
                    
                    rule.parent = currentOpen
                    rule.openNode = currentNode
                    openRules.append(rule)
                    rule.parent?.children.append(rule)
                    
//                    print(#function, #line, currentNode.intRange, currentNode.contents)
                    
                } else {
                    
                    let currentNode = self.content(rule.source.type)
                    currentNode.range = offset ... offset
                    currentNode.intRange = .init(location: intOffset, length: 0)
                    
                    rule.parent = nil
                    rule.openNode = currentNode
                    openRules.append(rule)
                    
//                    print(#function, #line, currentNode.intRange, currentNode.contents)
                    
                }
                
            }
            
            // MARK: Cancles rules
            for rule in cancles {
                
//                print(#function, #line, "cancle block: ", rule.source.type)
                
                openRules.removeAll(where: { $0 === rule })
                rule.parent?.children.removeAll(where: { $0 === rule })
                
                rule.children.forEach({
                    $0.parent = rule.parent
                    if $0.isWorkingDone, let open = $0.openNode, open.type != .text {
                        paragraph.append(open)
                    }
                })
                
                if rule.haveDoneChildren {
                    rule.doneChildren.forEach {
                        let parent = rule.parent?.openNode ?? paragraph
                        $0.parentNode?.remove(child: $0)
                        parent.append($0)
                    }
                }
                
                rule.clear(isContainsHeadInfo: false)
            }
            
            // MARK: Done rules
            for rule in dones {
                
                guard rule.isWorkingDone == false else { continue }
                
//                print(#function, #line, "done block: ", rule.source.type)
                
                if rule.source.isOpenDone {
                    
                    let node = self.content(rule.source.type)
                    node.contents = [String(unicode)]
                    node.rawContentIndices = [0]
                    node.renderContents = rule.source.contents
                    node.renderContentOffsets = rule.source.contentOffsets
                    node.range = offset ... offset
                    node.intRange = .init(location: intOffset, length: 1)
                    node.documentRange = .init(
                        location: node.intRange.location + paragraph.intRange.location,
                        length: node.intRange.length
                    )
                    
                    let markNode = self.contentMark(rule.source.type, mark: .text)
                    markNode.contents = node.contents
                    markNode.rawContentIndices = node.rawContentIndices
                    markNode.renderContents = node.renderContents
                    markNode.renderContentOffsets = node.renderContentOffsets
                    markNode.range = node.range
                    markNode.intRange = node.intRange
                    markNode.documentRange = node.documentRange
                    node.append(markNode)
                    
//                    print(#function, #line, "mark", paragraph.rawContent[markNode.range])
                    
                    addToParent(rule: rule, currentOpen: node, in: paragraph)
                    
                    upChildParent(rule: rule, currentOpen: node, in: dones)
                    
//                    print(#function, #line, node.intRange, node.contents, "parent: ", node.parentNode ?? "None Parent")
                    
//                    if node.parentNode === paragraph {
//                        splitSelfTextWholeContains(
//                            currentOpen: node,
//                            currentNode: node,
//                            in: paragraph,
//                            isDepth: true
//                        )
//                    } else {
//                        splitSelfText(currentOpen: node, in: paragraph)
//                    }
                    
                    adjustmentChildParent(currentOpen: node)
                    
                    if markNode.mark == .text {
                        markTexts.append(markNode)
                    }
                    
                    if markNode.mark != .text && markNode.mark != .none {
                        marks.append(markNode)
                    }
                    
                } else {
                    
                    /// always true
                    if let currentOpen = rule.openNode {
                        
                        currentOpen.contents = rule.source.rawContents
                        currentOpen.rawContentIndices = rule.source.contentIndices
                        currentOpen.renderContents = rule.source.contents
                        currentOpen.renderContentOffsets = rule.source.contentOffsets
                        currentOpen.range = currentOpen.range.lowerBound ... offset
                        increaseLength(&currentOpen.intRange, by: rule.source.totalContent, in: paragraph)
                        currentOpen.documentRange = .init(
                            location: currentOpen.intRange.location + paragraph.intRange.location,
                            length: currentOpen.intRange.length
                        )
                        
                        if currentOpen.renderContents.count <= 1 {
                            
                            let markNode = self.contentMark(rule.source.type, mark: .text)
                            markNode.contents = currentOpen.contents
                            markNode.rawContentIndices = currentOpen.rawContentIndices
                            markNode.renderContents = currentOpen.renderContents
                            markNode.renderContentOffsets = currentOpen.renderContentOffsets
                            markNode.range = currentOpen.range
                            markNode.intRange = currentOpen.intRange
                            markNode.documentRange = currentOpen.documentRange
                            currentOpen.append(markNode)
                            
                            if markNode.mark == .text {
                                markTexts.append(markNode)
                            }
                            
                            if markNode.mark != .text && markNode.mark != .none {
                                marks.append(markNode)
                            }
                            
                        } else {
                            
                            var markOffset = currentOpen.range.lowerBound
                            let markOffsetLimit = currentOpen.range.upperBound
                            
                            var markIntOffset = currentOpen.intRange.location
                            
                            let loopContents = zip(
                                currentOpen.contents,
                                zip(currentOpen.renderContents, currentOpen.renderContentOffsets)
                            )
                            
                            for (index, (content, (renderContent, renderContentOffset))) in loopContents.enumerated() {
                                
                                let count = content.count
                                
                                let markNode = self.contentMark(
                                    rule.source.type,
                                    mark: currentOpen.rawContentIndices.contains(index) ? .text : rule.source.type.mark
                                )
                                
                                markNode.contents = [content]
                                markNode.rawContentIndices = [0] /// [index]
                                markNode.renderContents = [renderContent]
                                markNode.renderContentOffsets = [renderContentOffset]
                                markNode.range = markOffset ... nextOffset(markOffset, count: count - 1, limit: markOffsetLimit, in: paragraph)
                                markNode.intRange = .init(location: markIntOffset, length: count)
                                markNode.documentRange = .init(
                                    location: markNode.intRange.location + paragraph.intRange.location,
                                    length: markNode.intRange.length
                                )
                                currentOpen.append(markNode)
                                
                                markOffset = nextOffset(markOffset, count: count, limit: markOffsetLimit, in: paragraph)
                                markIntOffset += count
                                
//                                print(#function, #line, "mark", paragraph.rawContent[markNode.range])
                                
                                if markNode.mark == .text {
                                    markTexts.append(markNode)
                                }
                                
                                if markNode.mark != .text && markNode.mark != .none {
                                    marks.append(markNode)
                                }
                            }
                            
                        }
                        
                        addToParent(rule: rule, currentOpen: currentOpen, in: paragraph)
                        
                        upChildParent(rule: rule, currentOpen: currentOpen, in: dones)
                        
//                        print(#function, #line, currentOpen.intRange, currentOpen.contents, "parent: ", currentOpen.parentNode ?? "None Parent")
                        
//                        if currentOpen.parentNode === paragraph {
//                            splitSelfTextWholeContains(
//                                currentOpen: currentOpen,
//                                currentNode: currentOpen,
//                                in: paragraph,
//                                isDepth: true
//                            )
//                        } else {
//                            splitSelfText(currentOpen: currentOpen, in: paragraph)
//                        }
                        
                        adjustmentChildParent(currentOpen: currentOpen)
                        
                    }
                    
                }
                
                openRules.removeAll(where: { $0 === rule })
                
                rule.isWorkingDone = true
                
//                if 
//                    let parentNode = rule.parentOpenNode,
//                    let currentNode = rule.openNode
//                {
//                    /// split parent node
//                    
//                    /// the knife
//                    let childMarks = currentNode.children.filter({
//                        guard let markNode = $0 as? DropContentMarkNode else { return false }
//                        return markNode.mark != .text && markNode.mark != .none
//                    })
//                    
//                    /// the content
//                    let parentTexts = parentNode.children.filter({
//                        guard let markNode = $0 as? DropContentMarkNode else { return false }
//                        return markNode.mark == .text
//                    })
//                    
//                    
//                    /// the knife
//                    let parentMarks = parentNode.children.filter({
//                        guard let markNode = $0 as? DropContentMarkNode else { return false }
//                        return markNode.mark != .text && markNode.mark != .none
//                    })
//                    
//                    /// the content
//                    let childTexts = currentNode.children.filter({
//                        guard let markNode = $0 as? DropContentMarkNode else { return false }
//                        return markNode.mark == .text
//                    })
//                    
//                    /// 完全被 parent 包裹
//                    let parentIntRange = parentNode.intRange
//                    let currentIntRange = currentNode.intRange
//                    
//                    if
//                        currentIntRange.location >= parentIntRange.location,
//                        currentIntRange.maxLocation <= parentIntRange.maxLocation
//                    {
//                        
//                        if let currentOpen = parentNode as? DropContentNode {
//                            splitSelfTextWholeContains(currentOpen: currentOpen, currentNode: currentNode, in: paragraph)
//                        }
//                        
//                    }
//                    /// 与 parent 有重叠的部分
//                    else {
//                        splitTextNode(byMarks: childMarks, texts: parentTexts, in: paragraph)
//                        splitTextNode(byMarks: parentMarks, texts: childTexts, in: paragraph)
//                    }
//                    
//                }
                
                childCaptureParent(rule: rule)
                
                /// clear for reuse
                rule.parent?.doneChildren.append(rule.openNode!)
                rule.parent?.children.removeAll(where: { $0 === rule })
                rule.clear(isContainsHeadInfo: false)
                
            }
            
            /// - Tag: Offset
            offset = Document.offset(in: paragraph.rawContent, current: offset, offset: 1)
            intOffset += 1
            
            /// - Tag: Previous
            previousUnicodes = String(unicode)
            
        }
        
        /// - Tag: Slpit text nodes
        var newChildren: [DropNode] = []
        var previousChild: DropNode? = nil
        var currentLocation: Int = 0
        for child in paragraph.children {
            if child.intRange.location > currentLocation {
                let text = self.content(.text)
                if let previous = previousChild {
                    let start = nextOffset(previous.range.upperBound, in: paragraph)
                    let intStart = previous.intRange.maxLocation
                    text.range = start ... previousOffset(child.range.lowerBound, limit: start, in: paragraph)
                    text.intRange = .init(location: intStart, length: child.intRange.location - intStart)
                } else {
                    let start = paragraph.rawContent.startIndex
                    let intStart = 0
                    text.range = start ... previousOffset(child.range.lowerBound, limit: start, in: paragraph)
                    text.intRange = .init(location: intStart, length: child.intRange.location - intStart)
                }
                text.documentRange = .init(
                    location: text.intRange.location + paragraph.intRange.location,
                    length: text.intRange.length
                )
                text.contents = [String(paragraph.rawContent[text.range])]
                text.rawContentIndices = [0]
                text.renderContents = text.contents
                text.renderContentOffsets = [0]
                text.parentNode = paragraph
                newChildren.append(text)
            }
            previousChild = child
            currentLocation = child.intRange.maxLocation
            newChildren.append(child)
        }
        
        /// the last text node
        if
            let last = newChildren.last,
            last.intRange.maxLocation < paragraph.rawContent.count
        {
            let text = self.content(.text)
            let start = nextOffset(last.range.upperBound, in: paragraph)
            let intStart = last.intRange.maxLocation
            text.range = start ... previousOffset(paragraph.rawContent.endIndex, in: paragraph)
            text.intRange = .init(location: intStart, length: paragraph.rawContent.count - intStart)
            text.documentRange = .init(
                location: text.intRange.location + paragraph.intRange.location,
                length: text.intRange.length
            )
            text.contents = [String(paragraph.rawContent[text.range])]
            text.rawContentIndices = [0]
            text.renderContents = text.contents
            text.renderContentOffsets = [0]
            text.parentNode = paragraph
            newChildren.append(text)
        }
        
        paragraph.children = newChildren
        
        /// - Tag: text paragraph
        if paragraph.haveChildren == false, paragraph.rawContent.isEmpty == false {
            let text = self.content(.text)
            text.range = paragraph.rawContent.startIndex ... previousOffset(paragraph.rawContent.endIndex, in: paragraph)
            text.intRange = .init(location: 0, length: paragraph.rawContent.count)
            text.documentRange = .init(
                location: text.intRange.location + paragraph.intRange.location,
                length: text.intRange.length
            )
            text.contents = [String(paragraph.rawContent[text.range])]
            text.rawContentIndices = [0]
            text.renderContents = text.contents
            text.renderContentOffsets = [0]
            text.parentNode = paragraph
            paragraph.children = [text]
        }
        
        /// - Tag: Split Texts
        var markNodes = markTexts
        
        while let text = markNodes.popLast() {
            
            var isClearText = false
            
            for mark in marks {
                guard 
                    text.rawContent.isEmpty == false,
                    mark.intRange.location >= text.intRange.location,
                    mark.intRange.maxLocation <= text.intRange.maxLocation
                else {
                    continue
                }
                
                let headOffset = mark.intRange.location - text.intRange.location
                let tailOffset = text.intRange.maxLocation - mark.intRange.maxLocation
                
                if headOffset > 0 {
                    let node = self.contentMark(text.type, mark: .text)
                    let start = text.range.lowerBound
                    let intStart = text.intRange.location
                    node.range = start ... previousOffset(mark.range.lowerBound, limit: start, in: paragraph)
                    node.intRange = .init(location: intStart, length: headOffset)
                    node.documentRange = .init(
                        location: node.intRange.location + text.intRange.location,
                        length: node.intRange.length
                    )
                    node.contents = [String(paragraph.rawContent[node.range])]
                    node.rawContentIndices = [0]
                    node.renderContents = node.contents
                    node.renderContentOffsets = [0]
                    text.append(node)
                    
                    if 
                        marks.filter({
                            $0.intRange.location >= node.intRange.location &&
                            $0.intRange.maxLocation <= node.intRange.maxLocation
                        }).isEmpty == false
                    {
                        markNodes.append(node)
                    }
                }
                
                if tailOffset > 0 {
                    let node = self.contentMark(text.type, mark: .text)
                    let start = nextOffset(mark.range.upperBound, limit: text.range.upperBound, in: paragraph)
                    let intStart = mark.intRange.maxLocation
                    node.range = start ... text.range.upperBound
                    node.intRange = .init(location: intStart, length: tailOffset)
                    node.documentRange = .init(
                        location: node.intRange.location + text.intRange.location,
                        length: node.intRange.length
                    )
                    node.contents = [String(paragraph.rawContent[node.range])]
                    node.rawContentIndices = [0]
                    node.renderContents = node.contents
                    node.renderContentOffsets = [0]
                    text.append(node)
                    
                    if
                        marks.filter({
                            $0.intRange.location >= node.intRange.location &&
                            $0.intRange.maxLocation <= node.intRange.maxLocation
                        }).isEmpty == false
                    {
                        markNodes.append(node)
                    }
                }
                
                if headOffset > 0 || tailOffset > 0 {
                    isClearText = true
                }
                
            }
            
            if isClearText {
                text.contents = []
                text.rawContentIndices = []
                text.renderContents = []
                text.renderContentOffsets = []
            }
            
        }
        
        /// - Tag: Fix Leaves
        
        var leaves = paragraph.leaves
        
        while let node = leaves.popLast() {
            
            guard 
                let markNode = node as? DropContentMarkNode,
                markNode.mark == .text,
                markNode.rawRenderContent.isEmpty == false
            else {
                continue
            }
            
            var parent = node.parentNode
            
            while 
                let currentParent = parent as? DropContentNodeProtocol,
                let parentRender = currentParent.type.render
            {
                if let lastRender = markNode.parentContainerRenderTypes.last {
                    if lastRender != parentRender {
                        markNode.parentContainerRenderTypes.append(parentRender)
                    }
                } else {
                    if 
                        let selfRender = markNode.type.render,
                        selfRender != parentRender
                    {
                        markNode.parentContainerRenderTypes.append(parentRender)
                    }
                }
                parent = currentParent.parentNode
            }
            
        }
        
        #if false
        print()
        print(#function, #line, paragraph.children)
        print(#function, #line, paragraph.children.map({ "(\($0.range.lowerBound.utf16Offset(in: paragraph.rawContent)), \($0.range.upperBound.utf16Offset(in: paragraph.rawContent)))" }))
        print(#function, #line, paragraph.children.map({ "(\($0.intRange.location), \($0.intRange.length))" }))
        print(#function, #line, paragraph.children.map({ paragraph.rawContent[$0.range] }))
        print(#function, #line, paragraph.children.map({
            let startI = paragraph.rawContent.startIndex
            let start = nextOffset(startI, count: $0.intRange.location, in: paragraph)
            let end = nextOffset(start, count: $0.intRange.length, in: paragraph)
            return paragraph.rawContent[start ..< end]
        }))
        print()
        #endif
        
    }
    
    private func previousOffset(_ offset: String.Index, count: Int = 1, limit: String.Index? = nil, in paragraph: DropContainerNode) -> String.Index {
        let start = limit ?? paragraph.rawContent.startIndex
        let result = paragraph.rawContent.index(offset, offsetBy: -count, limitedBy: start) ?? start
        return result
    }
    
    private func nextOffset(_ offset: String.Index, count: Int = 1, limit: String.Index? = nil, in paragraph: DropContainerNode) -> String.Index {
        let end = limit ?? paragraph.rawContent.endIndex
        let result = paragraph.rawContent.index(offset, offsetBy: count, limitedBy: end) ?? end
        return result
    }
    
    private func previousIntOffset(_ offset: Int, count: Int = 1) -> Int {
        let start = 0
        let result = offset - count
        return result < start ? start : result
    }
    
    private func nextIntOffset(_ offset: Int, count: Int = 1, in paragraph: DropContainerNode) -> Int {
        let start = 0
        let end = paragraph.rawContent.count - 1
        let result = offset + count
        return result < start ? start : (result > end ? end : result)
    }
    
    private func decreaseContent(_ content: inout String, by count: Int) {
        guard count > 0 else { return }
        guard content.count > count else {
            content = ""
            return
        }
        content = String(content.dropLast(count))
    }
    
    private func decreaseRange(_ range: inout DropContants.Range, using count: Int, in paragraph: DropContainerNode) {
        let start = range.lowerBound
        let originEnd = range.upperBound
        let end = paragraph.rawContent.index(originEnd, offsetBy: -count, limitedBy: start) ?? start
        range = start ... end
    }
    
    private func decreaseLength(_ range: inout DropContants.IntRange, by count: Int, in paragraph: DropContainerNode) {
        let totalLength = paragraph.rawContent.count
        var result = max(0, range.length - count)
        let contentLength = range.location + result
        if contentLength > totalLength { result = totalLength - range.location }
        range.length = result
    }
    
    private func increaseLength(_ range: inout DropContants.IntRange, by content: String, in paragraph: DropContainerNode) {
        increaseLength(&range, by: content.count, in: paragraph)
    }
    
    private func increaseLength(_ range: inout DropContants.IntRange, by count: Int, in paragraph: DropContainerNode) {
        let totalLength = paragraph.rawContent.count
        var result = range.length + count
        let contentLength = range.location + result
        if contentLength > totalLength { result = totalLength - range.location }
        range.length = result
    }
    
    private func increaseLength(_ range: inout DropContants.IntRange, in paragraph: DropContainerNode) {
        let totalLength = paragraph.rawContent.count
        var result = range.length + 1
        let contentLength = range.location + result
        if contentLength > totalLength { result = totalLength - range.location }
        range.length = result
    }
    
    @discardableResult
    private func addToParent(rule: ProcessRule, currentOpen: DropContentNode, in paragraph: DropContainerNode) -> DropNode {
        let parent = (rule.parentNode ?? rule.parent?.openNode) ?? paragraph
        parent.append(currentOpen)
        return parent
    }
    
    private func upChildParent(rule: ProcessRule, currentOpen: DropContentNode, in dones: [ProcessRule]) {
        /// 父节点完成的时候，子节点应该已经完成才对，
        /// 如果子节点还没完成，把它的 父节点 提升为 合适的父节点
        if rule.haveChildren {
            for child in rule.children {
                
                /// 在当前字符下完成，即同时完成
                if dones.contains(child) {
                    child.parentNode = currentOpen
                }
                else
                /// 未完成，即超出当前字符才完成
                if child.isWorkingDone == false {
                    child.parentNode = currentOpen.parentNode
                }
                
            }
        }
    }
    
    private func splitSelfTextWholeContains(currentOpen: DropContentNode, currentNode: DropContentNode, in paragraph: DropContainerNode, isDepth: Bool = false) {
        /// 未完全覆盖，使用子节点直接切割出 text Node
        let texts = currentOpen.children
            .filter({
                if let content = $0 as? DropContentNodeProtocol {
                    return content.type == currentOpen.type
                }
                return false
            })
            .sorted(by: { $0.intRange.location < $1.intRange.location })
        
        let marks: [DropNode]
        if currentOpen === currentNode {
            marks = (isDepth ? currentNode.nodes : currentNode.children)
                .filter({
                    guard let markNode = $0 as? DropContentMarkNode else { return false }
                    return markNode.mark != .text && markNode.mark != .none && markNode.type != currentNode.type
                })
                .sorted(by: { $0.intRange.location < $1.intRange.location })
        } else {
            marks = (isDepth ? currentNode.nodes : currentNode.children)
                .filter({
                    guard let markNode = $0 as? DropContentMarkNode else { return false }
                    return markNode.mark != .text && markNode.mark != .none
                })
                .sorted(by: { $0.intRange.location < $1.intRange.location })
        }
        
        let minChild = marks.first
        let maxChild = marks.last
        
        if
            let min = minChild,
            let max = maxChild,
            let minParent = texts.first(where: {
                $0.intRange.contains(min.intRange.location)
            }),
            let maxParent = texts.first(where: {
                $0.intRange.contains(max.intRange.maxLocation) ||
                $0.intRange.maxLocation == max.intRange.maxLocation
            })
        {
            /// using child split self nodes
        
            let headOffset = min.intRange.location - minParent.intRange.location
            let tailOffset = maxParent.intRange.maxLocation - max.intRange.maxLocation
            
            if headOffset > 0 {
                let text = self.contentMark(currentOpen.type, mark: .text)
                let start = minParent.range.lowerBound
                let intStart = minParent.intRange.location
                text.range = start ... previousOffset(min.range.lowerBound, limit: start, in: paragraph)
                text.intRange = .init(location: intStart, length: headOffset)
                text.documentRange = .init(
                    location: text.intRange.location + minParent.intRange.location,
                    length: text.intRange.length
                )
                text.contents = [String(paragraph.rawContent[text.range])]
                text.rawContentIndices = [0]
                text.renderContents = text.contents
                text.renderContentOffsets = [0]
                minParent.append(text)
            }
            
            if tailOffset > 0 {
                let text = self.contentMark(currentOpen.type, mark: .text)
                let start = nextOffset(max.range.upperBound, limit: maxParent.range.upperBound, in: paragraph)
                let intStart = max.intRange.maxLocation
                text.range = start ... maxParent.range.upperBound
                text.intRange = .init(location: intStart, length: tailOffset)
                text.documentRange = .init(
                    location: text.intRange.location + maxParent.intRange.location,
                    length: text.intRange.length
                )
                text.contents = [String(paragraph.rawContent[text.range])]
                text.rawContentIndices = [0]
                text.renderContents = text.contents
                text.renderContentOffsets = [0]
                maxParent.append(text)
            }
            
            if headOffset > 0 {
                minParent.contents = []
                minParent.rawContentIndices = []
                minParent.renderContents = []
                minParent.renderContentOffsets = []
            }
            
            if tailOffset > 0 {
                maxParent.contents = []
                maxParent.rawContentIndices = []
                minParent.renderContents = []
                minParent.renderContentOffsets = []
            }
            
        }
    }
    
    private func splitSelfText(currentOpen: DropContentNode, in paragraph: DropContainerNode) {
        /// 未完全覆盖，使用子节点直接切割出 text Node
        guard let nodes = currentOpen.nodes as? [DropContentNodeProtocol] else {
            return
        }
        
        var texts = nodes
            .filter({
                if let content = $0 as? DropContentNode {
                    return content.type == .text
                }
                if let markNode = $0 as? DropContentMarkNode {
                    return markNode.mark == .text
                }
                return false
            })
        
        let marks = nodes
            .filter({
                guard let markNode = $0 as? DropContentMarkNode else { return false }
                return markNode.mark != .text && markNode.mark != .none
            })
        
        while let text = texts.popLast() {
            
            guard text.rawContent.isEmpty == false else {
                continue
            }
            
            var isClearText = false
            
            for mark in marks {
                guard text.intRange.contains(mark.intRange.location) else {
                    continue
                }
                
                let headOffset = mark.intRange.location - text.intRange.location
                let tailOffset = text.intRange.maxLocation - mark.intRange.maxLocation
                
                if headOffset > 0 {
                    let node = self.contentMark(text.type, mark: .text)
                    let start = text.range.lowerBound
                    let intStart = text.intRange.location
                    node.range = start ... previousOffset(mark.range.lowerBound, limit: start, in: paragraph)
                    node.intRange = .init(location: intStart, length: headOffset)
                    node.documentRange = .init(
                        location: node.intRange.location + text.intRange.location,
                        length: node.intRange.length
                    )
                    node.contents = [String(paragraph.rawContent[node.range])]
                    node.rawContentIndices = [0]
                    node.renderContents = node.contents
                    node.renderContentOffsets = [0]
                    text.append(node)
                }
                
                if tailOffset > 0 {
                    let node = self.contentMark(text.type, mark: .text)
                    let start = nextOffset(mark.range.upperBound, limit: text.range.upperBound, in: paragraph)
                    let intStart = mark.intRange.maxLocation
                    node.range = start ... text.range.upperBound
                    node.intRange = .init(location: intStart, length: tailOffset)
                    node.documentRange = .init(
                        location: node.intRange.location + text.intRange.location,
                        length: node.intRange.length
                    )
                    node.contents = [String(paragraph.rawContent[node.range])]
                    node.rawContentIndices = [0]
                    node.renderContents = node.contents
                    node.renderContentOffsets = [0]
                    text.append(node)
                }
                
                if headOffset > 0 || tailOffset > 0 {
                    isClearText = true
                }
                
            }
            
            if isClearText {
                text.contents = []
                text.rawContentIndices = []
                text.renderContents = []
                text.renderContentOffsets = []
            }
            
        }
        
//        let minChild = texts.first
//        let maxChild = texts.last
//        
//        if
//            let min = minChild,
//            let max = maxChild,
//            let minParent = marks.first(where: {
//                $0.intRange.contains(min.intRange.location)
//            }),
//            let maxParent = marks.first(where: {
//                $0.intRange.contains(max.intRange.maxLocation) ||
//                $0.intRange.maxLocation == max.intRange.maxLocation
//            })
//        {
//            /// using child split self nodes
//        
//            let headOffset = min.intRange.location - minParent.intRange.location
//            let tailOffset = maxParent.intRange.maxLocation - max.intRange.maxLocation
//            
//            if headOffset > 0 {
//                let text = self.contentMark(currentOpen.type, mark: .text)
//                let start = minParent.range.lowerBound
//                let intStart = minParent.intRange.location
//                text.range = start ... previousOffset(min.range.lowerBound, limit: start, in: paragraph)
//                text.intRange = .init(location: intStart, length: headOffset)
//                text.documentRange = .init(
//                    location: text.intRange.location + minParent.intRange.location,
//                    length: text.intRange.length
//                )
//                text.contents = [String(paragraph.rawContent[text.range])]
//                text.rawContentIndices = [0]
//                text.renderContents = text.contents
//                text.renderContentOffsets = [0]
//                minParent.append(text)
//            }
//            
//            if tailOffset > 0 {
//                let text = self.contentMark(currentOpen.type, mark: .text)
//                let start = nextOffset(max.range.upperBound, limit: maxParent.range.upperBound, in: paragraph)
//                let intStart = max.intRange.maxLocation
//                text.range = start ... maxParent.range.upperBound
//                text.intRange = .init(location: intStart, length: tailOffset)
//                text.documentRange = .init(
//                    location: text.intRange.location + maxParent.intRange.location,
//                    length: text.intRange.length
//                )
//                text.contents = [String(paragraph.rawContent[text.range])]
//                text.rawContentIndices = [0]
//                text.renderContents = text.contents
//                text.renderContentOffsets = [0]
//                maxParent.append(text)
//            }
//            
//            if headOffset > 0 {
//                minParent.contents = []
//                minParent.rawContentIndices = []
//                minParent.renderContents = []
//                minParent.renderContentOffsets = []
//            }
//            
//            if tailOffset > 0 {
//                maxParent.contents = []
//                maxParent.rawContentIndices = []
//                maxParent.renderContents = []
//                maxParent.renderContentOffsets = []
//            }
//            
//        }
        
    }
    
    private func adjustmentChildParent(currentOpen: DropContentNode) {
        /// 尝试调整 child 的父节点到更合适的位置
        /// 找到 1 对 多 映射 ( intRange : node )
        
        var sameRangeChildDict: [DropContants.IntRange: [DropNode]] = .init()
        currentOpen.children.forEach({
            if sameRangeChildDict[$0.intRange] == nil {
                sameRangeChildDict[$0.intRange] = []
            }
            sameRangeChildDict[$0.intRange]?.append($0)
        })
        
        let sameRangeChilds = sameRangeChildDict.filter({ $0.value.count > 1 })
        
        let parentType = currentOpen.type
        
        for sames in sameRangeChilds {
            
            let findParent = sames.value.filter({
                if let content = $0 as? DropContentNode {
                    return content.type == parentType
                }
                if let markContent = $0 as? DropContentMarkNode {
                    return markContent.type == parentType
                }
                return false
            }).first
            
            sames.value.forEach({
                guard $0 !== findParent else { return }
                
                $0.parentNode?.remove(child: $0)
                findParent?.append($0)
            })
            
        }
    }
    
    private func childCaptureParent(rule: ProcessRule) {
        if rule.haveChildren {
            rule.children.forEach({
                guard $0.isWorkingDone == false else { return }
                /// capture parent state
                $0.parentOpenNode = rule.openNode
            })
        }
    }
    
    private func splitTextNode(byMarks knifes: [DropNode]?, texts dealingTexts: [DropNode]?, in paragraph: DropContainerNode) {
        
        if
            let marks = knifes as? [DropContentMarkNode],
            let texts = dealingTexts as? [DropContentMarkNode]
        {
            for text in texts {
                guard
                    text.rawContent.isEmpty == false,
                    let mark = marks.first(where: {
                        text.intRange.contains($0.intRange.location)
                    })
                else {
                    continue
                }
                
                let headOffset = mark.intRange.location - text.intRange.location
                let tailOffset = text.intRange.maxLocation - mark.intRange.maxLocation
                
                if headOffset > 0 {
                    let node = self.contentMark(text.type, mark: .text)
                    let start = text.range.lowerBound
                    let intStart = text.intRange.location
                    node.range = start ... previousOffset(mark.range.lowerBound, limit: start, in: paragraph)
                    node.intRange = .init(location: intStart, length: headOffset)
                    node.documentRange = .init(
                        location: node.intRange.location + text.intRange.location,
                        length: node.intRange.length
                    )
                    node.contents = [String(paragraph.rawContent[node.range])]
                    node.rawContentIndices = [0]
                    node.renderContents = node.contents
                    node.renderContentOffsets = [0]
                    text.append(node)
                }
                
                if tailOffset > 0 {
                    let node = self.contentMark(text.type, mark: .text)
                    let start = nextOffset(mark.range.upperBound, limit: text.range.upperBound, in: paragraph)
                    let intStart = mark.intRange.maxLocation
                    node.range = start ... text.range.upperBound
                    node.intRange = .init(location: intStart, length: tailOffset)
                    node.documentRange = .init(
                        location: node.intRange.location + text.intRange.location,
                        length: node.intRange.length
                    )
                    node.contents = [String(paragraph.rawContent[node.range])]
                    node.rawContentIndices = [0]
                    node.renderContents = node.contents
                    node.renderContentOffsets = [0]
                    text.append(node)
                }
                
                if headOffset > 0 || tailOffset > 0 {
                    text.contents = []
                    text.rawContentIndices = []
                    text.renderContents = []
                    text.renderContentOffsets = []
                }
                
            }
        }
    }
    
    private func sortChildren(node: DropNode) {
        node.children.sort(by: { $0.documentRange.location < $1.documentRange.location })
    }
    
    
    private func createBlockRules() -> [ProcessRule] {
        var rules = createNormalRules()
        rules += [
            .init(DropBulletRule()),
            .init(DropNumberOrderRule()),
            .init(DropLetterOrderRule())
        ]
        return rules
    }
    
    private func createNormalRules() -> [ProcessRule] {
        let tabIndentRule = DropTabIndentRule()
        let spaceIndentRule = DropSpaceIndentRule()
        
        let hashtagRule = DropHashTagRule()
        let mentionRule = DropMentionRule()
        
        let boldRule = DropBoldRule()
        let italicsRule = DropItalicsRule()
        let underlineRule = DropUnderlineRule()
        let highlightRule = DropHighlightRule()
        let strokeRule = DropStrokeRule()
        
        let rules: [ProcessRule] = [
            .init(tabIndentRule), .init(spaceIndentRule),
            .init(hashtagRule), .init(mentionRule),
            .init(boldRule), .init(italicsRule), .init(underlineRule), .init(highlightRule), .init(strokeRule)
        ]
        
        return rules
    }
    
    // MARK: Nodes
    
    private func container(_ type: DropContainerType) -> DropContainerNode {
        let result = DropContainerNode()
        result.type = type
        result.contents = []
        result.rawContentIndices = []
        result.renderContents = []
        result.renderContentOffsets = []
        return result
    }
    
    private func container(_ type: DropContainerType, paragraph: String, range: DropContants.Range, intRange: DropContants.IntRange) -> DropContainerNode {
        
        let result = DropContainerNode()
        result.type = type
        result.contents = [paragraph]
        result.rawContentIndices = [0]
//        result.renderContents = result.contents
//        result.renderContentOffsets = [0]
        result.range = range
        result.intRange = intRange
        #if false
//        print(#function, #line, "get doc content: \(document.raw[result.range])")
        print(#function, #line, "get doc content: \(document.raw[result.exculdeNewlineRange])")
        print(#function, #line, "nsrange: \(result.intRange)), content: \(document.content(in: result.exculdeNewlineIntRange))")
        #endif
        return result
    }
    
    private func content(_ type: DropContentType) -> DropContentNode {
        
        let node = DropContentNode(type: type)
        return node
    }
    
    private func contentMark(_ type: DropContentType) -> DropContentMarkNode {
        
        let node = DropContentMarkNode(type: type, mark: type.mark)
        return node
    }
    
    private func contentMark(_ type: DropContentType, mark: DropContentMarkType) -> DropContentMarkNode {
        
        let node = DropContentMarkNode(type: type, mark: mark)
        return node
    }
    
    // MARK: Render
    
    public func makeAttributedString() -> NSAttributedString {
        fatalError()
    }
    
    public func makeHtmlString() -> String {
        fatalError()
    }
    
    public func makeCommonMarkString() -> String {
        fatalError()
    }
    
    public func makePlainText() -> String {
        fatalError()
    }
    
}

extension Dropper {
    
    public final class ProcessRule: Hashable {
        
        // MARK: Properties
        public let source: DropRule
        public var isWorking: Bool = false
        public var isWorkingDone: Bool = false
        public var openNode: DropContentNode? = nil
        
        public weak var parent: ProcessRule? = nil
        public var children: [ProcessRule] = []
        
        public weak var parentOpenNode: DropNode? = nil
        public weak var parentNode: DropNode? = nil
        
        public var doneChildren: [DropNode] = []
        
        public var haveChildren: Bool {
            children.isEmpty == false
        }
        
        public var haveDoneChildren: Bool {
            doneChildren.isEmpty == false
        }
        
        // MARK: Init
        public init(source: DropRule) {
            self.source = source
        }
        
        public init(_ source: DropRule) {
            self.source = source
        }
        
        // MARK: Clear
        public func clear(isContainsHeadInfo: Bool) {
            source.clear(isContainsHeadInfo: isContainsHeadInfo)
            isWorking = false
            isWorkingDone = false
            parent = nil
            parentOpenNode = nil
            parentNode = nil
            openNode = nil
            children = []
            doneChildren = []
        }
        
        // MARK: Hashable
        public static func == (lhs: ProcessRule, rhs: ProcessRule) -> Bool {
            lhs.source == rhs.source &&
            lhs.isWorking == rhs.isWorking &&
            lhs.isWorkingDone == rhs.isWorkingDone &&
            lhs.openNode == rhs.openNode &&
            lhs.parent === rhs.parent &&
            lhs.children == rhs.children
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(source)
            hasher.combine(isWorking)
            hasher.combine(isWorkingDone)
            hasher.combine(children)
        }
        
    }
    
}

