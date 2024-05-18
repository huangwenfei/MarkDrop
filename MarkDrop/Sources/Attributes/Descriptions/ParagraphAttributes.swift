//
//  ParagraphAttributes.swift
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

public struct ParagraphAttributes: Hashable {
    
    // MARK: Properties
    public var alignment: NSTextAlignment
    public var maximumLineHeight: CGFloat
    public var minimumLineHeight: CGFloat
    
    public var lineSpacing: CGFloat
    public var paragraphSpacingBefore: CGFloat
    public var paragraphSpacingAfter: CGFloat
    
    public var lineBreakMode: NSLineBreakMode
    public var lineBreakStrategy: NSParagraphStyle.LineBreakStrategy
    
    // MARK: Init
    public init(
        alignment: NSTextAlignment = NSParagraphStyle.default.alignment,
        maximumLineHeight: CGFloat = NSParagraphStyle.default.maximumLineHeight,
        minimumLineHeight: CGFloat = NSParagraphStyle.default.minimumLineHeight,
        lineSpacing: CGFloat = NSParagraphStyle.default.lineSpacing,
        paragraphSpacingBefore: CGFloat = NSParagraphStyle.default.paragraphSpacingBefore,
        paragraphSpacingAfter: CGFloat = NSParagraphStyle.default.paragraphSpacing,
        lineBreakMode: NSLineBreakMode = NSParagraphStyle.default.lineBreakMode,
        lineBreakStrategy: NSParagraphStyle.LineBreakStrategy = NSParagraphStyle.default.lineBreakStrategy
    ) {
        self.alignment = alignment
        self.maximumLineHeight = maximumLineHeight
        self.minimumLineHeight = minimumLineHeight
        self.lineSpacing = lineSpacing
        self.paragraphSpacingBefore = paragraphSpacingBefore
        self.paragraphSpacingAfter = paragraphSpacingAfter
        self.lineBreakMode = lineBreakMode
        self.lineBreakStrategy = lineBreakStrategy
    }

    // MARK: Style
    public var paragraphStyle: NSParagraphStyle {
        let result = NSMutableParagraphStyle()
        result.setParagraphStyle(.default)
        result.alignment = alignment
        result.maximumLineHeight = maximumLineHeight
        result.minimumLineHeight = minimumLineHeight
        result.lineSpacing = lineSpacing
        result.paragraphSpacingBefore = paragraphSpacingBefore
        result.paragraphSpacing = paragraphSpacingAfter
        result.lineBreakMode = lineBreakMode
        result.lineBreakStrategy = lineBreakStrategy
        return result.copy() as! NSParagraphStyle
    }
    
}

extension AttributesKey {
    
    public static var paragraph: Self {
        .init(rawValue: "drop.attributes.paragraph.key")
    }
    
    public static var paragraphAlignment: Self {
        .init(rawValue: "drop.attributes.paragraph.alignment.key")
    }
    
    public static var paragraphMaximumLineHeight: Self {
        .init(rawValue: "drop.attributes.paragraph.maximumLineHeight.key")
    }
    
    public static var paragraphMinimumLineHeight: Self {
        .init(rawValue: "drop.attributes.paragraph.minimumLineHeight.key")
    }
    
    public static var paragraphLineSpacing: Self {
        .init(rawValue: "drop.attributes.paragraph.lineSpacing.key")
    }
    
    public static var paragraphSpacingBefore: Self {
        .init(rawValue: "drop.attributes.paragraph.paragraphSpacingBefore.key")
    }
    
    public static var paragraphSpacingAfter: Self {
        .init(rawValue: "drop.attributes.paragraph.paragraphSpacingAfter.key")
    }
    
    public static var paragraphLineBreakMode: Self {
        .init(rawValue: "drop.attributes.paragraph.lineBreakMode.key")
    }
    
    public static var paragraphLineBreakStrategy: Self {
        .init(rawValue: "drop.attributes.paragraph.lineBreakStrategy.key")
    }
    
}
