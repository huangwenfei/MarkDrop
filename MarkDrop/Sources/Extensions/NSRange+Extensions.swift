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
    
}

extension NSRange {
    internal var maxLocation: Int {
        drop.maxLocation
    }
}
