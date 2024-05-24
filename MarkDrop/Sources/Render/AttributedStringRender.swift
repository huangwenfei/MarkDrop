//
//  AttributedStringRender.swift
//  MarkDrop
//
//  Created by windy on 2024/5/3.
//

import Foundation

public final class AttributedStringRender: DropRendable {
    
    // MARK: Types
    public typealias Result = NSAttributedString
    public typealias AttributedDict = DropContants.AttributedDict
    
    // MARK: Properties
    public var document: Document
    public var rules: [DropRule]
    
    private var renderAST: DropTree? = nil
    private var attributes: DropAttributes? = nil
    private var mapping: DropAttributedMapping? = nil
    
    // MARK: Init
    public init(string: String, using rules: [DropRule]) {
        self.document = .init(raw: string)
        self.rules = rules
    }
    
    // MARK: Render
    public func render() -> Result {
        render(with: DropAttributes(), mapping: DropDefaultAttributedMapping())
    }
    
    public func render(with attributes: DropAttributes, mapping: DropAttributedMapping) -> Result {
        
        /// - Tag: Mapping
        self.attributes = attributes
        self.mapping = mapping
        
        /// - Tag: AST
        let ast = Dropper(document: document).process(using: rules)
        self.renderAST = ast

        return rerender(attributes: attributes, mapping: mapping)
    }
    
    private func render(docOffset: inout Int, block multiParagraphs: [DropContainerNode], isLastLine: Bool, base: ParagraphTextAttributes, with attributes: DropAttributes, mapping: DropAttributedMapping) -> Result {
        
        let result = NSMutableAttributedString()
        
        var stack = Array(multiParagraphs.reversed())
        
        while let child = stack.popLast() {
            
            let paragraphText: NSAttributedString
            
            switch child.type {
            case .document:
                paragraphText = .init(string: "")
                
            case .block(let type):
                
                let base: ParagraphTextAttributes
                switch type {
                case .bulletList:      base = attributes.bulletList.paragraphText
                case .numberOrderList: base = attributes.numberOrderList.paragraphText
                case .letterOrderList: base = attributes.letterOrderList.paragraphText
                }
                
                // TODO: 不用递归
                paragraphText = render(
                    docOffset: &docOffset,
                    block: child.containers(),
                    isLastLine: child.isLastLine,
                    base: base,
                    with: attributes,
                    mapping: mapping
                )
                
            case .paragraph:
                paragraphText = render(
                    docOffset: &docOffset,
                    paragraph: child,
                    base: base,
                    with: attributes,
                    mapping: mapping
                )
                
            case .break:
                paragraphText = render(
                    docOffset: &docOffset,
                    break: child,
                    base: base,
                    with: attributes,
                    mapping: mapping
                )
            }
            
            result.append(paragraphText)
            
        }
        
        return result
    }
    
    private func render(docOffset: inout Int, paragraph: DropContainerNode, base: ParagraphTextAttributes, with attributes: DropAttributes, mapping: DropAttributedMapping) -> Result {
        
        render(
            docOffset: &docOffset,
            paragraph: paragraph,
            isBreak: false,
            base: base,
            with: attributes,
            mapping: mapping
        )
    }
    
    private func render(docOffset: inout Int, break paragraph: DropContainerNode, base: ParagraphTextAttributes, with attributes: DropAttributes, mapping: DropAttributedMapping) -> Result {
        
        render(
            docOffset: &docOffset,
            paragraph: paragraph,
            isBreak: true,
            base: base,
            with: attributes,
            mapping: mapping
        )
    }
    
    private func render(docOffset: inout Int, paragraph: DropContainerNode, isBreak: Bool, base: ParagraphTextAttributes, with attributes: DropAttributes, mapping: DropAttributedMapping) -> Result {
        
        /// - Tag: Render Dict
        var paragraphRenderDict: [DropContants.IntRange: RenderElement] = .init()
        
        /// - Tag: Contents
        var offset: Int = 0
        
        var indentList: [DropParagraphIndent] = []
        
        var renderMarkAttributes: [RenderMarkAttributes] = []

        var contentRenders: [RenderContentSpecial] = .init()
        
//        var expandRenders: [RenderActionMark] = []
//        var actionRenders: [RenderActionMark] = []
        
        let sortedLeaves = paragraph.leaves
            .sorted(by: { $0.intRange.location < $1.intRange.location })
        
        var paragraphContent: NSMutableAttributedString = .init(string: "")
        
        for leave in sortedLeaves {
            
            paragraphContent.beginEditing()
            
            let string = leave.rawRenderContent
            
            guard leave.rawRenderContent.isEmpty == false else {
                continue
            }
            
            let result = append(
                renderMarkAttributes: renderMarkAttributes,
                current: paragraphContent,
                textNode: leave,
                base: base,
                attributes: attributes,
                mapping: mapping,
                with: &indentList
            )
            
            var mappingResult           = result.mappingResult
            let shouldAppendContent     = result.shouldAppendContent
            let isUsingParentAttributes = result.isUsingParentAttributes
            
            guard shouldAppendContent else {
                continue
            }
            
            let renderRange: DropContants.IntRange
            
            if let element = paragraphRenderDict[leave.intRange] {
                
                combine(
                    oldAttributes: element.bindMappingResult,
                    in: &mappingResult,
                    mapping: mapping,
                    with: paragraphContent,
                    in: element.renderRange
                )
                
                element.bindMappingResult = mappingResult
                
                renderRange = element.renderRange
                
            } else {
                
                let attributedString = NSAttributedString(string: string, attributes: mappingResult)
                paragraphContent.append(attributedString)
                
                renderRange = DropContants.IntRange(
                    location: offset,
                    length: attributedString.length /// min(0, attributedString.length - 1)
                )
                paragraphRenderDict[leave.intRange] = .init(
                    renderRange: renderRange, bindMappingResult: mappingResult
                )
                
                offset += attributedString.length
                
            }
            
            if
                let content = leave as? DropContentNodeProtocol,
                let renderType = content.type.render
            {
                renderMarkAttributes.append(
                    .init(
                        type: renderType,
                        intRange: content.intRange,
                        mappingResult: mappingResult
                    )
                )
            }
            
            /// - Tag: Capture Expands & Actions
            captureExpandsAndActions(
                contentRenders: &contentRenders,
                leave: leave,
                attributes: attributes,
                isUsingParentAttributes: isUsingParentAttributes,
                renderRange: renderRange,
                content: string,
                mappingResult: mappingResult
            )
            
            paragraphContent.endEditing()
        }
        
        /// - Tag: Combine Content
        let combineContentRenders = combineExpandActions(
            contentRenders: contentRenders,
            attributes: attributes,
            paragraphContent: paragraphContent
        )
        
        /// - Tag: Compact Content
        let compactContentRenders = compactExpandActions(
            combineContentRenders: combineContentRenders,
            paragraphContent: paragraphContent
        )
        
        /// - Tag: Replace Content
        replaceExpandActionContents(
            compactContentRenders: compactContentRenders,
            base: base,
            attributes: attributes,
            mapping: mapping,
            paragraphContent: &paragraphContent
        )
        
        /// - Tag: Empty line
        if isBreak, paragraphContent.string.isEmpty {
            paragraphContent = NSMutableAttributedString(string: "\n")
        }
        
        /// - Tag: Paragraph
        append(
            paragraph: base.paragraph,
            mapping: mapping,
            in: &paragraphContent,
            with: indentList
        )
        
        /// - Tag: Increase
        docOffset += offset
        
        /// - Tag: Clear
        paragraphRenderDict = .init()
        
        return paragraphContent
    }
    
    // MARK: Rerender
    public func rerender(ast rules: [DropRule]) {
        self.rules = rules
        
        let ast = Dropper(document: document).process(using: rules)
        self.renderAST = ast
    }
    
    public func rerender(using attributes: DropAttributes) -> Result {
        guard let mapping = mapping else {
            return .init(string: "")
        }
        
        return rerender(attributes: attributes, mapping: mapping)
    }
    
    public func rerender(using mapping: DropAttributedMapping) -> Result {
        guard let attributes = attributes else {
            return .init(string: "")
        }
        
        return rerender(attributes: attributes, mapping: mapping)
    }
    
    public func rerender(attributes: DropAttributes, mapping: DropAttributedMapping) -> Result {
        guard let ast = renderAST else {
            return .init(string: "")
        }
        
        self.attributes = attributes
        self.mapping = mapping
        
        /// - Tag: Render
        var docOffset: Int = 0
        
        return render(
            docOffset: &docOffset,
            block: ast.containers(),
            isLastLine: false,
            base: attributes.paragraphText,
            with: attributes,
            mapping: mapping
        )
    }
    
    // MARK: Attributes
    private func append(paragraph: ParagraphAttributes, mapping: DropAttributedMapping, in content: inout NSMutableAttributedString, with indentList: [DropParagraphIndent]) {
        
        /// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/TextAttributes/ChangingAttrStrings.html#//apple_ref/doc/uid/20000162-BBCBGCDG
        /// Paragraph styles must apply to entire paragraphs.
        mapping.append(
            paragraph: paragraph,
            in: &content,
            with: indentList
        )
    }
    
    private func combine(oldAttributes: DropContants.AttributedDict, in attributed: inout DropContants.AttributedDict, mapping: DropAttributedMapping, with content: NSMutableAttributedString, in renderRange: DropContants.IntRange) {
        
        mapping.combine(
            oldAttributes: oldAttributes,
            in: &attributed
        )
        
        content.addAttributes(attributed, range: renderRange)
        
    }
    
    private func append(renderMarkAttributes: [RenderMarkAttributes], current: NSMutableAttributedString, textNode node: DropNode, base: ParagraphTextAttributes, attributes: DropAttributes, mapping: DropAttributedMapping, with indentList: inout [DropParagraphIndent]) -> AppendAttributesResult {
        
        if
            let textNode = node as? DropContentNode,
            textNode.type == .text
        {
            let mappingResult = mapping.mapping(text: base.text, type: .text, content: textNode.rawRenderContent, in: attributes.paragraph)
            return .init(mappingResult: mappingResult, shouldAppendContent: true, isUsingParentAttributes: false)
        }
        
        guard let markNode = node as? DropContentMarkNode else {
            return .init(mappingResult: .init(), shouldAppendContent: true, isUsingParentAttributes: false)
        }
        
        var mappingResult: DropContants.AttributedDict = .init()
        var shouldAppendContent: Bool = true
        var isUsingParentAttributes: Bool = true
        
        /// - Tag: Current
        
        func fillNewDict() {
            
            if
                let type = markNode.type.render,
                let previousMappingResult = renderMarkAttributes.last(where: { $0.type == type })?.mappingResult
            {
                
                mappingResult = previousMappingResult
                
            } else {
                
                self.attributeDict(
                    current: current,
                    shouldAppendContent: &shouldAppendContent,
                    type: markNode.type,
                    textNode: node,
                    base: base,
                    attributes: attributes,
                    mapping: mapping,
                    in: &mappingResult,
                    with: &indentList
                )
                
                isUsingParentAttributes = false
                
            }
        }
        
        if
            let _ = markNode.type.render,
            markNode.parentContainerRenderTypes.filter({
                attributes.markAttributes($0).isFillChildAttributes
            })
            .isEmpty == false
        {
            
            let parentAttributes = renderMarkAttributes.last

            if let previousMappingResult = parentAttributes?.mappingResult {
                mappingResult = previousMappingResult
            } else {
                fillNewDict()
            }
            
        } else {
            
            fillNewDict()
            
        }
        
        /// - Tag: Combine Parent If can
        
        for type in markNode.parentContainerRenderTypes {
            
            if attributes.markAttributes(type).isFillChildAttributes {
                
                let parentAttributes = renderMarkAttributes.last(where: { $0.type == type })
                
                if let previousMappingResult = parentAttributes?.mappingResult {
                    switch attributes.markAttributes(type).fillChildMode {
                    case .none: break
                    case .fill: mappingResult = previousMappingResult
                    case .fillIgnoreFont:
                        let fontValues = previousMappingResult.filter({ $0.value is DropFont })
                        if let fontKey = fontValues.first?.key {
                            
                            fillCombine(
                                fontKey: fontKey,
                                using: previousMappingResult,
                                in: &mappingResult
                            )
                            
                            isUsingParentAttributes = dictEqual(
                                lhs: previousMappingResult, rhs: mappingResult
                            )
                            
                        } else {
                            mappingResult = previousMappingResult
                        }
                    }
                }
                
            } else {
                
                func mappingIt(text: TextAttributes, type: DropAttributeType) -> DropContants.AttributedDict {
                    mapping.mapping(
                        text: text,
                        type: type,
                        content: node.rawRenderContent,
                        in: base.paragraph
                    )
                }
                
                let previousMappingResult: DropContants.AttributedDict
                switch type {
                case .hashTag:   previousMappingResult = mappingIt(text: attributes.hashTag, type: .hashTag)
                case .mention:   previousMappingResult = mappingIt(text: attributes.mention, type: .mention)
                case .bold:      previousMappingResult = mappingIt(text: attributes.bold, type: .bold)
                case .italics:   previousMappingResult = mappingIt(text: attributes.italics, type: .italics)
                case .underline: previousMappingResult = mappingIt(text: attributes.underline, type: .underline)
                case .highlight: previousMappingResult = mappingIt(text: attributes.highlight, type: .highlight)
                case .stroke:    previousMappingResult = mappingIt(text: attributes.stroke, type: .stroke)
                }
                
                mapping.combine(
                    oldAttributes: previousMappingResult,
                    in: &mappingResult
                )
                
                isUsingParentAttributes = dictEqual(lhs: previousMappingResult, rhs: mappingResult)
                
            }
            
        }
        
        return .init(
            mappingResult: mappingResult,
            shouldAppendContent: shouldAppendContent,
            isUsingParentAttributes: isUsingParentAttributes
        )
    }
    
    private func attributeDict(current: NSMutableAttributedString, shouldAppendContent: inout Bool, type: DropContentType, textNode node: DropNode, base: ParagraphTextAttributes, attributes: DropAttributes, mapping: DropAttributedMapping, in mappingResult: inout DropContants.AttributedDict, with indentList: inout [DropParagraphIndent]) {
        
        func mappingIt(text: TextAttributes, type: DropAttributeType) -> DropContants.AttributedDict {
            mapping.mapping(
                text: text,
                type: type,
                content: node.rawRenderContent,
                in: base.paragraph
            )
        }
        
        switch type {
        case .text:            mappingResult = mappingIt(text: base.text, type: .text)
        case .hashTag:         mappingResult = mappingIt(text: attributes.hashTag, type: .hashTag)
        case .mention:         mappingResult = mappingIt(text: attributes.mention, type: .mention)
        case .bold:            mappingResult = mappingIt(text: attributes.bold, type: .bold)
        case .italics:         mappingResult = mappingIt(text: attributes.italics, type: .italics)
        case .underline:       mappingResult = mappingIt(text: attributes.underline, type: .underline)
        case .highlight:       mappingResult = mappingIt(text: attributes.highlight, type: .highlight)
        case .stroke:          mappingResult = mappingIt(text: attributes.stroke, type: .stroke)
            
        case .bulletList:
            mappingResult = mappingIt(text: attributes.bulletList.mark, type: .text)
            fillIndentList(
                indentList: &indentList,
                in: node,
                attributes: mappingResult,
                mode: .tabStop
            )
            
        case .numberOrderList: 
            mappingResult = mappingIt(text: attributes.numberOrderList.mark, type: .text)
            fillIndentList(
                indentList: &indentList,
                in: node,
                attributes: mappingResult,
                mode: .tabStop
            )
            
        case .letterOrderList: 
            mappingResult = mappingIt(text: attributes.letterOrderList.mark, type: .text)
            fillIndentList(
                indentList: &indentList,
                in: node,
                attributes: mappingResult,
                mode: .tabStop
            )
            
        case .tabIndent:
            
            let mappingResult = mappingIt(text: attributes.tabIndent, type: .text)
            
            /// 只让段首的 fillIndentList
            guard current.string.isEmpty else {
                break
            }
            
            fillIndentList(
                indentList: &indentList,
                in: node,
                attributes: mappingResult,
                mode: .firstHeadIndent
            )
            
            shouldAppendContent = false
            
        case .spaceIndent:
            
            let mappingResult = mappingIt(text: attributes.spaceIndent, type: .text)
            
            /// 只让段首的 fillIndentList
            guard current.string.isEmpty else {
                break
            }
            
            fillIndentList(
                indentList: &indentList,
                in: node,
                attributes: mappingResult,
                mode: .firstHeadIndent
            )
            
            shouldAppendContent = false
        }
        
    }
    
    private func fillCombine(fontKey: DropContants.AttributedDict.Key, using oldAttributes: DropContants.AttributedDict, in attributed: inout DropContants.AttributedDict) {
        
        let font = oldAttributes[fontKey] as? DropFont
        let newFont = attributed[fontKey] as? DropFont
        
        attributed = oldAttributes
        
        if var font, let newFont {
            if newFont.isBold      { font = font.bold }
            if newFont.isItalic    { font = font.italic }
            if newFont.isMonoSpace { font = font.monoSpace }
            attributed[fontKey] = font
        }
    }
    
    private func fillIndentList(indentList: inout [DropParagraphIndent], in node: DropNode, attributes: DropContants.AttributedDict, mode: DropParagraphIndentMode) {
        
        let content = node.rawRenderContent
        let width = NSAttributedString(string: content, attributes: attributes).size().width
        indentList.append(.init(indentation: width, mode: mode))
        
    }
    
    // MARK: Expand & Actions
    private func captureExpandsAndActions(contentRenders: inout [RenderContentSpecial], leave: DropNode, attributes: DropAttributes, isUsingParentAttributes: Bool, renderRange: DropContants.IntRange, content string: String, mappingResult: DropContants.AttributedDict) {
        
        if
            let content = leave as? DropContentNodeProtocol,
            let renderType = content.type.render
        {
            
            let isExpand = attributes.markAttributes(renderType).shouldExpandContent
            let isAction = attributes.markAttributes(renderType).action != nil
            
            let mode: RenderContentSpecialMode?
            
            switch (isExpand, isAction) {
            case (false, false): mode = nil
            case (true, false): mode = .expand
            case (false, true): mode = .action
            case (true, true): mode = .both
            }
            
            if let mode {
                contentRenders.append(.init(
                    mode: mode,
                    isUsingParentAttributes: isUsingParentAttributes,
                    renderType: renderType,
                    markNode: content,
                    range: renderRange,
                    content: string,
                    mappingResult: mappingResult
                ))
                contentRenders.sort(by: { $0.range.location < $1.range.location })
            }
            
        }
        
    }
    
    private func combineExpandActions(contentRenders: [RenderContentSpecial], attributes: DropAttributes, paragraphContent: NSAttributedString) -> [[RenderContentSpecial]] {
        
        var combineContentRenders: [[RenderContentSpecial]] = []
        
        for contentRender in contentRenders {
            
            if contentRender.isUsingParentAttributes {
                let theLast = combineContentRenders.count - 1
                if combineContentRenders.indices.contains(theLast) {
                    if
                        let last = combineContentRenders[theLast].last,
                        contentRender.markNode.parentContainerRenderTypes.contains(last.renderType),
                        attributes.markAttributes(last.renderType).isFillChildAttributes
                    {
                        combineContentRenders[theLast].append(contentRender)
                    } else {
                        if
                            combineContentRenders[theLast].contains(where: {
                                $0.renderType == contentRender.renderType
                            })
                        {
                            combineContentRenders[theLast].append(contentRender)
                        } else {
                            combineContentRenders.append([contentRender])
                        }
                    }
                } else {
                    combineContentRenders.append([contentRender])
                }
            } else {
                let theLast = combineContentRenders.count - 1
                if
                    combineContentRenders.indices.contains(theLast),
                    combineContentRenders[theLast].contains(where: {
                        $0.renderType == contentRender.renderType
                    })
                {
                    combineContentRenders[theLast].append(contentRender)
                } else {
                    combineContentRenders.append([contentRender])
                }
            }
            
        }
        
        print(
            #function, #line,
            contentRenders.map({
                ($0.mode, paragraphContent.attributedSubstring(from: $0.range).string)
            })
        )
        print(
            #function, #line,
            combineContentRenders.map({
                $0.map({
                    ($0.mode, paragraphContent.attributedSubstring(from: $0.range).string)
                })
            })
        )
        
        return combineContentRenders
    }
    
    private func compactExpandActions(combineContentRenders: [[RenderContentSpecial]], paragraphContent: NSAttributedString) -> [RenderContentSpecial] {
        
        var compactContentRenders: [RenderContentSpecial] = []
        
        var previousCompactRender: RenderContentSpecial? = nil
        
        for combineContentRender in combineContentRenders {
            
            guard combineContentRender.isEmpty == false else {
                continue
            }
            
            /// 同位 (range) 重合压缩
            var subCompactDict: [DropContants.IntRange: RenderContentSpecial] = .init()
            combineContentRender.forEach({
                subCompactDict[$0.range] = $0
            })
            
            print(
                #function, #line,
                Array(subCompactDict.values).sorted(by: {
                    $0.range.location < $1.range.location
                }).map({
                    ($0.mode, paragraphContent.attributedSubstring(from: $0.range).string)
                })
            )
            
            /// 内连接，连接(相邻)合并压缩
            let subCompacts = Array(subCompactDict.values).sorted(by: {
                $0.range.location < $1.range.location
            })

            var compact: RenderContentSpecial? = subCompacts.first

            for index in stride(from: 1, to: subCompacts.count, by: 1) {

                let render = subCompacts[index]

                compact?.range.length += render.range.length
                compact?.content += render.content

                compact?.mappingResult.merge(
                    render.mappingResult, uniquingKeysWith: { current,_ in current }
                )

            }

            print(#function, #line, compactContentRenders.count)

            print(
                #function, #line,
                (compact!.mode, compact!.range, paragraphContent.attributedSubstring(from: compact!.range).string)
            )
            
            /// 前置交叠/连接压缩
            if let previous = previousCompactRender, let current = compact {
                
                /// 交叠压缩
                if previous.range.vaildMaxLocation >= current.range.location {
                    
                    var newPrevious = previous
                    
                    let offset = current.range.vaildMaxLocation - previous.range.vaildMaxLocation
                    
                    newPrevious.range.length += offset
                    
                    newPrevious.content = paragraphContent.attributedSubstring(
                        from: newPrevious.range
                    ).string
                    
                    /// current or previous ???
                    newPrevious.mappingResult.merge(
                        current.mappingResult, uniquingKeysWith: { current,_ in current }
                    )
                    
                    compactContentRenders[compactContentRenders.count - 1] = newPrevious
                    
                    compact = newPrevious
                }
                /// 连接(相邻)合并压缩
                else if previous.range.maxLocation == current.range.location {
                    
                    var newPrevious = previous
                    
                    newPrevious.range.length += current.range.length
                    
                    newPrevious.content = paragraphContent.attributedSubstring(
                        from: newPrevious.range
                    ).string
                    
                    newPrevious.mappingResult.merge(
                        current.mappingResult, uniquingKeysWith: { current,_ in current }
                    )
                    
                    compactContentRenders[compactContentRenders.count - 1] = newPrevious
                    
                    compact = newPrevious
                }
                else {
                    compactContentRenders.append(current)
                }
            } else {
                if let compact {
                    compactContentRenders.append(compact)
                }
            }
            
            print(#function, #line, compactContentRenders.count)
            
            previousCompactRender = compact
            
        }
        
        print(
            #function, #line,
            compactContentRenders.map({
                ($0.mode, $0.content, $0.range, paragraphContent.attributedSubstring(from: $0.range).string)
            })
        )
        
        return compactContentRenders
    }
    
    private func replaceExpandActionContents(compactContentRenders: [RenderContentSpecial], base: ParagraphTextAttributes, attributes: DropAttributes, mapping: DropAttributedMapping, paragraphContent: inout NSMutableAttributedString) {
        
        var compactOffset: Int = 0
        
        for render in compactContentRenders {
            
            var replaceRange = render.range
            replaceRange.location += compactOffset
            
            switch render.mode {
            case .expand:
                guard let expand = mapping.mapping(
                    expand: attributes.markAttributes(render.renderType),
                    content: .init(string: render.content, attributes: render.mappingResult),
                    renderRange: render.range,
                    in: base.paragraph
                )
                else {
                    continue
                }
                
                paragraphContent.replaceCharacters(in: replaceRange, with: expand.content)
                
                compactOffset += expand.content.length - render.content.count
                
            case .action:
                let attributed = attributes.markAttributes(render.renderType)
                guard let action = mapping.mapping(
                    action: attributed.action!,
                    text: attributed,
                    content: .init(string: render.content, attributes: render.mappingResult),
                    renderRange: render.range,
                    in: base.paragraph
                )
                else {
                    continue
                }
                
                paragraphContent.replaceCharacters(in: replaceRange, with: action.content)
                
                compactOffset += action.content.length - render.content.count
                
            case .both:
                let attributed = attributes.markAttributes(render.renderType)
                
                guard
                    let expand = mapping.mapping(
                        expand: attributed,
                        content: .init(string: render.content, attributes: render.mappingResult),
                        renderRange: render.range,
                        in: base.paragraph
                    ),
                    let action = mapping.mapping(
                        action: attributed.action!,
                        text: attributed,
                        content: .init(string: render.content, attributes: render.mappingResult),
                        renderRange: render.range,
                        in: base.paragraph
                    )
                else {
                    continue
                }
                
                let result = mapping.mappingConflict(expand: expand, action: action)
                paragraphContent.replaceCharacters(in: replaceRange, with: result.content)
                
                compactOffset += result.content.length - render.content.count
            }
            
        }
        
    }
    
}

extension AttributedStringRender {
    
    final class RenderElement {
        
        // MARK: Properties
        var renderRange: DropContants.IntRange
        var bindMappingResult: DropContants.AttributedDict
        
        // MARK: Init
        init(renderRange: DropContants.IntRange, bindMappingResult: DropContants.AttributedDict) {
            self.renderRange = renderRange
            self.bindMappingResult = bindMappingResult
        }
        
    }
    
    struct RenderMarkAttributes {
        
        // MARK: Properties
        public var type: DropRenderMarkType
        public var intRange: DropContants.IntRange
        public var mappingResult: DropContants.AttributedDict
        
        // MARK: Init
        public init(type: DropRenderMarkType, intRange: DropContants.IntRange, mappingResult: DropContants.AttributedDict) {
            self.type = type
            self.intRange = intRange
            self.mappingResult = mappingResult
        }
        
    }
    
    struct RenderActionMark {
        
        // MARK: Properties
        public var type: DropRenderMarkType
        public var parentTypes: [DropRenderMarkType]
        public var intRange: DropContants.IntRange
        
        public var newRange: DropContants.IntRange = .init()
        public var content: NSAttributedString = .init()
        
        public var date: Date = .init()
        
        // MARK: Init
        public init(type: DropRenderMarkType, parentTypes: [DropRenderMarkType], intRange: DropContants.IntRange) {
            self.type = type
            self.parentTypes = parentTypes
            self.intRange = intRange
        }
        
    }
    
    struct RenderActionMiniMark {
        
        // MARK: Properties
        
        public var intRange: DropContants.IntRange
        public var content: NSAttributedString
        
        // MARK: Init
        public init(intRange: DropContants.IntRange, content: NSAttributedString) {
            self.intRange = intRange
            self.content = content
        }
        
    }
    
    enum RenderContentSpecialMode: Int {
        case expand, action, both
    }
    
    struct RenderContentSpecial {
        
        // MARK: Properties
        public var mode: RenderContentSpecialMode
        public var isUsingParentAttributes: Bool
        public var renderType: DropRenderMarkType
        public var markNode: DropContentNodeProtocol
        public var range: DropContants.IntRange
        public var content: String
        public var mappingResult: DropContants.AttributedDict
        
        // MARK: Init
        public init(
            mode: RenderContentSpecialMode,
            isUsingParentAttributes: Bool,
            renderType: DropRenderMarkType,
            markNode: DropContentNodeProtocol,
            range: DropContants.IntRange,
            content: String,
            mappingResult: DropContants.AttributedDict
        ) {
            self.mode = mode
            self.isUsingParentAttributes = isUsingParentAttributes
            self.renderType = renderType
            self.markNode = markNode
            self.range = range
            self.content = content
            self.mappingResult = mappingResult
        }
        
    }
    
    struct AppendAttributesResult {
        
        // MARK: Properties
        public var mappingResult: DropContants.AttributedDict
        public var shouldAppendContent: Bool
        public var isUsingParentAttributes: Bool
        
        // MARK: Init
        public init(mappingResult: DropContants.AttributedDict, shouldAppendContent: Bool = false, isUsingParentAttributes: Bool = false) {
            self.mappingResult = mappingResult
            self.shouldAppendContent = shouldAppendContent
            self.isUsingParentAttributes = isUsingParentAttributes
        }
        
    }
    
}

extension AttributedStringRender {
    
    func dictEqual(lhs: DropContants.AttributedDict, rhs: DropContants.AttributedDict) -> Bool {
        AttributedStringRender.dictEqual(lhs: lhs, rhs: rhs)
    }
    
    static func dictEqual(lhs: DropContants.AttributedDict, rhs: DropContants.AttributedDict) -> Bool {
        
        guard lhs.keys.count == rhs.keys.count else {
            return false
        }
        
        var isEqual: Bool = true
        
        for (key, value) in lhs {
            
            isEqual = isEqual && (rhs[key] == nil ? false : String(describing: rhs[key]!) == String(describing: value))
            
            if isEqual == false {
                break
            }
        }
        
        return isEqual
    }
    
}
