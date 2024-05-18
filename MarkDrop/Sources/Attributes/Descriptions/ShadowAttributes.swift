//
//  ShadowAttributes.swift
//  MarkDrop
//
//  Created by windy on 2024/5/17.
//

import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct ShadowAttributes: Hashable {
    
    // MARK: Properties
    public var color: DropColor
    public var radius: CGFloat
    public var offset: CGSize
    public var blendMode: CGBlendMode
    
    // MARK: Init
    public init(
        color: DropColor = .black,
        radius: CGFloat = 4,
        offset: CGSize = .init(width: 0, height: 0),
        blendMode: CGBlendMode = .normal
    ) {
        self.color = color
        self.radius = radius
        self.offset = offset
        self.blendMode = blendMode
    }
    
    // MARK: Methods
    public var shadow: NSShadow {
        let result = NSShadow()
        result.shadowColor = color
        result.shadowOffset = offset
        result.shadowBlurRadius = radius
        return result
    }
    
}

extension AttributesKey {
    
    public static var shadow: Self {
        .init(rawValue: "drop.attributes.shadow.key")
    }
    
    public static var shadowColor: Self {
        .init(rawValue: "drop.attributes.shadow.color.key")
    }
    
    public static var shadowRadius: Self {
        .init(rawValue: "drop.attributes.shadow.radius.key")
    }
    
    public static var shadowOffset: Self {
        .init(rawValue: "drop.attributes.shadow.offset.key")
    }
    
    public static var shadowBlendMode: Self {
        .init(rawValue: "drop.attributes.shadow.blendMode.key")
    }
    
}
