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
    public typealias FormatCaptureClosure = (_ type: DropRenderType, _ text: String) -> Void
    
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
        render(formatCapture: { _,_ in })
    }
    
    public func render(formatCapture: FormatCaptureClosure) -> Result {
        
        /// - Tag: AST
        let ast = Dropper(document: document).process(using: rules)
        
        /// - Tag: Render
        return render(block: ast.containers(), isLastLine: false, formatCapture: formatCapture)
    }
    
    private func render(block multiParagraphs: [DropContainerNode], isLastLine: Bool, formatCapture: FormatCaptureClosure) -> Result {
        
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
                    formatCapture: formatCapture
                )
                
            case .paragraph:
                paragraphText = render(paragraph: child, formatCapture: formatCapture)
                
            case .break:
                paragraphText = render(break: child, formatCapture: formatCapture)
            }
            
            result += paragraphText
            
        }
        
        return result
    }
    
    private func render(paragraph: DropContainerNode, formatCapture: FormatCaptureClosure) -> Result {
        render(paragraph: paragraph, isBreak: false, formatCapture: formatCapture)
    }
    
    private func render(break paragraph: DropContainerNode, formatCapture: FormatCaptureClosure) -> Result {
        render(paragraph: paragraph, isBreak: true, formatCapture: formatCapture)
    }
    
    private func render(paragraph: DropContainerNode, isBreak: Bool, formatCapture: FormatCaptureClosure) -> Result {
        
        /// - Tag: Clear
        renderSet = []
        
        /// - Tag: Contents
        var result = paragraph.leaves
            .sorted(by: { $0.intRange.location < $1.intRange.location })
            .reduce("", {
                
                if let content = $1 as? DropContentMarkNode {
                    formatCapture(.init(type: content.type, mark: content.mark), $1.rawRenderContent)
                }
                
                guard renderSet.contains($1.intRange) == false else {
                    return $0
                }
                renderSet.insert($1.intRange)
                
                let string = $1.rawRenderContent
                
                guard string.isEmpty == false else {
                    return $0
                }
                
                return $0 + string
            })
        
        /// - Tag: Empty line
        if isBreak, result.isEmpty { result = "\n" }
        
        /// - Tag: Clear
        renderSet = []
        
        return result
    }
    
    // MARK: Rerender
    public func rerender(string: String) -> Result {
        rerender(string: string, formatCapture: { _,_ in })
    }
    
    public func rerender(string: String, formatCapture: FormatCaptureClosure) -> Result {
        
        /// - Tag: Update Raw
        document.raw = string
        
        /// - Tag: AST
        let ast = Dropper(document: document).process(using: rules)
        
        /// - Tag: Render
        return render(block: ast.containers(), isLastLine: false, formatCapture: formatCapture)
        
    }
    
}
