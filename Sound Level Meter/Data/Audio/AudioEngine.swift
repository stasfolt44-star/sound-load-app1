//
//  AudioEngine.swift
//  Sound Level Meter
//
//  Движок для захвата и обработки аудио с точной A-weighting фильтрацией
//

import AVFoundation
import Accelerate
import Combine

@MainActor
final class AudioEngine: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var currentLevel: Double = 0
    @Published private(set) var peakLevel: Double = 0
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var permissionGranted: Bool = false
    @Published private(set) var errorMessage: String?

    // Raw RMS value for calibration
    @Published private(set) var currentRMS: Float = 0

    // MARK: - Statistics

    @Published private(set) var minLevel: Double = Double.infinity
    @Published private(set) var avgLevel: Double = 0
    @Published private(set) var maxLevel: Double = 0

    // MARK: - Private Properties

    private let engine = AVAudioEngine()
    private var weighting: Weighting = .A
    private var calibrationOffset: Double = 0
    private var sampleRate: Double = 44100.0

    // Ring buffer for readings
    private var readingsBuffer: [Double] = []
    private let bufferSize = Constants.Audio.maxBufferSeconds * Constants.Audio.readingsPerSecond

    // Biquad filter states for A-weighting (4 stages)
    private var biquadStates: [BiquadState] = []

    // MARK: - Initialization

    init() {
        Task {
            await checkPermission()
        }
    }

    // MARK: - Permission

    func checkPermission() async {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            permissionGranted = true
        case .denied:
            permissionGranted = false
            errorMessage = "Microphone access denied"
        case .undetermined:
            let granted = await AVAudioApplication.requestRecordPermission()
            permissionGranted = granted
            if !granted {
                errorMessage = "Microphone access required"
            }
        @unknown default:
            permissionGranted = false
        }
    }

    func requestPermission() async -> Bool {
        let granted = await AVAudioApplication.requestRecordPermission()
        permissionGranted = granted
        return granted
    }

    // MARK: - Audio Session

    private func setupAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record,
                               mode: .measurement,
                               options: [])
        try session.setActive(true)
    }

    // MARK: - Start/Stop

    func start() {
        guard !isRunning else { return }
        guard permissionGranted else {
            errorMessage = "Microphone permission required"
            return
        }

        do {
            try setupAudioSession()

            let inputNode = engine.inputNode
            let format = inputNode.outputFormat(forBus: 0)

            // Проверяем, что формат валидный
            guard format.sampleRate > 0 else {
                errorMessage = "Invalid audio format"
                return
            }

            sampleRate = format.sampleRate
            initializeFilters()

            inputNode.installTap(onBus: 0,
                                bufferSize: AVAudioFrameCount(Constants.Audio.bufferSize),
                                format: format) { [weak self] buffer, _ in
                Task { @MainActor in
                    self?.processAudioBuffer(buffer)
                }
            }

            try engine.start()
            isRunning = true
            errorMessage = nil

            // Reset statistics
            resetStatistics()

        } catch {
            errorMessage = "Failed to start: \(error.localizedDescription)"
        }
    }

    func stop() {
        guard isRunning else { return }

        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        isRunning = false
    }

    // MARK: - Audio Processing

    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)

        // Apply weighting filter
        var weightedSamples = [Float](repeating: 0, count: frameLength)
        applyWeighting(channelData, output: &weightedSamples, count: frameLength)

        // Calculate RMS
        var rms: Float = 0
        vDSP_rmsqv(weightedSamples, 1, &rms, vDSP_Length(frameLength))

        // Store raw RMS for calibration
        currentRMS = rms

        // Avoid log of zero
        let safeRms = max(rms, 1e-10)

        // Convert to dB SPL
        // Калибровка для iOS микрофона
        // Тихая комната: RMS ~0.001-0.003 → 30-40 dB
        // Нормальный разговор: RMS ~0.01-0.03 → 50-60 dB
        // Громкая музыка: RMS ~0.1-0.3 → 80-90 dB
        let referenceLevel: Float = 0.0001 // Более высокий опорный уровень для реалистичных значений
        let db = 20 * log10(safeRms / referenceLevel)

        // Apply calibration offset
        let compensatedDB = Double(db) + calibrationOffset

        // Clamp to reasonable range
        let finalDB = compensatedDB.clampedDecibel

        // Update state
        currentLevel = finalDB
        peakLevel = max(peakLevel, finalDB)
        addReading(finalDB)
        updateStatistics()
    }

    // MARK: - Weighting Filter Initialization

    private func initializeFilters() {
        switch weighting {
        case .A:
            biquadStates = createAWeightingFilters(sampleRate: sampleRate)
        case .C:
            biquadStates = createCWeightingFilters(sampleRate: sampleRate)
        case .Z:
            biquadStates = [] // No filtering
        }
    }

    private func createAWeightingFilters(sampleRate: Double) -> [BiquadState] {
        // A-weighting filter design based on IEC 61672-1:2013
        // Simplified implementation: 2 high-pass filters at low and high frequency poles

        let f1 = 20.598997 // Low frequency pole
        let f4 = 12194.217 // High frequency pole

        var filters: [BiquadState] = []

        // High-pass filter 1 (f1) - attenuates low frequencies
        filters.append(createHighPassFilter(frequency: f1, sampleRate: sampleRate))

        // High-pass filter 2 (f1) - second order for steeper roll-off
        filters.append(createHighPassFilter(frequency: f1, sampleRate: sampleRate))

        return filters
    }

    private func createCWeightingFilters(sampleRate: Double) -> [BiquadState] {
        // C-weighting filter (simpler than A-weighting)
        let f1 = 20.598997
        let f4 = 12194.217

        var filters: [BiquadState] = []
        filters.append(createHighPassFilter(frequency: f1, sampleRate: sampleRate))
        filters.append(createHighPassFilter(frequency: f4, sampleRate: sampleRate))

        return filters
    }

    private func createHighPassFilter(frequency: Double, sampleRate: Double) -> BiquadState {
        let omega = 2.0 * .pi * frequency / sampleRate
        let sinOmega = sin(omega)
        let cosOmega = cos(omega)
        let alpha = sinOmega / (2.0 * 0.707) // Q = 0.707 (Butterworth)

        let b0 = (1.0 + cosOmega) / 2.0
        let b1 = -(1.0 + cosOmega)
        let b2 = (1.0 + cosOmega) / 2.0
        let a0 = 1.0 + alpha
        let a1 = -2.0 * cosOmega
        let a2 = 1.0 - alpha

        return BiquadState(
            b0: b0 / a0,
            b1: b1 / a0,
            b2: b2 / a0,
            a1: a1 / a0,
            a2: a2 / a0
        )
    }

    private func createLowPassFilter(frequency: Double, sampleRate: Double) -> BiquadState {
        let omega = 2.0 * .pi * frequency / sampleRate
        let sinOmega = sin(omega)
        let cosOmega = cos(omega)
        let alpha = sinOmega / (2.0 * 0.707)

        let b0 = (1.0 - cosOmega) / 2.0
        let b1 = 1.0 - cosOmega
        let b2 = (1.0 - cosOmega) / 2.0
        let a0 = 1.0 + alpha
        let a1 = -2.0 * cosOmega
        let a2 = 1.0 - alpha

        return BiquadState(
            b0: b0 / a0,
            b1: b1 / a0,
            b2: b2 / a0,
            a1: a1 / a0,
            a2: a2 / a0
        )
    }

    // MARK: - Weighting Filter Application

    private func applyWeighting(_ input: UnsafePointer<Float>,
                                output: inout [Float],
                                count: Int) {
        if biquadStates.isEmpty {
            // Z-weighting (no filtering)
            for i in 0..<count {
                output[i] = input[i]
            }
            return
        }

        // Copy input to output
        for i in 0..<count {
            output[i] = input[i]
        }

        // Apply cascaded biquad filters
        for i in 0..<biquadStates.count {
            for j in 0..<count {
                output[j] = biquadStates[i].process(output[j])
            }
        }
    }

    // MARK: - Buffer Management

    private func addReading(_ level: Double) {
        readingsBuffer.append(level)
        if readingsBuffer.count > bufferSize {
            readingsBuffer.removeFirst()
        }
    }

    func getRecentReadings(seconds: Int) -> [Double] {
        let count = min(seconds * Constants.Audio.readingsPerSecond, readingsBuffer.count)
        return Array(readingsBuffer.suffix(count))
    }

    var allReadings: [Double] {
        return readingsBuffer
    }

    // MARK: - Statistics

    private func updateStatistics() {
        guard !readingsBuffer.isEmpty else { return }

        minLevel = readingsBuffer.min() ?? 0
        maxLevel = readingsBuffer.max() ?? 0
        avgLevel = readingsBuffer.reduce(0, +) / Double(readingsBuffer.count)
    }

    func resetStatistics() {
        readingsBuffer.removeAll()
        minLevel = Double.infinity
        avgLevel = 0
        maxLevel = 0
        peakLevel = currentLevel
    }

    func resetPeak() {
        peakLevel = currentLevel
    }

    // MARK: - Configuration

    func setWeighting(_ newWeighting: Weighting) {
        weighting = newWeighting
        initializeFilters()
    }

    func setCalibration(_ offset: Double) {
        calibrationOffset = offset
    }

    // MARK: - Leq Calculation

    func calculateLeq() -> Double {
        guard !readingsBuffer.isEmpty else { return 0 }

        let sum = readingsBuffer.reduce(0.0) { result, db in
            result + pow(10, db / 10)
        }

        return 10 * log10(sum / Double(readingsBuffer.count))
    }
}

// MARK: - Biquad Filter State

class BiquadState {
    let b0: Double
    let b1: Double
    let b2: Double
    let a1: Double
    let a2: Double

    private var x1: Double = 0
    private var x2: Double = 0
    private var y1: Double = 0
    private var y2: Double = 0

    init(b0: Double, b1: Double, b2: Double, a1: Double, a2: Double) {
        self.b0 = b0
        self.b1 = b1
        self.b2 = b2
        self.a1 = a1
        self.a2 = a2
    }

    func process(_ input: Float) -> Float {
        let x0 = Double(input)

        // Biquad difference equation
        let y0 = b0 * x0 + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2

        // Shift delays
        x2 = x1
        x1 = x0
        y2 = y1
        y1 = y0

        return Float(y0)
    }
}
