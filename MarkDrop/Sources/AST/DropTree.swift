//
//  DropTree.swift
//  MarkDrop
//
//  Created by windy on 2024/5/3.
//

import Foundation

public final class DropTree: Hashable {
    
    // MARK: Types
    public typealias Visitor = (_ node: DropNode, _ isStop: inout Bool) -> Void
    public typealias ContentVisitor = (_ node: DropNode, _ isStop: inout Bool) -> Void
    
    // MARK: Properties
    public var root: DropNode? = nil
    
    // MARK: Init
    public init(document: Document) {
        let container = DropContainerNode()
        container.type = .document
        container.intRange = .init(location: 0, length: document.raw.count)
        self.root = container
    }
    
    // MARK: Append
    public func addChild(_ child: DropNode) {
        root?.children.append(child)
        child.parentNode = root
    }
    
    // MARK: Search
    public func containers() -> [DropContainerNode] {
        (root?.children as? [DropContainerNode]) ?? []
    }
    
    public func lastContainer() -> DropContainerNode? {
        root?.children.last as? DropContainerNode
    }
    
    public func nodes() -> [DropNode] {
        DropTree.nodes(in: root)
    }
    
    public static func nodes(in root: DropNode?) -> [DropNode] {
        var result: [DropNode] = []
        depthFirstSearch(in: root) { node, _ in
            result.append(node)
        }
        return result
    }
    
    public func node(by range: DropContants.IntRange) -> DropNode? {
        var result: DropNode? = nil
        depthFirstSearch { node, isStop in
            isStop = (node.intRange == range)
            if isStop { result = node }
        }
        return result
    }
    
    public func node(byDoc range: DropContants.IntRange) -> DropNode? {
        var result: DropNode? = nil
        depthFirstSearch { node, isStop in
            isStop = (node.documentRange == range)
            if isStop { result = node }
        }
        return result
    }
    
    public func node(by type: DropContainerType) -> [DropNode] {
        var result: [DropNode] = []
        depthFirstSearch { node, _ in
            if (node as? DropContainerNode)?.type == type {
                result.append(node)
            }
        }
        return result
    }
    
    public func nodes(by type: DropContentType) -> [DropNode] {
        var result: [DropNode] = []
        depthFirstSearch { node, _ in
            if (node as? DropContentNode)?.type == type {
                result.append(node)
            }
        }
        return result
    }
    
    public func depthFirstSearch(visitor: Visitor) {
        DropTree.depthFirstSearch(in: root, visitor: visitor)
    }
    
    public static func depthFirstSearch(in root: DropNode?, visitor: Visitor) {
        guard let root else { return }
        
        var isStop: Bool = false
        var stack: [DropNode] = [root]
        
        while let node = stack.popLast() {
            /// - Tag: Node
            visitor(node, &isStop)
            if isStop { return }
            
            /// - Tag: Node Children
            stack.append(contentsOf: node.children.reversed())
        }
        
    }
    
    public func breadthFirstSearch(visitor: Visitor) {
        guard let root else { return }
        
        var isStop: Bool = false
        var queue: [DropNode] = [root]
        
        while queue.isEmpty == false {
            
            let node = queue.removeFirst()
            
            /// - Tag: Node
            visitor(node, &isStop)
            if isStop { return }
            
            queue.append(contentsOf: node.children)
        }
        
    }
    
    public func depthFirstSearchContentNode(visitor: ContentVisitor) {
        guard let root else { return }
        
        var isStop: Bool = false
        var stack: [DropNode] = [root]
        
        while let node = stack.popLast() {
            /// - Tag: Node
            if let contentNode = node as? DropContentNode {
                visitor(contentNode, &isStop)
            }
            if isStop { return }
            
            /// - Tag: Node Children
            stack.append(contentsOf: node.children.reversed())
        }
        
    }
    
    public func breadthFirstSearchContentNode(visitor: ContentVisitor) {
        guard let root else { return }
        
        var isStop: Bool = false
        var queue: [DropNode] = [root]
        
        while queue.isEmpty == false {
            
            let node = queue.removeFirst()
            
            /// - Tag: Node
            if let contentNode = node as? DropContentNode {
                visitor(contentNode, &isStop)
            }
            if isStop { return }
            
            queue.append(contentsOf: node.children)
        }
        
    }
    
    // MARK: Hashable
    public static func == (lhs: DropTree, rhs: DropTree) -> Bool {
        lhs.root === rhs.root
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(root)
    }
    
}

extension DropNode {
    
    public var nodes: [DropNode] {
        DropTree.nodes(in: self)
    }
    
    public var leaves: [DropNode] {
        var nodes: [DropNode] = []
        DropTree.depthFirstSearch(in: self) { node, isStop in
            guard node.isLeafNode else { return }
            nodes.append(node)
        }
        return nodes
    }
    
    public var texts: [DropNode] {
        var nodes: [DropNode] = []
        DropTree.depthFirstSearch(in: self) { node, isStop in
            guard node.isLeafNode, node.rawRenderContent.isEmpty == false else { return }
            nodes.append(node)
        }
        return nodes
    }
    
    public func depthFirstSearch(visitor: @escaping (_ node: DropNode) -> Void) {
        DropTree.depthFirstSearch(in: self) { node,_ in
            visitor(node)
        }
    }
    
}
