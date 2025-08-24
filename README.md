#  MarkDrop

A lightweight library that parses and renders text according to rules.
Only characters up to 10,000 are supported。

# Installation

```swift
dependencies: [
    .package(url: "https://github.com/huangwenfei/MarkDrop.git", .upToNextMajor(from: "0.0.2"))
]
```

# Usage

```swift
import MarkDrop
```

<img width="301.5" height="655.5" alt="Light" src="https://github.com/user-attachments/assets/eb9809ac-67ac-4a13-94fd-c9ffec43e877" />
<img width="301.5" height="655.5" alt="Dark" src="https://github.com/user-attachments/assets/bb5d3181-520d-45c1-925d-d72358c280a0" />


```swift

let string =
"""
👋，吾友
::drop:: 是一款全平台卡片笔记 App，主要功能有：
- ::极简记录::，做笔记毫无压力#欢迎🍎
- ::多级标签::，让记录井井有条
- ::每日回顾::，**与**记录@不期而遇

1. 你说::??努力??::有用吗？
- 不期而遇&& Opportunity &&，期望美好的开始
::drop:: 是卡片??笔记??

现在，试着把当前脑海中的!!想法、**灵感**、情绪!!等等记下来，尝试下无压记录的??愉悦??。
\t- #欢迎 新人??指南??
    现在，试着把当前脑海中的😤
"""

let rules = [
    DropBulletRule(),
    DropNumberOrderRule(),
    DropLetterOrderRule(),
    
    DropTabIndentRule(),
    DropSpaceIndentRule(),
    
    DropHashTagRule(),
    DropMentionRule(),
    
    DropShortBoldRule(),
    DropShortItalicsRule(),
    DropShortUnderlineRule(),
    DropShortHighlightRule(),
    DropShortStrokeRule(),
]

let attributes = DropEnvironmentAttributes()
let mapping = DropAppleAttributedMapping()

let style = traitCollection.userInterfaceStyle
let theme = EnvironmentTheme(style: style)

let attributedString = AttributedStringRender
    .init(
        string: string,
        using: rules
    )
    .render(
        with: attributes.attributes(in: theme),
        mapping: mapping
    )

let textView = UITextView...
textView.attributedText = attributedString

```

# Rule

All rules inherit from the `DropRule` class.

There are now five kinds of rules:
- `DropTokenSet`: `#xxx ` `@xxx `
- `DropLargeTokenSet`: `a. xxx` `一. xxx` `1. xxx`
- `DropTagSet`: `**xxx**` `__xxx__` `*xxx*`
- `DropLargeTagSet`: For the future
- `DropMultiTagSet`: For the future

The inherited structures are:

```swift
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
```

```swift

/// <#Name#> : Class name
/// <#TagType#> : TagSet and TagSetRender
/// <#RuleType#> : DropContentType: Rule type

public final class Drop<#Name#>Rule: DropRule {
    
    // MARK: Class
    public static let rule: Drop<#TagType#>Set = {
        var rule = Drop<#TagType#>Set()
        ...
        return rule
    }()
    
    public static let render: MarkRuleDict<Drop<#TagType#>RenderType> = {
        var dict = MarkRuleDict<Drop<#TagType#>RenderType>()
        ...
        return dict
    }()
    
    // MARK: Init
    public init() {
        super.init(
            rule: .<#TagType#>(rule: Drop<#Name#>Rule.rule, render: Drop<#Name#>Rule.render),
            type: <#RuleType#>
        )
    }
    
}

```

Supported types `DropContentType`: 

```swift
public enum DropContentType: Int, Hashable, Codable {
    /// - Tag: Normal
    /// 无格式文本，叶子结点
    case text
    
    /// - Tag: Block
    /// 子弹列表
    case bulletList
    /// 数字列表
    case numberOrderList
    /// 字母列表
    case letterOrderList

    /// - Tag: Inline
    /// 标签
    case hashTag
    /// 关联 [内容]
    case mention
    
    /// 加粗 [文字]
    case bold
    /// 斜体 [文字]
    case italics
    /// 下划线 [文字]
    case underline
    /// 高亮 [文字]
    case highlight
    /// 描边 [文字]
    case stroke

    /// - Tag: Other
    /// 缩进 ( 4 个空格 Or \t)
    case spaceIndent
    case tabIndent

}
```

## DropTokenSet

token + content(optional) + close(optional), 1 ~ 3 node

- `token`: #, @ ...
- `content`: What needs to be processed
- `close`: A sign of the end of the judgment. [space, newline, eof]

example: `#Drop ` : token is `#`, content is `Drop`, close is ` ` (Space)

## DropLargeTokenSet

tokens + close + content(optional) , 1 ~ 3 node

- `tokens`: 1. , a. ...
- `close`: A sign of the end of the judgment. [space, newline, eof]
- `content`: What needs to be processed

example: `1. Drop` : tokens is `1.`, close is ` ` (Space), content is `Drop`

## DropTagSet

open + content(optional) + meidan(optional) + content(optional) + close, 2 ~ 5 node

- `open`: **, ## ...
- `content`: What needs to be processed
- `meidan`: |, ? ...
- `content`: What needs to be processed
- `close`: **, ## ...

example: `**Drop**` : open is `**`, content is `Drop`, close is `**`

## MarkRuleDict

Used to control rendering

`public typealias MarkRuleDict<Set: Hashable> = [Set : DropMarkRenderMode]`

Like `dict[.open] =.remove ; dict[.close] =.remove` in `DropCommonMarkBoldRule` removes both `**` flags.

`DropMarkRenderMode`:
- keepItAsIs, remove, replace(new: String), append(leading: String, trailing: String)

# Environment Attributes

Structs that apply specific appearance to 'content', including light and dark.

```swift

/// DropAttributes

public var paragraph: ParagraphAttributes = .init()
public var text: TextAttributes = .init()
public var bulletList: ParagraphMarkTextAttributes = .init()
public var numberOrderList: ParagraphMarkTextAttributes = .init()
public var letterOrderList: ParagraphMarkTextAttributes = .init()
public var hashTag: TextAttributes = .init()
public var mention: TextAttributes = .init()
public var bold: TextAttributes = .init()
public var italics: TextAttributes = .init()
public var underline: TextAttributes = .init()
public var highlight: TextAttributes = .init()
public var stroke: TextAttributes = .init()
public var spaceIndent: TextAttributes = .init()
public var tabIndent: TextAttributes = .init()

```

# Attributed Mapping

It's a mapping that handles the overlap of several styles when rendering. It inherits from the `DropAttributedMapping` class.

With the default `DropDefaultAttributedMapping` and apple `NSAttributedString` `DropAppleAttributedMapping`.

## Three key methods:

### Append

Add the rendered text to the final result

`func append(type: DropParagraphType, paragraph: ParagraphAttributes, listMark: NSAttributedString?, in content: inout NSMutableAttributedString, with indentList: [DropParagraphIndent])`

- type: DropParagraphType
    - document, bulletList, numberOrderList, letterOrderList, text，break
- paragraph：Current attributes
- listMark: This parameter only has a value if type is one of the following bulletList, numberOrderList, or letterOrderList.
- content: Final result
- indentList: The current total number of indents

### Combine

The way the old property is combined with the new property, often when text is rendered by multiple styles in conflict.

`func combine(oldAttributes: DropContants.AttributedDict, in attributed: inout DropContants.AttributedDict)`

- oldAttributes: The old render property
- attributed: The new render property is also the result of the return

### Mapping

What are the specific properties for different rendering styles

`func mapping(text: TextAttributes, type: DropAttributeType, content: String, in paragraph: ParagraphAttributes) -> DropContants.AttributedDict`

- text：Text rendering styles
- type：Attributes type
    - text, hashTag, mention, bold, italics, underline, highlight, stroke
- content：Plain text
- paragraph：The style of the section in which it resides

- return: The final rendered property

# Renderer

There are currently two renderers implemented, both of which follow the `DropRendable` protocol.

- `AttributedStringRender`: Format Text -> NSAttributedString
- `PlainTextRender`: Format Text -> Text

# Dropper

`Dropper` is the core parser class that parses formatted text into a tree structure. Those who are interested can go and have a look.

```swift
let string = ...
let rules = ...
let dropper = Dropper(string: string)
let ast = dropper.process(using: rules)
```

