//
//  NSParagraphStyle+Extensions.swift
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

extension NSParagraphStyle {

    func indented(by indentation: CGFloat) -> NSParagraphStyle {
        guard let result = mutableCopy() as? NSMutableParagraphStyle else {
            return self
        }
        
        result.firstLineHeadIndent += indentation
        result.headIndent += indentation

        result.tabStops = tabStops.map {
            NSTextTab(textAlignment: $0.alignment, location: $0.location + indentation, options: $0.options)
        }

        return result
    }

    func inset(by amount: CGFloat) -> NSParagraphStyle {
        guard let result = mutableCopy() as? NSMutableParagraphStyle else { return self }
        result.paragraphSpacingBefore += amount
        result.paragraphSpacing += amount
        result.firstLineHeadIndent += amount
        result.headIndent += amount
        result.tailIndent = -amount
        return result
    }

}

extension NSParagraphStyle.LineBreakStrategy: Hashable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
    
}
