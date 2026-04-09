//
//  Item.swift
//  ZekkaLog
//
//  Created by 大村勇人 on 2026/02/23.
//

import Foundation
import SwiftData

enum MedicationType: String, Codable, CaseIterable, Identifiable {
    case cedar = "スギ花粉"
    case dustMite = "ダニ"

    var id: String { rawValue }
    var displayName: String { rawValue }

    var systemImage: String {
        switch self {
        case .cedar: return "leaf.fill"
        case .dustMite: return "ant.fill"
        }
    }
}

@Model
final class MedicationRecord {
    var typeRawValue: String
    var takenAt: Date

    var type: MedicationType {
        MedicationType(rawValue: typeRawValue) ?? .cedar
    }

    init(type: MedicationType, takenAt: Date = Date()) {
        self.typeRawValue = type.rawValue
        self.takenAt = takenAt
    }
}
