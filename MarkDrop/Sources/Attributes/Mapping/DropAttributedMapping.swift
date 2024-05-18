//
//  DropAttributedMapping.swift
//  MarkDrop
//
//  Created by windy on 2024/5/18.
//

import Foundation

public class DropAttributedMapping {
    
    // MARK: Init
    public init() {}
    
    // MARK: Mapping
    public func append(paragraph: ParagraphAttributes, in content: inout NSMutableAttributedString, with indentList: [CGFloat]) {
        fatalError("Using subclass !")
    }
    
    public func combine(oldAttributes: DropContants.AttributedDict, in attributed: inout DropContants.AttributedDict, with content: NSMutableAttributedString, in renderRange: DropContants.IntRange) {
        fatalError("Using subclass !")
    }
    
    public func mapping(text: TextAttributes, type: DropAttributeType) -> DropContants.AttributedDict {
        fatalError("Using subclass !")
    }
}


public final class DropDefaultAttributedMapping: DropAttributedMapping {
    
    public override func append(paragraph: ParagraphAttributes, in content: inout NSMutableAttributedString, with indentList: [CGFloat]) {
        
        let style = DropMutableParagraph()
        style.setParagraphStyle(paragraph.paragraphStyle)
        
        style.firstLineHeadIndent = 0
        style.headIndent = 0
        style.tabStops = []
        
        indentList.forEach({ indentation in
            style.firstLineHeadIndent += indentation
            style.headIndent += indentation
            let tabStop = DropTabStop(textAlignment: .left, location: indentation)
            style.tabStops.append(tabStop)
        })
        
        content.addAttribute(
            .paragraphStyle,
            value: style,
            range: .init(location: 0, length: content.length)
        )
    }
    
    public override func combine(oldAttributes: DropContants.AttributedDict, in attributed: inout DropContants.AttributedDict, with content: NSMutableAttributedString, in renderRange: DropContants.IntRange) {
        
        let fontKey = AttributesKey.characterFont.attributed
        
        oldAttributes.forEach({
            guard $0.key != fontKey else { return }
            attributed[$0.key] = $0.value
        })
        
        if
            var font = oldAttributes[fontKey] as? DropFont,
            let newFont = attributed[fontKey] as? DropFont
        {
            if newFont.isBold      { font = font.bold }
            if newFont.isItalic    { font = font.italic }
            if newFont.isMonoSpace { font = font.monoSpace }
            attributed[fontKey] = font
        }
        
        content.addAttributes(attributed, range: renderRange)
    }
    
    public override func mapping(text: TextAttributes, type: DropAttributeType) -> DropContants.AttributedDict {
        
        var result = DropContants.AttributedDict()
        
        merge(character(text.character), in: &result)
        merge(stroke(text.stroke), in: &result)
        merge(border(text.border), in: &result)
        merge(backgroundBorder(text.backgroundBorder), in: &result)
        merge(underline(text.underline), in: &result)
        merge(shadow(text.shadow), in: &result)
        
        return result
    }
    
    private func character(_ value: CharacterAttributes) -> DropContants.AttributedDict {
        [
            key(.characterColor): value.color,
            key(.characterFont): value.font
        ]
    }
    
    private func stroke(_ value: StrokeAttributes) -> DropContants.AttributedDict {
        [
            key(.strokeColor): value.color,
            key(.strokeWidth): value.width
        ]
    }
    
    private func border(_ value: BorderAttributes) -> DropContants.AttributedDict {
        [
            key(.borderColor): value.color,
            key(.borderWidth): value.width,
            key(.borderCornerRadius): value.cornerRadius,
            key(.borderFillColor): value.fillColor,
            key(.borderPaddings): value.paddings
        ]
    }
    
    private func backgroundBorder(_ value: BorderAttributes) -> DropContants.AttributedDict {
        [
            key(.backgroundBorderColor): value.color,
            key(.backgroundBorderWidth): value.width,
            key(.backgroundBorderCornerRadius): value.cornerRadius,
            key(.backgroundBorderFillColor): value.fillColor,
            key(.backgroundBorderPaddings): value.paddings
        ]
    }
    
    private func underline(_ value: UnderlineAttributes) -> DropContants.AttributedDict {
        [
            key(.underlineColor): value.color,
            key(.underlineWidth): value.width,
            key(.underlineMargins): value.margins,
            key(.underlineMode): value.mode
        ]
    }
    
    private func shadow(_ value: ShadowAttributes) -> DropContants.AttributedDict {
        [
            key(.shadowColor): value.color,
            key(.shadowRadius): value.radius,
            key(.shadowOffset): value.offset,
            key(.shadowBlendMode): value.blendMode
        ]
    }
    
    private func paragraph(_ value: ParagraphAttributes) -> DropContants.AttributedDict {
        [
            key(.paragraph): value,
        ]
    }
    
    private func key(_ key: AttributesKey) -> NSAttributedString.Key {
        .init(rawValue: key.rawValue)
    }
    
    private func merge(_ dict: DropContants.AttributedDict, in result: inout DropContants.AttributedDict) {
        
        result.merge(dict, uniquingKeysWith: { current,_ in current })
    }
    
}
