//
//  AttributesKey.swift
//  MarkDrop
//
//  Created by windy on 2024/5/18.
//

import Foundation

public struct AttributesKey: RawRepresentable, Hashable {
    
    // MARK: Types
    public typealias RawValue = String
    
    // MARK: Properties
    public var rawValue: RawValue
    
    // MARK: Init
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
    // MARK: Methods
    public var attributed: NSAttributedString.Key {
        .init(rawValue: rawValue)
    }
    
}
