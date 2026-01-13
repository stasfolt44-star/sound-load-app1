//
//  Sound_Level_MeterApp.swift
//  Sound Level Meter
//

import SwiftUI

@main
struct Sound_Level_MeterApp: App {
    @State private var storeManager = StoreManager.shared
    @State private var settingsManager = SettingsManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(storeManager)
                .environmentObject(settingsManager)
                .task {
                    // Validate subscription on launch if needed
                    await storeManager.validateIfNeeded()
                }
        }
    }
}
