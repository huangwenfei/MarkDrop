//
//  DropActionState.swift
//  MarkDrop
//
//  Created by windy on 2024/5/18.
//

import Foundation

public enum DropActionState: Int, Hashable, Codable {
    case normal, highlight, focus, invoke
}
