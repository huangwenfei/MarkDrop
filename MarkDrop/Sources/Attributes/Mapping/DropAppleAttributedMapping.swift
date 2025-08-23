//
//  DropAppleAttributedMapping.swift
//  MarkDrop
//
//  Created by windy on 2024/5/18.
//

import Foundation

public final class DropAppleAttributedMapping: DropAttributedMapping {
    
    public override func append(type: DropParagraphType, paragraph: ParagraphAttributes, listMark: NSAttributedString?, in content: inout NSMutableAttributedString, with indentList: [DropParagraphIndent]) {
        
        let style = DropMutableParagraph()
        style.setParagraphStyle(paragraph.paragraphStyle)
        
        style.firstLineHeadIndent = 0
        style.headIndent = 0
        style.tabStops = []
        
        let font = content.attribute(.font, at: 0, effectiveRange: nil) ?? DropFont.systemFont(ofSize: 16)
        let color = content.attribute(.foregroundColor, at: 0, effectiveRange: nil) ?? DropColor.green
        let kern = content.attribute(.kern, at: 0, effectiveRange: nil) ?? 0
        
        let charAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .kern: kern
        ]
        
        if type.isList {
            if paragraph.usingFixWidth {
                let max = paragraph.fixHeadMaxWidth?.value(charAttributes) ?? 0
                style.firstLineHeadIndent = Swift.max(0, max - (listMark?.size().width ?? 0))
                style.headIndent = max
            } else {
                style.headIndent = paragraph.startHeadIndent
            }
        }
        
        let indentation = paragraph.indentWidthClosure?.value(charAttributes) ?? 20
        
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
        
        let fontKey = NSAttributedString.Key.font
        
        let font = oldAttributes[fontKey] as? DropFont
        let newFont = attributed[fontKey] as? DropFont
        
        /// 如果 key 重复，就使用 attributed 的 value (current)
//        attributed.merge(oldAttributes, uniquingKeysWith: { current,_ in current })
        attributed.merge(oldAttributes, uniquingKeysWith: { _,old in old })
        
        if var font, let newFont {
            if newFont.isBold      { font = font.bold }
            if newFont.isItalic    { font = font.italic }
            if newFont.isMonoSpace { font = font.monoSpace }
            attributed[fontKey] = font
        }
        
    }
    
    public override func mapping(expand: ExpandAttributes, text: CharacterAttributes, content attributedContent: NSAttributedString, renderRange: DropContants.IntRange, in paragraph: ParagraphAttributes) -> DropAttributedMappingResult? {
        
        nil
        
    }
    
    public override func mapping(action: ActionAttributes, text: CharacterAttributes, content attributedContent: NSAttributedString, renderRange: DropContants.IntRange, in paragraph: ParagraphAttributes) -> DropAttributedMappingResult? {
        
        nil
    }
    
    public override func mapping(expand: ExpandAttributes, action: ActionAttributes, text: CharacterAttributes, content attributedContent: NSAttributedString, renderRange: DropContants.IntRange, in paragraph: ParagraphAttributes) -> DropAttributedMappingResult? {
        
        nil
    }
    
    public override func expandActionReplace(_ previous: NSAttributedString, replaceRange: DropContants.IntRange, content: NSAttributedString) -> NSAttributedString? {
        
        nil
    }
    
    public override func mapping(text: TextAttributes, type: DropAttributeType, content: String, in paragraph: ParagraphAttributes) -> DropContants.AttributedDict {
        
        var result = DropContants.AttributedDict()
        
        merge(character(text.character), in: &result)
        
        if let stroke = text.stroke { merge(self.stroke(stroke), in: &result) }
        if let border = text.backgroundBorder { merge(self.border(border), in: &result) }
        if let underline = text.underline { merge(self.underline(underline), in: &result) }
        if let shadow = text.shadow { merge(self.shadow(shadow), in: &result) }
        
        return result
    }
    
    private func character(_ value: CharacterAttributes) -> DropContants.AttributedDict {
        [
            .font: value.font,
            .foregroundColor: value.color,
            .kern: NSNumber(value: value.kern)
        ]
    }
    
    private func stroke(_ value: StrokeAttributes) -> DropContants.AttributedDict {
        [
            .strokeColor: value.color,
            // NSNumber containing floating point value, in percent of font point size, default 0: no stroke; positive for stroke alone, negative for stroke and fill (a typical value for outlined text would be 3.0)
            .strokeWidth: NSNumber(value: value.width)
        ]
    }
    
    private func underline(_ value: UnderlineAttributes) -> DropContants.AttributedDict {
        [
            .underlineColor: value.color,
            .underlineStyle: NSNumber(value: value.mode.style.rawValue)
        ]
    }
    
    private func border(_ value: BorderAttributes) -> DropContants.AttributedDict {
        [
            .backgroundColor: value.fillColor
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
