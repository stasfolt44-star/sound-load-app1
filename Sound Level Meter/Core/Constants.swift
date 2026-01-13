//
//  Constants.swift
//  Sound Level Meter
//
//  Константы приложения
//

import Foundation

enum Constants {

    // MARK: - Audio
    enum Audio {
        static let sampleRate: Double = 44100.0
        static let bufferSize: Int = 1024
        static let readingsPerSecond: Int = 10
        static let maxBufferSeconds: Int = 30
        static let minDecibelLevel: Double = 0
        static let maxDecibelLevel: Double = 140
    }

    // MARK: - UI
    enum UI {
        static let animationDuration: Double = 0.3
        static let graphUpdateInterval: Double = 0.1
        static let miniGraphSeconds: Int = 5
        static let extendedGraphSeconds: Int = 30
    }

    // MARK: - Storage
    enum Storage {
        static let maxFreeHistoryDays: Int = 7
        static let maxFreeHistoryItems: Int = 10
    }

    // MARK: - Subscription
    enum Subscription {
        static let gracePeriodDays: Int = 7
        static let lifetimeProductID = "com.soundmeter.pro.lifetime"
        static let weeklyProductID = "com.soundmeter.pro.weekly"
        static let annualProductID = "com.soundmeter.pro.annual"
    }

    // MARK: - Safety Thresholds (NIOSH)
    enum Safety {
        static let safeLevel: Double = 70
        static let cautionLevel: Double = 80
        static let warningLevel: Double = 85
        static let dangerLevel: Double = 90
        static let extremeLevel: Double = 100
    }
}
