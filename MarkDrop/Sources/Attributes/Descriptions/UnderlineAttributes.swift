//
//  UnderlineAttributes.swift
//  MarkDrop
//
//  Created by windy on 2024/5/16.
//

import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct UnderlineAttributes: Hashable {
    
    // MARK: Properties
    public var color: DropColor
    public var width: CGFloat
    public var margins: CGFloat
    public var mode: Mode
    
    // MARK: Init
    public init(
        color: DropColor = .black,
        width: CGFloat = 0,
        margins: CGFloat = 1,
        mode: Mode = .single
    ) {
        self.color = color
        self.width = width
        self.margins = margins
        self.mode = mode
    }
    
}

extension UnderlineAttributes {
    
    public enum Mode: Int {
        case single, thick, double,
             patternDot, patternDash, patternDashDot, patternDashDotDot,
             byWord
        
        public var style: NSUnderlineStyle {
            switch self {
            case .single:            return .single
            case .thick:             return .thick
            case .double:            return .double
            case .patternDot:        return .patternDot
            case .patternDash:       return .patternDash
            case .patternDashDot:    return .patternDashDot
            case .patternDashDotDot: return .patternDashDotDot
            case .byWord:            return .byWord
            }
        }
    }
    
}

extension AttributesKey {
    
    public static var underline: Self {
        .init(rawValue: "drop.attributes.underline.key")
    }
    
    public static var underlineColor: Self {
        .init(rawValue: "drop.attributes.underline.color.key")
    }
    
    public static var underlineWidth: Self {
        .init(rawValue: "drop.attributes.underline.width.key")
    }
    
    public static var underlineMargins: Self {
        .init(rawValue: "drop.attributes.underline.margins.key")
    }
    
    public static var underlineMode: Self {
        .init(rawValue: "drop.attributes.underline.mode.key")
    }
    
}
