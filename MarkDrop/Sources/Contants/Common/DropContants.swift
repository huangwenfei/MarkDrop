//
//  DropContants.swift
//  MarkDrop
//
//  Created by windy on 2024/5/3.
//

import Foundation

public struct DropContants {
    
    // MARK: Types
    public typealias Range = ClosedRange<String.Index>
    public typealias ExculdeNewlineRange = Swift.Range<String.Index>
    
    public typealias IntRange = NSRange
    
    // MARK: Properties
    
    /// 在Unicode中，确实存在一些控制字符（control characters）和格式字符（format characters），它们在渲染时通常不会显示任何可见的内容，但会对文本的布局或解释产生影响。以下是一些常见的例子：
    ///
    /// 1. **空格字符（Space Character）**：
    ///    - U+0020 SPACE：这是最常见的空格字符，通常用于在文本中插入空格。
    ///
    /// 2. **制表符（Tab Character）**：
    ///    - U+0009 CHARACTER TABULATION (HT)：用于在文本中插入制表符，通常用于对齐。
    ///
    /// 3. **换行符（Line Feed）和回车符（Carriage Return）**：
    ///    - U+000A LINE FEED (LF)：在Unix和Unix-like系统（如Linux和macOS）中用作行结束符。
    ///    - U+000D CARRIAGE RETURN (CR)：在旧式的Mac系统和一些Windows文本文件中用作行结束符。但在现代Windows系统中，通常与LF一起使用（CR+LF）。
    ///
    /// 4. **垂直制表符（Vertical Tab Character）**：
    ///    - U+000B LINE TABULATION (VT)：较少使用，用于在文本中插入垂直制表符。
    ///
    /// 5. **非打印字符（Non-Printing Characters）**：
    ///    - 这些字符通常用于控制文本的处理方式，但不会在屏幕上显示。例如，U+007F DELETE (DEL) 控制字符通常用于删除前一个字符。
    ///
    /// 6. **零宽度字符（Zero-Width Characters）**：
    ///    - 这些字符在文本中占用位置，但渲染时不会显示任何内容。例如：
    ///      - U+200B ZERO WIDTH SPACE：零宽度空格，用于在文本中插入一个不可见的空格。
    ///      - U+200C ZERO WIDTH NON-JOINER (ZWNJ)：防止某些字符（如阿拉伯语中的字母）相互连接。
    ///      - U+200D ZERO WIDTH JOINER (ZWJ)：在某些上下文中，使两个字符相互连接（例如，在Emoji组合中）。
    ///
    /// 7. **不可见控制字符**：
    ///    - Unicode中还有许多其他不可见的控制字符，如U+FEFF BYTE ORDER MARK (BOM)，它通常用于指示UTF-16或UTF-32文本的字节顺序。虽然它本身不可见，但在某些文本编辑器或处理器中可能会显示为特殊标记。
    ///
    ///
    ///     在 Swift 语言中，使用 Unicode 字符时，大小写是**没有**影响的，因为 Unicode 代码点是基于十六进制数的，而十六进制数在编程中是不区分大小写的。不过，Swift 中有两种方式来表示 Unicode 字符：
    ///
    ///     1. 使用 `\u{...}` 来表示一个 Unicode 字符，其中 `...` 是字符的 Unicode 代码点的十六进制表示，并且这个代码点必须在 `U+0000` 到 `U+FFFF` 的范围内（即最多四个十六进制数字）。注意这里是小写的 `\u`。
    ///
    ///     2. 使用 `\U{...}` 来表示一个 Unicode 字符，其中 `...` 是字符的 Unicode 代码点的十六进制表示，这个代码点可以是 `U+000000` 到 `U+10FFFF` 范围内的任何值（即最多八个十六进制数字）。注意这里是大写的 `\U`。
    ///
    ///     所以，在 Swift 中，`\u{000A}` 和 `\u{000a}` 是等价的，都表示 Unicode 字符 `LINE FEED`（换行符）。同样，`\U{000A}` 和 `\U{000a}` 也是等价的，但在这里使用了 `\U` 格式，虽然这通常用于表示超出 `U+FFFF` 范围的 Unicode 字符。
    ///
    public static let newlines: CharacterSet = .newlines
    public static let spaces = CharacterSet.whitespaces
    public static let spacesAndNewLines: CharacterSet = .whitespacesAndNewlines
    
    public static let characterContentSet: String = "#@!?*&:"
    public static let numbers: String = "0123456789"
    public static let letters: String = lowercaseLetters + uppercaseLetters
    public static let lowercaseLetters: String = "abcdefghijklmnopqrstuvwxyz"
    public static let uppercaseLetters: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    
    public static let hyphen: String = "-"
    
    ///     Bullet（项目符号）在 Unicode 中可以有多种表示，因为不同的符号可能用于不同的上下文或样式。但是，一些常见的项目符号在 Unicode 中有对应的字符。
    ///
    ///     例如，一个常见的圆点项目符号（bullet point）在 Unicode 中是 `•`（U+2022 BULLET）。你可以在 Swift 或其他支持 Unicode 的编程语言中通过 `\u{2022}` 来表示它。
    ///
    ///     此外，还有其他一些类似的符号也可以用作项目符号，比如：
    ///
    ///     - `‣`（U+2023 TRIANGULAR BULLET）
    ///     - `●`（U+25CF BLACK CIRCLE）
    ///     - `◦`（U+25E6 WHITE BULLET）
    ///     - `▪`（U+25AA BLACK SMALL SQUARE）
    ///     - `▫`（U+25AB WHITE SMALL SQUARE）
    ///
    ///     这些只是 Unicode 中可用作项目符号的众多字符中的一部分。你可以根据你的具体需求和上下文选择适合的符号。
    ///
    public static let bullet: String = "\u{2022}"
    
    /// "."（句号）
    public static let period: String = "\u{002e}"
    
    // MARK: Render
    public typealias AttributedDict = [NSAttributedString.Key: Any]
    
}
