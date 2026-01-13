//
//  SafetyLevel.swift
//  Sound Level Meter
//
//  Уровни безопасности звука
//

import SwiftUI

enum SafetyLevel: String, Codable, CaseIterable {
    case safe = "Safe"
    case caution = "Caution"
    case warning = "Limited exposure"
    case danger = "Hearing damage risk"
    case extreme = "Immediate risk"

    var color: Color {
        Color.forSafetyLevel(self)
    }

    var icon: String {
        switch self {
        case .safe:
            return "checkmark.shield.fill"
        case .caution:
            return "exclamationmark.triangle"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .danger:
            return "xmark.shield.fill"
        case .extreme:
            return "xmark.octagon.fill"
        }
    }

    static func forLevel(_ dB: Double) -> SafetyLevel {
        switch dB {
        case ..<Constants.Safety.cautionLevel:
            return .safe
        case ..<Constants.Safety.warningLevel:
            return .caution
        case ..<Constants.Safety.dangerLevel:
            return .warning
        case ..<Constants.Safety.extremeLevel:
            return .danger
        default:
            return .extreme
        }
    }
}
