//
//  MiniGraph.swift
//  Sound Level Meter
//
//  Мини-график уровня звука в реальном времени
//

import SwiftUI

struct MiniGraph: View {
    let readings: [Double]
    var minValue: Double = 20
    var maxValue: Double = 120
    var height: CGFloat = 60
    var showGradient: Bool = true

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background with threshold lines
                thresholdLines(in: geometry)

                // Graph line
                if readings.count > 1 {
                    graphPath(in: geometry)
                }
            }
        }
        .frame(height: height)
    }

    // MARK: - Graph Path

    private func graphPath(in geometry: GeometryProxy) -> some View {
        let width = geometry.size.width
        let height = geometry.size.height

        return ZStack {
            // Fill
            if showGradient {
                Path { path in
                    let points = normalizedPoints(width: width, height: height)
                    guard let first = points.first else { return }

                    path.move(to: CGPoint(x: first.x, y: height))
                    path.addLine(to: first)

                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }

                    if let last = points.last {
                        path.addLine(to: CGPoint(x: last.x, y: height))
                    }

                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [Color.accentColor.opacity(0.3), Color.accentColor.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }

            // Line
            Path { path in
                let points = normalizedPoints(width: width, height: height)
                guard let first = points.first else { return }

                path.move(to: first)

                for point in points.dropFirst() {
                    path.addLine(to: point)
                }
            }
            .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }
    }

    private func normalizedPoints(width: CGFloat, height: CGFloat) -> [CGPoint] {
        guard !readings.isEmpty else { return [] }

        let step = width / CGFloat(max(readings.count - 1, 1))

        return readings.enumerated().map { index, value in
            let normalizedValue = (value - minValue) / (maxValue - minValue)
            let clampedValue = max(0, min(1, normalizedValue))
            let y = height - (CGFloat(clampedValue) * height)
            let x = CGFloat(index) * step

            return CGPoint(x: x, y: y)
        }
    }

    // MARK: - Threshold Lines

    private func thresholdLines(in geometry: GeometryProxy) -> some View {
        let height = geometry.size.height

        return ZStack {
            // Safe threshold (70 dB)
            thresholdLine(at: 70, height: height, color: .safeGreen.opacity(0.3))

            // Warning threshold (85 dB)
            thresholdLine(at: 85, height: height, color: .warningOrange.opacity(0.3))
        }
    }

    private func thresholdLine(at dB: Double, height: CGFloat, color: Color) -> some View {
        let normalizedY = (dB - minValue) / (maxValue - minValue)
        let y = height - (CGFloat(normalizedY) * height)

        return Path { path in
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: 1000, y: y))
        }
        .stroke(color, style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
    }
}

// MARK: - Live Graph (Extended version)

struct LiveGraph: View {
    let readings: [Double]
    var minValue: Double = 20
    var maxValue: Double = 120
    var showLabels: Bool = true
    var showStats: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            // Y-axis labels and graph
            HStack(alignment: .top, spacing: 8) {
                if showLabels {
                    yAxisLabels
                }

                MiniGraph(
                    readings: readings,
                    minValue: minValue,
                    maxValue: maxValue,
                    height: 150,
                    showGradient: true
                )
            }

            // Statistics
            if showStats, !readings.isEmpty {
                statisticsView
            }
        }
    }

    private var yAxisLabels: some View {
        VStack {
            Text("\(Int(maxValue))")
            Spacer()
            Text("\(Int((maxValue + minValue) / 2))")
            Spacer()
            Text("\(Int(minValue))")
        }
        .font(.caption2)
        .foregroundStyle(.tertiary)
        .frame(width: 30, height: 150)
    }

    private var statisticsView: some View {
        HStack(spacing: 20) {
            StatValue(label: "MIN", value: readings.min() ?? 0)
            StatValue(label: "AVG", value: readings.reduce(0, +) / Double(max(readings.count, 1)))
            StatValue(label: "MAX", value: readings.max() ?? 0)
        }
        .padding(.top, 8)
    }
}

struct StatValue: View {
    let label: String
    let value: Double

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text(value.formattedDecibel)
                .font(.headline)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        MiniGraph(readings: [45, 50, 48, 65, 70, 68, 72, 75, 70, 65])
            .frame(height: 60)
            .padding(.horizontal)

        LiveGraph(
            readings: [45, 50, 48, 65, 70, 68, 72, 75, 70, 65, 60, 55, 58, 62, 68],
            showLabels: true,
            showStats: true
        )
        .padding()
    }
}
