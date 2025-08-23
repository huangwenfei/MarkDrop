//
//  DropExtensions.swift
//  MarkDrop
//
//  Created by windy on 2024/5/20.
//

import Foundation

public struct DropWrapper<RawValue> {
    public typealias RawValue = RawValue
    public let rawValue: RawValue
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

public protocol DropExtensions { }

extension DropExtensions {
    public var drop: DropWrapper<Self> {
        .init(rawValue: self)
    }
}

#if false
extension NSRange: DropExtensions { }
extension DropWrapper where RawValue == NSRange {
    var min: Int { rawValue.location }
}

import UIKit
extension UIView: DropExtensions { }
extension DropWrapper where RawValue == UIView {
    var width: CGFloat { rawValue.frame.size.width }
}

func testWrapper() {
    
    let range = NSRange()
    let _ = range.drop.min
    
    let view = UIView()
    let _ = view.drop.width
    
}
#endif
