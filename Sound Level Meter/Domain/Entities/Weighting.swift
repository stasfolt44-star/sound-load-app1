//
//  Weighting.swift
//  Sound Level Meter
//
//  Типы частотного взвешивания
//

import Foundation

enum Weighting: String, Codable, CaseIterable, Identifiable {
    case A = "dBA"
    case C = "dBC"
    case Z = "dBZ"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .A:
            return "A-weighted (recommended)"
        case .C:
            return "C-weighted (bass/music)"
        case .Z:
            return "Z-weighted (flat)"
        }
    }

    var shortName: String {
        return rawValue
    }

    var description: String {
        switch self {
        case .A:
            return "Best for human hearing perception"
        case .C:
            return "Better for low frequencies"
        case .Z:
            return "No weighting applied"
        }
    }

    var isPro: Bool {
        switch self {
        case .A:
            return false
        case .C, .Z:
            return true
        }
    }
}
