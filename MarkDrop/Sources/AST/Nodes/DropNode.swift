//
//  DropNode.swift
//  MarkDrop
//
//  Created by windy on 2024/5/3.
//

import Foundation

public class DropNode: Hashable, CustomStringConvertible {
    
    // MARK: Properties
    public var contents: [String] = []
    public var rawContentIndices: [Int] = []
    
    public var renderContents: [String] = []
    public var renderContentOffsets: [Int] = []
    
    public var allContent: String {
        contents.reduce("", { $0 + $1 })
    }
    
    public var rawContents: [String] {
        rawContentIndices.map({
            contents.indices.contains($0) ? contents[$0] : ""
        })
    }
    
    public var rawContent: String {
        rawContents.reduce("", { $0 + $1 })
    }
    
    public var rawRenderContent: String {
        renderContents.reduce("", { $0 + $1 })
    }
    
    public var range: DropContants.Range
    public var intRange: DropContants.IntRange = .init()
    public var documentRange: DropContants.IntRange = .init()
    
    public weak var parentNode: DropNode? = nil
    public var children: [DropNode] = []
    
    public var lineDescription: String {
        "{ contents: \(contents), rawContentIndices: \(rawContentIndices), range: \(range), intRange: \(intRange), docRange: \(documentRange) }"
    }
    
    public var description: String {
        """
        \nparent: \(parentNode?.lineDescription ?? "nil"),
        contents: \(contents),
        rawContentIndices: \(rawContentIndices),
        range: \(range),
        intRange: \(intRange),
        docRange: \(documentRange),
        children.count: \(children.count),
        children: [ \(children.reduce("", { $0 + ", " + $1.lineDescription }).dropFirst(2)) ]\n
        """
    }
    
    // MARK: Init
    public init() {
        range = "".startIndex ... "".endIndex
    }
    
    // MARK: Methods
    public var isRoot: Bool { parentNode == nil }
    public var haveChildren: Bool { children.isEmpty == false }
    public var isLeafNode: Bool { haveChildren == false }
    
    public var exculdeNewlineRange: DropContants.ExculdeNewlineRange {
        range.lowerBound ..< range.upperBound
    }
    
    public var exculdeNewlineIntRange: DropContants.IntRange {
        .init(location: intRange.location, length: max(0, intRange.length - 1))
    }
    
    public var attributedContent: NSAttributedString { fatalError() }
    
    // MARK: Node
    public var first: DropNode? { children.first }
    public var last: DropNode? { children.last }
    
    // MARK: Append
    public func append(_ child: DropNode) {
        children.append(child)
        child.parentNode = self
    }
    
    // MARK: Remove
    public func remove(child: DropNode) {
        children.removeAll(where: { $0 === child })
        child.parentNode = nil
    }
 
    // MARK: Hashable
    public static func == (lhs: DropNode, rhs: DropNode) -> Bool {
        equal(lhs: lhs, rhs: rhs)
    }
    
    public static func equal(lhs: DropNode, rhs: DropNode) -> Bool {
        lhs.contents == rhs.contents &&
        lhs.rawContentIndices == rhs.rawContentIndices &&
        lhs.range == rhs.range &&
        lhs.parentNode?.lineDescription == rhs.parentNode?.lineDescription &&
        lhs.children.reduce("", { $0 + $1.lineDescription }) == rhs.children.reduce("", { $0 + $1.lineDescription })
    }
    
    public func hash(into hasher: inout Hasher) {
        DropNode.hash(self, into: &hasher)
    }
    
    public static func hash(_ node: DropNode, into hasher: inout Hasher) {
        hasher.combine(node.contents)
        hasher.combine(node.rawContentIndices)
        hasher.combine(node.range)
        hasher.combine(node.parentNode?.lineDescription)
        hasher.combine(node.children.reduce("", { $0 + $1.lineDescription }))
    }
    
}
