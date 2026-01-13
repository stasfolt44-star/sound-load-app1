//
//  StatisticsCard.swift
//  Sound Level Meter
//
//  Карточка статистики Min/Avg/Max
//

import SwiftUI

struct StatisticsCard: View {
    let minLevel: Double
    let avgLevel: Double
    let maxLevel: Double
    var showLabels: Bool = true

    var body: some View {
        HStack(spacing: 0) {
            StatBox(
                label: "MIN",
                value: minLevel,
                color: .safeGreen
            )

            Divider()
                .frame(height: 50)

            StatBox(
                label: "AVG",
                value: avgLevel,
                color: Color.forDecibelLevel(avgLevel)
            )

            Divider()
                .frame(height: 50)

            StatBox(
                label: "MAX",
                value: maxLevel,
                color: .dangerRed
            )
        }
        .padding(.vertical, 16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct StatBox: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            Text(value.isInfinite ? "--" : value.formattedDecibel)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)
                .contentTransition(.numericText())

            Text("dB")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Compact Statistics

struct CompactStatistics: View {
    let minLevel: Double
    let avgLevel: Double
    let maxLevel: Double

    var body: some View {
        HStack(spacing: 16) {
            CompactStatItem(label: "Min", value: minLevel, color: .safeGreen)
            CompactStatItem(label: "Avg", value: avgLevel, color: .accentColor)
            CompactStatItem(label: "Max", value: maxLevel, color: .dangerRed)
        }
    }
}

struct CompactStatItem: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value.isInfinite ? "--" : value.formattedDecibel)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(color)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        StatisticsCard(minLevel: 45, avgLevel: 68, maxLevel: 89)
            .padding(.horizontal)

        CompactStatistics(minLevel: 45, avgLevel: 68, maxLevel: 89)
            .padding()
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
    }
}
