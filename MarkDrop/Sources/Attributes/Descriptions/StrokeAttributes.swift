//
//  StrokeAttributes.swift
//  MarkDrop
//
//  Created by windy on 2024/5/12.
//

import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct StrokeAttributes: Hashable {
    
    // MARK: Properties
    public var color: DropColor
    public var width: CGFloat
    
    // MARK: Init
    public init(color: DropColor = .black, width: CGFloat = 0) {
        self.color = color
        self.width = width
    }
    
}

extension AttributesKey {
    
    public static var stroke: Self {
        .init(rawValue: "drop.attributes.stroke.key")
    }
    
    public static var strokeColor: Self {
        .init(rawValue: "drop.attributes.stroke.color.key")
    }
    
    public static var strokeWidth: Self {
        .init(rawValue: "drop.attributes.stroke.width.key")
    }
    
}
