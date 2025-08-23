//
//  EnvironmentTheme.swift
//  MarkDrop
//
//  Created by windy on 2024/5/16.
//

import Foundation

public enum EnvironmentTheme: Int, ThemeProtocol {
    case light, dark
}

#if canImport(UIKit)
import UIKit

extension EnvironmentTheme {
    public init(style: UIUserInterfaceStyle) {
        switch style {
        case .unspecified: self = .light
        case .light:       self = .light
        case .dark:        self = .dark
        @unknown default:  self = .light
        }
    }
}
#endif
