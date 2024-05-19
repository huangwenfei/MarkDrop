//
//  DropParagraphIndent.swift
//  MarkDrop
//
//  Created by windy on 2024/5/19.
//

import Foundation

public struct DropParagraphIndent: Hashable {
    
    // MARK: Properties
    public var indentation: CGFloat
    public var mode: DropParagraphIndentMode
    
    // MARK: Init
    public init(indentation: CGFloat, mode: DropParagraphIndentMode) {
        self.indentation = indentation
        self.mode = mode
    }
    
}

public struct DropParagraphIndentMode: OptionSet, Hashable {
    
    // MARK: Types
    public typealias RawValue = UInt
    
    // MARK: Properties
    public var rawValue: RawValue
    
    // MARK: Init
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
    // MARK: Values
    public static let firstHeadIndent: Self = .init(rawValue: 1 << 0)
    public static let headIndent: Self = .init(rawValue: 1 << 1)
    public static let tailIndent: Self = .init(rawValue: 1 << 2)
    public static let tabStop: Self = .init(rawValue: 1 << 3)
    
}
