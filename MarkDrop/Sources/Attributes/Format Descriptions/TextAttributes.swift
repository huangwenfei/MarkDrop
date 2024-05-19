//
//  TextAttributes.swift
//  MarkDrop
//
//  Created by windy on 2024/5/3.
//

import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct TextAttributes: Hashable {
    
    // MARK: Properties
    public var character: CharacterAttributes
    public var stroke: StrokeAttributes?
    public var underline: UnderlineAttributes?
    public var border: BorderAttributes?
    public var backgroundBorder: BorderAttributes?
    public var shadow: ShadowAttributes?
    
    public var action: ActionAttributes?
    
    // MARK: Init
    public init(
        character: CharacterAttributes = .init(),
        stroke: StrokeAttributes? = nil,
        underline: UnderlineAttributes? = nil,
        border: BorderAttributes? = nil,
        backgroundBorder: BorderAttributes? = nil,
        shadow: ShadowAttributes? = nil,
        action: ActionAttributes? = nil
    ) {
        self.character = character
        self.stroke = stroke
        self.underline = underline
        self.border = border
        self.backgroundBorder = backgroundBorder
        self.shadow = shadow
        self.action = action
    }
    
}
