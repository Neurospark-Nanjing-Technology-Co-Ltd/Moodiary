//
//  Item.swift
//  Moodiary
//
//  Created by F1reC on 2024/9/17.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
