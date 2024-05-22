//
//  DropAttributedMappingResult.swift
//  MarkDrop
//
//  Created by windy on 2024/5/22.
//

import Foundation

public struct DropAttributedMappingResult {
    
    // MARK: Properties
    public var content: NSAttributedString
    public var attributes: DropContants.AttributedDict
    
    // MARK: Init
    public init(content: NSAttributedString = .init(string: ""), attributes: DropContants.AttributedDict = .init()) {
        self.content = content
        self.attributes = attributes
    }
    
}
