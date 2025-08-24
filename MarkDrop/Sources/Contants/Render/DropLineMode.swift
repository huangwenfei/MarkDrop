//
//  DropLineMode.swift
//  MarkDrop
//
//  Created by windy on 2024/5/20.
//

import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public enum DropLineMode: Int {
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
