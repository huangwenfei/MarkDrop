//
//  DropRule+HiFlomo.swift
//  MarkDrop
//
//  Created by windy on 2024/5/15.
//

import Foundation

public final class DropHashTagRule: DropRule {
    
    // MARK: Class
    public static let rule: DropTokenSet = {
        var rule = DropTokenSet()
        rule.token = "#"
        rule.closeRule = [.space, .newline, .eof]
//        rule.isInvalidCaptureOn = true
//        rule.invaildCaptureSet = rule.token
        return rule
    }()
    
    public static let render: MarkRuleDict<DropTokenRenderType> = {
        var dict = MarkRuleDict<DropTokenRenderType>()
        dict[.open] = .keepItAsIs
        dict[.close] = .keepItAsIs
        return dict
    }()
    
    // MARK: Init
    public init() {
        super.init(
            rule: .token(rule: DropHashTagRule.rule, render: DropHashTagRule.render),
            type: .hashTag
        )
    }
    
}

public final class DropMentionRule: DropRule {
    
    // MARK: Class
    public static let rule: DropTokenSet = {
        var rule = DropTokenSet()
        rule.token = "@"
        rule.closeRule = [.space, .newline, .eof]
//        rule.isInvalidCaptureOn = true
//        rule.invaildCaptureSet = rule.token
        return rule
    }()
    
    public static let render: MarkRuleDict<DropTokenRenderType> = {
        var dict = MarkRuleDict<DropTokenRenderType>()
        dict[.open] = .keepItAsIs
        dict[.close] = .remove
        return dict
    }()
    
    // MARK: Init
    public init() {
        super.init(
            rule: .token(rule: DropMentionRule.rule, render: DropMentionRule.render),
            type: .mention
        )
    }
    
}

public final class DropPlainHashTagRule: DropRule {
    
    // MARK: Class
    public static let rule = DropHashTagRule.rule
    
    public static let render: MarkRuleDict<DropTokenRenderType> = {
        var dict = DropHashTagRule.render
        dict[.close] = .keepItAsIs
        return dict
    }()
    
    // MARK: Init
    public init() {
        super.init(
            rule: .token(rule: DropPlainHashTagRule.rule, render: DropPlainHashTagRule.render),
            type: .hashTag
        )
    }
    
}

public final class DropPlainMentionRule: DropRule {
    
    // MARK: Class
    public static let rule = DropMentionRule.rule
    
    public static let render: MarkRuleDict<DropTokenRenderType> = {
        var dict = DropMentionRule.render
        dict[.close] = .remove
        return dict
    }()
    
    // MARK: Init
    public init() {
        super.init(
            rule: .token(rule: DropPlainMentionRule.rule, render: DropPlainMentionRule.render),
            type: .mention
        )
    }
    
}

public final class DropBoldRule: DropRule {
    
    // MARK: Class
    public static let rule: DropTagSet = {
        var rule = DropTagSet()
        let mark = "|flomoBold|"
        rule.openTag = "<" + mark
        rule.meidanTag = nil
        rule.closeTag = .init(mark.reversed()) + ">"
        return rule
    }()
    
    public static let render: MarkRuleDict<DropTagRenderType> = {
        var dict = MarkRuleDict<DropTagRenderType>()
        dict[.open] = .remove
        dict[.close] = .remove
        return dict
    }()
    
    // MARK: Init
    public init() {
        super.init(
            rule: .tag(rule: DropBoldRule.rule, render: DropBoldRule.render),
            type: .bold
        )
    }
    
}

public final class DropItalicsRule: DropRule {
    
    // MARK: Class
    public static let rule: DropTagSet = {
        var rule = DropTagSet()
        let mark = "|flomoItalics|"
        rule.openTag = "<" + mark
        rule.meidanTag = nil
        rule.closeTag = .init(mark.reversed()) + ">"
        return rule
    }()
    
    public static let render: MarkRuleDict<DropTagRenderType> = {
        var dict = MarkRuleDict<DropTagRenderType>()
        dict[.open] = .remove
        dict[.close] = .remove
        return dict
    }()
    
    // MARK: Init
    public init() {
        super.init(
            rule: .tag(rule: DropItalicsRule.rule, render: DropItalicsRule.render),
            type: .italics
        )
    }
    
}

public final class DropUnderlineRule: DropRule {
    
    // MARK: Class
    public static let rule: DropTagSet = {
        var rule = DropTagSet()
        let mark = "|flomoUnderline|"
        rule.openTag = "<" + mark
        rule.meidanTag = nil
        rule.closeTag = .init(mark.reversed()) + ">"
        return rule
    }()
    
    public static let render: MarkRuleDict<DropTagRenderType> = {
        var dict = MarkRuleDict<DropTagRenderType>()
        dict[.open] = .remove
        dict[.close] = .remove
        return dict
    }()
    
    // MARK: Init
    public init() {
        super.init(
            rule: .tag(rule: DropUnderlineRule.rule, render: DropUnderlineRule.render),
            type: .underline
        )
    }
    
}

public final class DropHighlightRule: DropRule {
    
    // MARK: Class
    public static let rule: DropTagSet = {
        var rule = DropTagSet()
        let mark = "|flomoHighlight|"
        rule.openTag = "<" + mark
        rule.meidanTag = nil
        rule.closeTag = .init(mark.reversed()) + ">"
        return rule
    }()
    
    public static let render: MarkRuleDict<DropTagRenderType> = {
        var dict = MarkRuleDict<DropTagRenderType>()
        dict[.open] = .remove
        dict[.close] = .remove
        return dict
    }()
    
    // MARK: Init
    public init() {
        super.init(
            rule: .tag(rule: DropHighlightRule.rule, render: DropHighlightRule.render),
            type: .highlight
        )
    }
    
}

public final class DropStrokeRule: DropRule {
    
    // MARK: Class
    public static let rule: DropTagSet = {
        var rule = DropTagSet()
        let mark = "|flomoStroke|"
        rule.openTag = "<" + mark
        rule.meidanTag = nil
        rule.closeTag = .init(mark.reversed()) + ">"
        return rule
    }()
    
    public static let render: MarkRuleDict<DropTagRenderType> = {
        var dict = MarkRuleDict<DropTagRenderType>()
        dict[.open] = .remove
        dict[.close] = .remove
        return dict
    }()
    
    // MARK: Init
    public init() {
        super.init(
            rule: .tag(rule: DropStrokeRule.rule, render: DropStrokeRule.render),
            type: .stroke
        )
    }
    
}

public final class DropShortBoldRule: DropRule {
    
    // MARK: Class
    public static let rule: DropTagSet = {
        var rule = DropTagSet()
        rule.openTag = "::"
        rule.meidanTag = nil
        rule.closeTag = rule.openTag
        return rule
    }()
    
    public static let render: MarkRuleDict<DropTagRenderType> = {
        var dict = MarkRuleDict<DropTagRenderType>()
        dict[.open] = .remove
        dict[.close] = .remove
        return dict
    }()
    
    // MARK: Init
    public init() {
        super.init(
            rule: .tag(rule: DropShortBoldRule.rule, render: DropShortBoldRule.render),
            type: .bold
        )
    }
    
}

public final class DropShortItalicsRule: DropRule {
    
    // MARK: Class
    public static let rule: DropTagSet = {
        var rule = DropTagSet()
        rule.openTag = "**"
        rule.meidanTag = nil
        rule.closeTag = rule.openTag
        return rule
    }()
    
    public static let render: MarkRuleDict<DropTagRenderType> = {
        var dict = MarkRuleDict<DropTagRenderType>()
        dict[.open] = .remove
        dict[.close] = .remove
        return dict
    }()
    
    // MARK: Init
    public init() {
        super.init(
            rule: .tag(rule: DropShortItalicsRule.rule, render: DropShortItalicsRule.render),
            type: .italics
        )
    }
    
}

public final class DropShortUnderlineRule: DropRule {
    
    // MARK: Class
    public static let rule: DropTagSet = {
        var rule = DropTagSet()
        rule.openTag = "!!"
        rule.meidanTag = nil
        rule.closeTag = rule.openTag
        return rule
    }()
    
    public static let render: MarkRuleDict<DropTagRenderType> = {
        var dict = MarkRuleDict<DropTagRenderType>()
        dict[.open] = .remove
        dict[.close] = .remove
        return dict
    }()
    
    // MARK: Init
    public init() {
        super.init(
            rule: .tag(rule: DropShortUnderlineRule.rule, render: DropShortUnderlineRule.render),
            type: .underline
        )
    }
    
}

public final class DropShortHighlightRule: DropRule {
    
    // MARK: Class
    public static let rule: DropTagSet = {
        var rule = DropTagSet()
        rule.openTag = "??"
        rule.meidanTag = nil
        rule.closeTag = rule.openTag
        return rule
    }()
    
    public static let render: MarkRuleDict<DropTagRenderType> = {
        var dict = MarkRuleDict<DropTagRenderType>()
        dict[.open] = .remove
        dict[.close] = .remove
        return dict
    }()
    
    // MARK: Init
    public init() {
        super.init(
            rule: .tag(rule: DropShortHighlightRule.rule, render: DropShortHighlightRule.render),
            type: .highlight
        )
    }
    
}

public final class DropShortStrokeRule: DropRule {
    
    // MARK: Class
    public static let rule: DropTagSet = {
        var rule = DropTagSet()
        rule.openTag = "&&"
        rule.meidanTag = nil
        rule.closeTag = rule.openTag
        return rule
    }()
    
    public static let render: MarkRuleDict<DropTagRenderType> = {
        var dict = MarkRuleDict<DropTagRenderType>()
        dict[.open] = .remove
        dict[.close] = .remove
        return dict
    }()
    
    // MARK: Init
    public init() {
        super.init(
            rule: .tag(rule: DropShortStrokeRule.rule, render: DropShortStrokeRule.render),
            type: .stroke
        )
    }
    
}

public final class DropTabIndentRule: DropRule {
    
    // MARK: Class
    public static let rule: DropTokenSet = {
        var rule = DropTokenSet()
        rule.token = "\t"
        rule.closeRule = [.newline, .eof]
        rule.shouldCapture = false
        rule.isOnlyVaildOnHead = true
        rule.vaildHeadSet = [.leadingHead, .space, .value("\t")]
        return rule
    }()
    
    public static let render: MarkRuleDict<DropTokenRenderType> = {
        var dict = MarkRuleDict<DropTokenRenderType>()
        dict[.open] = .keepItAsIs
        return dict
    }()
    
    // MARK: Init
    public init() {
        super.init(
            rule: .token(rule: DropTabIndentRule.rule, render: DropTabIndentRule.render),
            type: .tabIndent
        )
    }
    
}

public final class DropSpaceIndentRule: DropRule {
    
    // MARK: Class
    public static let rule: DropTokenSet = {
        var rule = DropTokenSet()
        rule.token = "    "
        rule.closeRule = [.newline, .eof]
        rule.shouldCapture = false
        rule.isOnlyVaildOnHead = true
        rule.vaildHeadSet = [.leadingHead, .space, .value("\t")]
        return rule
    }()
    
    public static let render: MarkRuleDict<DropTokenRenderType> = {
        var dict = MarkRuleDict<DropTokenRenderType>()
        dict[.open] = .keepItAsIs
        return dict
    }()
    
    // MARK: Init
    public init() {
        super.init(
            rule: .token(rule: DropSpaceIndentRule.rule, render: DropSpaceIndentRule.render),
            type: .spaceIndent
        )
    }
    
}

public final class DropBulletRule: DropRule {
    
    // MARK: Class
    public static let rule: DropTokenSet = {
        var rule = DropTokenSet()
        rule.token = "- "
        rule.closeRule = [.space]
        rule.shouldCapture = false
        rule.isOnlyVaildOnHead = true
        rule.vaildHeadSet = [.leadingHead, .space, .value("\t")]
        return rule
    }()
    
    public static let render: MarkRuleDict<DropTokenRenderType> = {
        var dict = MarkRuleDict<DropTokenRenderType>()
        dict[.open] = .replace(new: "\u{2022} ")
        return dict
    }()
    
    // MARK: Init
    public init() {
        super.init(
            rule: .token(rule: DropBulletRule.rule, render: DropBulletRule.render),
            type: .bulletList
        )
    }
    
}

public final class DropNumberOrderRule: DropRule {
    
    // MARK: Class
    public static let rule: DropLargeTokenSet = {
        var rule = DropLargeTokenSet()
        rule.token = [DropContants.numbers, ".", " "]
        rule.closeRule = [.space]
        rule.shouldCapture = false
        rule.isOnlyVaildOnHead = true
        rule.vaildHeadSet = [.leadingHead, .space, .value("\t")]
        /// 000000 ~ 999999.
        rule.firstMaxRepeatCount = 6
        return rule
    }()
    
    public static let render: MarkRuleDict<DropLargeTokenRenderType> = {
        var dict = MarkRuleDict<DropLargeTokenRenderType>()
        dict[.open] = .keepItAsIs
        return dict
    }()
    
    // MARK: Methods
    public static func startNumber() -> String {
        "1. "
    }
    
    public static func number(index: Int) -> String {
        "\(index). "
    }
    
    public static func nextNumber(by current: String) -> String {
        guard
            let first = current.split(separator: ".").first
        else {
            return current
        }
        
        let value = (String(first) as NSString).integerValue
        
        return "\(value + 1). "
        
    }
    
    public static func minWidth(with attributes: [NSAttributedString.Key: Any]) -> CGFloat {
        
        let string = " 9. "
        let attriString = NSAttributedString(string: string, attributes: attributes)
        
        return attriString.size().width
    }
    
    public static func maxWidth(with attributes: [NSAttributedString.Key: Any]) -> CGFloat {
        
        let string = " 999. "
        let attriString = NSAttributedString(string: string, attributes: attributes)
        
        return attriString.size().width
    }
    
    // MARK: Init
    public init() {
        super.init(
            rule: .largeToken(rule: DropNumberOrderRule.rule, render: DropNumberOrderRule.render),
            type: .numberOrderList
        )
    }
    
}

public final class DropLetterOrderRule: DropRule {
    
    // MARK: Class
    public static let rule: DropLargeTokenSet = {
        var rule = DropLargeTokenSet()
        rule.token = [DropContants.lowercaseLetters, ".", " "]
        rule.closeRule = [.space]
        rule.shouldCapture = false
        rule.isOnlyVaildOnHead = true
        rule.vaildHeadSet = [.leadingHead, .space, .value("\t")]
        /// aaaaaa ~ zzzzzz.
        rule.firstMaxRepeatCount = 6
        return rule
    }()
    
    public static let render: MarkRuleDict<DropLargeTokenRenderType> = {
        var dict = MarkRuleDict<DropLargeTokenRenderType>()
        dict[.open] = .keepItAsIs
        return dict
    }()
    
    // MARK: Init
    public init() {
        super.init(
            rule: .largeToken(rule: DropLetterOrderRule.rule, render: DropLetterOrderRule.render),
            type: .letterOrderList
        )
    }
    
}

public final class DropChineseLetterOrderRule: DropRule {
    
    // MARK: Class
    public static let rule: DropLargeTokenSet = {
        var rule = DropLargeTokenSet()
        rule.token = ["一二三四五六七八九十", ".", " "]
        rule.closeRule = [.space]
        rule.shouldCapture = false
        rule.isOnlyVaildOnHead = true
        rule.vaildHeadSet = [.leadingHead, .space, .value("\t")]
        /// 一一一一一一 ~ 十十十十十十.
        rule.firstMaxRepeatCount = 6
        return rule
    }()
    
    public static let render: MarkRuleDict<DropLargeTokenRenderType> = {
        var dict = MarkRuleDict<DropLargeTokenRenderType>()
        dict[.open] = .keepItAsIs
        return dict
    }()
    
    // MARK: Init
    public init() {
        super.init(
            rule: .largeToken(rule: DropChineseLetterOrderRule.rule, render: DropChineseLetterOrderRule.render),
            type: .letterOrderList
        )
    }
    
}

public final class DropPlainBulletRule: DropRule {
    
    // MARK: Class
    public static let rule = DropBulletRule.rule
    
    public static let render: MarkRuleDict<DropTokenRenderType> = {
        var dict = DropBulletRule.render
        dict[.open] = .keepItAsIs
        return dict
    }()
    
    // MARK: Init
    public init() {
        super.init(
            rule: .token(rule: DropPlainBulletRule.rule, render: DropPlainBulletRule.render),
            type: .bulletList
        )
    }
    
}

public typealias DropPlainNumberOrderRule = DropNumberOrderRule
public typealias DropPlainLetterOrderRule = DropLetterOrderRule
public typealias DropPlainChineseLetterOrderRule = DropChineseLetterOrderRule
