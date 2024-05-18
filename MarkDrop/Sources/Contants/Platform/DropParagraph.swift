//
//  DropParagraph.swift
//  MarkDrop
//
//  Created by windy on 2024/5/18.
//

import Foundation

#if canImport(UIKit)
import UIKit

public typealias DropParagraph = NSParagraphStyle
public typealias DropMutableParagraph = NSMutableParagraphStyle

public typealias DropTabStop = NSTextTab

#elseif canImport(AppKit)
import AppKit
public typealias DropParagraph = NSParagraphStyle
public typealias DropMutableParagraph = NSMutableParagraphStyle

public typealias DropTabStop = NSTextTab
#endif
