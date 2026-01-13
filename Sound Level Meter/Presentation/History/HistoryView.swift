//
//  HistoryView.swift
//  Sound Level Meter
//
//  Экран истории измерений
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var storeManager: StoreManager
    @StateObject private var historyManager = HistoryManager.shared
    @State private var showPaywall = false
    @State private var showExportError = false
    @State private var exportErrorMessage = ""
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []

    private var isPro: Bool {
        storeManager.isPro
    }

    private var sessions: [MeasurementSession] {
        historyManager.sessions
    }

    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    emptyState
                } else {
                    sessionsList
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(LocalizedString.Common.done) {
                        dismiss()
                    }
                }

                if !sessions.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button {
                                if isPro {
                                    exportAll()
                                } else {
                                    showPaywall = true
                                }
                            } label: {
                                Label(LocalizedString.History.exportAll, systemImage: "square.and.arrow.up")
                            }

                            Button(role: .destructive) {
                                historyManager.deleteAllSessions()
                            } label: {
                                Label(LocalizedString.History.deleteAll, systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .environmentObject(storeManager)
            }
            .alert(LocalizedString.History.exportError, isPresented: $showExportError) {
                Button("OK") { }
            } message: {
                Text(exportErrorMessage)
            }
            .sheet(isPresented: $showShareSheet) {
                ActivityViewController(activityItems: shareItems)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 60))
                .foregroundStyle(.tertiary)

            Text(LocalizedString.History.emptyTitle)
                .font(.title3)
                .fontWeight(.semibold)

            Text(LocalizedString.History.startRecording)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - Sessions List

    private var sessionsList: some View {
        List {
            ForEach(groupedSessions.keys.sorted().reversed(), id: \.self) { date in
                Section {
                    ForEach(groupedSessions[date] ?? []) { session in
                        NavigationLink {
                            HistoryDetailView(session: session)
                        } label: {
                            SessionRow(session: session)
                        }
                    }
                    .onDelete { indexSet in
                        deleteSessions(at: indexSet, for: date)
                    }
                } header: {
                    Text(formatSectionDate(date))
                }
            }

            // Export button
            Section {
                Button {
                    if isPro {
                        exportAll()
                    } else {
                        showPaywall = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text(LocalizedString.History.exportAllPro)

                        Spacer()

                        if !isPro {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private var groupedSessions: [Date: [MeasurementSession]] {
        Dictionary(grouping: sessions) { session in
            Calendar.current.startOfDay(for: session.startTime)
        }
    }

    private func formatSectionDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return LocalizedString.History.today
        } else if Calendar.current.isDateInYesterday(date) {
            return LocalizedString.History.yesterday
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }

    private func deleteSessions(at indexSet: IndexSet, for date: Date) {
        guard let sessionsForDate = groupedSessions[date] else { return }
        let sessionsToDelete = indexSet.map { sessionsForDate[$0] }
        sessionsToDelete.forEach { historyManager.deleteSession($0) }
    }

    private func exportAll() {
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
                print("Error exporting all sessions: \(error.localizedDescription)")
                exportErrorMessage = LocalizedString.History.exportAllError
                showExportError = true
            }
        }
    }
}

// MARK: - Session Row

struct SessionRow: View {
    let session: MeasurementSession

    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            Text(session.category.icon)
                .font(.title2)
                .frame(width: 40)

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(session.name ?? session.category.localizedName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 12) {
                    Label("\(session.avgLevel.formattedDecibel) dB", systemImage: "waveform")
                    Label(session.formattedDuration, systemImage: "timer")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            // Max level indicator
            VStack(alignment: .trailing, spacing: 2) {
                Text(session.maxLevel.formattedDecibel)
                    .font(.headline)
                    .foregroundStyle(Color.forDecibelLevel(session.maxLevel))

                Text("max")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - History Detail View

struct HistoryDetailView: View {
    let session: MeasurementSession
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var storeManager: StoreManager
    @StateObject private var historyManager = HistoryManager.shared
    @State private var showPaywall = false
    @State private var showDeleteConfirmation = false
    @State private var showExportError = false
    @State private var exportErrorMessage = ""
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []

    private var isPro: Bool {
        storeManager.isPro
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection

                // Graph
                if !session.readings.isEmpty {
                    graphSection
                }

                // Statistics
                statisticsSection

                // Details
                detailsSection

                // Actions
                actionsSection
            }
            .padding()
        }
        .navigationTitle(session.name ?? "Measurement")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .environmentObject(storeManager)
        }
        .alert(LocalizedString.History.delete, isPresented: $showDeleteConfirmation) {
            Button(LocalizedString.Common.cancel, role: .cancel) { }
            Button(LocalizedString.Common.delete, role: .destructive) {
                deleteSession()
            }
        } message: {
            Text(LocalizedString.History.deleteConfirmation)
        }
        .alert(LocalizedString.History.exportError, isPresented: $showExportError) {
            Button("OK") { }
        } message: {
            Text(exportErrorMessage)
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityViewController(activityItems: shareItems)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(session.category.icon)
                .font(.system(size: 60))

            Text(session.category.localizedName)
                .font(.title2)
                .fontWeight(.semibold)

            Text(formatDate(session.startTime))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var graphSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedString.History.recording)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            LiveGraph(readings: session.readings, showLabels: true, showStats: false)
                .frame(height: 180)
                .padding()
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var statisticsSection: some View {
        StatisticsCard(
            minLevel: session.minLevel,
            avgLevel: session.avgLevel,
            maxLevel: session.maxLevel
        )
    }

    private var detailsSection: some View {
        VStack(spacing: 12) {
            detailRow(label: "Duration", value: session.formattedDuration)
            detailRow(label: "Weighting", value: session.weighting.shortName)

            if let leq = session.leq {
                HStack {
                    Text(LocalizedString.Stats.leq)
                    Spacer()
                    HStack(spacing: 4) {
                        Text(String(format: "%.1f dB", leq))
                        if !isPro {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                        }
                    }
                    .foregroundStyle(isPro ? .primary : .secondary)
                }
                .onTapGesture {
                    if !isPro { showPaywall = true }
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                shareSession()
            } label: {
                Label(LocalizedString.History.share, systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button {
                if isPro {
                    exportCSV()
                } else {
                    showPaywall = true
                }
            } label: {
                HStack {
                    Label(LocalizedString.History.exportCSV, systemImage: "doc.text")
                    if !isPro {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label(LocalizedString.History.delete, systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func shareSession() {
        let text = """
        Sound Measurement
        \(session.category.localizedName)
        Avg: \(session.avgLevel.formattedDecibel) dB
        Max: \(session.maxLevel.formattedDecibel) dB
        Duration: \(session.formattedDuration)
        """

        shareItems = [text]
        showShareSheet = true
    }

    private func exportCSV() {
        Task {
            do {
                // Capture session data on main thread
                let sessionName = session.name ?? session.category.localizedName
                let startTime = session.startTime
                let formattedDuration = session.formattedDuration
                let minLevel = session.minLevel
                let avgLevel = session.avgLevel
                let maxLevel = session.maxLevel
                let leq = session.leq
                let readings = session.readings
                let weighting = session.weighting
                let sessionId = session.id

                let startTimeFormatted = formatDate(startTime)

                // Generate CSV on background thread
                let csvURL = try await Task.detached {
                    // Create CSV content
                    var csvText = ""

                    // Add header information as comments
                    csvText += "# Sound Measurement Export\n"
                    csvText += "# Measurement: \(sessionName)\n"
                    csvText += "# Start Time: \(startTimeFormatted)\n"
                    csvText += "# Duration: \(formattedDuration)\n"
                    csvText += "# Statistics:\n"
                    csvText += "# - Min: \(String(format: "%.1f", minLevel)) dB\n"
                    csvText += "# - Avg: \(String(format: "%.1f", avgLevel)) dB\n"
                    csvText += "# - Max: \(String(format: "%.1f", maxLevel)) dB\n"
                    if let leqValue = leq {
                        csvText += "# - Leq: \(String(format: "%.1f", leqValue)) dB\n"
                    }
                    csvText += "#\n"
                    csvText += "Timestamp,Decibel Level (dB),Weighting\n"

                    // Add readings (1 reading per second)
                    let formatter = ISO8601DateFormatter()
                    for (index, reading) in readings.enumerated() {
                        let timestamp = startTime.addingTimeInterval(Double(index))
                        let timestampStr = formatter.string(from: timestamp)
                        csvText += "\(timestampStr),\(String(format: "%.1f", reading)),\(weighting.shortName)\n"
                    }

                    // Create temporary file
                    let fileName = "sound_measurement_\(sessionId.uuidString).csv"
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
                print("Error exporting CSV: \(error.localizedDescription)")
                exportErrorMessage = LocalizedString.History.exportCSVError
                showExportError = true
            }
        }
    }

    private func deleteSession() {
        historyManager.deleteSession(session)
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    HistoryView()
}
