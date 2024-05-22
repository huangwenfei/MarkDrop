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

    public var fillChildMode: DropRenderFillMode = .none
    public var isFillChildAttributes: Bool {
        fillChildMode != .none
    }
    
    public var shouldExpandContent: Bool = false
    
    public var shouldBuildBackgroundBorderInMappingText: Bool {
        action == nil && shouldExpandContent == false
    }
    
    // MARK: Init
    public init(
        character: CharacterAttributes = .init(),
        stroke: StrokeAttributes? = nil,
        underline: UnderlineAttributes? = nil,
        border: BorderAttributes? = nil,
        backgroundBorder: BorderAttributes? = nil,
        shadow: ShadowAttributes? = nil,
        action: ActionAttributes? = nil,
        fillMode: DropRenderFillMode = .none,
        shouldExpandContent: Bool = false
    ) {
        self.character = character
        self.stroke = stroke
        self.underline = underline
        self.border = border
        self.backgroundBorder = backgroundBorder
        self.shadow = shadow
        self.action = action
        self.fillChildMode = fillMode
        self.shouldExpandContent = shouldExpandContent
    }
    
}
