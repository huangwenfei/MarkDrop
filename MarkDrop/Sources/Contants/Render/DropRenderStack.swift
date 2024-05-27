//
//  DropRenderStack.swift
//  MarkDrop
//
//  Created by windy on 2024/5/27.
//

import Foundation

public final class DropParagraphRender: CustomStringConvertible {
    
    // MARK: Properties
    public var type: DropContainerType
    public var renderRange: DropContants.IntRange
    public var renderDocRange: DropContants.IntRange { renderRange }
    public var paragraphRange: DropContants.IntRange
    public var docRange: DropContants.IntRange
    public var children: [DropRenderStack]
    
    public var description: String {
        """
        \ntype: \(type),
        renderRange: \(renderRange),
        paragraphRange: \(paragraphRange),
        docRange: \(docRange),
        children: \(children.map({ $0.lineDescription }))
        """
    }
    
    // MARK: Init
    public init(type: DropContainerType, renderRange: DropContants.IntRange = .init(), paragraphRange: DropContants.IntRange, docRange: DropContants.IntRange, children: [DropRenderStack]) {
        
        self.type = type
        self.renderRange = renderRange
        self.paragraphRange = paragraphRange
        self.docRange = docRange
        self.children = children
    }
    
}

public final class DropRenderStack: CustomStringConvertible {
    
    // MARK: Properties
    public var renderRange: DropContants.IntRange
    public var renderDocRange: DropContants.IntRange
    public var paragraphRange: DropContants.IntRange
    public var docRange: DropContants.IntRange
    public var type: DropContentType
    public var renderType: DropRenderType
    public var content: String
    public var attribute: TextAttributes
    
    public var lineDescription: String {
        "{ range: \(renderRange), renderDocRange: \(renderDocRange), type: \(type), renderType: \(renderType), content: \(content) }"
    }
    
    public var description: String {
        """
        \nrenderRange: \(renderRange),
        renderDocRange: \(renderDocRange),
        paragraphRange: \(paragraphRange),
        docRange: \(docRange),
        type: \(type),
        renderType: \(renderType),
        content: \(content),
        attribute: \(attribute)
        """
    }
    
    // MARK: Init
    public init(renderRange: DropContants.IntRange = .init(), renderDocRange: DropContants.IntRange = .init(), paragraphRange: DropContants.IntRange = .init(), docRange: DropContants.IntRange = .init(), type: DropContentType = .text, renderType: DropRenderType = .text, content: String = .init(), attribute: TextAttributes = .init()) {
        
        self.renderRange = renderRange
        self.renderDocRange = renderDocRange
        self.paragraphRange = paragraphRange
        self.docRange = docRange
        self.type = type
        self.renderType = renderType
        self.attribute = attribute
        self.content = content
    }
    
}
