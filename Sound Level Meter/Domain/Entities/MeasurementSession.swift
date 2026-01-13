//
//  MeasurementSession.swift
//  Sound Level Meter
//
//  Модель сессии измерения
//

import Foundation

struct MeasurementSession: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    var endTime: Date?
    var name: String?

    // Statistics
    var minLevel: Double
    var avgLevel: Double
    var maxLevel: Double
    var leq: Double?

    // Settings used
    let weighting: Weighting
    let calibrationOffset: Double

    // Raw data for graph
    var readings: [Double]
    let sampleRate: Double

    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }

    var formattedDuration: String {
        let totalSeconds = Int(duration)
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
        return SoundCategory.category(for: avgLevel)
    }

    init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        weighting: Weighting = .A,
        calibrationOffset: Double = 0.0,
        sampleRate: Double = 10.0
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = nil
        self.name = nil
        self.minLevel = Double.infinity
        self.avgLevel = 0
        self.maxLevel = 0
        self.leq = nil
        self.weighting = weighting
        self.calibrationOffset = calibrationOffset
        self.readings = []
        self.sampleRate = sampleRate
    }

    mutating func addReading(_ level: Double) {
        readings.append(level)

        // Update statistics
        if level < minLevel {
            minLevel = level
        }
        if level > maxLevel {
            maxLevel = level
        }

        // Recalculate average
        avgLevel = readings.reduce(0, +) / Double(readings.count)
    }

    mutating func finish() {
        endTime = Date()
        calculateLeq()
    }

    private mutating func calculateLeq() {
        guard !readings.isEmpty else {
            leq = 0
            return
        }

        let sum = readings.reduce(0.0) { result, db in
            result + pow(10, db / 10)
        }

        leq = 10 * log10(sum / Double(readings.count))
    }
}
