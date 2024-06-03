//
//  DropRenderStack.swift
//  MarkDrop
//
//  Created by windy on 2024/5/27.
//

import Foundation

public protocol DropRenderStackProtocol: AnyObject {
    var renderRange: DropContants.IntRange { get set }
    var renderDocRange: DropContants.IntRange { get }
    var paragraphRange: DropContants.IntRange { get set }
    var docRange: DropContants.IntRange { get set }
    var lineDescription: String { get }
}

public final class DropParagraphRender: DropRenderStackProtocol, CustomStringConvertible, Hashable {
    
    // MARK: Properties
    public var parentType: DropContainerRenderType?
    public var type: DropContainerType
    public var renderRange: DropContants.IntRange
    public var renderDocRange: DropContants.IntRange { renderRange }
    public var paragraphRange: DropContants.IntRange
    public var docRange: DropContants.IntRange
    public var children: [DropRenderStackProtocol]
    
    public var lineDescription: String {
        "{ type: \(type), parentType: \(String(describing: parentType)), range: \(renderRange), renderDocRange: \(renderDocRange) }"
    }
    
    public var description: String {
        """
        \nparentType:\(String(describing: parentType)),
        type: \(type),
        renderRange: \(renderRange),
        paragraphRange: \(paragraphRange),
        docRange: \(docRange),
        children: \(children.map({ $0.lineDescription }))
        """
    }
    
    // MARK: Init
    public init(parentType: DropContainerRenderType? = nil, type: DropContainerType = .document, renderRange: DropContants.IntRange = .init(), paragraphRange: DropContants.IntRange = .init(), docRange: DropContants.IntRange = .init(), children: [DropRenderStackProtocol] = []) {
        
        self.parentType = parentType
        self.type = type
        self.renderRange = renderRange
        self.paragraphRange = paragraphRange
        self.docRange = docRange
        self.children = children
    }
    
    // MARK: Content
    public var contents: [DropRenderStack]? {
        children as? [DropRenderStack]
    }
    
    // MARK: Hashable
    public static func ==(lhs: DropParagraphRender, rhs: DropParagraphRender) -> Bool {
        lhs.parentType == rhs.parentType &&
        lhs.renderRange == rhs.renderRange &&
        lhs.renderDocRange == rhs.renderDocRange &&
        lhs.paragraphRange == rhs.paragraphRange &&
        lhs.docRange == rhs.docRange &&
        lhs.type == rhs.type
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(parentType)
        hasher.combine(renderRange)
        hasher.combine(renderDocRange)
        hasher.combine(paragraphRange)
        hasher.combine(docRange)
        hasher.combine(type)
    }
    
}

public final class DropRenderStack: DropRenderStackProtocol, CustomStringConvertible, Hashable {
    
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
    
    // MARK: Hashable
    public static func ==(lhs: DropRenderStack, rhs: DropRenderStack) -> Bool {
        lhs.renderRange == rhs.renderRange &&
        lhs.renderDocRange == rhs.renderDocRange &&
        lhs.paragraphRange == rhs.paragraphRange &&
        lhs.docRange == rhs.docRange &&
        lhs.type == rhs.type &&
        lhs.renderType == rhs.renderType &&
        lhs.attribute == rhs.attribute &&
        lhs.content == rhs.content
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(renderRange)
        hasher.combine(renderDocRange)
        hasher.combine(paragraphRange)
        hasher.combine(docRange)
        hasher.combine(type)
        hasher.combine(renderType)
        hasher.combine(attribute)
        hasher.combine(content)
    }
    
}
