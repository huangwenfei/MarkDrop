//
//  DropAppleAttributedMapping.swift
//  MarkDrop
//
//  Created by windy on 2024/5/18.
//

import Foundation

public final class DropAppleAttributedMapping: DropAttributedMapping {
    
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
        
        let fontKey = NSAttributedString.Key.font
        
        oldAttributes.forEach({
            guard $0.key != fontKey else { return }
            attributed[$0.key] = $0.value
        })
        
        if
            let font = oldAttributes[fontKey] as? DropFont,
            var newFont = attributed[fontKey] as? DropFont
        {
            if font.isBold      { newFont = newFont.bold }
            if font.isItalic    { newFont = newFont.italic }
            if font.isMonoSpace { newFont = newFont.monoSpace }
            attributed[fontKey] = newFont
        }
        
        content.addAttributes(attributed, range: renderRange)
    }
    
    public override func mapping(text: TextAttributes, type: DropAttributeType) -> DropContants.AttributedDict {
        
        var result = DropContants.AttributedDict()
        
        merge(character(text.character), in: &result)
        merge(stroke(text.stroke), in: &result)
        merge(underline(text.underline), in: &result)
        merge(shadow(text.shadow), in: &result)
        
        return result
    }
    
    private func character(_ value: CharacterAttributes) -> DropContants.AttributedDict {
        [
            .font: value.font,
            .foregroundColor: value.color
        ]
    }
    
    private func stroke(_ value: StrokeAttributes) -> DropContants.AttributedDict {
        [
            .strokeColor: value.color,
            .strokeWidth: value.width
        ]
    }
    
    private func underline(_ value: UnderlineAttributes) -> DropContants.AttributedDict {
        [
            .underlineColor: value.color,
            .underlineStyle: value.mode.style
        ]
    }
    
    private func shadow(_ value: ShadowAttributes) -> DropContants.AttributedDict {
        [
            .shadow: value.shadow
        ]
    }
    
    private func paragraph(_ value: ParagraphAttributes) -> DropContants.AttributedDict {
        [
            .paragraphStyle: value.paragraphStyle,
        ]
    }
    
    private func merge(_ dict: DropContants.AttributedDict, in result: inout DropContants.AttributedDict) {
        
        result.merge(dict, uniquingKeysWith: { current,_ in current })
    }
    
}
