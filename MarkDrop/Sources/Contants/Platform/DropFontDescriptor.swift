//
//  DropFontDescriptor.swift
//  MarkDrop
//
//  Created by windy on 2024/5/17.
//

import Foundation

#if canImport(UIKit)

import UIKit
public typealias DropFontDescriptor = UIFontDescriptor

#elseif canImport(AppKit)

import AppKit
public typealias DropFontDescriptor = NSFontDescriptor

#endif
