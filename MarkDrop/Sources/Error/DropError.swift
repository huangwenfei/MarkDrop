//
//  DropError.swift
//  MarkDrop
//
//  Created by windy on 2024/5/3.
//

import Foundation

public enum DropError: Error {
    case process
}

extension DropError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .process:
            return "Process Failure !"
        }
    }
}
