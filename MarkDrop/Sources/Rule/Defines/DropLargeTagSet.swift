//
//  DropLargeTagSet.swift
//  MarkDrop
//
//  Created by windy on 2024/5/10.
//

import Foundation

/// mark + content + mark, 3 node
public struct DropLargeTagSet: Hashable, CustomStringConvertible {
    
    // MARK: Properties
    public var openTag: [String] = .init()
    public var closeTag: String = .init()
    
    public var firstMaxRepeatCount: Int = 1
    
    public var openTagCount: Int {
        (openTag.count - 1) + firstMaxRepeatCount
    }
    
    public func openMarks(by index: Int) -> String {
        guard (0 ..< openTagCount).contains(index) else { return "" }
        return firstMaxRepeatCount > 1
            ? (0 ..< firstMaxRepeatCount).contains(index) ? openTag[0] : openTag[index - firstMaxRepeatCount + 1]
            : openTag[index]
    }
    
    /// control close point
    public var isLooseModeOn: Bool = false
    public var looseCanSpanParagraphs: Bool = false
    
    public var isMultiParagraphMode: Bool {
        isLooseModeOn && looseCanSpanParagraphs
    }
    
    public var description: String {
        """
        openTag: \(openTag),
        endTag: \(closeTag)
        """
    }
    
    // MARK: Init
    public init() { }
    
    // MARK: Methods
    
    // MARK: Hashable
    
}
