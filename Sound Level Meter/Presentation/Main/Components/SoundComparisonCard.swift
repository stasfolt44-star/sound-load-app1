//
//  SoundComparisonCard.swift
//  Sound Level Meter
//
//  Карточка с забавным сравнением текущего уровня звука
//

import SwiftUI

struct SoundComparisonCard: View {
    let comparison: SoundComparison?
    @State private var shouldWobble = false

    var body: some View {
        if let comparison = comparison {
            HStack(spacing: 12) {
                // Emoji icon
                Text(comparison.emoji)
                    .font(.system(size: 40))

                VStack(alignment: .leading, spacing: 4) {
                    Text(comparison.title)
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text(comparison.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.accentColor.opacity(0.4), .accentColor.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
            .shadow(color: .accentColor.opacity(0.1), radius: 12, y: 4)
            .modifier(WobbleEffect(trigger: shouldWobble))
            .onAppear {
                // Запускаем анимацию покачивания при появлении
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    shouldWobble = true
                }
            }
        }
    }
}

// MARK: - Wobble Effect

struct WobbleEffect: ViewModifier {
    let trigger: Bool
    @State private var rotationAngle: Double = 0

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotationAngle))
            .onChange(of: trigger) { oldValue, newValue in
                guard newValue else { return }

                // Последовательность покачиваний
                withAnimation(.easeInOut(duration: 0.1)) {
                    rotationAngle = -3
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        rotationAngle = 3
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        rotationAngle = -2
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        rotationAngle = 2
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        rotationAngle = 0
                    }
                }
            }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        SoundComparisonCard(
            comparison: SoundComparison(
                minDB: 60,
                maxDB: 70,
                emoji: "🍳",
                title: "Злой повар",
                description: "Жарит стейк и ругается на официантов"
            )
        )

        SoundComparisonCard(
            comparison: SoundComparison(
                minDB: 105,
                maxDB: 110,
                emoji: "🎵",
                title: "Дискотека глухих",
                description: "Басы так долбят, что трясутся стены"
            )
        )

        SoundComparisonCard(
            comparison: SoundComparison(
                minDB: 80,
                maxDB: 85,
                emoji: "🏃",
                title: "Несущийся поезд",
                description: "В метро на Таганской в час пик"
            )
        )
    }
    .padding()
}
