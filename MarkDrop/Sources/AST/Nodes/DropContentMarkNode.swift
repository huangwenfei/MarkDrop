//
//  DropContentMarkNode.swift
//  MarkDrop
//
//  Created by windy on 2024/5/14.
//

import Foundation

public class DropContentMarkNode: DropNode {
    
    // MARK: Properties
    /// instance.type !=== .none
    public var type: DropContentType = .text
    public var mark: DropContentMarkType = .none
    
    public override var lineDescription: String {
        "{ markType: \(type), mark: \(mark), rawContent: \(rawContent), range: \(range), intRange: \(intRange), docRange: \(documentRange) }"
    }
    
    public override var description: String {
        """
        \ntype: \(type),
        mark: \(mark)
        rawContent: \(rawContent),
        range: \(range),
        intRange: \(intRange),
        docRange: \(documentRange),
        parent: \(parentNode?.lineDescription ?? "nil"),
        children.count: \(children.count),
        children: [ \(children.reduce("", { $0 + ", " + $1.lineDescription }).dropFirst(2)) ]\n
        """
    }
    
    // MARK: Init
    public init(type: DropContentType, mark: DropContentMarkType) {
        self.type = type
        self.mark = mark
        super.init()
    }
    
    // MARK: Hashable
    public static func == (lhs: DropContentMarkNode, rhs: DropContentMarkNode) -> Bool {
        DropNode.equal(lhs: lhs, rhs: rhs) &&
        lhs.type == rhs.type &&
        lhs.mark == rhs.mark
    }
    
    public override func hash(into hasher: inout Hasher) {
        DropNode.hash(self, into: &hasher)
        hasher.combine(type)
        hasher.combine(mark)
    }
    
}
