//
//  CGSize+Extensions.swift
//  MarkDrop
//
//  Created by windy on 2024/5/17.
//

import Foundation
import CoreGraphics

extension CGSize: Hashable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.width == rhs.width &&
        lhs.height == rhs.height
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
    }
    
}
