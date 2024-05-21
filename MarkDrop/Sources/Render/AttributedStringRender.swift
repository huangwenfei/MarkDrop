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
    
    public var charExpandSpaceWidthDict: [DropRenderMarkType: CGFloat] = .init()
    
    public private(set) var renderDict: [DropCaptureRenderKey: DropCaptureRenderNode] = .init()
    
    private var paragraphRenderDict: [DropContants.IntRange: RenderElement] = .init()
    
    // MARK: Init
    public init(string: String, using rules: [DropRule]) {
        self.document = .init(raw: string)
        self.rules = rules
        self.charExpandSpaceWidthDict = .init()
    }
    
    public init(string: String, using rules: [DropRule], charExpandSpaceWidth: CGFloat) {
        self.document = .init(raw: string)
        self.rules = rules
        self.charExpandSpaceWidthDict = .init(
            uniqueKeysWithValues: DropRenderMarkType.allCases.map({
                ($0, charExpandSpaceWidth)
            })
        )
    }
    
    public init(string: String, using rules: [DropRule], charExpandSpaceWidthDict: [DropRenderMarkType: CGFloat]) {
        self.document = .init(raw: string)
        self.rules = rules
        self.charExpandSpaceWidthDict = charExpandSpaceWidthDict
    }
    
    // MARK: Render
    public func render() -> Result {
        render(with: DropAttributes(), mapping: DropDefaultAttributedMapping())
    }
    
    public func render(with attributes: DropAttributes, mapping: DropAttributedMapping) -> Result {
        /// - Tag: AST
        let ast = Dropper(document: document).process(using: rules)

        /// - Tag: Render
        mapping.expandSpaces = .init()
        
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
        
        /// - Tag: Clear
        paragraphRenderDict = .init()
        
        /// - Tag: Contents
        var offset: Int = 0
        
        var indentList: [DropParagraphIndent] = []
        
        var renderMarkAttributes: [RenderMarkAttributes] = []
        
        var result = paragraph.leaves
            .sorted(by: { $0.intRange.location < $1.intRange.location })
            .reduce(NSMutableAttributedString(string: ""), {
                
                $0.beginEditing()
                
                var string = $1.rawRenderContent
                
                guard string.isEmpty == false else {
                    return $0
                }
                
                var attributed = AttributedDict()
                let shouldAppendContent = append(
                    renderMarkAttributes: renderMarkAttributes,
                    current: $0,
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
                
                if let content = $1 as? DropContentNodeProtocol {
                    expandContent(
                        renderType: content.type.render,
                        content: &string,
                        in: content.renderExpandWidthMode,
                        using: attributed,
                        captureIn: mapping
                    )
                }
                
                if let element = paragraphRenderDict[$1.intRange] {
                    
                    combine(
                        oldAttributes: element.bindAttributes,
                        in: &attributed,
                        mapping: mapping,
                        with: $0,
                        in: element.renderRange
                    )
                    
                    element.bindAttributes = attributed
                    
                    if let render = renderDict[DropCaptureRenderKey(nodeRange: $1.intRange)] {
                        render.nodes.append($1)
                    }
                    
                } else {
                    
                    let attributedString = NSAttributedString(string: string, attributes: attributed)
                    $0.append(attributedString)
                    
                    let renderRange = DropContants.IntRange(
                        location: offset,
                        length: attributedString.length /// min(0, attributedString.length - 1)
                    )
                    paragraphRenderDict[$1.intRange] = .init(renderRange: renderRange, bindAttributes: attributed)
                    
                    var docRenderRange = renderRange
                    docRenderRange.location += docOffset
                    let captureRenderRange = DropCaptureRenderKey(
                        nodeRange: $1.intRange,
                        docRenderRange: docRenderRange
                    )
                    
                    renderDict[captureRenderRange] = .init(
                        docRenderRange: docRenderRange,
                        paragraphRenderRange: renderRange,
                        bindAttributes: attributed,
                        nodes: [$1]
                    )
                    
                    offset += attributedString.length
                    
                }
                
                if 
                    let content = $1 as? DropContentNodeProtocol,
                    let renderType = content.type.render
                {
                    renderMarkAttributes.append(
                        .init(type: renderType, intRange: content.intRange, dict: attributed)
                    )
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
        
        /// - Tag: Increase
        docOffset += offset
        
        /// - Tag: Clear
        paragraphRenderDict = .init()
        
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
    
    private func append(renderMarkAttributes: [RenderMarkAttributes], current: NSMutableAttributedString, textNode node: DropNode, text: TextAttributes, attributes: DropAttributes, mapping: DropAttributedMapping, in dict: inout AttributedDict, with indentList: inout [DropParagraphIndent]) -> Bool {
        
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
        
        /// - Tag: Current
        
        func fillNewDict() {
            
            if
                let type = markNode.type.render,
                let previousDict = renderMarkAttributes.last(where: { $0.type == type })?.dict
            {
                
                dict = previousDict
                
            } else {
                
                self.attributeDict(
                    current: current,
                    shouldAppendContent: &shouldAppendContent,
                    type: markNode.type,
                    textNode: node,
                    text: text,
                    attributes: attributes,
                    mapping: mapping,
                    in: &dict,
                    with: &indentList
                )
                
            }
        }
        
        if
            let type = markNode.type.render,
            attributes.markAttributes(type).isFillChildAttributes
        {
            
            let parentAttributes = renderMarkAttributes.last(where: { $0.type == type })

            if let parentDict = parentAttributes?.dict {
                dict = parentDict
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
                
                if let parentDict = parentAttributes?.dict {
                    switch attributes.markAttributes(type).fillMode {
                    case .none: break
                    case .fill: dict = parentDict
                    case .fillIgnoreFont:
                        let fontValues = parentDict.filter({ $0.value is DropFont })
                        if let fontKey = fontValues.first?.key {
                            
                            fillCombine(
                                fontKey: fontKey,
                                using: parentDict,
                                in: &dict
                            )
                            
                        } else {
                            dict = parentDict
                        }
                    }
                }
                
            } else {
                
                let parentAttributes: DropContants.AttributedDict
                switch type {
                case .hashTag:   parentAttributes = mapping.mapping(text: attributes.hashTag, type: .hashTag)
                case .mention:   parentAttributes = mapping.mapping(text: attributes.mention, type: .mention)
                case .bold:      parentAttributes = mapping.mapping(text: attributes.bold, type: .bold)
                case .italics:   parentAttributes = mapping.mapping(text: attributes.italics, type: .italics)
                case .underline: parentAttributes = mapping.mapping(text: attributes.underline, type: .underline)
                case .highlight: parentAttributes = mapping.mapping(text: attributes.highlight, type: .highlight)
                case .stroke:    parentAttributes = mapping.mapping(text: attributes.stroke, type: .stroke)
                }
                
                mapping.combine(
                    oldAttributes: parentAttributes,
                    in: &dict
                )
                
            }
            
        }
        
        return shouldAppendContent
    }
    
    private func attributeDict(current: NSMutableAttributedString, shouldAppendContent: inout Bool, type: DropContentType, textNode node: DropNode, text: TextAttributes, attributes: DropAttributes, mapping: DropAttributedMapping, in dict: inout AttributedDict, with indentList: inout [DropParagraphIndent]) {
        
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
            
            /// 只让段首的 fillIndentList
            guard current.string.isEmpty else {
                break
            }
            
            fillIndentList(
                indentList: &indentList,
                in: node,
                attributes: dict,
                mode: .firstHeadIndent
            )
            
            shouldAppendContent = false
            
        case .spaceIndent:
            
            let dict = mapping.mapping(text: attributes.spaceIndent, type: .text)
            
            /// 只让段首的 fillIndentList
            guard current.string.isEmpty else {
                break
            }
            
            fillIndentList(
                indentList: &indentList,
                in: node,
                attributes: dict,
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
    
    private func expandContent(renderType: DropRenderMarkType?, content: inout String, in mode: DropDiretionExpandWidthMode, using dict: DropContants.AttributedDict, captureIn mapping: DropAttributedMapping) {
        
        guard let renderType else {
            return
        }
        
        guard mode.contains(.leading) || mode.contains(.trailing) else {
            return
        }
        
        let spaceString = calculateExpandSpace(renderType: renderType, with: dict)
        
        if mode.contains(.leading) {
            content = spaceString + content
        }
        
        if mode.contains(.trailing) {
            content = content + spaceString
        }
        
        if let old = mapping.expandSpaces[renderType] {
            let leading = mode.contains(.leading) ? spaceString : ""
            let trailing = mode.contains(.trailing) ? spaceString : ""
            /// 不能累加
            mapping.expandSpaces[renderType] = .init(
                leading: old.leading.isEmpty ? leading : old.leading,
                trailing: old.trailing.isEmpty ? trailing : old.trailing
            )
        } else {
            mapping.expandSpaces[renderType] = .init(
                leading: mode.contains(.leading) ? spaceString : "",
                trailing: mode.contains(.trailing) ? spaceString : ""
            )
        }
        
    }
    
    private func calculateExpandSpace(renderType: DropRenderMarkType, with dict: DropContants.AttributedDict) -> String {
        
        let expandWidth: CGFloat?
        switch renderType {
        case .hashTag:   expandWidth = charExpandSpaceWidthDict[.hashTag]
        case .mention:   expandWidth = charExpandSpaceWidthDict[.mention]
        case .bold:      expandWidth = charExpandSpaceWidthDict[.bold]
        case .italics:   expandWidth = charExpandSpaceWidthDict[.italics]
        case .underline: expandWidth = charExpandSpaceWidthDict[.underline]
        case .highlight: expandWidth = charExpandSpaceWidthDict[.highlight]
        case .stroke:    expandWidth = charExpandSpaceWidthDict[.stroke]
        }
        
        guard let expandWidth else {
            return ""
        }
        
        let spaceWidth = NSAttributedString(string: " ", attributes: dict).size().width
        let spaceCount = Int(ceil(expandWidth / spaceWidth))
        
        return repeatElement(" ", count: spaceCount).reduce("", { $0 + $1 })
    }
    
}

extension AttributedStringRender {
    
    final class RenderElement {
        
        // MARK: Properties
        var renderRange: DropContants.IntRange
        var bindAttributes: AttributedDict
        var isFillChild = false
        
        // MARK: Init
        init(renderRange: DropContants.IntRange, bindAttributes: AttributedDict) {
            self.renderRange = renderRange
            self.bindAttributes = bindAttributes
        }
        
    }
    
    struct RenderMarkAttributes {
        
        // MARK: Properties
        public var type: DropRenderMarkType
        public var intRange: DropContants.IntRange
        public var dict: DropContants.AttributedDict
        
        // MARK: Init
        public init(type: DropRenderMarkType, intRange: DropContants.IntRange, dict: DropContants.AttributedDict) {
            self.type = type
            self.intRange = intRange
            self.dict = dict
        }
        
    }
    
}
