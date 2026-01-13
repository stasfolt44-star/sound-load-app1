//
//  MainViewModel.swift
//  Sound Level Meter
//
//  ViewModel для главного экрана
//

import SwiftUI
import Combine

@MainActor
final class MainViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var isRecording: Bool = false
    @Published var showExtendedPanel: Bool = false
    @Published var showSettings: Bool = false
    @Published var showHistory: Bool = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var showSwipeHint: Bool = true

    // MARK: - Dependencies

    let audioEngine: AudioEngine
    let settingsManager: SettingsManager

    // MARK: - Private Properties

    private var recordingTimer: Timer?
    private var currentSession: MeasurementSession?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties

    var currentLevel: Double {
        audioEngine.currentLevel
    }

    var minLevel: Double {
        audioEngine.minLevel
    }

    var avgLevel: Double {
        audioEngine.avgLevel
    }

    var maxLevel: Double {
        audioEngine.maxLevel
    }

    var peakLevel: Double {
        audioEngine.peakLevel
    }

    var weighting: Weighting {
        settingsManager.weighting
    }

    var recentReadings: [Double] {
        audioEngine.getRecentReadings(seconds: Constants.UI.miniGraphSeconds)
    }

    var extendedReadings: [Double] {
        audioEngine.getRecentReadings(seconds: Constants.UI.extendedGraphSeconds)
    }

    var isRunning: Bool {
        audioEngine.isRunning
    }

    var permissionGranted: Bool {
        audioEngine.permissionGranted
    }

    var currentComparison: SoundComparison? {
        // Показываем сравнение только после завершения записи
        // на основе максимального уровня
        guard !isRecording, maxLevel > 0, maxLevel != Double.infinity else {
            return nil
        }
        return SoundComparison.forLevel(maxLevel)
    }

    var formattedDuration: String {
        let totalSeconds = Int(recordingDuration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    var category: SoundCategory {
        SoundCategory.category(for: currentLevel)
    }

    var safetyLevel: SafetyLevel {
        SafetyLevel.forLevel(currentLevel)
    }

    // MARK: - Initialization

    init() {
        self.audioEngine = AudioEngine()
        self.settingsManager = SettingsManager.shared

        setupBindings()
        checkFirstLaunch()
    }

    private func setupBindings() {
        // Apply settings to audio engine
        audioEngine.setWeighting(settingsManager.weighting)
        audioEngine.setCalibration(settingsManager.calibrationOffset)

        // Listen to settings changes
        settingsManager.$settings
            .sink { [weak self] settings in
                self?.audioEngine.setWeighting(settings.weighting)
                self?.audioEngine.setCalibration(settings.calibrationOffset)
            }
            .store(in: &cancellables)
    }

    private func checkFirstLaunch() {
        // Hide swipe hint after first use
        if UserDefaults.standard.bool(forKey: "hasSeenSwipeHint") {
            showSwipeHint = false
        }
    }

    // MARK: - Actions

    func startMeasurement() {
        audioEngine.start()
    }

    func stopMeasurement() {
        audioEngine.stop()
        stopRecording()
    }

    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    func startRecording() {
        if !audioEngine.isRunning {
            startMeasurement()
        }

        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isRecording = true
        }
        recordingDuration = 0
        audioEngine.resetStatistics()

        // Start session
        currentSession = MeasurementSession(
            weighting: settingsManager.weighting,
            calibrationOffset: settingsManager.calibrationOffset
        )

        // Start timer (записываем каждую секунду)
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                self.recordingDuration += 1

                // Добавляем текущий уровень в сессию
                self.currentSession?.addReading(self.audioEngine.currentLevel)
            }
        }
    }

    func stopRecording() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isRecording = false
        }
        recordingTimer?.invalidate()
        recordingTimer = nil

        // Finalize session and save
        if var session = currentSession {
            session.finish()
            HistoryManager.shared.saveSession(session)
            currentSession = nil
        }
    }

    func resetPeak() {
        audioEngine.resetPeak()
    }

    func resetStatistics() {
        audioEngine.resetStatistics()
        recordingDuration = 0
    }

    func requestPermission() async {
        _ = await audioEngine.requestPermission()
    }

    func hideSwipeHint() {
        showSwipeHint = false
        UserDefaults.standard.set(true, forKey: "hasSeenSwipeHint")
    }

    func toggleExtendedPanel() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showExtendedPanel.toggle()
        }

        if showExtendedPanel {
            hideSwipeHint()
        }
    }

    // MARK: - Screen State

    func onAppear() {
        startMeasurement()

        // Keep screen on if enabled
        if settingsManager.keepScreenOn {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }

    func onDisappear() {
        // Allow screen to sleep
        UIApplication.shared.isIdleTimerDisabled = false
    }
}
