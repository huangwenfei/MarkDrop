//
//  DropContentNode.swift
//  MarkDrop
//
//  Created by windy on 2024/5/3.
//

import Foundation

public class DropContentNode: DropNode {
    
    // MARK: Properties
    public var type: DropContentType = .text
    
    /// for capture
//    public internal(set) var rule: DropContentRule? = nil
//    public internal(set) var tokenState: DropContentTokenRuleState = .idle
//    public internal(set) var tagState: DropContentTagRuleState = .idle
    
    public override var lineDescription: String {
        "{ type: \(type), contents: \(contents), rawContentIndices: \(rawContentIndices), range: \(range), intRange: \(intRange), docRange: \(documentRange) }"
    }
    
    public override var description: String {
        """
        \ntype: \(type),
        contents: \(contents),
        rawContentIndices: \(rawContentIndices),
        range: \(range),
        intRange: \(intRange),
        docRange: \(documentRange),
        parent: \(parentNode?.lineDescription ?? "nil"),
        children.count: \(children.count),
        children: [ \(children.reduce("", { $0 + ", " + $1.lineDescription }).dropFirst(2)) ]\n
        """
    }
    
    // MARK: Init
    public init(type: DropContentType) {
        super.init()
        change(to: type)
    }
    
    // MARK: Change
    public func change(to type: DropContentType) {
        self.type = type
    }
    
    // MARK: Hashable
    public static func == (lhs: DropContentNode, rhs: DropContentNode) -> Bool {
        DropNode.equal(lhs: lhs, rhs: rhs) &&
        lhs.type == rhs.type
    }
    
    public override func hash(into hasher: inout Hasher) {
        DropNode.hash(self, into: &hasher)
        hasher.combine(type)
    }
    
}
