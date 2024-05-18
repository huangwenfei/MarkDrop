//
//  DropRendable.swift
//  MarkDrop
//
//  Created by windy on 2024/5/16.
//

import Foundation

public protocol DropRendable {
    
    var document: Document { get set }
    var rules: [DropRule] { get set }
    
    init(string: String, using rules: [DropRule])
    
    associatedtype Result
    func render() -> Result
    
}
