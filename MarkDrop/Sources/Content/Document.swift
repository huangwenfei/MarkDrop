//
//  Document.swift
//  MarkDrop
//
//  Created by windy on 2024/5/3.
//

import Foundation

public final class Document: Hashable {
    
    // MARK: Properties
    public var raw: String
    
    // MARK: Init
    public init(raw: String) {
        self.raw = raw
    }
    
    // MARK: Index
    public var startIndex: String.Index { raw.startIndex }
    public var endIndex: String.Index { raw.endIndex }
    
    public func offset(current: String.Index, string: String) -> String.Index {
        offset(current: current, offset: string.count)
    }
    
    public func offset(current: String.Index, offset: Int) -> String.Index {
        let limit = offset > 0 ? endIndex : startIndex
        return raw.index(current, offsetBy: offset, limitedBy: limit) ?? limit
    }
    
    public func offset(current: String.Index, offset: Int, limit: String.Index) -> String.Index {
        raw.index(current, offsetBy: offset, limitedBy: limit) ?? limit
    }
    
    public func offset(in content: String, current: String.Index, offset: Int) -> String.Index {
        Document.offset(in: content, current: current, offset: offset)
    }
    
    public static func offset(in content: String, current: String.Index, offset: Int) -> String.Index {
        let limit = offset > 0 ? content.endIndex : content.startIndex
        return content.index(current, offsetBy: offset, limitedBy: limit) ?? limit
    }
    
    // MARK: Content
    public func content(in range: DropContants.IntRange) -> String {
        guard range.length > 0 else { return "" }
        let start = offset(current: raw.startIndex, offset: range.location)
        var end = offset(current: start, offset: range.length)
        if end == raw.endIndex {
            end = offset(current: end, offset: -1)
        }
        if start == end, start == raw.endIndex {
            return ""
        } else {
            return String(raw[start ... end])
        }
    }
    
    // MARK: Hashable
    public static func == (lhs: Document, rhs: Document) -> Bool {
        lhs.raw == rhs.raw
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(raw)
    }
    
}
