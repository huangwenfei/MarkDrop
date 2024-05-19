//
//  ViewController.swift
//  MarkDropDemo
//
//  Created by windy on 2024/5/18.
//

import UIKit
import MarkDrop

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let string =
        """
        👋，吾友
        ::hiflomo:: 是一款全平台卡片笔记 App，主要功能有：
        - ::极简记录::，做笔记毫无压力#欢迎🍎
        - ::多级标签::，让记录井井有条
        - ::每日回顾::，**&与&**记录不期而遇
            - ::每日回顾:，与**记录@不期而遇
        
        1. 你说::??努力??::有用吗？
        - 不期而&&遇 Opportunity &&，期望美好的开始
        不期, ::hiflomo: 是卡片??笔记

        现在，试着把当前脑海中的!!想法、**灵 Memo 感**、情绪!!等等记下来，尝试下无压记录的??愉悦??。
        \t- #欢迎/新人??指南??
            
                现在，试着把当前脑海中的😤
        """
        
        let string1 =
        """
            \t现在，试着把当前脑海中的!!想法、**A灵无??压Press记录感Z**、情??绪!!等等记下来，尝试下#无压记录的??愉悦??。
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
        
        // MARK: Edit View
        
        let new = NSMutableAttributedString(string: "Result: ")
        new.addAttribute(.underlineColor, value: UIColor.red, range: .init(location: 0, length: new.length))
        new.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: .init(location: 0, length: new.length))
        
        let textView = UITextView(frame: view.bounds)
        textView.contentInset = .init(top: 60, left: 16, bottom: 40, right: 16)
        textView.attributedText = attributedString
        
        view.addSubview(textView)
        
    }


}

