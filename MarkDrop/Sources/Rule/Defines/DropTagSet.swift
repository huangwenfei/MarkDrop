//
//  DropTagSet.swift
//  MarkDrop
//
//  Created by windy on 2024/5/3.
//

import Foundation

/// open + content(optional) + meidan(optional) + content(optional) + close, 2 ~ 5 node
public struct DropTagSet: Hashable, CustomStringConvertible {
    
    // MARK: Properties
    public var openTag: String = .init()
    public var meidanTag: String? = nil
    public var closeTag: String = .init()
    
    /// control close point
    public var isLooseModeOn: Bool = false
    public var looseCanSpanParagraphs: Bool = false
    
    public var isMultiParagraphMode: Bool {
        isLooseModeOn && looseCanSpanParagraphs
    }
    
    public var description: String {
        """
        openTag: \(openTag),
        meidanTag: \(meidanTag ?? "nil"),
        endTag: \(closeTag)
        """
    }
    
    // MARK: Init
    public init() { }
    
    // MARK: Methods
    
    // MARK: Hashable
    
}
