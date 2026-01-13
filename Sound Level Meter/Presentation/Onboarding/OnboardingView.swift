//
//  OnboardingView.swift
//  Sound Level Meter
//
//  Экраны онбординга для первого запуска
//

import SwiftUI
import AVFoundation

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var currentPage = 0
    @State private var permissionGranted = false

    private var pages: [OnboardingPage] {
        [
            OnboardingPage(
                icon: "waveform.circle.fill",
                title: LocalizedString.Onboarding.welcomeTitle,
                subtitle: LocalizedString.Onboarding.welcomeSubtitle,
                description: LocalizedString.Onboarding.welcomeDescription,
                gradient: [Color.blue, Color.cyan]
            ),
            OnboardingPage(
                icon: "chart.line.uptrend.xyaxis",
                title: LocalizedString.Onboarding.monitoringTitle,
                subtitle: LocalizedString.Onboarding.monitoringSubtitle,
                description: LocalizedString.Onboarding.monitoringDescription,
                gradient: [Color.purple, Color.pink]
            ),
            OnboardingPage(
                icon: "ear.badge.checkmark",
                title: LocalizedString.Onboarding.hearingTitle,
                subtitle: LocalizedString.Onboarding.hearingSubtitle,
                description: LocalizedString.Onboarding.hearingDescription,
                gradient: [Color.orange, Color.red]
            )
        ]
    }

    var body: some View {
        ZStack {
            // Animated gradient background
            if currentPage < pages.count {
                LinearGradient(
                    colors: pages[currentPage].gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: currentPage)
            } else {
                Color(.systemBackground)
                    .ignoresSafeArea()
            }

            VStack(spacing: 0) {
                // Page content
                if currentPage < pages.count {
                    pageView(pages[currentPage])
                        .transition(.asymmetric(
                            insertion: .push(from: .trailing),
                            removal: .push(from: .leading)
                        ))
                        .id(currentPage)
                } else {
                    permissionPage
                        .transition(.opacity)
                }

                Spacer()

                // Bottom section
                VStack(spacing: 20) {
                    // Page indicators
                    HStack(spacing: 8) {
                        ForEach(0...pages.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? Color.white : Color.white.opacity(0.4))
                                .frame(width: index == currentPage ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }
                    .padding(.bottom, 4)

                    // Main button
                    Button {
                        handleContinue()
                    } label: {
                        HStack {
                            Text(buttonTitle)
                                .font(.headline)
                                .fontWeight(.semibold)

                            if currentPage < pages.count {
                                Image(systemName: "arrow.right")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background {
                            if currentPage < pages.count {
                                buttonGradient
                            } else {
                                Color.accentColor
                            }
                        }
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                    }
                    .padding(.horizontal, 24)

                    // Skip button
                    if currentPage < pages.count {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                currentPage = pages.count
                            }
                        } label: {
                            Text(LocalizedString.Onboarding.skip)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.8))
                                .frame(height: 44)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            checkInitialPermission()
        }
    }

    // MARK: - Page View

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon with animated gradient background
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 140, height: 140)

                Image(systemName: page.icon)
                    .font(.system(size: 60))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.9))
            }

            Text(page.description)
                .font(.body)
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
        .padding()
    }

    // MARK: - Permission Page

    private var permissionPage: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon with pulsing animation
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 140, height: 140)

                Image(systemName: "mic.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(Color.accentColor)
                    .symbolEffect(.pulse.byLayer, options: .repeating)
            }

            VStack(spacing: 12) {
                Text(LocalizedString.Onboarding.microphoneAccess)
                    .font(.system(size: 32, weight: .bold))

                Text(LocalizedString.Onboarding.microphoneRequired)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 20) {
                Text(LocalizedString.Onboarding.microphoneDescription)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                // Privacy note
                HStack(spacing: 12) {
                    Image(systemName: "lock.shield.fill")
                        .font(.title2)
                        .foregroundStyle(.green)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(LocalizedString.Onboarding.privacyProtected)
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Text(LocalizedString.Onboarding.privacyNote)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding()
                .background(Color.green.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
        .padding()
    }

    // MARK: - Helpers

    private var buttonGradient: LinearGradient {
        // Create darker, more saturated gradient for button based on current page
        switch currentPage {
        case 0: // Blue/Cyan page
            return LinearGradient(
                colors: [Color.blue.opacity(0.9), Color.cyan.opacity(0.85)],
                startPoint: .leading,
                endPoint: .trailing
            )
        case 1: // Purple/Pink page
            return LinearGradient(
                colors: [Color.purple.opacity(0.85), Color.pink.opacity(0.9)],
                startPoint: .leading,
                endPoint: .trailing
            )
        case 2: // Orange/Red page
            return LinearGradient(
                colors: [Color.orange.opacity(0.9), Color.red.opacity(0.95)],
                startPoint: .leading,
                endPoint: .trailing
            )
        default:
            return LinearGradient(
                colors: [Color.accentColor],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }

    private var buttonTitle: String {
        if currentPage < pages.count {
            return currentPage == pages.count - 1 ? LocalizedString.Onboarding.next : LocalizedString.Onboarding.continue
        } else if permissionGranted {
            return LocalizedString.Onboarding.getStarted
        } else {
            return LocalizedString.Onboarding.allowMicrophone
        }
    }

    private func handleContinue() {
        if currentPage < pages.count {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentPage += 1
            }
        } else if permissionGranted {
            completeOnboarding()
        } else {
            requestPermission()
        }
    }

    private func checkInitialPermission() {
        permissionGranted = AVAudioApplication.shared.recordPermission == .granted
    }

    private func requestPermission() {
        Task {
            let granted = await AVAudioApplication.requestRecordPermission()
            await MainActor.run {
                permissionGranted = granted
                if granted {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        completeOnboarding()
                    }
                }
            }
        }
    }

    private func completeOnboarding() {
        settingsManager.hasCompletedOnboarding = true
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isPresented = false
        }
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let gradient: [Color]
}

// MARK: - Preview

#Preview {
    OnboardingView(isPresented: .constant(true))
        .environmentObject(SettingsManager.shared)
}
