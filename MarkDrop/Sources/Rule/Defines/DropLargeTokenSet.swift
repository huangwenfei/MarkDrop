//
//  DropLargeTokenSet.swift
//  MarkDrop
//
//  Created by windy on 2024/5/10.
//

import Foundation

/// mark + content(optional) + mark(optional), 1 ~ 3 node
/// mark == content  + mark(optional), 1 ~ 2 node
public struct DropLargeTokenSet: Hashable, CustomStringConvertible {
    
    // MARK: Properties
    public var token: [String] = .init()
    public var closeRule: [DropTokenClose] = []
    
    public var isOnlyVaildOnHead: Bool = false
    public var vaildHeadSet: [DropVaildHead] = []
    
    public var shouldCapture: Bool = true
    public var firstMaxRepeatCount: Int = 1
    
    public var tokenCount: Int {
        (token.count - 1) + firstMaxRepeatCount
    }
    
    public func marks(by index: Int) -> String {
        guard (0 ..< tokenCount).contains(index) else { return "" }
        return firstMaxRepeatCount > 1
            ? (0 ..< firstMaxRepeatCount).contains(index) ? token[0] : token[index - firstMaxRepeatCount + 1]
            : token[index]
    }
    
    public var description: String {
        """
        token: \(token),
        closeRule: \(closeRule)
        """
    }
    
    // MARK: Init
    public init() { }
    
    // MARK: Methods
    public func isVaildHead(_ value: String) -> Bool {
        var isVaild = false
        for item in vaildHeadSet {
            switch item {
            case .leadingHead:
                isVaild = value.isEmpty
                
            case .space:
                isVaild = (value.first?.isWhitespace == true)
                
            case .newline:
                isVaild = (value.first?.isNewline == true)
                
            case .value(let vaild):
                isVaild = vaild.contains(value)
            }
            if isVaild { break }
        }
        return isVaild
    }
    
    // MARK: Hashable
    
}
