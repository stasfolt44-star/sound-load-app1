//
//  PaywallView.swift
//  Sound Level Meter
//
//  Экран покупки Pro версии
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var storeManager: StoreManager

    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var selectedProduct: Product?

    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: [
                        Color.accentColor.opacity(0.15),
                        Color.accentColor.opacity(0.05),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        headerSection

                        // Features
                        featuresSection

                        // Products
                        productsSection

                        // Main CTA Button - Start Free Trial
                        trialButton

                        // Restore & Legal
                        VStack(spacing: 12) {
                            restoreSection
                            legalSection
                        }
                    }
                    .padding()
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle(LocalizedString.Paywall.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary.opacity(0.4))
                    }
                }
            }
            .alert(LocalizedString.Paywall.error, isPresented: $showError) {
                Button(LocalizedString.Paywall.ok) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                // Check for StoreKit errors on appear
                if let error = storeManager.errorMessage, !error.isEmpty {
                    errorMessage = error
                    showError = true
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            // App icon
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.accentColor, Color.accentColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolEffect(.bounce, value: isPurchasing)

            // Title only
            Text(LocalizedString.Paywall.unlockFeatures)
                .font(.title2)
                .fontWeight(.bold)
        }
        .padding(.top, 4)
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(spacing: 6) {
            FeatureRow(icon: "waveform.path", title: LocalizedString.Paywall.extendedGraph)
            FeatureRow(icon: "slider.horizontal.3", title: LocalizedString.Paywall.frequencyWeighting)
            FeatureRow(icon: "tuningfork", title: LocalizedString.Paywall.calibration)
            FeatureRow(icon: "bell.badge", title: LocalizedString.Paywall.alerts)
            FeatureRow(icon: "square.and.arrow.up", title: LocalizedString.Paywall.exportCSV)
            FeatureRow(icon: "xmark.circle", title: LocalizedString.Paywall.noAds)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    // MARK: - Products

    private var productsSection: some View {
        VStack(spacing: 12) {
            // Annual - Try 3 Days Free (ГЛАВНОЕ ПРЕДЛОЖЕНИЕ)
            if let annual = storeManager.annualProduct {
                let hasTrial = storeManager.hasTrial(product: annual)
                ProductCard(
                    product: annual,
                    title: LocalizedString.Paywall.annualSubscription,
                    subtitle: hasTrial ? LocalizedString.Paywall.annualSubtitle : LocalizedString.Paywall.annualSubtitle,
                    badge: hasTrial ? LocalizedString.Paywall.tryFreeBadge : nil,
                    badgeColor: .green,
                    isSelected: selectedProduct?.id == annual.id,
                    isPurchasing: isPurchasing
                ) {
                    selectedProduct = annual
                    await purchase(annual)
                }
                .onTapGesture {
                    withAnimation(.spring(response: 0.3)) {
                        selectedProduct = annual
                    }
                }
            }

            // Lifetime - Best Value
            if let lifetime = storeManager.lifetimeProduct {
                ProductCard(
                    product: lifetime,
                    title: LocalizedString.Paywall.lifetimeAccess,
                    subtitle: LocalizedString.Paywall.oneTimePurchase,
                    badge: LocalizedString.Paywall.lifetimeBadge,
                    badgeColor: .orange,
                    isSelected: selectedProduct?.id == lifetime.id,
                    isPurchasing: isPurchasing
                ) {
                    selectedProduct = lifetime
                    await purchase(lifetime)
                }
                .onTapGesture {
                    withAnimation(.spring(response: 0.3)) {
                        selectedProduct = lifetime
                    }
                }
            }

            // Weekly
            if let weekly = storeManager.weeklyProduct {
                ProductCard(
                    product: weekly,
                    title: LocalizedString.Paywall.weeklySubscription,
                    subtitle: LocalizedString.Paywall.weeklySubtitle,
                    badge: nil,
                    badgeColor: .blue,
                    isSelected: selectedProduct?.id == weekly.id,
                    isPurchasing: isPurchasing
                ) {
                    selectedProduct = weekly
                    await purchase(weekly)
                }
                .onTapGesture {
                    withAnimation(.spring(response: 0.3)) {
                        selectedProduct = weekly
                    }
                }
            }

            // Loading state
            if storeManager.isLoading && storeManager.products.isEmpty {
                VStack(spacing: 12) {
                    ProgressView()
                    Text(LocalizedString.Paywall.loadingProducts)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(height: 120)
            }

            // No products (for testing)
            if !storeManager.isLoading && storeManager.products.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.orange)

                    Text(LocalizedString.Paywall.productsNotAvailable)
                        .font(.headline)

                    Text(LocalizedString.Paywall.configureStoreKit)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    // MARK: - Trial Button

    private var trialButton: some View {
        Group {
            if let annual = storeManager.annualProduct, storeManager.hasTrial(product: annual) {
                Button {
                    Task {
                        selectedProduct = annual
                        await purchase(annual)
                    }
                } label: {
                    VStack(spacing: 3) {
                        Text(LocalizedString.Paywall.startFreeTrial)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)

                        Text("Then \(annual.displayPrice)/year")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.65))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.green, Color.green.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .green.opacity(0.3), radius: 12, y: 6)
                }
                .disabled(isPurchasing)
                .opacity(isPurchasing ? 0.6 : 1.0)
            }
        }
    }

    // MARK: - Restore

    private var restoreSection: some View {
        Button {
            Task {
                isPurchasing = true
                do {
                    try await storeManager.restorePurchases()
                    if storeManager.isPro {
                        dismiss()
                    }
                } catch {
                    errorMessage = LocalizedString.Paywall.restoreFailed
                    showError = true
                }
                isPurchasing = false
            }
        } label: {
            Text(LocalizedString.Paywall.restorePurchases)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color.accentColor)
                .frame(height: 44)
        }
        .disabled(isPurchasing)
    }

    // MARK: - Legal

    private var legalSection: some View {
        HStack(spacing: 16) {
            Link(LocalizedString.Paywall.terms, destination: URL(string: "https://stasfolt44-star.github.io/soundlevelmeter-app/terms.html")!)
            Text("•").foregroundStyle(.tertiary)
            Link(LocalizedString.Paywall.privacy, destination: URL(string: "https://stasfolt44-star.github.io/soundlevelmeter-app/privacy.html")!)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.horizontal)
    }

    // MARK: - Purchase Action

    private func purchase(_ product: Product) async {
        isPurchasing = true

        do {
            let success = try await storeManager.purchase(product)
            if success {
                // Small delay for satisfaction
                try? await Task.sleep(nanoseconds: 300_000_000)
                dismiss()
            }
        } catch {
            errorMessage = LocalizedString.Paywall.purchaseFailed
            showError = true
        }

        isPurchasing = false
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.callout)
                .foregroundStyle(Color.accentColor)
                .frame(width: 22)

            Text(title)
                .font(.callout)
                .foregroundColor(.primary)

            Spacer()

            Image(systemName: "checkmark")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.green)
        }
        .padding(.vertical, 1)
    }
}

// MARK: - Product Card

struct ProductCard: View {
    let product: Product
    let title: String
    let subtitle: String
    let badge: String?
    let badgeColor: Color
    let isSelected: Bool
    let isPurchasing: Bool
    let action: () async -> Void

    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            VStack(spacing: 0) {
                // Badge - компактнее
                if let badge = badge {
                    Text(badge)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(badgeColor)
                        .clipShape(Capsule())
                        .offset(y: -6)
                }

                // Content - компактнее
                HStack(spacing: 12) {
                    // Info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    // Price or loading
                    if isPurchasing && isSelected {
                        ProgressView()
                            .tint(.accentColor)
                    } else {
                        VStack(alignment: .trailing, spacing: 1) {
                            Text(product.displayPrice)
                                .font(.title3)
                                .fontWeight(.bold)

                            if product.type == .autoRenewable {
                                Text(LocalizedString.Paywall.perMonth)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .padding(.top, badge != nil ? 0 : 4)
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(
                                badge != nil ? badgeColor : Color(.systemGray4),
                                lineWidth: badge != nil ? 2 : 1
                            )
                    )
            )
            .shadow(color: .black.opacity(badge != nil ? 0.08 : 0.03), radius: badge != nil ? 10 : 5, y: 3)
        }
        .buttonStyle(.plain)
        .disabled(isPurchasing)
    }
}

// MARK: - Preview

#Preview {
    PaywallView()
        .environmentObject(StoreManager.shared)
}
