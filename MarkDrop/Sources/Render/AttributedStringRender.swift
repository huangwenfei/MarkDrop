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
    
    private var renderDict: [DropContants.IntRange: RenderElement] = .init()
    
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
        /// - Tag: AST
        let ast = Dropper(document: document).process(using: rules)

        /// - Tag: Render
        return render(
            block: ast.containers(),
            isLastLine: false,
            base: attributes.paragraphText,
            with: attributes,
            mapping: mapping
        )
    }
    
    private func render(block multiParagraphs: [DropContainerNode], isLastLine: Bool, base: ParagraphTextAttributes, with attributes: DropAttributes, mapping: DropAttributedMapping) -> Result {
        
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
                paragraphText = render(block: child.containers(), isLastLine: child.isLastLine, base: base, with: attributes, mapping: mapping)
                
            case .paragraph:
                paragraphText = render(paragraph: child, base: base, with: attributes, mapping: mapping)
                
            case .break:
                paragraphText = render(break: child, base: base, with: attributes, mapping: mapping)
            }
            
            result.append(paragraphText)
            
        }
        
        return result
    }
    
    private func render(paragraph: DropContainerNode, base: ParagraphTextAttributes, with attributes: DropAttributes, mapping: DropAttributedMapping) -> Result {
        
        render(
            paragraph: paragraph,
            isBreak: false,
            base: base,
            with: attributes,
            mapping: mapping
        )
    }
    
    private func render(break paragraph: DropContainerNode, base: ParagraphTextAttributes, with attributes: DropAttributes, mapping: DropAttributedMapping) -> Result {
        
        render(
            paragraph: paragraph,
            isBreak: true,
            base: base,
            with: attributes,
            mapping: mapping
        )
    }
    
    private func render(paragraph: DropContainerNode, isBreak: Bool, base: ParagraphTextAttributes, with attributes: DropAttributes, mapping: DropAttributedMapping) -> Result {
        
        /// - Tag: Clear
        renderDict = .init()
        
        /// - Tag: Contents
        var offset: Int = 0
        
        var indentList: [DropParagraphIndent] = []
        
        var result = paragraph.leaves
            .sorted(by: { $0.intRange.location < $1.intRange.location })
            .reduce(NSMutableAttributedString(string: ""), {
                
                $0.beginEditing()
                
                let string = $1.rawRenderContent
                
                guard string.isEmpty == false else {
                    return $0
                }
                
                var attributed = AttributedDict()
                let shouldAppendContent = append(
                    textNode: $1,
                    text: base.text,
                    attributes: attributes,
                    mapping: mapping,
                    in: &attributed,
                    with: &indentList
                )
                
                guard shouldAppendContent else {
                    return $0
                }
                
                if let element = renderDict[$1.intRange] {
                    
                    combine(
                        oldAttributes: element.bindAttributes,
                        in: &attributed,
                        mapping: mapping,
                        with: $0,
                        in: element.renderRange
                    )
                    
                    element.bindAttributes = attributed
                    
                } else {
                    
                    let attributedString = NSAttributedString(string: string, attributes: attributed)
                    $0.append(attributedString)
                    
                    let renderRange = DropContants.IntRange(
                        location: offset,
                        length: attributedString.length /// min(0, attributedString.length - 1)
                    )
                    renderDict[$1.intRange] = .init(renderRange: renderRange, bindAttributes: attributed)
                    
                    offset += attributedString.length
                    
                }
                
                $0.endEditing()
                
                return $0
            })
        
        /// - Tag: Empty line
        if isBreak, result.string.isEmpty { result = NSMutableAttributedString(string: "\n") }
        
        /// - Tag: Paragraph
        append(
            paragraph: base.paragraph, 
            mapping: mapping,
            in: &result,
            with: indentList
        )
        
        /// - Tag: Clear
        renderDict = .init()
        
        return result
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
    
    private func combine(oldAttributes: AttributedDict, in attributed: inout AttributedDict, mapping: DropAttributedMapping, with content: NSMutableAttributedString, in renderRange: DropContants.IntRange) {
        
        mapping.combine(
            oldAttributes: oldAttributes,
            in: &attributed
        )
        
        content.addAttributes(attributed, range: renderRange)
        
    }
    
    private func append(textNode node: DropNode, text: TextAttributes, attributes: DropAttributes, mapping: DropAttributedMapping, in dict: inout AttributedDict, with indentList: inout [DropParagraphIndent]) -> Bool {
        
        if
            let textNode = node as? DropContentNode,
            textNode.type == .text
        {
            dict = mapping.mapping(text: text, type: .text)
            return true
        }
        
        guard let markNode = node as? DropContentMarkNode else {
            return true
        }
        
        var shouldAppendContent: Bool = true
        
        self.attributeDict(
            shouldAppendContent: &shouldAppendContent,
            type: markNode.type,
            textNode: node,
            text: text,
            attributes: attributes,
            mapping: mapping,
            in: &dict,
            with: &indentList
        )
        
        if markNode.type != .text {
            
            var parentMark = markNode.parentNode as? DropContentNodeProtocol
            
            while let parent = parentMark {
                
//                print(#function, #line, markNode.rawRenderContent, markNode.type, markNode.mark, "Parent", parent.rawRenderContent, parent.type)
                
                if parent.type == markNode.type, parent.type == .text {
                    parentMark = parent.parentNode as? DropContentNodeProtocol
                    continue
                }
                
                var oldAttributes: DropContants.AttributedDict = .init()
                var oldIndentList: [DropParagraphIndent] = []
                
                self.attributeDict(
                    shouldAppendContent: &shouldAppendContent,
                    type: parent.type,
                    textNode: parent,
                    text: text,
                    attributes: attributes,
                    mapping: mapping,
                    in: &oldAttributes,
                    with: &oldIndentList
                )
                
                mapping.combine(
                    oldAttributes: oldAttributes,
                    in: &dict
                )
                
                parentMark = parent.parentNode as? DropContentNodeProtocol
            }
            
        }
        
        return shouldAppendContent
    }
    
    private func attributeDict(shouldAppendContent: inout Bool, type: DropContentType, textNode node: DropNode, text: TextAttributes, attributes: DropAttributes, mapping: DropAttributedMapping, in dict: inout AttributedDict, with indentList: inout [DropParagraphIndent]) {
        
        switch type {
        case .text:            dict = mapping.mapping(text: text, type: .text)
        case .hashTag:         dict = mapping.mapping(text: attributes.hashTag, type: .hashTag)
        case .mention:         dict = mapping.mapping(text: attributes.mention, type: .mention)
        case .bold:            dict = mapping.mapping(text: attributes.bold, type: .bold)
        case .italics:         dict = mapping.mapping(text: attributes.italics, type: .italics)
        case .underline:       dict = mapping.mapping(text: attributes.underline, type: .underline)
        case .highlight:       dict = mapping.mapping(text: attributes.highlight, type: .highlight)
        case .stroke:          dict = mapping.mapping(text: attributes.stroke, type: .stroke)
            
        case .bulletList:
            dict = mapping.mapping(text: attributes.bulletList.mark, type: .text)
            fillIndentList(
                indentList: &indentList,
                in: node,
                attributes: dict,
                mode: .tabStop
            )
            
        case .numberOrderList: 
            dict = mapping.mapping(text: attributes.numberOrderList.mark, type: .text)
            fillIndentList(
                indentList: &indentList,
                in: node,
                attributes: dict,
                mode: .tabStop
            )
            
        case .letterOrderList: 
            dict = mapping.mapping(text: attributes.letterOrderList.mark, type: .text)
            fillIndentList(
                indentList: &indentList,
                in: node,
                attributes: dict,
                mode: .tabStop
            )
            
        case .tabIndent:
            let dict = mapping.mapping(text: attributes.tabIndent, type: .text)
            fillIndentList(
                indentList: &indentList,
                in: node,
                attributes: dict,
                mode: .firstHeadIndent
            )
            
            shouldAppendContent = false
            
        case .spaceIndent:
            let dict = mapping.mapping(text: attributes.spaceIndent, type: .text)
            fillIndentList(
                indentList: &indentList,
                in: node,
                attributes: dict,
                mode: .firstHeadIndent
            )
            
            shouldAppendContent = false
        }
        
    }
    
    private func fillIndentList(indentList: inout [DropParagraphIndent], in node: DropNode, attributes: DropContants.AttributedDict, mode: DropParagraphIndentMode) {
        
        let content = node.rawRenderContent
        let width = NSAttributedString(string: content, attributes: attributes).size().width
        indentList.append(.init(indentation: width, mode: mode))
        
    }
    
}

extension AttributedStringRender {
    
    final class RenderElement {
        
        // MARK: Properties
        var renderRange: DropContants.IntRange
        var bindAttributes: AttributedDict
        
        // MARK: Init
        init(renderRange: DropContants.IntRange, bindAttributes: AttributedDict) {
            self.renderRange = renderRange
            self.bindAttributes = bindAttributes
        }
        
    }
    
}
