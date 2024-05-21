//
//  DropRenderExpandSpaces.swift
//  MarkDrop
//
//  Created by windy on 2024/5/21.
//

import Foundation

public struct DropRenderExpandSpaces: Hashable {
    
    // MARK: Properties
    public var leading: String
    public var trailing: String
    
    // MARK: Init
    public init(leading: String, trailing: String) {
        self.leading = leading
        self.trailing = trailing
    }
    
}
