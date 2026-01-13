//
//  Colors.swift
//  Sound Level Meter
//
//  Цветовая схема приложения
//

import SwiftUI

extension Color {

    // MARK: - Safety Level Colors
    static let safeGreen = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let cautionYellow = Color(red: 1.0, green: 0.8, blue: 0.0)
    static let warningOrange = Color(red: 1.0, green: 0.6, blue: 0.0)
    static let dangerRed = Color(red: 1.0, green: 0.3, blue: 0.3)

    // MARK: - Background Colors
    static let cardBackground = Color(.systemGray6)
    static let panelBackground = Color(.systemBackground)

    // MARK: - Graph Colors
    static let graphLine = Color.accentColor
    static let graphFill = Color.accentColor.opacity(0.3)
    static let graphGrid = Color.gray.opacity(0.2)
}

// MARK: - Safety Level Extension
extension Color {
    static func forSafetyLevel(_ level: SafetyLevel) -> Color {
        switch level {
        case .safe:
            return .safeGreen
        case .caution:
            return .cautionYellow
        case .warning:
            return .warningOrange
        case .danger, .extreme:
            return .dangerRed
        }
    }

    static func forDecibelLevel(_ dB: Double) -> Color {
        switch dB {
        case ..<Constants.Safety.cautionLevel:
            return .safeGreen
        case ..<Constants.Safety.warningLevel:
            return .cautionYellow
        case ..<Constants.Safety.dangerLevel:
            return .warningOrange
        default:
            return .dangerRed
        }
    }
}
