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
    
    public private(set) var renderStacks: [DropParagraphRender] = []
    
    private var renderAST: DropTree? = nil
    private var attributes: DropAttributes? = nil
    private var mapping: DropAttributedMapping? = nil
    
    // MARK: Init
    public init(string: String, using rules: [DropRule]) {
        self.document = .init(raw: string)
        self.rules = rules
    }
    
    public init(using rules: [DropRule], attributes: DropAttributes? = nil, mapping: DropAttributedMapping) {
        
        self.document = .init(raw: "")
        self.rules = rules
        self.attributes = attributes
        self.mapping = mapping
    }
    
    // MARK: Render
    public func render() -> Result {
        render(
            with: attributes ?? DropAttributes(),
            mapping: mapping ?? DropDefaultAttributedMapping()
        )
    }
    
    public func render(with attributes: DropAttributes, mapping: DropAttributedMapping) -> Result {
        
        /// - Tag: Mapping
        self.attributes = attributes
        self.mapping = mapping
        
        /// - Tag: Vaild Raw
        guard document.raw.isEmpty == false else {
            return .init()
        }
        
        /// - Tag: AST
        let ast = Dropper(document: document).process(using: rules)
        self.renderAST = ast

        return rerender(attributes: attributes, mapping: mapping)
    }
    
    private func render(docOffset: inout Int, renderStacks: inout [DropParagraphRender], parentType: DropContainerRenderType, parentStack: DropParagraphRender?, block multiParagraphs: [DropContainerNode], isLastLine: Bool, base: ParagraphTextAttributes, with attributes: DropAttributes, mapping: DropAttributedMapping) -> Result {
        
        let result = NSMutableAttributedString()
        
        var stack = Array(multiParagraphs.reversed())
        
        while let child = stack.popLast() {
            
            let paragraphText: NSAttributedString
            
            switch child.type {
            case .document:
                paragraphText = .init(string: "")
                
            case .block(let type):
                
                /// - Tag: Paragraph text
                let base: ParagraphTextAttributes
                switch type {
                case .bulletList:      base = attributes.bulletList.paragraphText
                case .numberOrderList: base = attributes.numberOrderList.paragraphText
                case .letterOrderList: base = attributes.letterOrderList.paragraphText
                }
                
                /// - Tag: Render stack
                let stack = DropParagraphRender(
                    parentType: .init(type: type),
                    type: child.type,
                    renderRange: .init(location: docOffset, length: 0),
                    paragraphRange: child.intRange,
                    docRange: child.documentRange,
                    children: []
                )
                
                renderStacks.append(stack)
                
                paragraphText = render(
                    docOffset: &docOffset,
                    renderStacks: &renderStacks, 
                    parentType: .init(type: type),
                    parentStack: stack,
                    block: child.containers(),
                    isLastLine: child.isLastLine,
                    base: base,
                    with: attributes,
                    mapping: mapping
                )
                
                stack.renderRange.length = paragraphText.length
                
            case .paragraph:
                let stack = DropParagraphRender(
                    parentType: parentType,
                    type: child.type,
                    renderRange: .init(location: docOffset, length: 0),
                    paragraphRange: child.intRange,
                    docRange: child.documentRange,
                    children: []
                )
                
                if let parentStack {
                    parentStack.children.append(stack)
                } else {
                    renderStacks.append(stack)
                }
                
                paragraphText = render(
                    docOffset: &docOffset,
                    renderStack: stack,
                    paragraph: child,
                    base: base,
                    with: attributes,
                    mapping: mapping
                )
                
                stack.renderRange.length = paragraphText.length
                
            case .break:
                let stack = DropParagraphRender(
                    parentType: parentType,
                    type: child.type,
                    renderRange: .init(location: docOffset, length: 0),
                    paragraphRange: child.intRange,
                    docRange: child.documentRange,
                    children: []
                )
                
                if let parentStack {
                    parentStack.children.append(stack)
                } else {
                    renderStacks.append(stack)
                }
                
                paragraphText = render(
                    docOffset: &docOffset,
                    renderStack: stack,
                    break: child,
                    base: base,
                    with: attributes,
                    mapping: mapping
                )
                
                stack.renderRange.length = paragraphText.length
            }
            
            result.append(paragraphText)
            
        }
        
        return result
    }
    
    private func render(docOffset: inout Int, renderStack: DropParagraphRender, paragraph: DropContainerNode, base: ParagraphTextAttributes, with attributes: DropAttributes, mapping: DropAttributedMapping) -> Result {
        
        render(
            docOffset: &docOffset,
            renderStack: renderStack,
            paragraph: paragraph,
            isBreak: false,
            base: base,
            with: attributes,
            mapping: mapping
        )
    }
    
    private func render(docOffset: inout Int, renderStack: DropParagraphRender, break paragraph: DropContainerNode, base: ParagraphTextAttributes, with attributes: DropAttributes, mapping: DropAttributedMapping) -> Result {
        
        render(
            docOffset: &docOffset,
            renderStack: renderStack,
            paragraph: paragraph,
            isBreak: true,
            base: base,
            with: attributes,
            mapping: mapping
        )
    }
    
    // MARK: Core
    private func render(docOffset: inout Int, renderStack: DropParagraphRender, paragraph: DropContainerNode, isBreak: Bool, base: ParagraphTextAttributes, with attributes: DropAttributes, mapping: DropAttributedMapping) -> Result {
        
        /// - Tag: Render Dict
        var paragraphRenderDict: [DropContants.IntRange: RenderElement] = .init()
        
        /// - Tag: Contents
        var offset: Int = 0
        
        var indentList: [DropParagraphIndent] = []
        
        var renderMarkAttributes: [RenderMarkAttributes] = []

        var expandActionRenders: [RenderContentSpecial] = .init()
        
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
            
            let attributedString: NSAttributedString
            let renderRange: DropContants.IntRange
            let isCombineResult: Bool
            
            if let element = paragraphRenderDict[leave.intRange] {
                
                combine(
                    oldAttributes: element.bindMappingResult,
                    in: &mappingResult,
                    mapping: mapping,
                    with: paragraphContent,
                    in: element.renderRange
                )
                
                element.bindMappingResult = mappingResult
                
                attributedString = element.content
                renderRange = element.renderRange
                isCombineResult = true
                
            } else {
                
                attributedString = NSAttributedString(string: string, attributes: mappingResult)
                paragraphContent.append(attributedString)
                
                renderRange = DropContants.IntRange(
                    location: offset,
                    length: attributedString.length /// min(0, attributedString.length - 1)
                )
                paragraphRenderDict[leave.intRange] = .init(
                    renderRange: renderRange, 
                    content: attributedString,
                    bindMappingResult: mappingResult
                )
                
                isCombineResult = false
                
                offset += attributedString.length
                
            }
            
            if
                let content = leave as? DropContentNodeProtocol,
                let renderType = content.type.render
            {
                renderMarkAttributes.append(
                    .init(
                        type: renderType,
                        parentTypes: content.parentContainerRenderTypes,
                        intRange: content.intRange,
                        mappingResult: mappingResult,
                        isCombineResult: isCombineResult
                    )
                )
            }
            
            /// - Tag: Capture Expands & Actions
            captureExpandsAndActions(
                expandActionRenders: &expandActionRenders,
                leave: leave,
                attributes: attributes,
                isUsingParentAttributes: isUsingParentAttributes,
                renderRange: renderRange,
                content: attributedString,
                mappingResult: mappingResult
            )
            
            /// - Tag: Render Stack
            if let content = leave as? DropContentNodeProtocol {
                
                let renderType = DropRenderType(type: content.type, mark: content.type.mark)
                
                let contentStack = DropRenderStack(
                    renderRange: renderRange,
                    renderDocRange: .init(
                        location: renderRange.location + renderStack.renderRange.location,
                        length: renderRange.length
                    ),
                    paragraphRange: leave.intRange,
                    docRange: leave.documentRange,
                    type: content.type,
                    renderType: renderType,
                    content: string,
                    attribute: attributes.attributes(renderType)
                )
                
                renderStack.children.append(contentStack)
            }
            
            paragraphContent.endEditing()
        }
        
        /// - Tag: Compact Content
        let compactContentRenders = compactExpandActions(
            combineContentRenders: expandActionRenders,
            paragraphContent: paragraphContent,
            attributes: attributes,
            mapping: mapping
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
        
        #if DEBUG && true
        print((#file as NSString).lastPathComponent, #function, #line, renderStack, paragraphContent)
        #endif
        
        return paragraphContent
    }
    
    // MARK: Rerender
    public func rerender(ast rules: [DropRule]) {
        self.rules = rules
        
        let ast = Dropper(document: document).process(using: rules)
        self.renderAST = ast
    }
    
    public func rerender(document string: String, using attributes: DropAttributes) -> Result {
        
        self.attributes = attributes
        
        if string != document.raw {
            
            self.document.raw = string
            
            let ast = Dropper(document: self.document).process(using: rules)
            self.renderAST = ast
            
            guard let mapping else {
                return .init(string: string)
            }
            
            return rerender(attributes: attributes, mapping: mapping)
            
        } else {
            
            guard let mapping else {
                return .init(string: string)
            }
            
            return rerender(attributes: attributes, mapping: mapping)
        }
    
    }
    
    public func rerender(using attributes: DropAttributes) -> Result {
        guard let mapping else {
            return .init(string: "")
        }
        
        return rerender(attributes: attributes, mapping: mapping)
    }
    
    public func rerender(using mapping: DropAttributedMapping) -> Result {
        guard let attributes else {
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
        renderStacks = []
        
        return render(
            docOffset: &docOffset,
            renderStacks: &renderStacks,
            parentType: .documant,
            parentStack: nil,
            block: ast.containers(),
            isLastLine: false,
            base: attributes.paragraphText,
            with: attributes,
            mapping: mapping
        )
    }
    
    // MARK: Content
    public func isContentUpdate(_ new: String) -> Bool {
        document.raw != new
    }
    
    public func isAttributesUpdate(_ new: DropAttributes) -> Bool {
        attributes != new
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
            let mappingResult = mapping.mapping(
                text: base.text,
                type: .text,
                content: textNode.rawRenderContent,
                in: attributes.paragraph
            )
            return .init(
                mappingResult: mappingResult,
                shouldAppendContent: true,
                isUsingParentAttributes: false
            )
        }
        
        guard let markNode = node as? DropContentMarkNode else {
            return .init(
                mappingResult: .init(),
                shouldAppendContent: true,
                isUsingParentAttributes: false
            )
        }
        
        var mappingResult: DropContants.AttributedDict = .init()
        var shouldAppendContent: Bool = true
        var isUsingParentAttributes: Bool = true
        
        /// - Tag: Current
        
        func generateNewDict() {
            
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
        
        func fillNewDict() {
            
            if
                let type = markNode.type.render,
                attributes.markAttributes(type).isLinkToParentOn
            {
                
                if
                    let previousMappingResult = renderMarkAttributes.filter({
                        $0.type == type &&
                        $0.parentTypes == markNode.parentContainerRenderTypes &&
                        $0.isCombineResult == false
                    }).last?.mappingResult
                {
                    
                    mappingResult = previousMappingResult
                    
                    isUsingParentAttributes = false
                    
                } else {
                    
                    generateNewDict()
                    
                }
                
            } else {
                
                generateNewDict()
                
            }
        }
        
        if let _ = markNode.type.render {
            
            let parentFilles = markNode.parentContainerRenderTypes.filter({
                attributes.markAttributes($0).isFillChildAttributes
            })
            
            if 
                parentFilles.isEmpty == false,
                let parentAttributes = renderMarkAttributes.first(where: {
                    $0.type == parentFilles.first!
                })
            {
                mappingResult = parentAttributes.mappingResult
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
    private func captureExpandsAndActions(expandActionRenders: inout [RenderContentSpecial], leave: DropNode, attributes: DropAttributes, isUsingParentAttributes: Bool, renderRange: DropContants.IntRange, content: NSAttributedString, mappingResult: DropContants.AttributedDict) {
        
        if
            let contentNode = leave as? DropContentNodeProtocol,
            let renderType = contentNode.type.render
        {
            
            let attribute = attributes.markAttributes(renderType)
            
            /// - Tag: Expand
            var isExpand = attribute.expand != nil
            
            let parentExpands = contentNode.parentContainerRenderTypes.filter({
                attributes.markAttributes($0).expand != nil
            })
            
            if parentExpands.isEmpty == false {
                isExpand = true
            }
            
            /// - Tag: Action
            var isAction = attribute.action != nil
            
            let parentActions = contentNode.parentContainerRenderTypes.filter({
                attributes.markAttributes($0).action != nil
            })
            
            if parentActions.isEmpty == false {
                isAction = true
            }
            
            let mode: RenderContentSpecialMode?
            
            switch (isExpand, isAction) {
            case (false, false): mode = nil
            case (true, false): mode = .expand
            case (false, true): mode = .action
            case (true, true): mode = .both
            }
            
            if let mode {
                expandActionRenders.append(.init(
                    mode: mode,
                    isUsingParentAttributes: isUsingParentAttributes,
                    renderType: renderType,
                    parentTypes: contentNode.parentContainerRenderTypes,
                    markNode: contentNode,
                    range: renderRange,
                    content: content,
                    mappingResult: mappingResult
                ))
                expandActionRenders.sort(by: { $0.range.location < $1.range.location })
            }
            
        }
        
    }
    
    private func compactExpandActions(combineContentRenders: [RenderContentSpecial], paragraphContent: NSAttributedString, attributes: DropAttributes, mapping: DropAttributedMapping) -> [RenderContentSpecial] {
        
        var compactContentRenders: [RenderContentSpecial] = []
        
        /// 同位同性 (range,type) 重合压缩
        var rangeTypeCompactDict: [RenderContentCompactKey: RenderContentSpecial] = .init()
        
        for render in combineContentRenders {
            let key = RenderContentCompactKey(range: render.range, type: render.renderType)
            rangeTypeCompactDict[key] = render
        }
        
        var typeCompactDict: [DropRenderMarkType: [RenderContentSpecial]] = .init()
        
        rangeTypeCompactDict.forEach({
            let key = $0.key.type
            if typeCompactDict[key] == nil {
                typeCompactDict[key] = []
            }
            typeCompactDict[key]?.append($0.value)
        })
        rangeTypeCompactDict = .init()
        
        /// 内连接，连接(相邻)合并压缩
        var linkTypeCompactDict: [DropRenderMarkType: [RenderContentSpecial]] = .init()
        
        for (type, values) in typeCompactDict {
            
            let subCompacts = values.sorted(by: {
                $0.range.location < $1.range.location
            })

            var compacts: [RenderContentSpecial] = []
            
            var previousCompact: RenderContentSpecial? = nil

            for index in 0 ..< subCompacts.count {

                var render = subCompacts[index]
                
                if let previous = previousCompact {
                    
                    if previous.range.vaildMaxLocation >= render.range.location {
                        
                        var newPrevious = previous
                        
                        let offset = render.range.vaildMaxLocation - previous.range.vaildMaxLocation
                        
                        newPrevious.range.length += offset
                        
                        newPrevious.content = paragraphContent.attributedSubstring(
                            from: newPrevious.range
                        )
                        
                        compacts.removeLast()
                        compacts.append(newPrevious)
                        
                        render = newPrevious
                        
                    }
                    else if previous.range.maxLocation == render.range.location {
                        
                        var newPrevious = previous
                        
                        newPrevious.range.length += render.range.length
                        
                        let newContent = NSMutableAttributedString(attributedString: newPrevious.content)
                        newContent.append(render.content)
                        newPrevious.content = newContent
                        
                        compacts.removeLast()
                        compacts.append(newPrevious)
                        
                        render = newPrevious
                        
                    } else {
                        compacts.append(render)
                    }
                    
                } else {
                    compacts.append(render)
                }
                
                previousCompact = render
                
                
                linkTypeCompactDict[type] = compacts
                
            }
            
            typeCompactDict = linkTypeCompactDict

            #if false
            print(#function, #line, compactContentRenders.count)

            print(
                #function, #line,
                compacts.map{
                    ($0.mode, $0.range, paragraphContent.attributedSubstring(from: $0.range).string)
                }
            )
            #endif
            
        }
        
        /// - Tag: Down Compact
        compactContentRenders = typeCompactDict
            .flatMap({ _, compacts in
                compacts
            })
            .sorted(by: {
                $0.range.location < $1.range.location
            })
        
        #if false
        print(
            #function, #line,
            compactContentRenders.map({
                ($0.mode, $0.content, $0.range, paragraphContent.attributedSubstring(from: $0.range).string)
            })
        )
        #endif
        
        return compactContentRenders
    }
    
    private func replaceExpandActionContents(compactContentRenders: [RenderContentSpecial], base: ParagraphTextAttributes, attributes: DropAttributes, mapping: DropAttributedMapping, paragraphContent: inout NSMutableAttributedString) {
        
        paragraphContent.beginEditing()
        
        struct Replace {
            
            var render: RenderContentSpecial
            var replaceRange: DropContants.IntRange
            var content: NSAttributedString
            var contentRange: DropContants.IntRange
            
            init(render: RenderContentSpecial, replaceRange: DropContants.IntRange, content: NSAttributedString, contentRange: DropContants.IntRange) {
                
                self.render = render
                self.replaceRange = replaceRange
                self.content = content
                self.contentRange = contentRange
            }
            
        }
        
        var replaces: [Replace] = []
        
        var compactOffset: Int = 0
        
        func getExpandContent(_ render: RenderContentSpecial) -> DropAttributedMappingResult? {
            
            let attribute = attributes.markAttributes(render.renderType)
            
            var parentAttribute: TextAttributes? = nil
            if 
                let parent = render.parentTypes.first
            {
                parentAttribute = attributes.markAttributes(parent)
            }
            
            if let expand = attribute.expand {
                
                return mapping.mapping(
                    expand: expand,
                    text: parentAttribute?.character ?? attribute.character,
                    content: render.content,
                    renderRange: render.range,
                    in: base.paragraph
                )
                
            }
            
            return nil
        }
        
        func getActionContent(_ render: RenderContentSpecial) -> DropAttributedMappingResult? {
            
            let attribute = attributes.markAttributes(render.renderType)
            
            var parentAttribute: TextAttributes? = nil
            if
                let parent = render.parentTypes.first
            {
                parentAttribute = attributes.markAttributes(parent)
            }
            
            if let action = attribute.action {
                
                return mapping.mapping(
                    action: action,
                    text: parentAttribute?.character ?? attribute.character,
                    content: render.content,
                    renderRange: render.range,
                    in: base.paragraph
                )
                
            }
            
            return nil
        }
        
        func getExpandActionContent(_ render: RenderContentSpecial) -> DropAttributedMappingResult? {
            
            let attribute = attributes.markAttributes(render.renderType)
            
            var parentAttribute: TextAttributes? = nil
            if
                let parent = render.parentTypes.first
            {
                parentAttribute = attributes.markAttributes(parent)
            }
            
            if 
                let expand = attribute.expand,
                let action = attribute.action
            {
                
                return mapping.mapping(
                    expand: expand,
                    action: action,
                    text: parentAttribute?.character ?? attribute.character,
                    content: render.content,
                    renderRange: render.range,
                    in: base.paragraph
                )
                
            }
            
            return nil
        }
        
        for render in compactContentRenders {
            
            var replaceRange = render.range
            replaceRange.location += compactOffset
            
            var replaceContent: NSAttributedString? = nil
            
            switch render.mode {
            case .expand:
                
                if 
                    let previous = replaces
                        .filter({
                            render.markNode.intRange.location >= $0.render.markNode.intRange.location &&
                            render.markNode.intRange.vaildMaxLocation <= $0.render.markNode.intRange.vaildMaxLocation
                        })
                        .sorted(by: {
                            $0.render.range.length < $1.render.range.length
                        })
                        .first,
                    let current = getExpandContent(render)
                {
                    
                    let renderReplaceRange = DropContants.IntRange(
                        location: render.range.location - previous.render.range.location,
                        length: render.range.length
                    )
                    
                    guard let content = mapping.expandActionReplace(
                        previous.content,
                        replaceRange: renderReplaceRange,
                        content: current.content
                    ) else {
                        continue
                    }
                    
                    paragraphContent.replaceCharacters(in: previous.contentRange, with: content)
                    
                    replaces.append(
                        .init(
                            render: render,
                            replaceRange: .init(
                                location: previous.replaceRange.location + renderReplaceRange.location,
                                length: renderReplaceRange.length
                            ),
                            content: current.content,
                            contentRange: .init(
                                location: renderReplaceRange.location,
                                length: current.content.length
                            )
                        )
                    )
                    
                } else {
                    guard let content = getExpandContent(render)?.content else {
                        continue
                    }
                    
                    paragraphContent.replaceCharacters(in: replaceRange, with: content)
                    compactOffset += content.length - render.content.length
                    
                    replaceContent = content
                }
                
            case .action:
                if
                    let previous = replaces
                        .filter({
                            render.range.location >= $0.render.range.location &&
                            render.range.vaildMaxLocation <= $0.render.range.vaildMaxLocation
                        })
                        .sorted(by: {
                            $0.render.range.length < $1.render.range.length
                        })
                        .first,
                    let current = getActionContent(render)
                {
                    
                    let renderReplaceRange = DropContants.IntRange(
                        location: render.range.location - previous.render.range.location,
                        length: render.range.length
                    )
                    
                    guard let content = mapping.expandActionReplace(
                        previous.content,
                        replaceRange: renderReplaceRange,
                        content: current.content
                    ) else {
                        continue
                    }
                    
                    paragraphContent.replaceCharacters(in: previous.contentRange, with: content)
                    
                    replaces.append(
                        .init(
                            render: render,
                            replaceRange: .init(
                                location: previous.replaceRange.location + renderReplaceRange.location,
                                length: renderReplaceRange.length
                            ),
                            content: current.content,
                            contentRange: .init(
                                location: renderReplaceRange.location,
                                length: current.content.length
                            )
                        )
                    )
                    
                } else {
                    guard let content = getActionContent(render)?.content else {
                        continue
                    }
                    
                    paragraphContent.replaceCharacters(in: replaceRange, with: content)
                    compactOffset += content.length - render.content.length
                    
                    replaceContent = content
                }
                
            case .both:
                if
                    let previous = replaces
                        .filter({
                            render.range.location >= $0.render.range.location &&
                            render.range.vaildMaxLocation <= $0.render.range.vaildMaxLocation
                        })
                        .sorted(by: {
                            $0.render.range.length < $1.render.range.length
                        })
                        .first,
                    let current = getExpandActionContent(render)
                {
                    
                    let renderReplaceRange = DropContants.IntRange(
                        location: render.range.location - previous.render.range.location,
                        length: render.range.length
                    )
                    
                    guard let content = mapping.expandActionReplace(
                        previous.content,
                        replaceRange: renderReplaceRange,
                        content: current.content
                    ) else {
                        continue
                    }
                    
                    paragraphContent.replaceCharacters(in: previous.contentRange, with: content)
                    
                    replaces.append(
                        .init(
                            render: render,
                            replaceRange: .init(
                                location: previous.replaceRange.location + renderReplaceRange.location,
                                length: renderReplaceRange.length
                            ),
                            content: current.content,
                            contentRange: .init(
                                location: renderReplaceRange.location,
                                length: current.content.length
                            )
                        )
                    )
                    
                } else {
                    guard let content = getExpandActionContent(render)?.content else {
                        continue
                    }
                    
                    paragraphContent.replaceCharacters(in: replaceRange, with: content)
                    compactOffset += content.length - render.content.length
                    
                    replaceContent = content
                }
            }
            
            if let replaceContent {
                replaces.append(
                    .init(
                        render: render,
                        replaceRange: replaceRange,
                        content: replaceContent,
                        contentRange: .init(location: replaceRange.location, length: replaceContent.length)
                    )
                )
            }
            
        }
        
        paragraphContent.endEditing()
        
    }
    
    // MARK: Node
//    public func
    
}

extension AttributedStringRender {
    
    final class RenderElement {
        
        // MARK: Properties
        var renderRange: DropContants.IntRange
        var content: NSAttributedString
        var bindMappingResult: DropContants.AttributedDict
        
        // MARK: Init
        init(renderRange: DropContants.IntRange, content: NSAttributedString, bindMappingResult: DropContants.AttributedDict) {
            self.renderRange = renderRange
            self.content = content
            self.bindMappingResult = bindMappingResult
        }
        
    }
    
    struct RenderMarkAttributes {
        
        // MARK: Properties
        public var type: DropRenderMarkType
        public var parentTypes: [DropRenderMarkType]
        public var intRange: DropContants.IntRange
        public var mappingResult: DropContants.AttributedDict
        public var isCombineResult: Bool
        
        // MARK: Init
        public init(type: DropRenderMarkType, parentTypes: [DropRenderMarkType], intRange: DropContants.IntRange, mappingResult: DropContants.AttributedDict, isCombineResult: Bool) {
            self.type = type
            self.parentTypes = parentTypes
            self.intRange = intRange
            self.mappingResult = mappingResult
            self.isCombineResult = isCombineResult
        }
        
    }
    
    enum RenderContentSpecialMode: Int {
        case expand, action, both
    }
    
    
    struct RenderContentCompactKey: Hashable {
        
        // MARK: Properties
        public var range: DropContants.IntRange
        public var type: DropRenderMarkType
        
        // MARK: Init
        public init(range: DropContants.IntRange, type: DropRenderMarkType) {
            self.range = range
            self.type = type
        }
        
    }
    
    struct RenderContentSpecial {
        
        // MARK: Properties
        public var mode: RenderContentSpecialMode
        public var isUsingParentAttributes: Bool
        public var renderType: DropRenderMarkType
        public var parentTypes: [DropRenderMarkType]
        public var markNode: DropContentNodeProtocol
        public var range: DropContants.IntRange
        public var content: NSAttributedString
        public var mappingResult: DropContants.AttributedDict
        
        // MARK: Init
        public init(
            mode: RenderContentSpecialMode,
            isUsingParentAttributes: Bool,
            renderType: DropRenderMarkType,
            parentTypes: [DropRenderMarkType],
            markNode: DropContentNodeProtocol,
            range: DropContants.IntRange,
            content: NSAttributedString,
            mappingResult: DropContants.AttributedDict
        ) {
            self.mode = mode
            self.isUsingParentAttributes = isUsingParentAttributes
            self.renderType = renderType
            self.parentTypes = parentTypes
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
