//
//  DropMarkRenderMode.swift
//  MarkDrop
//
//  Created by windy on 2024/5/15.
//

import Foundation

public enum DropMarkRenderMode: Hashable {
    
    case keepItAsIs,
         remove,
         replace(new: String),
         append(leading: String, trailing: String)
    
}
