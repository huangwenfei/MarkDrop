//
//  DropContentNodeProtocol.swift
//  MarkDrop
//
//  Created by windy on 2024/5/19.
//

import Foundation

public protocol DropContentNodeProtocol where Self: DropNode {
    var type: DropContentType { get set }
}
