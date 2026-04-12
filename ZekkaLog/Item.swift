//
//  Item.swift
//  ZekkaLog
//
//

import Foundation
import SwiftData

enum MedicationTarget: String, CaseIterable {
    case both
    case cedarOnly
    case dustMiteOnly

    var displayName: String {
        switch self {
        case .both: return "両方"
        case .cedarOnly: return "スギ花粉のみ"
        case .dustMiteOnly: return "ダニのみ"
        }
    }

    var includedTypes: [MedicationType] {
        switch self {
        case .both: return [.cedar, .dustMite]
        case .cedarOnly: return [.cedar]
        case .dustMiteOnly: return [.dustMite]
        }
    }
}

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
