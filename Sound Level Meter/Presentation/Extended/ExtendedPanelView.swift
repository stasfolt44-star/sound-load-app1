//
//  ExtendedPanelView.swift
//  Sound Level Meter
//
//  Расширенная панель с графиком и статистикой (Level 2)
//

import SwiftUI

struct ExtendedPanelView: View {
    let currentLevel: Double
    let minLevel: Double
    let avgLevel: Double
    let maxLevel: Double
    let readings: [Double]
    let duration: String
    let isRecording: Bool

    var onStop: () -> Void
    var onClose: () -> Void

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            handleBar

            // Content
            VStack(spacing: 20) {
                // Current level header
                headerSection

                // Sound comparison (показываем только после записи, на основе максимума)
                if !isRecording, maxLevel > 0, maxLevel != Double.infinity,
                   let comparison = SoundComparison.forLevel(maxLevel) {
                    SoundComparisonCard(comparison: comparison)
                        .transition(.scale.combined(with: .opacity))
                }

                // Graph
                graphSection

                // Statistics
                statisticsSection

                // Duration and controls
                controlsSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
        }
        .background(Color.panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 20, y: -5)
        .offset(y: max(0, dragOffset))
        .gesture(dragGesture)
    }

    // MARK: - Handle Bar

    private var handleBar: some View {
        VStack(spacing: 12) {
            Capsule()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 12)

            HStack {
                Text(LocalizedString.Extended.details)
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Button {
                    onClose()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(currentLevel.formattedDecibel)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.forDecibelLevel(currentLevel))

                Text("dB")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Safety indicator
            VStack(alignment: .trailing, spacing: 4) {
                Circle()
                    .fill(Color.forDecibelLevel(currentLevel))
                    .frame(width: 20, height: 20)

                Text(SafetyLevel.forLevel(currentLevel).rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Graph Section

    private var graphSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedString.Extended.levelOverTime)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            LiveGraph(
                readings: readings,
                showLabels: true,
                showStats: false
            )
            .frame(height: 180)
            .padding()
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Statistics Section

    private var statisticsSection: some View {
        StatisticsCard(
            minLevel: minLevel,
            avgLevel: avgLevel,
            maxLevel: maxLevel
        )
    }

    // MARK: - Controls Section

    private var controlsSection: some View {
        HStack {
            // Duration
            HStack(spacing: 8) {
                Image(systemName: "timer")
                    .foregroundStyle(.secondary)

                Text(LocalizedString.Extended.duration)
                    .foregroundStyle(.secondary)

                Text(duration)
                    .fontWeight(.semibold)
                    .monospacedDigit()
            }
            .font(.subheadline)

            Spacer()

            // Stop button (if recording)
            if isRecording {
                StopButton {
                    onStop()
                }
            }
        }
    }

    // MARK: - Drag Gesture

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation.height
            }
            .onEnded { value in
                if value.translation.height > 100 {
                    onClose()
                }
                dragOffset = 0
            }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.gray.opacity(0.3)
            .ignoresSafeArea()

        VStack {
            Spacer()

            ExtendedPanelView(
                currentLevel: 73,
                minLevel: 45,
                avgLevel: 68,
                maxLevel: 89,
                readings: [45, 50, 55, 60, 65, 70, 75, 80, 75, 70, 65, 60, 68, 72, 73],
                duration: "00:05:32",
                isRecording: true,
                onStop: { },
                onClose: { }
            )
        }
    }
}
