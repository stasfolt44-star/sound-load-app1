//
//  LevelIndicator.swift
//  Sound Level Meter
//
//  Круговой индикатор уровня звука
//

import SwiftUI

struct LevelIndicator: View {
    let level: Double
    var maxLevel: Double = 120
    var lineWidth: CGFloat = 12
    var showLabels: Bool = true

    private var progress: Double {
        min(level / maxLevel, 1.0)
    }

    private var displayColor: Color {
        Color.forDecibelLevel(level)
    }

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(
                    Color.gray.opacity(0.2),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )

            // Progress arc
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    displayColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.15), value: progress)

            // Center content
            VStack(spacing: 4) {
                Text(level.formattedDecibel)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(displayColor)
                    .contentTransition(.numericText())

                Text("dB")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            // Level markers (optional)
            if showLabels {
                levelMarkers
            }
        }
    }

    private var levelMarkers: some View {
        ZStack {
            ForEach([30, 60, 90, 120], id: \.self) { value in
                let angle = Double(value) / maxLevel * 360 - 90

                VStack {
                    Text("\(value)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .offset(y: -85)
                .rotationEffect(.degrees(angle))
            }
        }
    }
}

// MARK: - Linear Level Indicator

struct LinearLevelIndicator: View {
    let level: Double
    var maxLevel: Double = 120
    var height: CGFloat = 8

    private var progress: Double {
        min(level / maxLevel, 1.0)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: height)

                // Progress
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(levelGradient)
                    .frame(width: geometry.size.width * progress, height: height)
                    .animation(.easeOut(duration: 0.1), value: progress)
            }
        }
        .frame(height: height)
    }

    private var levelGradient: LinearGradient {
        LinearGradient(
            colors: [.safeGreen, .cautionYellow, .warningOrange, .dangerRed],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        LevelIndicator(level: 65)
            .frame(width: 200, height: 200)

        LinearLevelIndicator(level: 75)
            .frame(width: 300)
    }
    .padding()
}
