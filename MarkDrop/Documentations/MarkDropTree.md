
#  MarkDropTree

## Contant

Node Container Type:
    document: 所有内容
    block: 块内容，是 >= 1 paragraph 组合
    paragraph: 一个段落，纯文本 Or 格式化内容 Or 它们的组合
    break: CRLF (换行) Or 空行，特殊段

Node Type:
    text: 无格式文本
    
    bullet list: 子弹列表
    order list: 数字列表
    letter list: 字母列表
    list item: 列表项
    
    hash tag: 标签
    mention: 关联
    bold: 加粗
    italics: 斜体
    underline: 下划线
    highlight: 高亮
    stroke: 描边
    
    crlf: 换行 ( \r Or \n ) ？？
    empty: 空行  ？？
    indent: 缩进 ( 4 个空格 Or \t)

## Node, 基础节点

Properties:
    content: String
    range: ClosedRange<String.Index>
    bindAttribute: Attribute
    parent node: Node?
    child nodes: [Node]

Methods:
    isRoot: Bool
    haveChildren: Bool
    nsRange: NSRange
    attributedContent: NSAttributedString
    
    
## Container Node: Node, 容器节点

Properties:
    container type: NodeContainerType
    paragraphs: [Paragraph]

Methods:

## Content Node: Node, 内容节点

Properties:
    content type: NodeContentType
    tagSet: NodeTagSet 包含前中后的 Token 解析内容,如：bullet 的 '- '
    replaceSet: 解析替换的内容，如：bullet 的 '·\t'

Methods:


## Tree AST 树


