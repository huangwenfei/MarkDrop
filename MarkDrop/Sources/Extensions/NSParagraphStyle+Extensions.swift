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

extension NSParagraphStyle: DropExtensions { }

extension DropWrapper where RawValue == NSParagraphStyle {

    public func indented(by indentation: CGFloat) -> NSParagraphStyle {
        guard let result = rawValue.mutableCopy() as? NSMutableParagraphStyle else {
            return self.rawValue
        }
        
        result.firstLineHeadIndent += indentation
        result.headIndent += indentation

        result.tabStops = rawValue.tabStops.map {
            NSTextTab(
                textAlignment: $0.alignment,
                location: $0.location + indentation,
                options: $0.options
            )
        }

        return result
    }

    public func inset(by amount: CGFloat) -> NSParagraphStyle {
        guard let result = rawValue.mutableCopy() as? NSMutableParagraphStyle else {
            return self.rawValue
        }
        result.paragraphSpacingBefore += amount
        result.paragraphSpacing += amount
        result.firstLineHeadIndent += amount
        result.headIndent += amount
        result.tailIndent = -amount
        return result
    }

}

extension NSParagraphStyle {
    
    internal func indented(by indentation: CGFloat) -> NSParagraphStyle {
        drop.indented(by: indentation)
    }
    
    internal func inset(by amount: CGFloat) -> NSParagraphStyle {
        drop.inset(by: amount)
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
