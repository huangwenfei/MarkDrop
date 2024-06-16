//
//  PlainTextRender.swift
//  MarkDrop
//
//  Created by windy on 2024/5/16.
//

import Foundation

public final class PlainTextRender: DropRendable {
    
    // MARK: Types
    public typealias Result = String
    public typealias ReplaceRenderContentClosure = (_ type: DropContentType, _ markType: DropContentMarkType, _ content: String, _ renderContent: String) -> (content: String, renderContent: String)
    public typealias FormatCaptureClosure = (_ mark: DropPlainRenderMark) -> Void
    
    // MARK: Properties
    public var document: Document
    public var rules: [DropRule]
    
    private var renderSet: Set<DropContants.IntRange> = .init()
    
    // MARK: Init
    public init(string: String, using rules: [DropRule]) {
        self.document = .init(raw: string)
        self.rules = rules
    }
    
    // MARK: Render
    public func render() -> Result {
        render(formatCapture: { _ in })
    }
    
    public func render(replaceRenderContent: ReplaceRenderContentClosure = { _,_,raw,render in (raw, render) }, formatCapture: FormatCaptureClosure) -> Result {
        
        /// - Tag: AST
        let ast = Dropper(document: document).process(using: rules)
        
        /// - Tag: Render
        return render(
            block: ast.containers(),
            isLastLine: false,
            paragraphOffset: 0,
            replaceRenderContent: replaceRenderContent,
            formatCapture: formatCapture
        )
    }
    
    private func render(block multiParagraphs: [DropContainerNode], isLastLine: Bool, paragraphOffset: Int, replaceRenderContent: ReplaceRenderContentClosure, formatCapture: FormatCaptureClosure) -> Result {
        
        var offset = paragraphOffset
        
        var result: String = ""
        
        var stack = Array(multiParagraphs.reversed())
        
        while let child = stack.popLast() {
            
            let paragraphText: String
            
            switch child.type {
            case .document:
                paragraphText = ""
                
            case .block:
                // TODO: 不用递归
                paragraphText = render(
                    block: child.containers(),
                    isLastLine: child.isLastLine,
                    paragraphOffset: offset,
                    replaceRenderContent: replaceRenderContent,
                    formatCapture: formatCapture
                )
                
            case .paragraph:
                paragraphText = render(
                    paragraph: child,
                    paragraphOffset: offset,
                    replaceRenderContent: replaceRenderContent,
                    formatCapture: formatCapture
                )
                
            case .break:
                paragraphText = render(
                    break: child,
                    paragraphOffset: offset,
                    replaceRenderContent: replaceRenderContent,
                    formatCapture: formatCapture
                )
            }
            
            offset += paragraphText.count
            
            result += paragraphText
            
        }
        
        return result
    }
    
    private func render(paragraph: DropContainerNode, paragraphOffset: Int, replaceRenderContent: ReplaceRenderContentClosure, formatCapture: FormatCaptureClosure) -> Result {
        
        render(
            paragraphOffset: paragraphOffset,
            paragraph: paragraph,
            isBreak: false,
            replaceRenderContent: replaceRenderContent,
            formatCapture: formatCapture
        )
    }
    
    private func render(break paragraph: DropContainerNode, paragraphOffset: Int, replaceRenderContent: ReplaceRenderContentClosure, formatCapture: FormatCaptureClosure) -> Result {
        render(
            paragraphOffset: paragraphOffset,
            paragraph: paragraph,
            isBreak: true,
            replaceRenderContent: replaceRenderContent,
            formatCapture: formatCapture
        )
    }
    
    private func render(paragraphOffset: Int, paragraph: DropContainerNode, isBreak: Bool, replaceRenderContent: ReplaceRenderContentClosure, formatCapture: FormatCaptureClosure) -> Result {
        
        /// - Tag: Clear
        renderSet = []
        
        /// - Tag: Offset
        var offset = 0
        
        /// - Tag: Contents
        var result = paragraph.leaves
            .sorted(by: { $0.intRange.location < $1.intRange.location })
            .reduce("", {
                
                var (rawContent, renderContent) = ($1.rawContent, $1.rawRenderContent)
                
                if let content = $1 as? DropContentMarkNode {
                    
                    (rawContent, renderContent) = replaceRenderContent(
                        content.type, content.mark, content.rawContent, content.rawRenderContent
                    )
                    
                    let mark = DropPlainRenderMark(
                        renderDocRange: .init(
                            location: offset + paragraphOffset,
                            length: renderContent.count
                        ),
                        docRange: $1.documentRange,
                        type: content.type,
                        markType: content.mark,
                        content: rawContent,
                        isReplaceRenderContent: $1.rawRenderContent != renderContent
                    )
                    
                    formatCapture(mark)
                }
                
                guard renderSet.contains($1.intRange) == false else {
                    return $0
                }
                renderSet.insert($1.intRange)
                
                guard renderContent.isEmpty == false else {
                    return $0
                }
                
                offset += renderContent.count
                
                return $0 + renderContent
            })
        
        /// - Tag: Empty line
        if isBreak, result.isEmpty { result = "\n" }
        
        /// - Tag: Clear
        renderSet = []
        
        return result
    }
    
    // MARK: Rerender
    public func rerender(string: String) -> Result {
        rerender(
            string: string,
            replaceRenderContent: { _,_,raw,render in (raw, render) },
            formatCapture: { _ in }
        )
    }
    
    public func rerender(string: String, replaceRenderContent: ReplaceRenderContentClosure = { _,_,raw,render in (raw, render) }, formatCapture: FormatCaptureClosure) -> Result {
        
        /// - Tag: Update Raw
        document.raw = string
        
        /// - Tag: AST
        let ast = Dropper(document: document).process(using: rules)
        
        /// - Tag: Render
        return render(
            block: ast.containers(),
            isLastLine: false,
            paragraphOffset: 0,
            replaceRenderContent: replaceRenderContent,
            formatCapture: formatCapture
        )
        
    }
    
    // MARK: Recover
    public static func renderAndDropMarks(string: String, using rules: [DropRule], replaceRenderContent: ReplaceRenderContentClosure = { _,_,raw,render in (raw, render) }, formatCapture: FormatCaptureClosure = { _ in }) -> (marks: [DropPlainRenderMark], plain: Result) {
        
        var marks: [DropPlainRenderMark] = []
        
        let plain = PlainTextRender(string: string, using: rules).render(
            replaceRenderContent: replaceRenderContent,
            formatCapture: { mark in
                if mark.shouldRecoverMark { marks.append(mark) }
                formatCapture(mark)
//                print(#function, #line, mark)
            }
        )
        
        return (marks, plain)
    }
    
    public static func recover(by marks: [DropPlainRenderMark], in renderResult: inout Result, replaceContent: (_ mark: DropPlainRenderMark, _ content: String) -> String = { _,content in content }) {

        let start = renderResult.startIndex
        var end = renderResult.endIndex
        
        var offset = 0
        
        for mark in marks {
            
            let location = mark.renderDocRange.location + offset
            let length = mark.renderDocRange.length
            
            var content = mark.content
            content = replaceContent(mark, content)
            
            if length == 0 {
                
                guard
                    let index = renderResult.index(
                        start,
                        offsetBy: location,
                        limitedBy: end
                    )
                else {
                    continue
                }
                
                renderResult.insert(contentsOf: content, at: index)
                
                offset += content.count
                
            } else {
                
                guard
                    let startIndex = renderResult.index(
                        start,
                        offsetBy: location,
                        limitedBy: end
                    ),
                    let endIndex = renderResult.index(
                        startIndex,
                        offsetBy: length,
                        limitedBy: end
                    )
                else {
                    continue
                }
                
                let oldCount = renderResult.count
                
                renderResult.replaceSubrange(startIndex ..< endIndex, with: content)
                
                offset += renderResult.count - oldCount
                
            }
            
            end = renderResult.endIndex
            
        }
        
    }
    
}

public struct DropPlainRenderMark: CustomStringConvertible, Hashable {
    
    // MARK: Properties
    public var renderDocRange: DropContants.IntRange
    public var docRange: DropContants.IntRange
    public var type: DropContentType
    public var markType: DropContentMarkType
    public var content: String
    public var isReplaceRenderContent: Bool
    
    public var renderType: DropRenderType {
        .init(type: type, mark: markType)
    }
    
    public var shouldRecoverMark: Bool {
        isReplaceRenderContent || (markType != .none && markType != .text)
    }
    
    public var lineDescription: String {
        "{ renderDocRange: \(renderDocRange), type: \(type), markType: \(markType), renderType: \(renderType), content: \(content), isReplaceRenderContent: \(isReplaceRenderContent) }"
    }
    
    public var description: String {
        """
        \nrenderDocRange: \(renderDocRange),
        docRange: \(docRange),
        type: \(type),
        markType: \(markType),
        renderType: \(renderType),
        content: \(content),
        isReplaceRenderContent: \(isReplaceRenderContent)
        """
    }
    
    // MARK: Init
    public init(renderDocRange: DropContants.IntRange = .init(), docRange: DropContants.IntRange = .init(), type: DropContentType = .text, markType: DropContentMarkType = .text, content: String = .init(), isReplaceRenderContent: Bool = false) {
        
        self.renderDocRange = renderDocRange
        self.docRange = docRange
        self.type = type
        self.markType = markType
        self.content = content
        self.isReplaceRenderContent = isReplaceRenderContent
    }
    
}
