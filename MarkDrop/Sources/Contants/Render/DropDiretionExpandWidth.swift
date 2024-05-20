//
//  DropDiretionExpandWidth.swift
//  MarkDrop
//
//  Created by windy on 2024/5/20.
//

import Foundation

public struct DropDiretionExpandWidth: Hashable {
    
    // MARK: Properties
    public var leading: CGFloat
    public var trailing: CGFloat
    
    // MARK: Init
    public init(leading: CGFloat = 0, trailing: CGFloat = 0) {
        self.leading = leading
        self.trailing = trailing
    }
    
}

public struct DropDiretionExpandWidthMode: OptionSet {
    
    // MARK: Types
    public typealias RawValue = UInt
    
    // MARK: Properties
    public var rawValue: RawValue
    
    // MARK: Init
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
    // MARK: Values
    
    public static let none: Self = []
    public static let leading: Self = .init(rawValue: 1 << 0)
    public static let trailing: Self = .init(rawValue: 1 << 1)
    public static let both: Self = [.leading, .trailing]
    
}
