//
//  DropFont.swift
//  MarkDrop
//
//  Created by windy on 2024/5/17.
//

import Foundation

#if canImport(UIKit)

import UIKit
public typealias DropFont = UIFont

#elseif canImport(AppKit)

import AppKit
public typealias DropFont = NSFont

#endif
