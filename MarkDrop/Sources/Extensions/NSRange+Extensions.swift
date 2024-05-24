//
//  NSRange+Extensions.swift
//  MarkDrop
//
//  Created by windy on 2024/5/11.
//

import Foundation

extension NSRange: DropExtensions { }

extension DropWrapper where RawValue == NSRange {
    
    public var maxLocation: Int {
        rawValue.location + rawValue.length
    }
    
    public var vaildMaxLocation: Int {
        rawValue.location == 0 
            ? rawValue.length
            : (rawValue.location < 0 ? 0 : maxLocation - 1)
    }
    
}

extension NSRange {
    internal var maxLocation: Int {
        drop.maxLocation
    }
    
    internal var vaildMaxLocation: Int {
        drop.vaildMaxLocation
    }
}
