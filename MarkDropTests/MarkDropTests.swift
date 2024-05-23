//
//  MarkDropTests.swift
//  MarkDropTests
//
//  Created by windy on 2024/5/2.
//

import XCTest
@testable import MarkDrop

final class MarkDropTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: Print
    func printNodes(tree: DropTree) {
        
        print()
        print("\tNodes Search !!!")
        
        tree.depthFirstSearch { node, isStop in
            let typeString: String
            if let container = node as? DropContainerNode {
                typeString = "\(container.type)"
            }
            else if let content = node as? DropContentNode {
                typeString = "\(content.type)"
            }
            else if let content = node as? DropContentMarkNode {
                typeString = "(\(content.type), mark->\(content.mark))"
            }
            else {
                typeString = "None Type"
            }
            
            let parentTypeString: String
            if let container = node.parentNode as? DropContainerNode {
                parentTypeString = "\(container.type)"
            }
            else if let content = node.parentNode as? DropContentNode {
                parentTypeString = "\(content.type)"
            }
            else if let content = node.parentNode as? DropContentMarkNode {
                parentTypeString = "(\(content.type), mark->\(content.mark))"
            }
            else {
                parentTypeString = "None Type"
            }
            
            if (node is DropContainerNode) { print() }
            print("{ isLeafNode: \(node.isLeafNode), type->\(typeString), content->\(node.contents), renderContent->\(node.renderContents), intRange->\(node.intRange), docRange->\(node.documentRange), |< parent: \(parentTypeString), \(node.parentNode?.rawContent ?? "None Text") >| }")
        }
        
        print()
        
        print("\t Leaf Nodes Search !!!")
        
        tree.depthFirstSearch { node, isStop in
            if (node is DropContainerNode) { print() }
            if (node as? DropContainerNode)?.type == .break {
                print("(\(node.rawRenderContent), \(node.intRange.location)-\(node.intRange.maxLocation))")
                return
            }
            guard node.isLeafNode, node.rawRenderContent.isEmpty == false else { return }
            
            print("(\(node.renderContents), \(node.intRange.location)-\(node.intRange.maxLocation))")
        }
        
        print()
        print("All leaf nodes, ", tree.containers()
            .map({
                let result = $0.texts
                    .sorted(by: { $0.intRange.location < $1.intRange.location })
                    .map({
                        if let content = $0 as? DropContentNodeProtocol {
                            return "(\($0.renderContents), \($0.intRange.location)-\($0.intRange.maxLocation), \(content.parentContainerRenderTypes.reduce(content.type.render == nil ? "nil" : "(self:\(content.type.render!))", { $0 + "-" + "\($1)" }))"
                        } else {
                            return "(\($0.renderContents), \($0.intRange.location)-\($0.intRange.maxLocation))"
                        }
                    })
                return result.isEmpty ? ["\n"] : result
            })
        )
        print()
    }

    // MARK: Process
    
    let flomoRules = HelpRules.flomoRules
    let shortRules = HelpRules.shortRules
    
    func testProcess() {
        let string = 
        """
        👋，吾友
        ::hiflomo:: 是一款全平台卡片笔记 App，主要功能有：
        - ::极简记录::，做笔记毫无压力\t#欢迎🍎
        - ::多级标签::，让记录井井有条
        - ::每日回顾::，**与**记录不期而遇
            - ::每日回顾:，与**记录不期而遇
        
        1. 你说::??努力??::有用吗？
        - 不期而遇，期望美好的开始
        不期, ::hiflomo: 是卡片??笔记

        现在，试着把当前脑海中的!!想法、灵感、情绪!!等等记下来，尝试下无压记录的??愉悦??。
        \t- \t#欢迎/新人??指南??
            
                现在，试着把当前脑海中的😤
        """
        
        let string1 =
        """
        现在，试着把当前脑海中的!!想法、**灵感**、情绪!!等等记下来，尝试下无压记录的??愉悦??。
        """
        
        let string2 =
        """
            现在，试着把当前脑海中的!!想法、**A灵无??压记录感Z**、情??绪!!等等记下来，尝试下无压记录的??愉悦??。
        """
        
        let string3 =
        """
        现在，试着把当前脑海中的!!想法、**灵感**、情绪!!等等记下来，尝试下#无压记录的??愉悦??。
        \t- \t#欢迎/新人??指南??
        """
        
        let string4 =
        """
            \t现在，试着把当前#脑海 中的!!想法、**A灵无??压Press记录感Z**、情??绪!!等等记下来，尝试下!!#无压记录的??愉悦??。!!
        """
        
        let dropper = Dropper(string: string4)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testUnformatTest() throws {
        let string =
        """
        👋，吾友
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testBold() {
        
        #if true
        /// short format, shortRules
        let string =
        """
        ::hiflomo:: 是一款全平台卡片笔记 App，主要功能有：
        """
        let rules = shortRules
        #else
        /// rich format, flomoRules
        let string =
        """
        \(DropBoldRule.rule.openTag)hiflomo\(DropBoldRule.rule.closeTag) 是一款全平台卡片笔记 App，主要功能有：
        """
        let rules = flomoRules
        #endif
        
        let dropper = Dropper(string: string)
        /// default is rich format
        let ast = dropper.process(using: rules)
        
        printNodes(tree: ast)
        
    }
    
    func testItalics() {
        
        #if true
        /// short format, shortRules
        let string =
        """
        hiflomo 是一款**全平台**卡片笔记 App，主要功能有：
        """
        let rules = shortRules
        #else
        /// rich format, flomoRules
        let string =
        """
        hiflomo 是一款\(DropItalicsRule.rule.openTag)全平台\(DropItalicsRule.rule.closeTag)卡片笔记 App，主要功能有：
        """
        let rules = flomoRules
        #endif
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: rules)
        
        printNodes(tree: ast)
        
    }
    
    func testUnderline() {
        
        #if true
        /// short format, shortRules
        let string =
        """
        hiflomo 是一款全平台!!卡片笔记!! App，主要功能有：
        """
        let rules = shortRules
        #else
        /// rich format, flomoRules
        let string =
        """
        hiflomo 是一款全平台\(DropUnderlineRule.rule.openTag)卡片笔记\(DropUnderlineRule.rule.closeTag) App，主要功能有：
        """
        let rules = flomoRules
        #endif
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: rules)
        
        printNodes(tree: ast)
        
    }
    
    func testHighlight() {
        
        #if true
        /// short format, shortRules
        let string =
        """
        你说??努力??有用吗？
        """
        let rules = shortRules
        #else
        /// rich format, flomoRules
        let string =
        """
        你说\(DropHighlightRule.rule.openTag)努力\(DropHighlightRule.rule.closeTag)有用吗？
        """
        let rules = flomoRules
        #endif
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: rules)
        
        printNodes(tree: ast)
        
    }
    
    func testStroke() {
        
        #if true
        /// short format, shortRules
        let string =
        """
        试着把当前&&脑海中&&的,试着把当前脑海中&&的&&, 试着把当前脑海中的&&
        """
        let rules = shortRules
        #else
        /// rich format, flomoRules
        let string =
        """
        试着把当前\(DropStrokeRule.rule.openTag)脑海中\(DropStrokeRule.rule.closeTag)的,试着把当前脑海中\(DropStrokeRule.rule.openTag)的\(DropStrokeRule.rule.closeTag), 试着把当前脑海中的\(DropStrokeRule.rule.openTag)
        """
        let rules = flomoRules
        #endif
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: rules)
        
        printNodes(tree: ast)
        
    }
    
    func testNormalStackString() {
        
        /// short format, shortRules
        let string =
        """
        你说::??努力??::有用吗？
        """
        // TODO: ::??努力??:: 切割不对
        // FIXME: 调整 markNode.mark != .text && markNode.mark != .none，调整 ??努力?? 父节点位置
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testNormalStackString2() {
        
        let string =
        """
            #欢迎/新人??指南??
        """
        // TODO: ??指南?? 的提取不对
        // FIXME: 引入新的提取方法
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testNormalStackString21() {
        
        let string =
        """
        现在，试着把当前脑海中的!!想法、**灵无??压记录感**、情??绪!!等等记下来，尝试下无压记录的??愉悦??。
        """
        // TODO: !!想法、**灵无??压记录感**、情??绪!! 的提取不对
        // FIXME: 引入新的提取方法
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testNormalStackString3() {
        
        let string =
        """
            - ::每日回顾:，与**记录!!不!!期而遇
        """
        // TODO: ** cancle 的时候要把 ！！不！！的 parent 进行提升
        // FIXME: ProcessRule 引入 doneChildren, cancle rules 修改 dones 的 parent
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testNormalStackString4() {
        
        let string =
        """
            - ::每日回顾，与**记录!!不期??而**遇
        """
        // TODO: ：： cancle 的时候要把 **记录!!不期??而** 的 parent 进行提升
        // FIXME: testNormalStackString3 已经处理
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testNormalStackString5() {
        
        let string =
        """
            - ::每日回顾**，农女吃#披萨k与**记&&录!!不j期而**遇
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testNormalStackString6() {
        
        let string =
        """
            - ::每日回顾**，农女吃#披萨与**记::&&录!!不期&&而遇!!
        """
        // TODO: 多提升问题
        // FIXME: 上面的已经同步解决
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testCancleStackString() {
        
        let string =
        """
        不期, ::hiflomo: 是卡片??笔记
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testSpaceIndent() throws {
        let string =
        """
            现在，试着把当前脑海中的😤
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testSpaceIndent11() throws {
        let string =
        """
                现在，试着把当前脑海中的😤
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testSpaceIndent12() throws {
        let string =
        """
        \t    现在，试着把当前脑海中的😤
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testEmpty() throws {
        
        let string =
        """
            
        
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testSpaceIndent2() throws {
        
        let string =
        """
            
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testTabIndent() throws {
        
        let string =
        """
        \t
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testTabIndent1() throws {
        let string =
        """
        \t现在，试着把当前脑海中的😤
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testTabIndent2() throws {
        let string =
        """
         \t    现在，试着把当前脑海中的😤
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testTabIndent3() throws {
        let string =
        """
         \t    现在，试着把当\t前脑海中的😤
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    // TODO: ???
    func testTabStop() throws {
        let string =
        """
        \t现在，试着把\t当前脑海中的😤\t
        \t
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testHashtag() throws {
        
        let string =
        """
        现在，试着把#弹谷 当前脑海中的😤, #谷海鸥
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testMention() throws {
        let string =
        """
        现在，试着把@弹谷 当前脑海中的😤, @谷海鸥
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testSpecialStackString() {
        
        let string =
        """
        现在，试着把::弹#丹丹弹 谷::当前脑海中的😤, 谷海鸥
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testBulletList() {
        
        let string =
        """
        - ::极简记录::，做笔记毫无压力#欢迎🍎
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testBulletList2() {
        
        let string =
        """
         - ::极简记录::，做笔记毫无压力#欢迎🍎
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testBulletList3() {
        
        let string =
        """
        fd- ::极简记录::，做笔记毫无压力#欢迎🍎
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testNumberOrderList() {
        
        let string =
        """
        1. ::极简记录::，做笔记毫无压力#欢迎🍎
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testNumberOrderList2() {
        
        let string =
        """
        231. 现在，试着, 毫无压力
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testNumberOrderList21() {
        
        let string =
        """
         231. 现在，试着, 毫无压力
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testNumberOrderList22() {
        
        let string =
        """
        \t231. 现在，试着, 毫无压力
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testNumberOrderList23() {
        
        let string =
        """
            231. 现在，试着, 毫无压力
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }

    func testNumberOrderList3() {
        
        let string =
        """
        231231. 现在，试着, 毫无压力
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testNumberOrderList4() {
        
        let string =
        """
        23123111. 现在，::试着::, 毫无压力
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testLetterOrderList() {
        
        let string =
        """
        a. ::极简记录::，做笔记毫无压力#欢迎🍎
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testLetterOrderList2() {
        
        let string =
        """
        cba. 现在，试着, 毫无压力
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testLetterOrderList21() {
        
        let string =
        """
         bac. 现在，试着, 毫无压力
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testLetterOrderList22() {
        
        let string =
        """
        \tabc. 现在，试着, 毫无压力
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testLetterOrderList23() {
        
        let string =
        """
            cca. 现在，试着, 毫无压力
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }

    func testLetterOrderList3() {
        
        let string =
        """
        abccab. 现在，试着, 毫无压力
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testLetterOrderList4() {
        
        let string =
        """
        abcccabc. 现在，::试着::, 毫无压力
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testLetterOrderList5() {
        
        let string =
        """
        ### Credit
        This library is a wrapper around [cmark](https://github.com/commonmark/cmark), which is built upon the [CommonMark](http://commonmark.org) Markdown specification.
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
    
    }
    
    
    func testBlock() {
        
        let string =
        """
        - ::极简记录::，做笔记毫无压力#欢迎🍎
        - ::多级标签::，让记录井井有条
        - ::每日回顾::，**与**记录不期而遇
            - ::每日回顾:，与**记录不期而遇
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    // MARK: Tree
    func testTreeDFS() {
        
        let string =
        """
        👋，吾友
        ::hiflomo:: 是一款全平台卡片笔记 App，主要功能有：
        - ::极简记录::，做笔记毫无压力#欢迎🍎
        - ::多级标签::，让记录井井有条
        - ::每日回顾::，**与**记录不期而遇
            - ::每日回顾:，与**记录不期而遇
        
            全平台卡片笔记 App
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        print("Nodes Search !!!")
        
        ast.depthFirstSearch { node, isStop in
            let typeString: String
            if let container = node as? DropContainerNode {
                typeString = "\(container.type)"
            }
            else if let content = node as? DropContentNode {
                typeString = "\(content.type)"
            }
            else {
                typeString = "None Type"
            }
            print("type-> \(typeString), content->\(node.contents), docRange->\(node.documentRange)")
        }
        
    }
    
    func testTreeBFS() {
        
        let string =
        """
        👋，吾友
        ::hiflomo:: 是一款全平台卡片笔记 App，主要功能有：
        - ::极简记录::，做笔记毫无压力#欢迎🍎
        - ::多级标签::，让记录井井有条
        - ::每日回顾::，**与**记录不期而遇
            - ::每日回顾:，与**记录不期而遇
        
            全平台卡片笔记 App
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        print("Nodes Search !!!")
        
        ast.breadthFirstSearch { node, isStop in
            let typeString: String
            if let container = node as? DropContainerNode {
                typeString = "\(container.type)"
            }
            else if let content = node as? DropContentNode {
                typeString = "\(content.type)"
            }
            else {
                typeString = "None Type"
            }
            print("type-> \(typeString), content->\(node.contents), docRange->\(node.documentRange)")
        }
        
    }
    
    func testTreeNodes() {
        
        let string =
        """
        👋，吾友
        ::hiflomo:: 是一款全平台卡片笔记 App，主要功能有：
        - ::极简记录::，做笔记毫无压力#欢迎🍎
        - ::多级标签::，让记录井井有条
        - ::每日回顾::，**与**记录不期而遇
            - ::每日回顾:，与**记录不期而遇
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        print("Nodes Search !!!")
        
        ast.nodes().forEach { node in
            let typeString: String
            if let container = node as? DropContainerNode {
                typeString = "\(container.type)"
            }
            else if let content = node as? DropContentNode {
                typeString = "\(content.type)"
            }
            else {
                typeString = "None Type"
            }
            print("type-> \(typeString), content->\(node.contents), docRange->\(node.documentRange)")
        }
        
    }
    
    func testTreeDFS2() {
        
        let string =
        """
        👋，吾友
        ::hiflomo:: 是一款全平台卡片笔记 App，主要功能有：
        - ::极简记录::，做笔记毫无压力#欢迎🍎
        - ::多级标签::，让记录井井有条
        - ::每日回顾::，**与**记录不期而遇
            - ::每日回顾:，与**记录不期而遇
        
        1. 你说::??努力??::有用吗？
        - 不期而遇，期望美好的开始
        不期, ::hiflomo: 是卡片??笔记
        
        现在，试着把当前脑海中的!!想法、**灵感**、情绪!!等等记下来，尝试下无压记录的??愉悦??。
        - #欢迎/新人??指南??
            
                现在，试着把当前脑海中的😤
        现在，试着把当前脑海中的!!想法、**灵无??压记录感**、情??绪!!等等记下来，尝试下无压记录的??愉悦??。
        
        """
        
        let string1 =
        """
        不期, ::hiflomo: 是卡片??笔记
            
        
        现在，试着把当前脑海中的!!想法、**灵无??压记录感**、情??绪!!等等记下来，尝试下无压记录的??愉悦??。
        """
        
        let string2 =
        """
        - 现在，试着把当前脑海中的!!想法、**灵无??压记录感**、情??绪!!等等记下来，尝试下无压记录的??愉悦??。
        """
        
        let dropper = Dropper(string: string2)
        let ast = dropper.process(using: shortRules)
        
        printNodes(tree: ast)
        
    }
    
    func testTreeNodes2() {
        
        let string =
        """
        👋，吾友
        ::hiflomo:: 是一款全平台卡片笔记 App，主要功能有：
        - ::极简记录::，做笔记毫无压力#欢迎🍎
        - ::多级标签::，让记录井井有条
        - ::每日回顾::，**与**记录不期而遇
            - ::每日回顾:，与**记录不期而遇
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        print(ast.node(by: .init(location: 11, length: 5)) ?? "None")
        print(ast.node(byDoc: .init(location: 92, length: 5)) ?? "None")
        
    }
    
    func testTreeNodes3() {
        
        let string =
        """
        👋，吾友
        ::hiflomo:: 是一款全平台卡片笔记 App，主要功能有：
        - ::极简记录::，做笔记毫无压力#欢迎🍎
        - ::多级标签::，让记录井井有条
        - ::每日回顾::，**与**记录不期而遇
            - ::每日回顾:，与**记录!!不!!期而遇
        """
        
        let dropper = Dropper(string: string)
        let ast = dropper.process(using: shortRules)
        
        print()
        
        print(ast.nodes(by: .bold)) ; print()
        print(ast.nodes(by: .italics)) ; print()
        print(ast.nodes(by: .underline)) ; print()
        
    }
    
    #if canImport(UIKit)
    func testFontNames() {
        
        let names = UIFont.familyNames
            .map({ UIFont.fontNames(forFamilyName: $0) })
            .flatMap { $0 }
        
        print(names)
        print()
        print(UIFont.fontNames(forFamilyName: "PingFang SC"))
        
    }
    #endif

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            testProcess()
        }
    }

}
