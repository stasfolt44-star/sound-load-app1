//
//  MainView.swift
//  Sound Level Meter
//
//  Главный экран приложения (Level 1 - Simple)
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var storeManager: StoreManager
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Main content
            mainContent

            // Extended panel overlay
            if viewModel.showExtendedPanel {
                extendedPanelOverlay
            }
        }
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsView()
                .environmentObject(settingsManager)
                .environmentObject(storeManager)
        }
        .sheet(isPresented: $viewModel.showHistory) {
            HistoryView()
                .environmentObject(storeManager)
        }
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: 0) {
            // Navigation bar
            navigationBar
                .padding(.horizontal)
                .padding(.top, 8)

            Spacer()

            // Decibel display
            DecibelDisplay(
                level: viewModel.currentLevel,
                weighting: viewModel.weighting,
                onTap: {
                    // Show stats on tap
                }
            )
            .padding(.horizontal)

            // Sound comparison card (показывается после записи с максимальным уровнем)
            if let comparison = viewModel.currentComparison {
                SoundComparisonCard(comparison: comparison)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
            }

            Spacer()

            // Mini graph
            miniGraphSection
                .padding(.horizontal)

            // Record button
            recordButtonSection
                .padding(.vertical, 24)

            // Swipe hint
            if viewModel.showSwipeHint {
                swipeHint
                    .padding(.bottom, 8)
            }
        }
    }

    // MARK: - Navigation Bar

    private var navigationBar: some View {
        HStack {
            // Settings button
            Button {
                viewModel.showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Recording indicator
            if viewModel.isRecording {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)

                    Text(viewModel.formattedDuration)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .monospacedDigit()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.red.opacity(0.15))
                .clipShape(Capsule())
            }

            Spacer()

            // History button
            Button {
                viewModel.showHistory = true
            } label: {
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Mini Graph Section

    private var miniGraphSection: some View {
        VStack(spacing: 8) {
            MiniGraph(
                readings: viewModel.recentReadings,
                height: 50
            )
            .frame(height: 50)

            // Compact stats
            if !viewModel.recentReadings.isEmpty {
                CompactStatistics(
                    minLevel: viewModel.minLevel,
                    avgLevel: viewModel.avgLevel,
                    maxLevel: viewModel.maxLevel
                )
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Record Button Section

    private var recordButtonSection: some View {
        VStack(spacing: 16) {
            RecordButton(isRecording: $viewModel.isRecording) {
                viewModel.toggleRecording()
            }

            // Reset button (when recording)
            if viewModel.isRecording {
                Button {
                    viewModel.resetStatistics()
                } label: {
                    Text(LocalizedString.Main.reset)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Swipe Hint

    private var swipeHint: some View {
        HStack(spacing: 4) {
            Image(systemName: "chevron.up")
                .font(.caption)

            Text(LocalizedString.Main.swipeForDetails)
                .font(.caption)
        }
        .foregroundStyle(.tertiary)
        .onTapGesture {
            viewModel.toggleExtendedPanel()
        }
    }

    // MARK: - Extended Panel Overlay

    private var extendedPanelOverlay: some View {
        ZStack(alignment: .bottom) {
            // Dimmed background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.toggleExtendedPanel()
                }

            // Panel
            ExtendedPanelView(
                currentLevel: viewModel.currentLevel,
                minLevel: viewModel.minLevel,
                avgLevel: viewModel.avgLevel,
                maxLevel: viewModel.maxLevel,
                readings: viewModel.extendedReadings,
                duration: viewModel.formattedDuration,
                isRecording: viewModel.isRecording,
                onStop: {
                    viewModel.stopRecording()
                },
                onClose: {
                    viewModel.toggleExtendedPanel()
                }
            )
            .transition(.move(edge: .bottom))
        }
    }

    // MARK: - Gestures

    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation.height
            }
            .onEnded { value in
                let threshold: CGFloat = 50

                if value.translation.height < -threshold && !viewModel.showExtendedPanel {
                    // Swipe up - show panel
                    viewModel.toggleExtendedPanel()
                } else if value.translation.height > threshold && viewModel.showExtendedPanel {
                    // Swipe down - hide panel
                    viewModel.toggleExtendedPanel()
                }

                dragOffset = 0
            }
    }
}

// MARK: - Permission Request View

struct PermissionRequestView: View {
    var onRequest: () async -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "mic.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.accentColor)

            Text(LocalizedString.Permission.Microphone.title)
                .font(.title2)
                .fontWeight(.semibold)

            Text(LocalizedString.Permission.Microphone.message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)

            Spacer()

            Button {
                Task {
                    await onRequest()
                }
            } label: {
                Text(LocalizedString.Permission.allow)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Preview

#Preview {
    MainView()
}
