//
//  RecordButton.swift
//  Sound Level Meter
//
//  Кнопка записи измерений
//

import SwiftUI

struct RecordButton: View {
    @Binding var isRecording: Bool
    var onTap: () -> Void

    @State private var isPulsing = false

    var body: some View {
        Button(action: {
            onTap()
        }) {
            HStack(spacing: 12) {
                // Record indicator
                Circle()
                    .fill(isRecording ? Color.red : Color.red.opacity(0.8))
                    .frame(width: 16, height: 16)
                    .scaleEffect(isPulsing && isRecording ? 1.2 : 1.0)
                    .animation(
                        isRecording ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default,
                        value: isPulsing
                    )

                Text(isRecording ? "Recording" : "REC")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(isRecording ? .white : .primary)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(isRecording ? Color.red : Color(.systemGray5))
            )
            .overlay(
                Capsule()
                    .stroke(isRecording ? Color.red : Color.clear, lineWidth: 2)
                    .scaleEffect(isPulsing && isRecording ? 1.15 : 1.0)
                    .opacity(isPulsing && isRecording ? 0 : 1)
                    .animation(
                        isRecording ? .easeOut(duration: 1.0).repeatForever(autoreverses: false) : .default,
                        value: isPulsing
                    )
            )
        }
        .buttonStyle(.plain)
        .onChange(of: isRecording) { _, newValue in
            isPulsing = newValue
        }
    }
}

// MARK: - Stop Button

struct StopButton: View {
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: "stop.fill")
                    .font(.subheadline)

                Text("Stop")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(Color.red)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        RecordButton(isRecording: .constant(false)) { }
        RecordButton(isRecording: .constant(true)) { }
        StopButton { }
    }
    .padding()
}
