//
//  SettingsManager.swift
//  Sound Level Meter
//
//  Менеджер настроек приложения
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class SettingsManager: ObservableObject {

    // MARK: - Singleton

    static let shared = SettingsManager()

    // MARK: - Published Properties

    @Published var settings: AppSettings {
        didSet {
            save()
        }
    }

    // MARK: - Keys

    private enum Keys {
        static let settings = "app_settings"
    }

    // MARK: - Initialization

    private init() {
        self.settings = Self.load()
    }

    // MARK: - Persistence

    private static func load() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: Keys.settings),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return AppSettings.default
        }
        return settings
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        UserDefaults.standard.set(data, forKey: Keys.settings)
    }

    // MARK: - Convenience Methods

    var weighting: Weighting {
        get { settings.weighting }
        set { settings.weighting = newValue }
    }

    var calibrationOffset: Double {
        get { settings.calibrationOffset }
        set { settings.calibrationOffset = newValue }
    }

    var alertEnabled: Bool {
        get { settings.alertEnabled }
        set { settings.alertEnabled = newValue }
    }

    var alertThreshold: Double {
        get { settings.alertThreshold }
        set { settings.alertThreshold = newValue }
    }

    var keepScreenOn: Bool {
        get { settings.keepScreenOn }
        set { settings.keepScreenOn = newValue }
    }

    var hasCompletedOnboarding: Bool {
        get { settings.hasCompletedOnboarding }
        set { settings.hasCompletedOnboarding = newValue }
    }

    // MARK: - Reset

    func resetToDefaults() {
        settings = AppSettings.default
    }

    func resetCalibration() {
        settings.calibrationOffset = 0
    }
}
