//
//  CalibrationView.swift
//  Sound Level Meter
//
//  Экран калибровки микрофона (Pro)
//

import SwiftUI

struct CalibrationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settingsManager: SettingsManager
    @StateObject private var audioEngine = AudioEngine()

    @State private var offset: Double = 0
    @State private var showDebugInfo = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Debug info toggle
                    debugToggle

                    // Current readings
                    if showDebugInfo {
                        currentReadingsCard
                    }

                    // Instructions
                    instructionsSection

                    // Current offset display
                    offsetDisplay

                    // Adjustment controls
                    adjustmentControls

                    // Buttons
                    actionButtons
                }
                .padding()
            }
            .navigationTitle(LocalizedString.Calibration.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(LocalizedString.Common.cancel) {
                        dismiss()
                    }
                }
            }
            .onAppear {
                offset = settingsManager.calibrationOffset
                Task {
                    await audioEngine.checkPermission()
                    audioEngine.start()
                }
            }
            .onDisappear {
                audioEngine.stop()
            }
        }
    }

    // MARK: - Debug Toggle

    private var debugToggle: some View {
        Button {
            showDebugInfo.toggle()
        } label: {
            HStack {
                Image(systemName: showDebugInfo ? "eye.fill" : "eye.slash.fill")
                Text(showDebugInfo ? LocalizedString.Calibration.hideDebug : LocalizedString.Calibration.showDebug)
                    .font(.subheadline)
                Spacer()
            }
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - Current Readings Card

    private var currentReadingsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(LocalizedString.Calibration.currentReadings, systemImage: "waveform.circle.fill")
                .font(.headline)

            Divider()

            VStack(spacing: 8) {
                readingRow(label: "Raw RMS", value: String(format: "%.6f", audioEngine.currentRMS))
                readingRow(label: "Current dB", value: String(format: "%.1f dB", audioEngine.currentLevel))
                readingRow(label: "With Offset", value: String(format: "%.1f dB", audioEngine.currentLevel + offset))
            }

            Divider()

            Text(LocalizedString.Calibration.formula)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fontWeight(.medium)

            Text(LocalizedString.Calibration.example)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.accentColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func readingRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.medium)
        }
    }

    // MARK: - Instructions

    private var instructionsSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "tuningfork")
                .font(.system(size: 50))
                .foregroundStyle(Color.accentColor)

            Text(LocalizedString.Calibration.instructionsTitle)
                .font(.headline)
                .multilineTextAlignment(.center)

            Text(LocalizedString.Calibration.instructionsDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Offset Display

    private var offsetDisplay: some View {
        VStack(spacing: 8) {
            Text(LocalizedString.Calibration.offset)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(String(format: "%+.1f dB", offset))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(offset == 0 ? .primary : Color.accentColor)
        }
    }

    // MARK: - Adjustment Controls

    private var adjustmentControls: some View {
        VStack(spacing: 16) {
            // Fine adjustment
            HStack(spacing: 24) {
                Button {
                    offset = max(-20, offset - 0.5)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.secondary)
                }

                Button {
                    offset = min(20, offset + 0.5)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.secondary)
                }
            }

            // Slider for coarse adjustment
            Slider(value: $offset, in: -20...20, step: 0.5)
                .padding(.horizontal)

            // Quick adjust buttons
            HStack(spacing: 12) {
                quickAdjustButton(value: -5)
                quickAdjustButton(value: -1)
                quickAdjustButton(value: 0)
                quickAdjustButton(value: +1)
                quickAdjustButton(value: +5)
            }
        }
    }

    private func quickAdjustButton(value: Double) -> some View {
        Button {
            if value == 0 {
                offset = 0
            } else {
                offset = max(-20, min(20, offset + value))
            }
        } label: {
            Text(value == 0 ? "0" : String(format: "%+.0f", value))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(value == 0 ? Color.accentColor : .primary)
                .frame(width: 50, height: 36)
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                settingsManager.calibrationOffset = offset
                dismiss()
            } label: {
                Text(LocalizedString.Calibration.save)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button {
                offset = 0
            } label: {
                Text(LocalizedString.Calibration.reset)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CalibrationView()
}
