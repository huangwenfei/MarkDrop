//
//  DropTokenSet.swift
//  MarkDrop
//
//  Created by windy on 2024/5/6.
//

import Foundation

/// mark + content(optional) + mark(optional), 1 ~ 3 node
/// mark == content  + mark(optional), 1 ~ 2 node
public struct DropTokenSet: Hashable, CustomStringConvertible {
    
    // MARK: Properties
    public var token: String = .init()
    public var closeRule: [DropTokenClose] = []
    
    public var isOnlyVaildOnHead: Bool = false
    public var vaildHeadSet: [DropVaildHead] = []
    
    public var shouldCapture: Bool = true
    
    public var isInvalidCaptureOn: Bool = false
    public var invaildCaptureSet: String = ""
    
    public var shouldOpenDone: Bool {
        closeRule.isEmpty && shouldCapture == false
    }
    
    public var isCombineContents: Bool = false
    
    public var isCaptureCloseContent: Bool = true
    
    public var description: String {
        """
        token: \(token),
        closeRule: \(closeRule)
        """
    }
    
    // MARK: Init
    
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
