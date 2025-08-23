//
//  ViewController.swift
//  MarkDropDemo
//
//  Created by windy on 2024/5/18.
//

import UIKit
import MarkDrop

class ViewController: UIViewController {
    
    // MARK: Properties
    
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
    let mapping = DropAppleAttributedMapping() /// DropDefaultAttributedMapping()
    
    // MARK: View
    var textView: UITextView!

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textView = UITextView(frame: view.bounds)
        textView.contentInset = .init(top: 60, left: 16, bottom: 40, right: 16)
        textView.attributedText = attributedString()
        self.textView = textView
        
        view.addSubview(textView)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        textView?.frame = view.bounds
    }
    
    // MARK: Render
    func attributedString() -> NSAttributedString {
        
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
        
        print()
        print("Result: ")
        print(attributedString)
        print()
        
        return attributedString
    }

    // MARK: App
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        textView?.attributedText = attributedString()
        
    }

}

