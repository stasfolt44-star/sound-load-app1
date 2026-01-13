//
//  AppSettings.swift
//  Sound Level Meter
//
//  Настройки приложения
//

import Foundation

struct AppSettings: Codable {
    var weighting: Weighting = .A
    var calibrationOffset: Double = 0.0
    var responseTime: ResponseTime = .fast
    var alertEnabled: Bool = false
    var alertThreshold: Double = 85.0
    var alertVibrate: Bool = true
    var alertSound: Bool = false
    var keepScreenOn: Bool = true
    var theme: AppTheme = .system
    var hasCompletedOnboarding: Bool = false

    static let `default` = AppSettings()
}

enum ResponseTime: String, Codable, CaseIterable, Identifiable {
    case slow = "Slow (1s)"
    case fast = "Fast (125ms)"

    var id: String { rawValue }

    var interval: TimeInterval {
        switch self {
        case .slow:
            return 1.0
        case .fast:
            return 0.125
        }
    }
}

enum AppTheme: String, Codable, CaseIterable, Identifiable {
    case light
    case dark
    case system

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case .system:
            return "System"
        }
    }
}
