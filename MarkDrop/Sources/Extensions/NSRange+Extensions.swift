//
//  NSRange+Extensions.swift
//  MarkDrop
//
//  Created by windy on 2024/5/11.
//

import Foundation

extension NSRange {
    
    public var maxLocation: Int {
        location + length
    }
    
}
