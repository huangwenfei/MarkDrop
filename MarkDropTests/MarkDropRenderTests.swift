//
//  MarkDropRenderTests.swift
//  MarkDropTests
//
//  Created by windy on 2024/5/13.
//

import XCTest
@testable import MarkDrop

final class MarkDropRenderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    let flomoRules = HelpRules.flomoRules
    let shortRules = HelpRules.shortRules
    let plainShortRules = HelpRules.plainShortRules
    
    func testPlainText() throws {
        
        let string =
        """
        👋，吾友
        ::drop:: 是一款全平台卡片笔记 App，主要功能有：
        - ::极简记录::，做笔记毫无压力#欢迎🍎
        - ::多级标签::，让记录井井有条
        - ::每日回顾::，**与**记录不期而遇
            - ::每日回顾:，与**记录不期而遇
        
        1. 你说::??努力??::有用吗？
        - 不期而遇，期望美好的开始
        不期, ::drop: 是卡片??笔记

        现在，试着把当前脑海中的!!想法、**灵感**、情绪!!等等记下来，尝试下无压记录的??愉悦??。
        - #欢迎/新人??指南??
            
                现在，试着把当前脑海中的😤
        """
        
        let rules = plainShortRules
        
        let plain = PlainTextRender(string: string, using: rules).render { mark in
            print(#function, #line, mark)
        }
        
        print()
        print("Result: ")
        print(plain)
        print()
    }
    
    func testPlainText2() throws {
        
        let string =
        """
        现在，试着把当前脑海中的!!想法、**灵无??压记录感**、情??绪!!等等记下来，尝试下无压记录的??愉悦??。
        """
        
        let rules = plainShortRules
        
        let plain = PlainTextRender(string: string, using: rules).render { mark in
            print(#function, #line, mark)
        }
        
        print()
        print("Result: ")
        print(plain)
        print()
    }
    
    func testPlainText3() throws {
        
        let string =
        """
        👋，吾友
        ::drop:: 是一款全平台卡片笔记 App，主要功能有：
        - ::极简记录::，做笔记毫无压力#欢迎🍎
        - ::多级标签::，让记录井井有条
        - ::每日回顾::，**与**记录不期而遇
            - ::每日回顾:，与**记录不期而遇
        
        1. 你说::??努力??::有用吗？
        - 不期而遇，期望美好的开始
        不期, ::drop: 是卡片??笔记

        现在，试着把当前脑海中的!!想法、**灵感**、情绪!!等等记下来，尝试下无压记录的??愉悦??。
        - #欢迎/新人??指南??
            
                现在，试着把当前脑海中的😤
        """
        
        let rules = plainShortRules
        
        let (marks, plain) = PlainTextRender.renderAndDropMarks(string: string, using: rules)
        
        print()
        print("marks: \(marks)\n")
        print("Result: ")
        print(plain)
        print()
        
        var originString = plain
        PlainTextRender.recover(by: marks, in: &originString)
        
        print()
        print("IsEqual: ", originString == string)
        print("Result: ")
        print(originString)
        print()
    }
    
    func testPlainText4() throws {
        
        let string =
        """
        现在，试着把当前脑海中的!!想法、**灵无??压记录感**、情??绪!!等等记下来，尝试下无压记录的??愉悦??。
        """
        
        let rules = plainShortRules
        
        let (marks, plain) = PlainTextRender.renderAndDropMarks(string: string, using: rules)
        
        print()
        print("marks: \(marks)\n")
        print("Result: ")
        print(plain)
        print()
        
        var originString = plain
        PlainTextRender.recover(by: marks, in: &originString)
        
        print()
        print("IsEqual: ", originString == string)
        print("Result: ")
        print(originString)
        print()
        
    }
    
    func testPlainText5() throws {
        
        let string =
        """
        现在，试着把当前#脑海中 的!!想法、**灵无??压记录感**、情??绪!!等等记下来，尝试下无压记录的??愉悦??。
        不期而遇，#期望美好 的开始
        """
        
        let rules = plainShortRules
        
        let (marks, plain) = PlainTextRender.renderAndDropMarks(string: string, using: rules)
        
        print()
        print("marks: \(marks)\n")
        print("Result: ")
        print(plain)
        print()
        
        var originString = plain
        PlainTextRender.recover(by: marks, in: &originString)
        
        print()
        print("IsEqual: ", originString == string)
        print("Result: ")
        print(originString)
        print()
        
    }
    
    func testPlainText6() throws {
        
        let string =
        """
        现在，试着把当前#脑海中 的!!想法、**灵无??压记录感**、情??绪!!等等记下来，尝试下无压记录的??愉悦??。
        不期而遇，#期望美好 的开始
        """
        
        let rules = plainShortRules
        
        var tagIds = [(raw: String, replace: String)]()
        
        func isReplace(_ type: DropContentType, _ markType: DropContentMarkType, _ content: String) -> Bool {
            type == .hashTag && markType == .text
        }
        
        let (marks, plain) = PlainTextRender.renderAndDropMarks(string: string, using: rules) { type, markType, content, renderContent in
            if isReplace(type, markType, content) {
                let tagId = UUID().uuidString
                tagIds.append((content, tagId))
                return (tagId, "")
            } else {
                return (content, renderContent)
            }
        }
        
        print()
        print("marks: \(marks)\n")
        print("tagIds: \(tagIds)\n")
        print("Result: ")
        print(plain)
        print()
        
        var originString = plain
        PlainTextRender.recover(by: marks, in: &originString) { mark, content in
            if isReplace(mark.type, mark.markType, content) {
                let raw = tagIds.first(where: { $0.replace == mark.content })
                return raw!.raw
            } else {
                return content
            }
        }
        
        print()
        print("IsEqual: ", originString == string)
        print("Result: ")
        print(originString)
        print()
        
    }
    
    func testPlainText7() throws {
        
        let string =
        """
        👋，吾友
        ::drop:: 是一款全平台卡片笔记 App，主要功能有：
        - ::极简记录::，做笔记毫无压力#欢迎🍎
        - ::多级标签::，让记录井井有条
        - ::每日回顾::，**与**记录不期而遇
            - ::每日回顾:，与**记录不期而遇
        
        1. 你说::??努力??::有用吗？
        - 不期而遇，期望美好的开始
        不期, ::drop: 是卡片??笔记

        现在，试着把当前脑海中的!!想法、**灵感**、情绪!!等等记下来，尝试下无压记录的??愉悦??。
        - #欢迎/新人??指南??
            
                现在，试着把当前脑海中的😤
        """
        
        let rules = plainShortRules
        
        var tagIds = [(raw: String, replace: String)]()
        
        /// #欢迎/新人??指南?? 应该拆解成 两个 而不是 三个
        let (marks, plain) = PlainTextRender.renderAndDropMarks(string: string, using: rules) { type, markType, content, renderContent in
            if DropPlainRenderMark.isReplace(type, markType, content) {
                let tagId = UUID().uuidString
                tagIds.append((content, tagId))
                return (tagId, "")
            } else {
                return (content, renderContent)
            }
        }
        
        print()
        print("marks: \(marks)\n")
        print("tagIds: \(tagIds)\n")
        print("Result: ")
        print(plain)
        print()
        
        var originString = plain
        PlainTextRender.recover(by: marks, in: &originString) { mark, content in
            if DropPlainRenderMark.isReplace(mark.type, mark.markType, content) {
                let raw = tagIds.first(where: { $0.replace == mark.content })
                return raw!.raw
            } else {
                return content
            }
        }
        
        print()
        print("IsEqual: ", originString == string)
        print("Result: ")
        print(originString)
        print()
        
    }

    func testAttributedString() throws {
        
        let string =
        """
        👋，吾友
        ::drop:: 是一款全平台卡片笔记 App，主要功能有：
        - ::极简记录::，做笔记毫无压力#欢迎🍎
        - ::多级标签::，让记录井井有条
        - ::每日回顾::，**与**记录不期而遇
            - ::每日回顾:，与**记录不期而遇
        
        1. 你说::??努力??::有用吗？
        - 不期而遇，期望美好的开始
        不期, ::drop: 是卡片??笔记

        现在，试着把当前脑海中的!!想法、**灵感**、情绪!!等等记下来，尝试下无压记录的??愉悦??。
        \t- #欢迎/新人??指南??
            
                现在，试着把当前脑海中的😤
        """
        
        let string1 =
        """
            现在，试着把当前脑海中的!!想法、**灵无??压记录感**、情??绪!!等等记下来，尝试下无压记录的??愉悦??。
        """
        
        let rules = shortRules
        
        let attributes = DropEnvironmentAttributes()
        let mapping = DropAppleAttributedMapping() /// DropDefaultAttributedMapping()
        
        let attributedString = AttributedStringRender
            .init(
                string: string,
                using: rules
            )
            .render(
                with: attributes.attributes(in: .light),
                mapping: mapping
            )
        
        print()
        print("Result: ")
        print(attributedString)
        print()
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
