//
//  DropMultiTagSet.swift
//  MarkDrop
//
//  Created by windy on 2024/5/14.
//

import Foundation

/// open + content(optional) + meidans(optional) + content(optional) + close, 2 ~ 5 node
public struct DropMultiTagSet: Hashable, CustomStringConvertible {
    
    // MARK: Properties
    public var openTag: String = .init()
    public var meidanTags: [String]? = nil
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
        meidanTags: \(String(describing: meidanTags)),
        endTag: \(closeTag),
        render: \(render)
        """
    }
    
    // MARK: Init
    public init() { }
    
    // MARK: Methods
    
    // MARK: Hashable
    
}
