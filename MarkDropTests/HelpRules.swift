//
//  HelpRules.swift
//  MarkDropTests
//
//  Created by windy on 2024/5/13.
//

import Foundation
@testable import MarkDrop

public struct HelpRules {
    
    public static let flomoRules: [DropRule] = [
        DropBulletRule(),
        DropNumberOrderRule(),
        DropLetterOrderRule(),
        
        DropTabIndentRule(),
        DropSpaceIndentRule(),
        
        DropHashTagRule(),
        DropMentionRule(),
        
        DropBoldRule(),
        DropItalicsRule(),
        DropUnderlineRule(),
        DropHighlightRule(),
        DropStrokeRule(),
    ]
    
    public static let shortRules: [DropRule] = [
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
    
    public static let plainShortRules: [DropRule] = [
        DropPlainBulletRule(),
        DropPlainNumberOrderRule(),
        DropPlainLetterOrderRule(),
        
        DropTabIndentRule(),
        DropSpaceIndentRule(),
        
        DropPlainHashTagRule(),
        DropPlainMentionRule(),
        
        DropShortBoldRule(),
        DropShortItalicsRule(),
        DropShortUnderlineRule(),
        DropShortHighlightRule(),
        DropShortStrokeRule(),
    ]
    
}
