//
//  ExpandAttributes.swift
//  MarkDrop
//
//  Created by windy on 2024/5/29.
//

import Foundation

public struct ExpandAttributes: Hashable {
    
    // MARK: Properties
    public var background: BorderAttributes
    
    // MARK: Init
    public init(background: BorderAttributes) {
        self.background = background
    }
    
}

extension AttributesKey {
    
    public static var expand: Self {
        .init(rawValue: "drop.attributes.expand.key")
    }
    
    public static var expandBackgroundActions: Self {
        .init(rawValue: "drop.attributes.expand.background.key")
    }
    
}
