//
//  ContentView.swift
//  Sound Level Meter
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var storeManager: StoreManager
    @State private var showOnboarding = false

    var body: some View {
        MainView()
            .environmentObject(settingsManager)
            .environmentObject(storeManager)
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView(isPresented: $showOnboarding)
                    .environmentObject(settingsManager)
            }
            .onAppear {
                checkOnboarding()
            }
    }

    private func checkOnboarding() {
        if !settingsManager.hasCompletedOnboarding {
            showOnboarding = true
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(StoreManager.shared)
        .environmentObject(SettingsManager.shared)
}
