
#  Hi Flomo File Format

## Content

- Paragraph 段
- Text 文本

- Hashtag 标签
- Mention 关联

- List 列表
    - Bullet 子弹列表
    - Order 数字列表
    - Letter 字母列表

- Font 字体
    - Bold 加粗
    - Italics 斜体
    - Underline 下划线
    - Highlight 高亮
    - Stroke 描边
    
- Other 其它
    - indent 缩进
    - break
        soft
        line
        
## Define

### Paragraph 段

Style: line 行

Rule: 
    openTag: '*' 任意字符
    closeTag: ('\n' Or '\r' CRLF 换行符) Or EOF 文件结束符
    indentLevel: [0, 6]
    
### Text 文本

Style: inline 行内的部分或整体内容，没有做任何的格式化

Rule: 
    openTag: nil
    intermediateTag: nil
    closeTag: nil

### Hashtag 标签
    
Style: inline 行内

Rule: 
    openTag: '#'
    intermediateTag: nil
    closeTag: ' '
    allowSpacing: false
    
### Mention 关联

Style: inline 行内

Rule:
    openTag: '@'
    intermediateTag: nil
    closeTag: ' '
    allowSpacing: false
    
### List 列表

#### Bullet 子弹列表

Style: block 块内容

Rule:
    openTag: '- ' (缩进) + 中横线 + 空格
    remove: .leading
    trimSpacing: true
    trimCount: 2 Or 4
    indentLevel: [0, 6]

#### Order 数字列表

Style: block 块内容

Rule:
    openTag: '\d. ' (缩进) + 数字 + 点 + 空格(不限数量)
    remove: .leading
    trimSpacing: true
    trimCount: 2 Or 4
    indentLevel: [0, 6]

#### Letter 字母列表

Style: block 块内容

Rule:
    openTag: '\s. ' (缩进) + 字母 + 点 + 空格(不限数量)
    remove: .leading
    trimSpacing: true
    trimCount: 2 Or 4
    indentLevel: [0, 6] 

### Font 字体

#### Bold 加粗

Style: inline 行内

Rule:
    openTag: '::' 双冒号
    intermediateTag: nil
    closeTag: '::'
    allowSpacing: true
    
#### Italics 斜体

Style: inline 行内

Rule:
    openTag: '**' 双星号
    intermediateTag: nil
    closeTag: '**'
    allowSpacing: true

#### Underline 下划线

Style: inline 行内

Rule:
    openTag: '!!' 双感叹号
    intermediateTag: nil
    closeTag: '!!'
    allowSpacing: true

#### Highlight 高亮

Style: inline 行内

Rule:
    openTag: '??' 双问号
    intermediateTag: nil
    closeTag: '??'
    allowSpacing: true
    
#### Stroke 描边

Style: inline 行内

Rule:
    openTag: '&&' 双与号
    intermediateTag: nil
    closeTag: '&&'
    allowSpacing: true
    

### Other 其它

#### indent 缩进

Define:
    '    ' 四个空格
    '\t' 制表符

Range: 
    [0, 6]

