//
//  DropCaptureRenderNode.swift
//  MarkDrop
//
//  Created by windy on 2024/5/20.
//

import Foundation

public struct DropCaptureRenderKey: Hashable {
    
    // MARK: Properties
    public let nodeRange: DropContants.IntRange
    public let docRenderRange: DropContants.IntRange
    
    // MARK: Init
    public init(nodeRange: DropContants.IntRange, docRenderRange: DropContants.IntRange) {
        self.nodeRange = nodeRange
        self.docRenderRange = docRenderRange
    }
    
    internal init(nodeRange: DropContants.IntRange) {
        self.nodeRange = nodeRange
        self.docRenderRange = .init()
    }
    
    // MARK: Hashable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.nodeRange == rhs.nodeRange
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(nodeRange)
    }
    
}

public final class DropCaptureRenderNode {
    
    // MARK: Properties
    public let docRenderRange: DropContants.IntRange
    public let paragraphRenderRange: DropContants.IntRange
    public let bindAttributes: DropContants.AttributedDict
    public var nodes: [DropNode]
    
    // MARK: Init
    public init(
        docRenderRange: DropContants.IntRange,
        paragraphRenderRange: DropContants.IntRange,
        bindAttributes: DropContants.AttributedDict,
        nodes: [DropNode]
    ) {
        self.docRenderRange = docRenderRange
        self.paragraphRenderRange = paragraphRenderRange
        self.bindAttributes = bindAttributes
        self.nodes = nodes
    }
    
}
