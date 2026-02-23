//
//  Item.swift
//  ZekkaLog
//
//  Created by 大村勇人 on 2026/02/23.
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
