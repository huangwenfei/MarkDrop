//
//  DropRule+CommonMark.swift
//  MarkDrop
//
//  Created by windy on 2024/5/15.
//

import Foundation

public final class DropCommonMarkBoldRule: DropRule {
    
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
            rule: .tag(rule: DropCommonMarkBoldRule.rule, render: DropCommonMarkBoldRule.render),
            type: .bold
        )
    }
    
}

public final class DropCommonMarkBoldRule2: DropRule {
    
    // MARK: Class
    public static let rule: DropTagSet = {
        var rule = DropTagSet()
        rule.openTag = "__"
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
            rule: .tag(rule: DropCommonMarkBoldRule2.rule, render: DropCommonMarkBoldRule2.render),
            type: .bold
        )
    }
    
}

public final class DropCommonMarkItalicsRule: DropRule {
    
    // MARK: Class
    public static let rule: DropTagSet = {
        var rule = DropTagSet()
        rule.openTag = "*"
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
            rule: .tag(rule: DropCommonMarkItalicsRule.rule, render: DropCommonMarkItalicsRule.render),
            type: .bold
        )
    }
    
}

public final class DropCommonMarkItalicsRule2: DropRule {
    
    // MARK: Class
    public static let rule: DropTagSet = {
        var rule = DropTagSet()
        rule.openTag = "_"
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
            rule: .tag(rule: DropCommonMarkItalicsRule2.rule, render: DropCommonMarkItalicsRule2.render),
            type: .bold
        )
    }
    
}

public final class DropCommonMarkUnderlineRule: DropRule {
    
    // MARK: Class
    public static let rule: DropTagSet = {
        var rule = DropTagSet()
        rule.openTag = "++"
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
            rule: .tag(rule: DropCommonMarkUnderlineRule.rule, render: DropCommonMarkUnderlineRule.render),
            type: .underline
        )
    }
    
}

public final class DropCommonMarkHighlightRule: DropRule {
    
    // MARK: Class
    public static let rule: DropTagSet = {
        var rule = DropTagSet()
        rule.openTag = "=="
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
            rule: .tag(rule: DropCommonMarkHighlightRule.rule, render: DropCommonMarkHighlightRule.render),
            type: .highlight
        )
    }
    
}

public final class DropCommonMarkStrokeRule: DropRule {
    
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
            rule: .tag(rule: DropCommonMarkStrokeRule.rule, render: DropCommonMarkStrokeRule.render),
            type: .stroke
        )
    }
    
}

public final class DropCommonMarkStrikethroughRule: DropRule {
    
    // MARK: Class
    public static let rule: DropTagSet = {
        var rule = DropTagSet()
        rule.openTag = "~~"
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
            rule: .tag(rule: DropCommonMarkStrikethroughRule.rule, render: DropCommonMarkStrikethroughRule.render),
            type: .stroke
        )
    }
    
}

public final class DropCommonMarkSubscriptRule: DropRule {
    
    // MARK: Class
    public static let rule: DropTagSet = {
        var rule = DropTagSet()
        rule.openTag = "~"
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
            rule: .tag(rule: DropCommonMarkSubscriptRule.rule, render: DropCommonMarkSubscriptRule.render),
            type: .stroke
        )
    }
    
}

public final class DropCommonMarkSuperscriptRule: DropRule {
    
    // MARK: Class
    public static let rule: DropTagSet = {
        var rule = DropTagSet()
        rule.openTag = "^"
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
            rule: .tag(rule: DropCommonMarkSuperscriptRule.rule, render: DropCommonMarkSuperscriptRule.render),
            type: .stroke
        )
    }
    
}


#if false
public final class DropHeadingLevel1Rule: DropRule {
    
    // MARK: Init
    public init() {
        var rule = DropTokenSet()
        rule.token = "# "
        rule.closeRule = [.newline, .eof]
        rule.isOnlyVaildOnHead = true
        rule.vaildHeadSet = [.leadingHead, .space, .value("\t")]
        super.init(rule: .token(rule: rule), type: .heading1)
    }
    
}

public final class DropHeadingLevel2Rule: DropRule {
    
    // MARK: Init
    public init() {
        var rule = DropTokenSet()
        rule.token = "## "
        rule.closeRule = [.newline, .eof]
        rule.isOnlyVaildOnHead = true
        rule.vaildHeadSet = [.leadingHead, .space, .value("\t")]
        super.init(rule: .token(rule: rule), type: .heading2)
    }
    
}

public final class DropHeadingLevel3Rule: DropRule {
    
    // MARK: Init
    public init() {
        var rule = DropTokenSet()
        rule.token = "### "
        rule.closeRule = [.newline, .eof]
        rule.isOnlyVaildOnHead = true
        rule.vaildHeadSet = [.leadingHead, .space, .value("\t")]
        super.init(rule: .token(rule: rule), type: .heading3)
    }
    
}

public final class DropHeadingLevel4Rule: DropRule {
    
    // MARK: Init
    public init() {
        var rule = DropTokenSet()
        rule.token = "#### "
        rule.closeRule = [.newline, .eof]
        rule.isOnlyVaildOnHead = true
        rule.vaildHeadSet = [.leadingHead, .space, .value("\t")]
        super.init(rule: .token(rule: rule), type: .heading4)
    }
    
}

public final class DropHeadingLevel5Rule: DropRule {
    
    // MARK: Init
    public init() {
        var rule = DropTokenSet()
        rule.token = "##### "
        rule.closeRule = [.newline, .eof]
        rule.isOnlyVaildOnHead = true
        rule.vaildHeadSet = [.leadingHead, .space, .value("\t")]
        super.init(rule: .token(rule: rule), type: .heading5)
    }
    
}

public final class DropHeadingLevel6Rule: DropRule {
    
    // MARK: Init
    public init() {
        var rule = DropTokenSet()
        rule.token = "###### "
        rule.closeRule = [.newline, .eof]
        rule.isOnlyVaildOnHead = true
        rule.vaildHeadSet = [.leadingHead, .space, .value("\t")]
        super.init(rule: .token(rule: rule), type: .heading6)
    }
    
}

public final class DropBlockquotesRule: DropRule {
    
    // MARK: Init
    public init() {
        var rule = DropTokenSet()
        rule.token = "> "
        rule.closeRule = [.newline, .eof]
        rule.isOnlyVaildOnHead = true
        rule.vaildHeadSet = [.leadingHead, .space, .value("\t")]
        super.init(rule: .token(rule: rule), type: .heading6)
    }
    
}

public final class DropInlineCodeRule: DropRule {
    
    // MARK: Init
    public init() {
        var rule = DropTagSet()
        rule.openTag = "`"
        rule.meidanTag = nil
        rule.closeTag = "`"
        super.init(rule: .tag(rule: rule), type: .inlineCode)
    }
    
}

/// 需要构建 done 两次，前后包裹的 paragraph 就是 code 的内容
public final class DropCodeRule: DropRule {
    
    // MARK: Init
    public init() {
        var rule = DropTokenSet()
        rule.token = "```"
        rule.closeRule = [.space, .newline, .eof]
        rule.shouldCapture = false
        rule.isOnlyVaildOnHead = true
        rule.vaildHeadSet = [.leadingHead, .space, .newline, .value("\t")]
        super.init(rule: .token(rule: rule), type: .code)
    }
    
}
#endif
