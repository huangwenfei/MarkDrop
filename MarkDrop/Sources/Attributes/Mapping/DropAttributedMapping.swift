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
    public func append(paragraph: ParagraphAttributes, in content: inout NSMutableAttributedString, with indentList: [DropParagraphIndent]) {
        fatalError("Using subclass !")
    }
    
    public func combine(oldAttributes: DropContants.AttributedDict, in attributed: inout DropContants.AttributedDict) {
        fatalError("Using subclass !")
    }
    
    public func mapping(text: TextAttributes, type: DropAttributeType) -> DropContants.AttributedDict {
        fatalError("Using subclass !")
    }
}


public final class DropDefaultAttributedMapping: DropAttributedMapping {
    
    public override func append(paragraph: ParagraphAttributes, in content: inout NSMutableAttributedString, with indentList: [DropParagraphIndent]) {
        
        let style = DropMutableParagraph()
        style.setParagraphStyle(paragraph.paragraphStyle)
        
        style.firstLineHeadIndent = 0
        style.headIndent = 0
        style.tabStops = []
        
        let indentation = paragraph.indentWidth
        
        indentList.forEach({
            
            let mode =  $0.mode
            
            if mode.contains(.firstHeadIndent) {
                style.firstLineHeadIndent += indentation
            }
            
            if mode.contains(.headIndent) {
                style.headIndent += indentation
            }
            
            if mode.contains(.tailIndent) {
                style.tailIndent += indentation
            }
            
            if mode.contains(.tabStop) {
                let tabStop = DropTabStop(textAlignment: .left, location: indentation)
                style.tabStops.append(tabStop)
            }
            
        })
        
        content.addAttribute(
            .paragraphStyle,
            value: style,
            range: .init(location: 0, length: content.length)
        )
    }
    
    public override func combine(oldAttributes: DropContants.AttributedDict, in attributed: inout DropContants.AttributedDict) {
        
        let fontKey = AttributesKey.characterFont.attributed
        
        let font = oldAttributes[fontKey] as? DropFont
        let newFont = attributed[fontKey] as? DropFont
        
        /// 如果 key 重复，就使用 attributed 的 value (current)
        attributed.merge(oldAttributes, uniquingKeysWith: { current,_ in current })
        
        if var font, let newFont {
            if newFont.isBold      { font = font.bold }
            if newFont.isItalic    { font = font.italic }
            if newFont.isMonoSpace { font = font.monoSpace }
            attributed[fontKey] = font
        }
        
    }
    
    public override func mapping(text: TextAttributes, type: DropAttributeType) -> DropContants.AttributedDict {
        
        var result = DropContants.AttributedDict()
        
        merge(character(text.character), in: &result)
        
        if let stroke = text.stroke { merge(self.stroke(stroke), in: &result) }
        if let border = text.border { merge(self.border(border), in: &result) }
        if let underline = text.underline { merge(self.underline(underline), in: &result) }
        if let shadow = text.shadow { merge(self.shadow(shadow), in: &result) }
        if let action = text.action { merge(self.action(action), in: &result) }
        
        if let backgroundBorder = text.backgroundBorder {
            merge(self.backgroundBorder(backgroundBorder), in: &result)
        }
        
        return result
    }
    
    private func character(_ value: CharacterAttributes) -> DropContants.AttributedDict {
        [
            key(.characterColor): value.color,
            key(.characterFont): value.font,
            key(.characterKern): value.kern
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
    
    private func action(_ value: ActionAttributes) -> DropContants.AttributedDict {
        [
            key(.actionCurrentState): value.currentState,
            key(.actionActions): value.actions
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
