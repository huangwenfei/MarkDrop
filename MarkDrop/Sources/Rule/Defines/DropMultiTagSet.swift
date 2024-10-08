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
    
    public var description: String {
        """
        openTag: \(openTag),
        meidanTags: \(meidanTags),
        endTag: \(closeTag),
        render: \(render)
        """
    }
    
    // MARK: Init
    
    // MARK: Methods
    
    // MARK: Hashable
    
}
