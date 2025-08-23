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



# Environment Attributes


# Attributed Mapping


# Renderer


# Dropper


