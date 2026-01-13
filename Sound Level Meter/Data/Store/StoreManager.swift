//
//  StoreManager.swift
//  Sound Level Meter
//
//  Менеджер подписок на StoreKit 2
//

import StoreKit
import SwiftUI
import Combine

// MARK: - Product Configuration

enum StoreProduct: String, CaseIterable {
    case lifetime = "com.soundmeter.pro.lifetime"
    case weekly = "com.soundmeter.pro.weekly"
    case annual = "com.soundmeter.pro.annual"

    var id: String { rawValue }

    static var allProductIds: Set<String> {
        Set(allCases.map { $0.id })
    }
}

// MARK: - Store Manager

@MainActor
final class StoreManager: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: - Computed Properties

    var isPro: Bool {
        !purchasedProductIDs.isEmpty
    }

    var lifetimeProduct: Product? {
        products.first { $0.id == StoreProduct.lifetime.id }
    }

    var weeklyProduct: Product? {
        products.first { $0.id == StoreProduct.weekly.id }
    }

    var annualProduct: Product? {
        products.first { $0.id == StoreProduct.annual.id }
    }

    // MARK: - Private Properties

    private let cacheManager = SubscriptionCacheManager()
    private var transactionListener: Task<Void, Error>?

    // MARK: - Singleton

    static let shared = StoreManager()

    // MARK: - Initialization

    private init() {
        // Start listening for transactions
        transactionListener = listenForTransactions()

        // Load from cache first (instant UI update)
        loadFromCache()

        // Then verify with StoreKit
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Cache Management

    private func loadFromCache() {
        if cacheManager.shouldUseCachedStatus() {
            purchasedProductIDs = cacheManager.cachedProductIDs
        }
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in StoreKit.Transaction.updates {
                await self?.handle(transactionResult: result)
            }
        }
    }

    private func handle(transactionResult: VerificationResult<StoreKit.Transaction>) async {
        switch transactionResult {
        case .verified(let transaction):
            await updatePurchasedProducts()
            await transaction.finish()

        case .unverified(_, let error):
            print("Unverified transaction: \(error)")
        }
    }

    // MARK: - Load Products

    func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            let storeProducts = try await Product.products(for: StoreProduct.allProductIds)

            // Sort: lifetime first, then by price
            products = storeProducts.sorted { p1, p2 in
                if p1.id == StoreProduct.lifetime.id { return true }
                if p2.id == StoreProduct.lifetime.id { return false }
                return p1.price < p2.price
            }

            isLoading = false
        } catch {
            print("Failed to load products: \(error)")
            errorMessage = LocalizedString.Paywall.loadFailed
            isLoading = false
        }
    }

    // MARK: - Update Purchased Products

    func updatePurchasedProducts() async {
        var purchased: Set<String> = []

        // Check current entitlements
        for await result in StoreKit.Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if StoreProduct.allProductIds.contains(transaction.productID) {
                    purchased.insert(transaction.productID)
                }

            case .unverified(_, _):
                break
            }
        }

        // Update state
        purchasedProductIDs = purchased

        // Update cache
        cacheManager.updateCache(
            isPro: !purchased.isEmpty,
            productIDs: purchased
        )
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws -> Bool {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                await transaction.finish()
                await updatePurchasedProducts()
                return true

            case .unverified(_, let error):
                print("Unverified purchase: \(error)")
                errorMessage = "Purchase could not be verified"
                return false
            }

        case .userCancelled:
            return false

        case .pending:
            errorMessage = "Purchase is pending approval"
            return false

        @unknown default:
            return false
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases() async throws {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        try await AppStore.sync()
        await updatePurchasedProducts()

        if purchasedProductIDs.isEmpty {
            errorMessage = "No purchases to restore"
        }
    }

    // MARK: - Validation Check

    func validateIfNeeded() async {
        guard cacheManager.needsValidation else { return }
        await updatePurchasedProducts()
    }

    // MARK: - Pro Access

    var canAccessProFeatures: Bool {
        if isPro { return true }
        if cacheManager.shouldUseCachedStatus() && cacheManager.cachedIsPro {
            return true
        }
        return false
    }

    var needsOnlineValidation: Bool {
        cacheManager.cachedIsPro &&
        cacheManager.needsValidation &&
        purchasedProductIDs.isEmpty
    }

    // MARK: - Trial Methods

    /// Check if product has a free trial
    func hasTrial(product: Product) -> Bool {
        product.subscription?.introductoryOffer?.paymentMode == .freeTrial
    }

    /// Get trial description for product
    func trialDescription(for product: Product) -> String? {
        guard let offer = product.subscription?.introductoryOffer,
              offer.paymentMode == .freeTrial else {
            return nil
        }

        let days = offer.period.value
        return "\(days) days free"
    }
}

// MARK: - Subscription Cache Manager

final class SubscriptionCacheManager {

    // MARK: - Constants

    private let gracePeriodDays: Int = 7

    // MARK: - Keys

    private enum Keys {
        static let isPro = "store_isPro"
        static let productIDs = "store_productIDs"
        static let lastValidation = "store_lastValidation"
    }

    // MARK: - UserDefaults

    private let defaults = UserDefaults.standard

    // MARK: - Cached Values

    var cachedIsPro: Bool {
        defaults.bool(forKey: Keys.isPro)
    }

    var cachedProductIDs: Set<String> {
        let array = defaults.stringArray(forKey: Keys.productIDs) ?? []
        return Set(array)
    }

    var lastValidation: Date? {
        defaults.object(forKey: Keys.lastValidation) as? Date
    }

    // MARK: - Grace Period Logic

    func shouldUseCachedStatus() -> Bool {
        guard cachedIsPro else { return false }
        guard let lastValidation = lastValidation else { return false }

        let daysSinceValidation = Calendar.current.dateComponents(
            [.day],
            from: lastValidation,
            to: Date()
        ).day ?? Int.max

        return daysSinceValidation < gracePeriodDays
    }

    var needsValidation: Bool {
        guard cachedIsPro else { return false }
        return !shouldUseCachedStatus()
    }

    // MARK: - Update Cache

    func updateCache(isPro: Bool, productIDs: Set<String>) {
        defaults.set(isPro, forKey: Keys.isPro)
        defaults.set(Array(productIDs), forKey: Keys.productIDs)
        defaults.set(Date(), forKey: Keys.lastValidation)
    }

    // MARK: - Clear Cache

    func clearCache() {
        defaults.removeObject(forKey: Keys.isPro)
        defaults.removeObject(forKey: Keys.productIDs)
        defaults.removeObject(forKey: Keys.lastValidation)
    }
}
