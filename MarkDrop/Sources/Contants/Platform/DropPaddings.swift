//
//  DropPaddings.swift
//  MarkDrop
//
//  Created by windy on 2024/5/17.
//

import Foundation

#if canImport(UIKit)
import UIKit
public typealias DropPaddings = UIEdgeInsets

#elseif canImport(AppKit)
import AppKit
public typealias DropPaddings = NSEdgeInsets

#endif
