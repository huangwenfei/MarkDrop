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
        
        var actionRenders: [RenderActionMark] = []
        
        var result = paragraph.leaves
            .sorted(by: { $0.intRange.location < $1.intRange.location })
            .reduce(NSMutableAttributedString(string: ""), {
                
                $0.beginEditing()
                
                let string = $1.rawRenderContent
                
                guard $1.rawRenderContent.isEmpty == false else {
                    return $0
                }
                
                let result = append(
                    renderMarkAttributes: renderMarkAttributes,
                    current: $0,
                    textNode: $1,
                    base: base,
                    attributes: attributes,
                    mapping: mapping,
                    with: &indentList
                )
                
                var mappingResult       = result.mappingResult
                let shouldAppendContent = result.shouldAppendContent
                
                guard shouldAppendContent else {
                    return $0
                }
                
                let renderRange: DropContants.IntRange
                
                if let element = paragraphRenderDict[$1.intRange] {
                    
                    combine(
                        oldAttributes: element.bindMappingResult,
                        in: &mappingResult,
                        mapping: mapping,
                        with: $0,
                        in: element.renderRange
                    )
                    
                    element.bindMappingResult = mappingResult
                    
                    renderRange = element.renderRange
                    
                } else {
                    
                    let attributedString = NSAttributedString(string: string, attributes: mappingResult)
                    $0.append(attributedString)
                    
                    renderRange = DropContants.IntRange(
                        location: offset,
                        length: attributedString.length /// min(0, attributedString.length - 1)
                    )
                    paragraphRenderDict[$1.intRange] = .init(
                        renderRange: renderRange, bindMappingResult: mappingResult
                    )
                    
                    offset += attributedString.length
                    
                }
                
                if
                    let content = $1 as? DropContentNodeProtocol,
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
                
                captureActionRenderRange(
                    &actionRenders,
                    renderRange: renderRange,
                    text: $1,
                    attributes: attributes
                )
                
                $0.endEditing()
                
                return $0
            })
        
        /// - Tag: Dealing Actions
        dealingActionContents(
            actionRenders,
            content: &result,
            mapping: mapping,
            attributes: attributes,
            paragraph: base.paragraph
        )
        
        /// - Tag: Empty line
        if isBreak, result.string.isEmpty { result = NSMutableAttributedString(string: "\n") }
        
        /// - Tag: Paragraph
        append(
            paragraph: base.paragraph,
            mapping: mapping,
            in: &result,
            with: indentList
        )
        
        /// - Tag: Increase
        docOffset += offset
        
        /// - Tag: Clear
        paragraphRenderDict = .init()
        
        return result
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
            let type = markNode.type.render,
            attributes.markAttributes(type).isFillChildAttributes
        {
            
            let parentAttributes = renderMarkAttributes.last(where: { $0.type == type })

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
                    switch attributes.markAttributes(type).fillMode {
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

    private func captureActionRenderRange(_ actions: inout [RenderActionMark], renderRange: DropContants.IntRange, text node: DropNode, attributes: DropAttributes) {
        
        guard
            let text = node as? DropContentNodeProtocol,
            let renderType = text.type.render
        else {
            return
        }
        
        let textAttributes = attributes.markAttributes(renderType)
        
        guard textAttributes.action != nil else {
            return
        }

        if 
            var last = actions.popLast(),
            text.parentContainerRenderTypes.contains(last.type),
            attributes.markAttributes(last.type).isFillChildAttributes,
            /// maxLocation = location + length + 1, 挨着并相接
            last.intRange.maxLocation == renderRange.location
        {
            
            last.intRange.length += renderRange.length
            actions.append(last)
            
        } else {
            actions.append(.init(type: renderType, intRange: renderRange))
        }
        
    }
    
    private func dealingActionContents(_ actions: [RenderActionMark], content: inout NSMutableAttributedString, mapping: DropAttributedMapping, attributes: DropAttributes, paragraph: ParagraphAttributes) {
        
        guard actions.isEmpty == false else {
            return
        }
        
        for actionRender in actions {
            
            let attributed = attributes.markAttributes(actionRender.type)
            
            guard let action = attributed.action else {
                continue
            }
            
            let range = actionRender.intRange
            
            let renderContent = content.attributedSubstring(from: range)
            
            guard 
                let result = mapping.mapping(
                    action: action,
                    text: attributed,
                    content: renderContent,
                    in: paragraph
                )
            else {
                continue
            }
            
            var oldAttributes: DropContants.AttributedDict = .init()
            content.enumerateAttributes(in: range) { keyValues, range, isStop in
                
                oldAttributes.merge(keyValues, uniquingKeysWith: { _,new in new })
                
            }
            
            let newContent = NSMutableAttributedString(attributedString: result.content)
            newContent.addAttributes(
                oldAttributes,
                range: .init(location: 0, length: result.content.length)
            )
            
            content.replaceCharacters(in: range, with: newContent)
            
        }
        
    }
    
}

extension AttributedStringRender {
    
    final class RenderElement {
        
        // MARK: Properties
        var renderRange: DropContants.IntRange
        var bindMappingResult: DropContants.AttributedDict
        var isFillChild = false
        
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
        public var intRange: DropContants.IntRange
        
        // MARK: Init
        public init(type: DropRenderMarkType, intRange: DropContants.IntRange) {
            self.type = type
            self.intRange = intRange
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
