//
//  DropContainerNode.swift
//  MarkDrop
//
//  Created by windy on 2024/5/3.
//

import Foundation

public class DropContainerNode: DropNode {
    
    // MARK: Properties
    public var type: DropContainerType = .document
    
    public var lineCount: Int = -1
    public var lineIndex: Int = -1
    
    public var isFirstLine: Bool {
        lineIndex == 0
    }
    
    public var isLastLine: Bool {
        lineIndex == lineCount - 1
    }
    
    public override var allContent: String {
        String(children.reduce("", { $0 + "\n" + $1.rawContent }).dropFirst(1))
    }
    
    public var allIntRange: DropContants.IntRange {
        guard let first = children.first else {
            /// 随便一个值
            return .init()
        }
        
        return .init(
            location: first.intRange.location,
            length: children.reduce(0, { $0 + $1.intRange.length }) +
                    children.count - 1 /* newline count */
        )
    }
    
    public override var documentRange: DropContants.IntRange {
        get {
            if type.isBlock {
                return allIntRange
            } else {
                return intRange
            }
        }
        set {
            
        }
    }
    
    public override var lineDescription: String {
        "{ type: \(type), lineIndex: \(lineIndex), contents: \(contents), rawContentIndices: \(rawContentIndices), intRange: \(intRange), docRange: \(documentRange) }"
    }
    
    public override var description: String {
        if type.isBlock {
            return """
            \ntype: \(type),
            lineIndex: \(lineIndex),
            content: \(allContent),
            intRange: \(allIntRange),
            docRange: \(documentRange),
            parent: \(parentNode?.lineDescription ?? "nil"),
            children.count: \(children.count),
            children: [ \(children.reduce("", { $0 + ", " + $1.lineDescription }).dropFirst(2)) ]\n
            """
        } else {
            return """
            \ntype: \(type),
            lineIndex: \(lineIndex),
            contents: \(contents),
            rawContentIndices: \(rawContentIndices),
            intRange: \(intRange),
            docRange: \(documentRange),
            parent: \(parentNode?.lineDescription ?? "nil")\n
            """
        }
        
    }
    
    // MARK: Init
    public override init() { 
        super.init()
    }
    
    // MARK: Nodes
    public func containers() -> [DropContainerNode] {
        (children as? [DropContainerNode]) ?? []
    }
    
    // MARK: Hashable
    public static func == (lhs: DropContainerNode, rhs: DropContainerNode) -> Bool {
        DropNode.equal(lhs: lhs, rhs: rhs) &&
        lhs.type == rhs.type &&
        lhs.lineIndex == rhs.lineIndex
    }
    
    public override func hash(into hasher: inout Hasher) {
        DropNode.hash(self, into: &hasher)
        hasher.combine(type)
        hasher.combine(lineIndex)
    }
    
}
