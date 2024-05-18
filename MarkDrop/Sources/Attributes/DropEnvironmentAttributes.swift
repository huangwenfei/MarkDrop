//
//  DropEnvironmentAttributes.swift
//  MarkDrop
//
//  Created by windy on 2024/5/16.
//

import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct DropEnvironmentAttributes: Hashable {
    
    // MARK: Types
    public typealias Paragraph = EnvironmentThemeElement<ParagraphAttributes>
    public typealias ListParagraph = EnvironmentThemeElement<ParagraphMarkTextAttributes>
    public typealias TextCharacter = EnvironmentThemeElement<TextAttributes>
    
    // MARK: Properties
    public let paragraph: Paragraph = defaultTextParagraph()
    
    public let text: TextCharacter = defaultText()
    
    public let bulletList: ListParagraph = defaultMarkTextParagraph()
    public let numberOrderList: ListParagraph = defaultMarkTextParagraph()
    public let letterOrderList: ListParagraph = defaultMarkTextParagraph()
    
    public let hashTag: TextCharacter = {
        var result = defaultText()
        result.light.character.font = .systemFont(ofSize: 16, weight: .semibold)
        result.light.backgroundBorder = .init(
            cornerRadius: 2,
            fillColor: .blue.withAlphaComponent(0.8),
            paddings: .init(top: 4, left: 6, bottom: 4, right: 6)
        )
        result.dark.character.font = .systemFont(ofSize: 16, weight: .semibold)
        result.dark.backgroundBorder = .init(
            cornerRadius: 2,
            fillColor: .blue,
            paddings: .init(top: 4, left: 6, bottom: 4, right: 6)
        )
        return result
    }()
    
    public let mention: TextCharacter = {
        var result = defaultText()
        result.light.character.color = .blue
        result.dark.character.color = .blue
        return result
    }()
    
    public let bold: TextCharacter = {
        var result = defaultText()
        result.light.character.font = result.light.character.font.bold
        result.dark.character.font = result.dark.character.font.bold
        return result
    }()
    
    public let italics: TextCharacter = {
        var result = defaultText()
        result.light.character.font = result.light.character.font.italic
        result.dark.character.font = result.dark.character.font.italic
        return result
    }()
    
    public let underline: TextCharacter = {
        var result = defaultText()
        result.light.underline = .init(color: .systemGray, mode: .single)
        result.dark.underline = .init(color: .systemGray6, mode: .single)
        return result
    }()
    
    public let highlight: TextCharacter = {
        var result = defaultText()
        result.light.character.font = .systemFont(ofSize: 16, weight: .semibold)
        result.light.backgroundBorder = .init(
            cornerRadius: 2,
            fillColor: .green.withAlphaComponent(0.8),
            paddings: .init(top: 4, left: 6, bottom: 4, right: 6)
        )
        result.dark.character.font = .systemFont(ofSize: 16, weight: .semibold)
        result.dark.backgroundBorder = .init(
            cornerRadius: 2,
            fillColor: .green,
            paddings: .init(top: 4, left: 6, bottom: 4, right: 6)
        )
        return result
    }()
    
    public let stroke: TextCharacter = {
        var result = defaultText()
        result.light.stroke = .init(color: .yellow.withAlphaComponent(0.8), width: 1)
        result.dark.stroke = .init(color: .yellow, width: 1)
        return result
    }()
    
    public let spaceIndent: TextCharacter = defaultText()
    public let tabIndent: TextCharacter = defaultText()
    
    // MARK: Init
    public init() { }
    
    // MARK: Attributes
    public func attributes(in theme: EnvironmentTheme) -> DropAttributes {
        
        var result = DropAttributes()
        
        switch theme {
        case .light:
            result.paragraph = paragraph.light
            result.text = text.light
            result.bulletList = bulletList.light
            result.numberOrderList = numberOrderList.light
            result.letterOrderList = letterOrderList.light
            result.hashTag = hashTag.light
            result.mention = mention.light
            result.bold = bold.light
            result.italics = italics.light
            result.underline = underline.light
            result.highlight = highlight.light
            result.stroke = stroke.light
            result.spaceIndent = spaceIndent.light
            result.tabIndent = tabIndent.light
            
        case .dark:
            result.paragraph = paragraph.dark
            result.text = text.dark
            result.bulletList = bulletList.dark
            result.numberOrderList = numberOrderList.dark
            result.letterOrderList = letterOrderList.dark
            result.hashTag = hashTag.dark
            result.mention = mention.dark
            result.bold = bold.dark
            result.italics = italics.dark
            result.underline = underline.dark
            result.highlight = highlight.dark
            result.stroke = stroke.dark
            result.spaceIndent = spaceIndent.dark
            result.tabIndent = tabIndent.dark
        }
        
        return result
    }
    
    // MARK: Methods
    public static func defaultTextParagraph() -> EnvironmentThemeElement<ParagraphAttributes> {
        
        var result = EnvironmentThemeElement<ParagraphAttributes>(
            light: .init(), dark: .init()
        )
        
        result.light = defaultParagraph()
        result.dark = result.light
        
        return result
    }

    public static func defaultTextParagraph() -> EnvironmentThemeElement<ParagraphTextAttributes> {
        
        var result = EnvironmentThemeElement<ParagraphTextAttributes>(
            light: .init(), dark: .init()
        )
        
        result.light.paragraph = defaultParagraph()
        result.dark.paragraph = result.light.paragraph
        
        result.light.text = defaultText().light
        result.dark.text = defaultText().dark
        
        return result
    }
    
    public static func defaultMarkTextParagraph() -> EnvironmentThemeElement<ParagraphMarkTextAttributes> {
        
        var result = EnvironmentThemeElement<ParagraphMarkTextAttributes>(
            light: .init(), dark: .init()
        )
        
        result.light.paragraph = defaultParagraph()
        result.dark.paragraph = result.light.paragraph
        
        result.light.mark = defaultText().light
        result.dark.mark = defaultText().dark
        
        result.light.text = defaultText().light
        result.dark.text = defaultText().dark
        
        return result
    }
    
    public static func defaultParagraph() -> ParagraphAttributes {
        var paragraph = ParagraphAttributes()
        paragraph.minimumLineHeight = 20
        paragraph.maximumLineHeight = 20
        paragraph.lineSpacing = 4
        paragraph.paragraphSpacingBefore = 4
        paragraph.paragraphSpacingAfter = 4
        return paragraph
    }
    
    public static func defaultText() -> EnvironmentThemeElement<TextAttributes> {
        var result = EnvironmentThemeElement<TextAttributes>(
            light: .init(), dark: .init()
        )
        result.light.character.color = .black
        result.light.character.font = .systemFont(ofSize: 16, weight: .regular)
        result.dark.character.color = .white
        result.dark.character.font = result.light.character.font
        return result
    }
    
}
