//
//  EnvironmentThemeElement.swift
//  MarkDrop
//
//  Created by windy on 2024/5/17.
//

import Foundation

public struct EnvironmentThemeElement<Element: Hashable>: Hashable {
    
    // MARK: Types
    public typealias Element = Element
    
    // MARK: Properties
    public var light: Element
    public var dark: Element
    
    // MARK: Init
    public init(light: Element, dark: Element) {
        self.light = light
        self.dark = dark
    }
    
}
