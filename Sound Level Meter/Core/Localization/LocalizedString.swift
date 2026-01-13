//
//  LocalizedString.swift
//  Sound Level Meter
//
//  Centralized localization system
//  All translations are managed in Localizable.xcstrings
//

import Foundation

/// Centralized localization keys
/// Usage: Text(LocalizedString.history.title)
enum LocalizedString {

    // MARK: - Common
    enum Common {
        static let cancel = String(localized: "common.cancel", comment: "Cancel button")
        static let done = String(localized: "common.done", comment: "Done button")
        static let delete = String(localized: "common.delete", comment: "Delete action")
        static let share = String(localized: "common.share", comment: "Share action")
    }

    // MARK: - App
    enum App {
        static let name = String(localized: "app.name", comment: "Application name")
    }

    // MARK: - History
    enum History {
        static let title = String(localized: "history.title", comment: "History screen title")
        static let emptyTitle = String(localized: "history.empty.title", comment: "Empty state title")
        static let emptyMessage = String(localized: "history.empty.message", comment: "Empty state message")
        static let startRecording = String(localized: "history.start_recording", comment: "Start recording hint")
        static let exportAll = String(localized: "history.export_all", comment: "Export all button")
        static let exportAllPro = String(localized: "history.export_all_pro", comment: "Export all Pro button")
        static let deleteAll = String(localized: "history.delete_all", comment: "Delete all button")
        static let exportCSV = String(localized: "history.export_csv", comment: "Export CSV button")
        static let today = String(localized: "history.today", comment: "Today label")
        static let yesterday = String(localized: "history.yesterday", comment: "Yesterday label")
        static let recording = String(localized: "history.recording", comment: "Recording label")
        static let share = String(localized: "history.share", comment: "Share button")
        static let delete = String(localized: "history.delete", comment: "Delete button")
        static let deleteConfirmation = String(localized: "history.delete_confirmation", comment: "Delete confirmation message")
        static let exportError = String(localized: "history.export_error", comment: "Export error title")
        static let exportAllError = String(localized: "history.export_all_error", comment: "Export all error message")
        static let exportCSVError = String(localized: "history.export_csv_error", comment: "Export CSV error message")
    }

    // MARK: - Main Screen
    enum Main {
        static let record = String(localized: "main.record", comment: "Record button")
        static let stop = String(localized: "main.stop", comment: "Stop button")
        static let reset = String(localized: "main.reset", comment: "Reset button")
        static let swipeForDetails = String(localized: "main.swipe_for_details", comment: "Swipe hint")
    }

    // MARK: - Statistics
    enum Stats {
        static let min = String(localized: "stats.min", comment: "Minimum label")
        static let avg = String(localized: "stats.avg", comment: "Average label")
        static let max = String(localized: "stats.max", comment: "Maximum label")
        static let leq = String(localized: "stats.leq", comment: "Leq label")
    }

    // MARK: - Settings
    enum Settings {
        static let title = String(localized: "settings.title", comment: "Settings title")
    }

    // MARK: - Permissions
    enum Permission {
        enum Microphone {
            static let title = String(localized: "permission.microphone.title", comment: "Microphone permission title")
            static let message = String(localized: "permission.microphone.message", comment: "Microphone permission message")
        }
        static let allow = String(localized: "permission.allow", comment: "Allow permission button")
    }

    // MARK: - Extended Panel
    enum Extended {
        static let details = String(localized: "extended.details", comment: "Details title")
        static let levelOverTime = String(localized: "extended.level_over_time", comment: "Level over time title")
        static let duration = String(localized: "extended.duration", comment: "Duration label")
    }

    // MARK: - Calibration
    enum Calibration {
        static let title = String(localized: "calibration.title", comment: "Calibration title")
        static let instructionsTitle = String(localized: "calibration.instructions.title", comment: "Calibration instructions title")
        static let instructionsDescription = String(localized: "calibration.instructions.description", comment: "Calibration instructions")
        static let currentReadings = String(localized: "calibration.current_readings", comment: "Current readings label")
        static let formula = String(localized: "calibration.formula", comment: "Calibration formula")
        static let example = String(localized: "calibration.example", comment: "Calibration example")
        static let offset = String(localized: "calibration.offset", comment: "Offset label")
        static let save = String(localized: "calibration.save", comment: "Save calibration button")
        static let reset = String(localized: "calibration.reset", comment: "Reset to default button")
        static let showDebug = String(localized: "calibration.show_debug", comment: "Show debug info button")
        static let hideDebug = String(localized: "calibration.hide_debug", comment: "Hide debug info button")
    }

    // MARK: - Settings Sections
    enum SettingsSection {
        static let subscription = String(localized: "settings.section.subscription", comment: "Subscription section header")
        static let measurement = String(localized: "settings.section.measurement", comment: "Measurement section header")
        static let alerts = String(localized: "settings.section.alerts", comment: "Alerts section header")
        static let data = String(localized: "settings.section.data", comment: "Data section header")
        static let appearance = String(localized: "settings.section.appearance", comment: "Appearance section header")
        static let about = String(localized: "settings.section.about", comment: "About section header")
    }

    // MARK: - Settings Items
    enum SettingsItem {
        // Subscription
        static let currentPlan = String(localized: "settings.current_plan", comment: "Current plan label")
        static let planFree = String(localized: "settings.plan.free", comment: "Free plan")
        static let planPro = String(localized: "settings.plan.pro", comment: "Pro plan")
        static let upgrade = String(localized: "settings.upgrade", comment: "Upgrade button")
        static let restorePurchases = String(localized: "settings.restore_purchases", comment: "Restore purchases button")
        static let restorePurchasesTitle = String(localized: "settings.restore_purchases_title", comment: "Restore purchases alert title")
        static let restoreSuccess = String(localized: "settings.restore_success", comment: "Restore success message")
        static let restoreNoPurchases = String(localized: "settings.restore_no_purchases", comment: "No purchases to restore message")
        static let restoreFailed = String(localized: "settings.restore_failed", comment: "Restore failed message")

        // Measurement
        static let frequencyWeighting = String(localized: "settings.frequency_weighting", comment: "Frequency weighting")
        static let responseTime = String(localized: "settings.response_time", comment: "Response time")

        // Alerts
        static let thresholdAlert = String(localized: "settings.threshold_alert", comment: "Threshold alert")
        static let alertAt = String(localized: "settings.alert_at", comment: "Alert at label")
        static let vibrate = String(localized: "settings.vibrate", comment: "Vibrate toggle")
        static let sound = String(localized: "settings.sound", comment: "Sound toggle")

        // Data
        static let exportFormat = String(localized: "settings.export_format", comment: "Export format")
        static let autoSaveRecordings = String(localized: "settings.auto_save_recordings", comment: "Auto-save recordings")
        static let clearAllData = String(localized: "settings.clear_all_data", comment: "Clear all data")
        static let clearAllDataTitle = String(localized: "settings.clear_all_data_title", comment: "Clear all data alert title")
        static let clearAllDataMessage = String(localized: "settings.clear_all_data_message", comment: "Clear all data alert message")
        static let clearAllButton = String(localized: "settings.clear_all_button", comment: "Clear all button")

        // Appearance
        static let theme = String(localized: "settings.theme", comment: "Theme picker")
        static let keepScreenOn = String(localized: "settings.keep_screen_on", comment: "Keep screen on toggle")

        // About
        static let howItWorks = String(localized: "settings.how_it_works", comment: "How it works")
        static let privacyPolicy = String(localized: "settings.privacy_policy", comment: "Privacy policy")
        static let termsOfService = String(localized: "settings.terms_of_service", comment: "Terms of service")
        static let rateApp = String(localized: "settings.rate_app", comment: "Rate app")
        static let contactSupport = String(localized: "settings.contact_support", comment: "Contact support")
        static let version = String(localized: "settings.version", comment: "Version label")
    }

    // MARK: - How It Works
    enum HowItWorks {
        static let title = String(localized: "how_it_works.title", comment: "How it works title")

        // Sound Measurement
        static let soundMeasurementTitle = String(localized: "how_it_works.sound_measurement.title", comment: "Sound measurement title")
        static let soundMeasurementDescription = String(localized: "how_it_works.sound_measurement.description", comment: "Sound measurement description")

        // A-Weighting
        static let aWeightingTitle = String(localized: "how_it_works.a_weighting.title", comment: "A-weighting title")
        static let aWeightingDescription = String(localized: "how_it_works.a_weighting.description", comment: "A-weighting description")

        // Safety Levels
        static let safetyLevelsTitle = String(localized: "how_it_works.safety_levels.title", comment: "Safety levels title")
        static let safetyLevelsDescription = String(localized: "how_it_works.safety_levels.description", comment: "Safety levels description")

        // Calibration
        static let calibrationTitle = String(localized: "how_it_works.calibration.title", comment: "Calibration title")
        static let calibrationDescription = String(localized: "how_it_works.calibration.description", comment: "Calibration description")

        // Note
        static let note = String(localized: "how_it_works.note", comment: "Professional disclaimer note")
    }

    // MARK: - Paywall
    enum Paywall {
        static let title = String(localized: "paywall.title", comment: "Paywall title")
        static let error = String(localized: "paywall.error", comment: "Error alert title")
        static let ok = String(localized: "paywall.ok", comment: "OK button")

        // Header
        static let unlockFeatures = String(localized: "paywall.unlock_features", comment: "Unlock features title")
        static let subtitle = String(localized: "paywall.subtitle", comment: "Subtitle text")

        // Features section
        static let whatsIncluded = String(localized: "paywall.whats_included", comment: "What's included header")

        // Feature items
        static let extendedGraph = String(localized: "paywall.feature.extended_graph", comment: "Extended graph feature")
        static let extendedGraphSubtitle = String(localized: "paywall.feature.extended_graph.subtitle", comment: "Extended graph subtitle")
        static let frequencyWeighting = String(localized: "paywall.feature.frequency_weighting", comment: "Frequency weighting feature")
        static let frequencyWeightingSubtitle = String(localized: "paywall.feature.frequency_weighting.subtitle", comment: "Frequency weighting subtitle")
        static let calibration = String(localized: "paywall.feature.calibration", comment: "Calibration feature")
        static let calibrationSubtitle = String(localized: "paywall.feature.calibration.subtitle", comment: "Calibration subtitle")
        static let alerts = String(localized: "paywall.feature.alerts", comment: "Alerts feature")
        static let alertsSubtitle = String(localized: "paywall.feature.alerts.subtitle", comment: "Alerts subtitle")
        static let exportCSV = String(localized: "paywall.feature.export_csv", comment: "Export CSV feature")
        static let exportCSVSubtitle = String(localized: "paywall.feature.export_csv.subtitle", comment: "Export CSV subtitle")
        static let noAds = String(localized: "paywall.feature.no_ads", comment: "No ads feature")
        static let noAdsSubtitle = String(localized: "paywall.feature.no_ads.subtitle", comment: "No ads subtitle")

        // Products
        static let lifetimeAccess = String(localized: "paywall.product.lifetime_access", comment: "Lifetime access")
        static let lifetimeSubtitle = String(localized: "paywall.product.lifetime_subtitle", comment: "Lifetime subtitle")
        static let lifetimeBadge = String(localized: "paywall.product.lifetime_badge", comment: "Lifetime badge")
        static let weeklySubscription = String(localized: "paywall.product.weekly_subscription", comment: "Weekly subscription")
        static let weeklySubtitle = String(localized: "paywall.product.weekly_subtitle", comment: "Weekly subtitle")
        static let monthlySubscription = String(localized: "paywall.product.monthly_subscription", comment: "Monthly subscription")
        static let monthlySubtitle = String(localized: "paywall.product.monthly_subtitle", comment: "Monthly subtitle")
        static let annualSubscription = String(localized: "paywall.product.annual_subscription", comment: "Annual subscription")
        static let annualSubtitle = String(localized: "paywall.product.annual_subtitle", comment: "Annual subtitle")
        static let perWeek = String(localized: "paywall.product.per_week", comment: "Per week label")
        static let perMonth = String(localized: "paywall.product.per_month", comment: "Per month label")
        static let perYear = String(localized: "paywall.product.per_year", comment: "Per year label")
        static let tryFreeBadge = String(localized: "paywall.product.try_free_badge", comment: "Try free badge")
        static let oneTimePurchase = String(localized: "paywall.product.one_time_purchase", comment: "One-time purchase label")
        static let startFreeTrial = String(localized: "paywall.product.start_free_trial", comment: "Start free trial button")

        // Loading states
        static let loadingProducts = String(localized: "paywall.loading_products", comment: "Loading products")
        static let productsNotAvailable = String(localized: "paywall.products_not_available", comment: "Products not available")
        static let configureStoreKit = String(localized: "paywall.configure_storekit", comment: "Configure StoreKit message")

        // Restore & errors
        static let restorePurchases = String(localized: "paywall.restore_purchases", comment: "Restore purchases button")
        static let restoreFailed = String(localized: "paywall.restore_failed", comment: "Restore failed error")
        static let purchaseFailed = String(localized: "paywall.purchase_failed", comment: "Purchase failed error")
        static let loadFailed = String(localized: "paywall.load_failed", comment: "Failed to load products error")

        // Legal
        static let terms = String(localized: "paywall.legal.terms", comment: "Terms link")
        static let privacy = String(localized: "paywall.legal.privacy", comment: "Privacy link")
        static let subscriptionRenews = String(localized: "paywall.legal.subscription_renews", comment: "Subscription renewal disclaimer")
    }

    // MARK: - Onboarding
    enum Onboarding {
        // Page 1 - Welcome
        static let welcomeTitle = String(localized: "onboarding.welcome.title", comment: "Welcome title")
        static let welcomeSubtitle = String(localized: "onboarding.welcome.subtitle", comment: "Welcome subtitle")
        static let welcomeDescription = String(localized: "onboarding.welcome.description", comment: "Welcome description")

        // Page 2 - Real-Time Monitoring
        static let monitoringTitle = String(localized: "onboarding.monitoring.title", comment: "Monitoring title")
        static let monitoringSubtitle = String(localized: "onboarding.monitoring.subtitle", comment: "Monitoring subtitle")
        static let monitoringDescription = String(localized: "onboarding.monitoring.description", comment: "Monitoring description")

        // Page 3 - Protect Hearing
        static let hearingTitle = String(localized: "onboarding.hearing.title", comment: "Hearing protection title")
        static let hearingSubtitle = String(localized: "onboarding.hearing.subtitle", comment: "Hearing protection subtitle")
        static let hearingDescription = String(localized: "onboarding.hearing.description", comment: "Hearing protection description")

        // Permission page
        static let microphoneAccess = String(localized: "onboarding.microphone_access", comment: "Microphone access title")
        static let microphoneRequired = String(localized: "onboarding.microphone_required", comment: "Microphone required subtitle")
        static let microphoneDescription = String(localized: "onboarding.microphone_description", comment: "Microphone description")
        static let privacyProtected = String(localized: "onboarding.privacy_protected", comment: "Privacy protected title")
        static let privacyNote = String(localized: "onboarding.privacy_note", comment: "Privacy note")

        // Buttons
        static let skip = String(localized: "onboarding.skip", comment: "Skip button")
        static let next = String(localized: "onboarding.next", comment: "Next button")
        static let `continue` = String(localized: "onboarding.continue", comment: "Continue button")
        static let getStarted = String(localized: "onboarding.get_started", comment: "Get started button")
        static let allowMicrophone = String(localized: "onboarding.allow_microphone", comment: "Allow microphone button")
    }

    // MARK: - Safety Messages
    enum SafetyMessage {
        static let safeExtended = String(localized: "safety.safe_extended", comment: "Safe for extended exposure")
        static let cautionAdvised = String(localized: "safety.caution_advised", comment: "Caution advised")
        static let limitedExposure = String(localized: "safety.limited_exposure", comment: "Limited exposure recommended")
        static let hearingDamageRisk = String(localized: "safety.hearing_damage_risk", comment: "Hearing damage risk")
        static let immediateRisk = String(localized: "safety.immediate_risk", comment: "Immediate hearing damage risk")
        static let safeForTemplate = String(localized: "safety.safe_for_template", comment: "Safe for time template")
        static let maxExposureTemplate = String(localized: "safety.max_exposure_template", comment: "Max exposure template")

        static func safeFor(_ time: String) -> String {
            safeForTemplate.replacingOccurrences(of: "{time}", with: time)
        }

        static func maxExposure(_ time: String) -> String {
            maxExposureTemplate.replacingOccurrences(of: "{time}", with: time)
        }
    }
}
