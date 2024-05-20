//
//  BorderAttributes.swift
//  MarkDrop
//
//  Created by windy on 2024/5/13.
//

import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct BorderAttributes: Hashable {
    
    // MARK: Properties
    public var color: DropColor
    public var lineMode: DropLineMode
    public var width: CGFloat
    public var cornerRadius: CGFloat
    public var fillColor: DropColor
    public var paddings: DropPaddings
    
    // MARK: Init
    public init(
        color: DropColor = .white,
        lineMode: DropLineMode = .single,
        width: CGFloat = 1,
        cornerRadius: CGFloat = 0,
        fillColor: DropColor = .clear,
        paddings: DropPaddings = .zero
    ) {
        self.color = color
        self.lineMode = lineMode
        self.width = width
        self.cornerRadius = cornerRadius
        self.fillColor = fillColor
        self.paddings = paddings
    }
    
    // MARK: Hashable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.color == rhs.color &&
        lhs.lineMode == rhs.lineMode &&
        lhs.width == rhs.width &&
        lhs.cornerRadius == rhs.cornerRadius &&
        lhs.fillColor == rhs.fillColor &&
        lhs.paddings == rhs.paddings
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(color)
        hasher.combine(lineMode)
        hasher.combine(width)
        hasher.combine(cornerRadius)
        hasher.combine(fillColor)
        hasher.combine(paddings.top)
        hasher.combine(paddings.left)
        hasher.combine(paddings.bottom)
        hasher.combine(paddings.right)
    }
    
}

extension AttributesKey {
    
    public static var border: Self {
        .init(rawValue: "drop.attributes.border.key")
    }
    
    public static var borderColor: Self {
        .init(rawValue: "drop.attributes.border.color.key")
    }
    
    public static var borderLineMode: Self {
        .init(rawValue: "drop.attributes.border.lineMode.key")
    }
    
    public static var borderWidth: Self {
        .init(rawValue: "drop.attributes.border.width.key")
    }
    
    public static var borderCornerRadius: Self {
        .init(rawValue: "drop.attributes.border.cornerRadius.key")
    }
    
    public static var borderFillColor: Self {
        .init(rawValue: "drop.attributes.border.fillColor.key")
    }
    
    public static var borderPaddings: Self {
        .init(rawValue: "drop.attributes.border.paddings.key")
    }
    
}

extension AttributesKey {
    
    public static var backgroundBorder: Self {
        .init(rawValue: "drop.attributes.border.background.key")
    }
    
    public static var backgroundBorderColor: Self {
        .init(rawValue: "drop.attributes.border.background.color.key")
    }
    
    public static var backgroundBorderLineMode: Self {
        .init(rawValue: "drop.attributes.border.background.lineMode.key")
    }
    
    public static var backgroundBorderWidth: Self {
        .init(rawValue: "drop.attributes.border.background.width.key")
    }
    
    public static var backgroundBorderCornerRadius: Self {
        .init(rawValue: "drop.attributes.border.background.cornerRadius.key")
    }
    
    public static var backgroundBorderFillColor: Self {
        .init(rawValue: "drop.attributes.border.background.fillColor.key")
    }
    
    public static var backgroundBorderPaddings: Self {
        .init(rawValue: "drop.attributes.border.background.paddings.key")
    }
    
}
