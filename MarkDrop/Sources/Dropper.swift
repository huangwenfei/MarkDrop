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
        
        let containerRules = rules.isEmpty
            ? createBlockRules()
            : rules.map({
                  $0.document = document
                  return .init($0)
              })
        
        var intOffset = 0
        
        var lineOffset: Int = 0

        for paragraph in paragraphs {
            
            /// - Tag: Clear
            containerRules.forEach({
                $0.clear(isContainsHeadInfo: true)
            })
            
            /// - Tag: Node
            let count = paragraph.count
            
            let intRange: DropContants.IntRange = .init(
                location: intOffset, length: count
            )
            
            let paragraphNode = self.container(
                .break,
                paragraph: paragraph,
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
                
            case .block(let child):
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
                
                switch child {
                case .bulletList:      paragraphNode.paragraphType = .bulletList
                case .numberOrderList: paragraphNode.paragraphType = .numberOrderList
                case .letterOrderList: paragraphNode.paragraphType = .letterOrderList
                }
                
            case .paragraph, .break:
                paragraphNode.type = containerType
                paragraphNode.paragraphType = containerType == .paragraph ? .text : .break
                tree.addChild(paragraphNode)
            }
            
            /// - Tag: Increase
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
        
        var previousUnicodes: String? = nil
        
        for unicode in paragraph.rawContent {
            
//            print(unicode)
            
            // MARK: Batch judge
            var dones:   [ProcessRule] = []
            var cancles: [ProcessRule] = []
            var opens:   [ProcessRule] = []
            
            let isParagraphFirstChar = (intOffset == 0)
            let isParagraphEndChar = (intOffset == paragraph.rawContent.count - 1)
            
            rules.forEach({
                $0.source.append(
                    content: unicode,
                    previousContent: previousUnicodes,
                    offset: paragraph.intRange.location + intOffset,
                    isParagraphFirstChar: isParagraphFirstChar,
                    isParagraphEndChar: isParagraphEndChar,
                    isDocFirstChar: paragraph.isLastLine && isParagraphFirstChar,
                    isDocEndChar: paragraph.isLastLine && isParagraphEndChar
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
                    currentNode.intRange = .init(location: intOffset, length: 0)
                    
                    rule.parent = currentOpen
                    rule.openNode = currentNode
                    openRules.append(rule)
                    rule.parent?.children.append(rule)
                    
//                    print(#function, #line, currentNode.intRange, currentNode.contents)
                    
                } else {
                    
                    let currentNode = self.content(rule.source.type)
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
                    node.intRange = {
                        var result = rule.source.contentRange
                        result.location -= paragraph.intRange.location
                        return result
                    }()
                    node.documentRange = rule.source.contentRange
                    
                    let markNode = self.contentMark(rule.source.type, mark: .text)
                    markNode.contents = node.contents
                    markNode.rawContentIndices = node.rawContentIndices
                    markNode.renderContents = node.renderContents
                    markNode.intRange = node.intRange
                    markNode.documentRange = node.documentRange
                    node.append(markNode)
                    
//                    print(#function, #line, "mark", paragraph.rawContent[markNode.range])
                    
                    addToParent(rule: rule, currentOpen: node, in: paragraph)
                    
                    upChildParent(rule: rule, currentOpen: node, in: dones)
                    
//                    print(#function, #line, node.intRange, node.contents, "parent: ", node.parentNode ?? "None Parent")
                    
                    adjustmentChildParent(currentOpen: node)
                    
                    /// total content as special text content node
                    markTexts.append(markNode)
                    
                    /// total content as special mark to split real text content nodes
                    marks.append(markNode)
                    
                } else {
                    
                    /// always true
                    if let currentOpen = rule.openNode {
                        
                        currentOpen.contents = rule.source.rawContents
                        currentOpen.rawContentIndices = rule.source.contentIndices
                        currentOpen.renderContents = rule.source.contents
                        currentOpen.intRange = {
                            var result = rule.source.contentRange
                            result.location -= paragraph.intRange.location
                            return result
                        }()
                        currentOpen.documentRange = rule.source.contentRange
                        
                        if currentOpen.renderContents.count <= 1 {
                            
                            let markNode = self.contentMark(rule.source.type, mark: .text)
                            markNode.contents = currentOpen.contents
                            markNode.rawContentIndices = currentOpen.rawContentIndices
                            markNode.renderContents = currentOpen.renderContents
                            markNode.intRange = currentOpen.intRange
                            markNode.documentRange = currentOpen.documentRange
                            currentOpen.append(markNode)
                            
                            /// total content as special text content node
                            markTexts.append(markNode)
                            
                            /// total content as special mark to split real text content nodes
                            marks.append(markNode)
                            
                        } else {
                            
                            var markIntOffset = currentOpen.intRange.location
                            
                            let loopContents = zip(
                                currentOpen.contents,
                                zip(currentOpen.renderContents, rule.source.rawContentRanges)
                            )
                            
                            for (index, (content, (renderContent, contentRange))) in loopContents.enumerated() {
                                
                                let count = content.count
                                
                                let markNode = self.contentMark(
                                    rule.source.type,
                                    mark: currentOpen.rawContentIndices.contains(index) ? .text : rule.source.type.mark
                                )
                                
                                markNode.contents = [content]
                                markNode.rawContentIndices = [0] /// [index]
                                markNode.renderContents = [renderContent]
                                markNode.intRange = {
                                    var result = contentRange
                                    result.location -= paragraph.intRange.location
                                    return result
                                }()
                                markNode.documentRange = contentRange
                                currentOpen.append(markNode)
                                
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
                        
                        adjustmentChildParent(currentOpen: currentOpen)
                        
                    }
                    
                }
                
                openRules.removeAll(where: { $0 === rule })
                
                rule.isWorkingDone = true

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
        let paragraphChildren = paragraph.children.sorted(by: {
            $0.intRange.location < $1.intRange.location
        })
        
        var newChildren: [DropNode] = []
        var currentLocation: Int = 0
        for child in paragraphChildren {
            
            let contentOffset = child.intRange.location - currentLocation
            
            if contentOffset > 0 {
                let text = self.content(.text)
                text.intRange = .init(location: currentLocation, length: contentOffset)
                text.documentRange = .init(
                    location: text.intRange.location + paragraph.intRange.location,
                    length: text.intRange.length
                )
                text.contents = [document.content(in: text.documentRange)]
                text.rawContentIndices = [0]
                text.renderContents = text.contents
                text.parentNode = paragraph
                newChildren.append(text)
            }
            
            currentLocation = child.intRange.maxLocation
            newChildren.append(child)
        }
        
        /// the last text node
        if
            let last = newChildren.last,
            last.intRange.maxLocation < paragraph.rawContent.count
        {
            let text = self.content(.text)
            let intStart = last.intRange.maxLocation
            text.intRange = .init(location: intStart, length: paragraph.rawContent.count - intStart)
            text.documentRange = .init(
                location: text.intRange.location + paragraph.intRange.location,
                length: text.intRange.length
            )
            text.contents = [document.content(in: text.documentRange)]
            text.rawContentIndices = [0]
            text.renderContents = text.contents
            text.parentNode = paragraph
            newChildren.append(text)
        }
        
        paragraph.children = newChildren
        
        /// - Tag: text paragraph
        if paragraph.haveChildren == false, paragraph.rawContent.isEmpty == false {
            let text = self.content(.text)
            text.intRange = .init(location: 0, length: paragraph.rawContent.count)
            text.documentRange = .init(
                location: text.intRange.location + paragraph.intRange.location,
                length: text.intRange.length
            )
            text.contents = [document.content(in: text.documentRange)]
            text.rawContentIndices = [0]
            text.renderContents = text.contents
            text.parentNode = paragraph
            paragraph.children = [text]
        }
        
        /// - Tag: Split Texts
        var markNodes = markTexts
        marks.sort(by: { $0.intRange.location < $1.intRange.location })
        
        while let text = markNodes.popLast() {
            
//            print()
//            print((#file as NSString).lastPathComponent, #function.split(separator: "(").first!, #line, "before", text.rawContent)
            
            var splitMarks: [DropContentMarkNode] = []
            
            for mark in marks {
                guard
                    text !== mark,
                    text.rawContent.isEmpty == false,
                    mark.intRange.location >= text.intRange.location,
                    mark.intRange.maxLocation <= text.intRange.maxLocation
                else {
                    continue
                }
                
                splitMarks.append(mark)
            }
            
            guard splitMarks.isEmpty == false else {
                continue
            }
            
//            print((#file as NSString).lastPathComponent, #function.split(separator: "(").first!, #line, "marks", splitMarks.map({ ($0.rawContent, $0.intRange) }))
            
            var currentRange = text.intRange
            
            for mark in splitMarks {
                
                let contentOffset = mark.intRange.location - currentRange.location
                
                if contentOffset > 0 {
                    let node = self.contentMark(text.type, mark: .text)
                    let intStart = currentRange.location
                    node.intRange = .init(location: intStart, length: contentOffset)
                    node.documentRange = .init(
                        location: paragraph.intRange.location + node.intRange.location,
                        length: node.intRange.length
                    )
                    node.contents = [document.content(in: node.documentRange)]
                    node.rawContentIndices = [0]
                    node.renderContents = node.contents
                    text.append(node)
                }
                
                currentRange.location = mark.intRange.maxLocation
                
            }
            
            /// the last content text
            let theLast = splitMarks.last!.intRange.vaildMaxLocation
            let contentOffset = text.intRange.vaildMaxLocation - theLast
            
            if contentOffset > 0 {
                let node = self.contentMark(text.type, mark: .text)
                node.intRange = .init(
                    location: splitMarks.last!.intRange.maxLocation,
                    length: contentOffset
                )
                node.documentRange = .init(
                    location: paragraph.intRange.location + node.intRange.location,
                    length: node.intRange.length
                )
                node.contents = [document.content(in: node.documentRange)]
                node.rawContentIndices = [0]
                node.renderContents = node.contents
                text.append(node)
            }
            
//            print((#file as NSString).lastPathComponent, #function.split(separator: "(").first!, #line, "after", text.leaves.map({ $0.rawContent }))
//            print()
            
            text.contents = []
            text.rawContentIndices = []
            text.renderContents = []
            
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
        return result
    }
    
    private func container(_ type: DropContainerType, paragraph: String, intRange: DropContants.IntRange) -> DropContainerNode {
        
        let result = DropContainerNode()
        result.type = type
        result.contents = [paragraph]
        result.rawContentIndices = [0]
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

