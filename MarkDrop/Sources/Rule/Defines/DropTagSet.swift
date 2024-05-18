//
//  DropTagSet.swift
//  MarkDrop
//
//  Created by windy on 2024/5/3.
//

import Foundation

/// mark + content + mark, 3 node
/// mark + content + mark + content + mark, 5 node
public struct DropTagSet: Hashable, CustomStringConvertible {
    
    // MARK: Properties
    public var openTag: String = .init()
    public var meidanTag: String? = nil
    public var closeTag: String = .init()
    
    public var description: String {
        """
        openTag: \(openTag),
        meidanTag: \(meidanTag ?? "nil"),
        endTag: \(closeTag)
        """
    }
    
    // MARK: Init
    
    // MARK: Methods
    
    // MARK: Hashable
    
}
