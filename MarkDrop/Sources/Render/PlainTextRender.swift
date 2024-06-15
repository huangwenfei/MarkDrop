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
    public typealias ReplaceRenderContentClosure = (_ type: DropContentType, _ content: String) -> (render: String, markRender: String)
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
    
    public func render(replaceRenderContent: ReplaceRenderContentClosure = { _,raw in (raw, raw) }, formatCapture: FormatCaptureClosure) -> Result {
        
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
                
                var (renderContent, markRenderContent) = ($1.rawRenderContent, $1.rawRenderContent)
                
                if let content = $1 as? DropContentNodeProtocol {
                    (renderContent, markRenderContent) = replaceRenderContent(
                        content.type, content.rawRenderContent
                    )
                }
                
                if let content = $1 as? DropContentMarkNode {
                    
                    let mark = DropPlainRenderMark(
                        renderDocLocation: offset + paragraphOffset,
                        docRange: $1.documentRange,
                        type: content.type,
                        markType: content.mark,
                        content: $1.rawContent,
                        renderContent: markRenderContent
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
            replaceRenderContent: { _,raw in (raw, raw) },
            formatCapture: { _ in }
        )
    }
    
    public func rerender(string: String, replaceRenderContent: ReplaceRenderContentClosure = { _,raw in (raw, raw) }, formatCapture: FormatCaptureClosure) -> Result {
        
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
    public static func renderAndDropMarks(string: String, using rules: [DropRule], replaceRenderContent: ReplaceRenderContentClosure = { _,raw in (raw, raw) }, formatCapture: FormatCaptureClosure = { _ in }) -> (marks: [DropPlainRenderMark], plain: Result) {
        
        var marks: [DropPlainRenderMark] = []
        
        let plain = PlainTextRender(string: string, using: rules).render(
            replaceRenderContent: replaceRenderContent,
            formatCapture: { mark in
                if mark.shouldRecoverMark { marks.append(mark) }
                formatCapture(mark)
                print(#function, #line, mark)
            }
        )
        
        return (marks, plain)
    }
    
    public static func recover(by marks: [DropPlainRenderMark], in renderResult: inout Result) {

        let start = renderResult.startIndex
        var end = renderResult.endIndex
        
        var offset = 0
        
        for mark in marks {
            
            let insertLocation = mark.renderDocLocation + offset
            
            if mark.renderContent.isEmpty {
                
                guard
                    let index = renderResult.index(
                        start,
                        offsetBy: insertLocation,
                        limitedBy: end
                    )
                else {
                    continue
                }
                
                renderResult.insert(contentsOf: mark.content, at: index)
                
                offset += mark.docRange.length
                
            } else {
                
                guard
                    let startIndex = renderResult.index(
                        start,
                        offsetBy: insertLocation,
                        limitedBy: end
                    ),
                    let endIndex = renderResult.index(
                        startIndex,
                        offsetBy: mark.renderContent.count,
                        limitedBy: end
                    )
                else {
                    continue
                }
                
                renderResult.replaceSubrange(startIndex ..< endIndex, with: mark.content)
                
                offset += (mark.content.count - mark.renderContent.count)
                
            }
            
            end = renderResult.endIndex
            
        }
        
    }
    
}

public struct DropPlainRenderMark: CustomStringConvertible, Hashable {
    
    // MARK: Properties
    public var renderDocLocation: Int
    public var docRange: DropContants.IntRange
    public var type: DropContentType
    public var markType: DropContentMarkType
    public var renderType: DropRenderType { .init(type: type, mark: markType) }
    public var content: String
    public var renderContent: String
    
    public var shouldRecoverMark: Bool {
        content != renderContent
    }
    
    public var lineDescription: String {
        "{ renderDocLocation: \(renderDocLocation), type: \(type), markType: \(markType), renderType: \(renderType), content: \(content), renderContent: \(renderContent) }"
    }
    
    public var description: String {
        """
        \nrenderDocLocation: \(renderDocLocation),
        docRange: \(docRange),
        type: \(type),
        markType: \(markType),
        renderType: \(renderType),
        content: \(content),
        renderContent: \(renderContent)
        """
    }
    
    // MARK: Init
    public init(renderDocLocation: Int = 0, docRange: DropContants.IntRange = .init(), type: DropContentType = .text, markType: DropContentMarkType = .text, content: String = .init(), renderContent: String = .init()) {
        
        self.renderDocLocation = renderDocLocation
        self.docRange = docRange
        self.type = type
        self.markType = markType
        self.content = content
        self.renderContent = renderContent
    }
    
}
