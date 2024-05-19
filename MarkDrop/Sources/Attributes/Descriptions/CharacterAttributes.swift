//
//  CharacterAttributes.swift
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

public struct CharacterAttributes: Hashable {
    
    // MARK: Properties
    public var color: DropColor
    public var font: DropFont
    public var kern: CGFloat
    
    // MARK: Init
    public init(
        color: DropColor = .white,
        font: DropFont = .systemFont(ofSize: 16, weight: .regular),
        kern: CGFloat = 0
    ) {
        self.color = color
        self.font = font
        self.kern = kern
    }
    
}

extension AttributesKey {
    
    public static var character: Self {
        .init(rawValue: "drop.attributes.character.key")
    }
    
    public static var characterColor: Self {
        .init(rawValue: "drop.attributes.character.color.key")
    }
    
    public static var characterFont: Self {
        .init(rawValue: "drop.attributes.character.font.key")
    }
    
    public static var characterKern: Self {
        .init(rawValue: "drop.attributes.character.kern.key")
    }
    
}
