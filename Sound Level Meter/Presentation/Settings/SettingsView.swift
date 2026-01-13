//
//  SettingsView.swift
//  Sound Level Meter
//
//  Экран настроек (Level 3 - Pro features)
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var storeManager: StoreManager
    @StateObject private var historyManager = HistoryManager.shared
    @State private var showPaywall = false
    @State private var showCalibration = false
    @State private var isRestoring = false
    @State private var showRestoreAlert = false
    @State private var restoreAlertMessage = ""
    @State private var showClearDataConfirmation = false
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []

    private var isPro: Bool {
        storeManager.isPro
    }

    var body: some View {
        NavigationStack {
            List {
                // Subscription Section
                subscriptionSection

                // Measurement Section
                measurementSection

                // Alerts Section
                alertsSection

                // Data Section
                dataSection

                // Appearance Section
                appearanceSection

                // About Section
                aboutSection
            }
            .navigationTitle(LocalizedString.Settings.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(LocalizedString.Common.done) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .environmentObject(storeManager)
            }
            .sheet(isPresented: $showCalibration) {
                CalibrationView()
                    .environmentObject(settingsManager)
            }
            .alert(LocalizedString.SettingsItem.restorePurchasesTitle, isPresented: $showRestoreAlert) {
                Button("OK") { }
            } message: {
                Text(restoreAlertMessage)
            }
            .alert(LocalizedString.SettingsItem.clearAllDataTitle, isPresented: $showClearDataConfirmation) {
                Button(LocalizedString.Common.cancel, role: .cancel) { }
                Button(LocalizedString.SettingsItem.clearAllButton, role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text(LocalizedString.SettingsItem.clearAllDataMessage)
            }
            .sheet(isPresented: $showShareSheet) {
                ActivityViewController(activityItems: shareItems)
            }
        }
    }

    // MARK: - Subscription Section

    private var subscriptionSection: some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedString.SettingsItem.currentPlan)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(isPro ? LocalizedString.SettingsItem.planPro : LocalizedString.SettingsItem.planFree)
                        .font(.headline)
                        .foregroundStyle(isPro ? Color.accentColor : .primary)
                }

                Spacer()

                if !isPro {
                    Button(LocalizedString.SettingsItem.upgrade) {
                        showPaywall = true
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }

            Button {
                restorePurchases()
            } label: {
                HStack {
                    Label(LocalizedString.SettingsItem.restorePurchases, systemImage: "arrow.clockwise")
                    if isRestoring {
                        Spacer()
                        ProgressView()
                            .controlSize(.small)
                    }
                }
            }
            .disabled(isRestoring)
        } header: {
            Text(LocalizedString.SettingsSection.subscription)
        }
    }

    // MARK: - Measurement Section

    private var measurementSection: some View {
        Section {
            // Frequency Weighting
            HStack {
                Label(LocalizedString.SettingsItem.frequencyWeighting, systemImage: "waveform.path")

                Spacer()

                if isPro {
                    Picker("", selection: $settingsManager.settings.weighting) {
                        ForEach(Weighting.allCases) { weighting in
                            Text(weighting.shortName).tag(weighting)
                        }
                    }
                    .pickerStyle(.menu)
                } else {
                    HStack(spacing: 4) {
                        Text(settingsManager.weighting.shortName)
                            .foregroundStyle(.secondary)

                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .onTapGesture {
                        showPaywall = true
                    }
                }
            }

            // Calibration
            Button {
                if isPro {
                    showCalibration = true
                } else {
                    showPaywall = true
                }
            } label: {
                HStack {
                    Label(LocalizedString.Calibration.title, systemImage: "tuningfork")

                    Spacer()

                    if settingsManager.calibrationOffset != 0 {
                        Text(String(format: "%+.1f dB", settingsManager.calibrationOffset))
                            .foregroundStyle(.secondary)
                    }

                    if !isPro {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .foregroundStyle(.primary)

            // Response Time
            HStack {
                Label(LocalizedString.SettingsItem.responseTime, systemImage: "timer")

                Spacer()

                if isPro {
                    Picker("", selection: $settingsManager.settings.responseTime) {
                        ForEach(ResponseTime.allCases) { time in
                            Text(time.rawValue).tag(time)
                        }
                    }
                    .pickerStyle(.menu)
                } else {
                    HStack(spacing: 4) {
                        Text(settingsManager.settings.responseTime.rawValue)
                            .foregroundStyle(.secondary)

                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .onTapGesture {
                        showPaywall = true
                    }
                }
            }
        } header: {
            Text(LocalizedString.SettingsSection.measurement)
        }
    }

    // MARK: - Alerts Section

    private var alertsSection: some View {
        Section {
            Toggle(isOn: Binding(
                get: { isPro && settingsManager.alertEnabled },
                set: { newValue in
                    if isPro {
                        settingsManager.alertEnabled = newValue
                    } else {
                        showPaywall = true
                    }
                }
            )) {
                HStack {
                    Label(LocalizedString.SettingsItem.thresholdAlert, systemImage: "bell.badge")

                    if !isPro {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if settingsManager.alertEnabled && isPro {
                HStack {
                    Text(LocalizedString.SettingsItem.alertAt)

                    Spacer()

                    Text("\(Int(settingsManager.alertThreshold)) dB")
                        .foregroundStyle(.secondary)
                }

                Slider(value: $settingsManager.settings.alertThreshold, in: 70...110, step: 5)

                Toggle(LocalizedString.SettingsItem.vibrate, isOn: $settingsManager.settings.alertVibrate)
                Toggle(LocalizedString.SettingsItem.sound, isOn: $settingsManager.settings.alertSound)
            }
        } header: {
            Text(LocalizedString.SettingsSection.alerts)
        }
    }

    // MARK: - Data Section

    private var dataSection: some View {
        Section {
            Button {
                if isPro {
                    exportAllData()
                } else {
                    showPaywall = true
                }
            } label: {
                HStack {
                    Label(LocalizedString.SettingsItem.exportFormat, systemImage: "square.and.arrow.up")

                    Spacer()

                    Text("CSV")
                        .foregroundStyle(.secondary)

                    if !isPro {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .foregroundStyle(.primary)

            Toggle(LocalizedString.SettingsItem.autoSaveRecordings, isOn: .constant(true))

            Button(role: .destructive) {
                showClearDataConfirmation = true
            } label: {
                Label(LocalizedString.SettingsItem.clearAllData, systemImage: "trash")
            }
        } header: {
            Text(LocalizedString.SettingsSection.data)
        }
    }

    // MARK: - Appearance Section

    private var appearanceSection: some View {
        Section {
            Picker(LocalizedString.SettingsItem.theme, selection: $settingsManager.settings.theme) {
                ForEach(AppTheme.allCases) { theme in
                    Text(theme.displayName).tag(theme)
                }
            }

            Toggle(LocalizedString.SettingsItem.keepScreenOn, isOn: $settingsManager.settings.keepScreenOn)
        } header: {
            Text(LocalizedString.SettingsSection.appearance)
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section {
            NavigationLink {
                HowItWorksView()
            } label: {
                Label(LocalizedString.SettingsItem.howItWorks, systemImage: "questionmark.circle")
            }

            Link(destination: URL(string: "https://stasfolt44-star.github.io/soundlevelmeter-app/privacy.html")!) {
                Label(LocalizedString.SettingsItem.privacyPolicy, systemImage: "hand.raised")
            }

            Link(destination: URL(string: "https://stasfolt44-star.github.io/soundlevelmeter-app/terms.html")!) {
                Label(LocalizedString.SettingsItem.termsOfService, systemImage: "doc.text")
            }

            Button {
                // Rate app
                if let url = URL(string: "itms-apps://itunes.apple.com/app/id6756615642?action=write-review") {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label(LocalizedString.SettingsItem.rateApp, systemImage: "star")
            }

            Link(destination: URL(string: "mailto:stasfolt44@gmail.com")!) {
                Label(LocalizedString.SettingsItem.contactSupport, systemImage: "envelope")
            }

            HStack {
                Text(LocalizedString.SettingsItem.version)
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text(LocalizedString.SettingsSection.about)
        }
    }

    // MARK: - Restore Purchases

    private func restorePurchases() {
        Task {
            isRestoring = true
            do {
                try await storeManager.restorePurchases()
                if storeManager.isPro {
                    restoreAlertMessage = LocalizedString.SettingsItem.restoreSuccess
                } else {
                    restoreAlertMessage = LocalizedString.SettingsItem.restoreNoPurchases
                }
                showRestoreAlert = true
            } catch {
                restoreAlertMessage = LocalizedString.SettingsItem.restoreFailed
                showRestoreAlert = true
            }
            isRestoring = false
        }
    }

    // MARK: - Export All Data

    private func exportAllData() {
        let sessions = historyManager.sessions
        guard !sessions.isEmpty else { return }

        Task {
            do {
                // Capture session data on main thread
                let sessionsData = sessions.map { session in
                    (
                        id: session.id,
                        startTime: session.startTime,
                        formattedDuration: session.formattedDuration,
                        minLevel: session.minLevel,
                        avgLevel: session.avgLevel,
                        maxLevel: session.maxLevel,
                        leq: session.leq,
                        weighting: session.weighting,
                        categoryName: session.category.localizedName
                    )
                }

                // Generate CSV on background thread
                let csvURL = try await Task.detached {
                    // Create CSV content for all sessions
                    var csvText = "Session ID,Start Time,Duration,Min (dB),Avg (dB),Max (dB),Leq (dB),Weighting,Category\n"

                    let formatter = ISO8601DateFormatter()

                    for sessionData in sessionsData {
                        let startTimeStr = formatter.string(from: sessionData.startTime)
                        let leqStr = sessionData.leq.map { String(format: "%.1f", $0) } ?? "N/A"

                        csvText += "\(sessionData.id.uuidString),"
                        csvText += "\(startTimeStr),"
                        csvText += "\(sessionData.formattedDuration),"
                        csvText += "\(String(format: "%.1f", sessionData.minLevel)),"
                        csvText += "\(String(format: "%.1f", sessionData.avgLevel)),"
                        csvText += "\(String(format: "%.1f", sessionData.maxLevel)),"
                        csvText += "\(leqStr),"
                        csvText += "\(sessionData.weighting.shortName),"
                        csvText += "\(sessionData.categoryName)\n"
                    }

                    // Create temporary file
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
                    let dateStr = dateFormatter.string(from: Date())
                    let fileName = "sound_measurements_export_\(dateStr).csv"
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

                    try csvText.write(to: tempURL, atomically: true, encoding: .utf8)
                    return tempURL
                }.value

                // Show share sheet on main thread
                await MainActor.run {
                    shareItems = [csvURL]
                    showShareSheet = true
                }
            } catch {
                print("Error exporting all data: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Clear All Data

    private func clearAllData() {
        historyManager.deleteAllSessions()
    }
}

// MARK: - How It Works View

struct HowItWorksView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                infoSection(
                    icon: "waveform",
                    title: LocalizedString.HowItWorks.soundMeasurementTitle,
                    description: LocalizedString.HowItWorks.soundMeasurementDescription
                )

                infoSection(
                    icon: "ear",
                    title: LocalizedString.HowItWorks.aWeightingTitle,
                    description: LocalizedString.HowItWorks.aWeightingDescription
                )

                infoSection(
                    icon: "shield.checkered",
                    title: LocalizedString.HowItWorks.safetyLevelsTitle,
                    description: LocalizedString.HowItWorks.safetyLevelsDescription
                )

                infoSection(
                    icon: "tuningfork",
                    title: LocalizedString.HowItWorks.calibrationTitle,
                    description: LocalizedString.HowItWorks.calibrationDescription
                )

                Text(LocalizedString.HowItWorks.note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 16)
            }
            .padding()
        }
        .navigationTitle(LocalizedString.HowItWorks.title)
    }

    private func infoSection(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
