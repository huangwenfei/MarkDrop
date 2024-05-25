//
//  DropMultiTagSet.swift
//  MarkDrop
//
//  Created by windy on 2024/5/14.
//

import Foundation

/// mark + content + mark, 3 node
/// mark + content + (mark + content)(optional) + mark, >= 5 node
public struct DropMultiTagSet: Hashable, CustomStringConvertible {
    
    // MARK: Properties
    public var openTag: String = .init()
    public var meidanTags: [String] = []
    public var closeTag: String = .init()
    
    public var render: [DropMultiTagRenderType: DropMarkRenderMode] = .init()
    
    /// control close point
    public var isLooseModeOn: Bool = false
    public var looseCanSpanParagraphs: Bool = false
    
    public var isMultiParagraphMode: Bool {
        isLooseModeOn && looseCanSpanParagraphs
    }
    
    public var description: String {
        """
        openTag: \(openTag),
        meidanTags: \(meidanTags),
        endTag: \(closeTag),
        render: \(render)
        """
    }
    
    // MARK: Init
    public init() { }
    
    // MARK: Methods
    
    // MARK: Hashable
    
}
