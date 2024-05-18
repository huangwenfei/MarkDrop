//
//  DropFont+Extensions.swift
//  MarkDrop
//
//  from Down
//
//  Created by windy on 2024/5/16.
//

import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension DropFont {

    public var isBold: Bool {
        return contains(.bold)
    }

    public var isItalic: Bool {
        return contains(.italic)
    }

    public var isMonoSpace: Bool {
        return contains(.monoSpace)
    }

    public var bold: DropFont {
        return with(.bold) ?? self
    }

    public var italic: DropFont {
        return with(.italic) ?? self
    }

    public var monoSpace: DropFont {
        return with(.monoSpace) ?? self
    }

    private func with(_ trait: DropFontDescriptor.SymbolicTraits) -> DropFont? {
        guard !contains(trait) else { return self }

        var traits = fontDescriptor.symbolicTraits
        traits.insert(trait)

        #if canImport(UIKit)
        guard let newDescriptor = fontDescriptor.withSymbolicTraits(traits) else { return self }
        return DropFont(descriptor: newDescriptor, size: pointSize)

        #elseif canImport(AppKit)
        let newDescriptor = fontDescriptor.withSymbolicTraits(traits)
        return DropFont(descriptor: newDescriptor, size: pointSize)

        #endif
    }

    private func contains(_ trait: DropFontDescriptor.SymbolicTraits) -> Bool {
        return fontDescriptor.symbolicTraits.contains(trait)
    }

}

#if canImport(UIKit)

private extension DropFontDescriptor.SymbolicTraits {

    static let bold = DropFontDescriptor.SymbolicTraits.traitBold
    static let italic = DropFontDescriptor.SymbolicTraits.traitItalic
    static let monoSpace = DropFontDescriptor.SymbolicTraits.traitMonoSpace

}

#elseif canImport(AppKit)

private extension DropFontDescriptor.SymbolicTraits {

    static let bold = DropFontDescriptor.SymbolicTraits.bold
    static let italic = DropFontDescriptor.SymbolicTraits.italic
    static let monoSpace = DropFontDescriptor.SymbolicTraits.monoSpace

}

#endif
