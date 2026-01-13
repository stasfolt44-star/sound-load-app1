//
//  DecibelDisplay.swift
//  Sound Level Meter
//
//  Главный компонент отображения уровня децибел
//

import SwiftUI

struct DecibelDisplay: View {
    let level: Double
    let weighting: Weighting
    var showDetails: Bool = false
    var onTap: (() -> Void)? = nil

    private var category: SoundCategory {
        SoundCategory.category(for: level)
    }

    private var safetyLevel: SafetyLevel {
        SafetyLevel.forLevel(level)
    }

    private var displayColor: Color {
        Color.forDecibelLevel(level)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Main dB value
            decibelValue

            // Color indicator
            colorIndicator

            // Category description
            categoryDescription

            // Safety status
            safetyStatus
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
    }

    // MARK: - Subviews

    private var decibelValue: some View {
        VStack(spacing: 4) {
            Text(level.formattedDecibel)
                .font(.system(size: 96, weight: .bold, design: .rounded))
                .foregroundStyle(displayColor)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.1), value: level.formattedDecibel)

            Text(weighting.shortName)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
    }

    private var colorIndicator: some View {
        Circle()
            .fill(displayColor)
            .frame(width: 24, height: 24)
            .shadow(color: displayColor.opacity(0.5), radius: 8)
            .animation(.easeInOut(duration: 0.3), value: safetyLevel)
    }

    private var categoryDescription: some View {
        HStack(spacing: 8) {
            Text(category.icon)
                .font(.title2)

            Text(category.localizedName)
                .font(.title3)
                .fontWeight(.medium)
        }
        .foregroundStyle(.primary)
    }

    private var safetyStatus: some View {
        HStack(spacing: 6) {
            Image(systemName: safetyLevel.icon)
                .font(.subheadline)

            Text(SoundCategory.safetyMessage(for: level))
                .font(.subheadline)
        }
        .foregroundStyle(displayColor)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(displayColor.opacity(0.15))
        .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        DecibelDisplay(level: 45, weighting: .A)
        DecibelDisplay(level: 75, weighting: .A)
        DecibelDisplay(level: 95, weighting: .A)
    }
    .padding()
}
