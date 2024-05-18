//
//  DropAction.swift
//  MarkDrop
//
//  Created by windy on 2024/5/18.
//

import Foundation

public final class DropAction: Hashable {
    
    // MARK: Properties
    public weak var target: NSObject!
    public var action: Selector
    
    // MARK: Init
    public init(target: NSObject, action: Selector) {
        self.target = target
        self.action = action
    }
    
    // MARK: Hashable
    public static func == (lhs: DropAction, rhs: DropAction) -> Bool {
        lhs.target === rhs.target &&
        lhs.action == rhs.action
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(target)
        hasher.combine(action)
    }
    
}
