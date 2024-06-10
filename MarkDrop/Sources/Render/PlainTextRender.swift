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
        
        /// - Tag: AST
        let ast = Dropper(document: document).process(using: rules)
        
        /// - Tag: Render
        return render(block: ast.containers(), isLastLine: false)
    }
    
    private func render(block multiParagraphs: [DropContainerNode], isLastLine: Bool) -> Result {
        
        var result: String = ""
        
        var stack = Array(multiParagraphs.reversed())
        
        while let child = stack.popLast() {
            
            let paragraphText: String
            
            switch child.type {
            case .document:
                paragraphText = ""
                
            case .block:
                // TODO: 不用递归
                paragraphText = render(block: child.containers(), isLastLine: child.isLastLine)
                
            case .paragraph:
                paragraphText = render(paragraph: child)
                
            case .break:
                paragraphText = render(break: child)
            }
            
            result += paragraphText
            
        }
        
        return result
    }
    
    private func render(paragraph: DropContainerNode) -> Result {
        render(paragraph: paragraph, isBreak: false)
    }
    
    private func render(break paragraph: DropContainerNode) -> Result {
        render(paragraph: paragraph, isBreak: true)
    }
    
    private func render(paragraph: DropContainerNode, isBreak: Bool) -> Result {
        
        /// - Tag: Clear
        renderSet = []
        
        /// - Tag: Contents
        var result = paragraph.leaves
            .sorted(by: { $0.intRange.location < $1.intRange.location })
            .reduce("", {
                
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
        
        /// - Tag: Update Raw
        document.raw = string
        
        /// - Tag: AST
        let ast = Dropper(document: document).process(using: rules)
        
        /// - Tag: Render
        return render(block: ast.containers(), isLastLine: false)
        
    }
    
}
