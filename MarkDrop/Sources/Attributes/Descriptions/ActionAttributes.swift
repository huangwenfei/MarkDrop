//
//  ActionAttributes.swift
//  MarkDrop
//
//  Created by windy on 2024/5/17.
//

import Foundation

public struct ActionAttributes: Hashable {
    
    // MARK: Properties
    public var currentState: DropActionState
    public var actions: [DropActionState: DropAction]
    
    // MARK: Init
    public init(currentState: DropActionState, actions: [DropActionState: DropAction]) {
        self.currentState = currentState
        self.actions = actions
    }
    
}

extension AttributesKey {
    
    public static var action: Self {
        .init(rawValue: "drop.attributes.action.key")
    }
    
    public static var actionCurrentState: Self {
        .init(rawValue: "drop.attributes.action.currentState.key")
    }
    
    public static var actionActions: Self {
        .init(rawValue: "drop.attributes.action.actions.key")
    }
    
}
