//
//  SoundCategory.swift
//  Sound Level Meter
//
//  Категории звуков с описаниями
//

import Foundation

struct SoundCategory: Identifiable {
    let id = UUID()
    let minDB: Double
    let maxDB: Double
    let name: String
    let nameRu: String
    let icon: String
    let examples: [String]
    let safetyLevel: SafetyLevel
    let maxExposureTime: TimeInterval?

    func contains(level: Double) -> Bool {
        return level >= minDB && level < maxDB
    }

    var localizedName: String {
        // Use localized string based on the name key
        let key = "sound_category.\(name.lowercased().replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: "/", with: "_"))"
        return String(localized: String.LocalizationValue(stringLiteral: key))
    }
}

// MARK: - Sound Categories Database
extension SoundCategory {
    static let allCategories: [SoundCategory] = [
        SoundCategory(
            minDB: 0, maxDB: 30,
            name: "Almost silent",
            nameRu: "Почти тишина",
            icon: "🤫",
            examples: ["Breathing", "Rustling leaves"],
            safetyLevel: .safe,
            maxExposureTime: nil
        ),
        SoundCategory(
            minDB: 30, maxDB: 40,
            name: "Whisper quiet",
            nameRu: "Шёпот",
            icon: "🌙",
            examples: ["Whisper", "Quiet library"],
            safetyLevel: .safe,
            maxExposureTime: nil
        ),
        SoundCategory(
            minDB: 40, maxDB: 50,
            name: "Quiet room",
            nameRu: "Тихая комната",
            icon: "🏠",
            examples: ["Quiet home", "Light rain"],
            safetyLevel: .safe,
            maxExposureTime: nil
        ),
        SoundCategory(
            minDB: 50, maxDB: 60,
            name: "Quiet office",
            nameRu: "Тихий офис",
            icon: "💼",
            examples: ["Quiet office", "Refrigerator hum"],
            safetyLevel: .safe,
            maxExposureTime: nil
        ),
        SoundCategory(
            minDB: 60, maxDB: 70,
            name: "Normal conversation",
            nameRu: "Обычный разговор",
            icon: "🗣",
            examples: ["Normal conversation", "Background music"],
            safetyLevel: .safe,
            maxExposureTime: nil
        ),
        SoundCategory(
            minDB: 70, maxDB: 80,
            name: "Busy traffic",
            nameRu: "Оживлённое движение",
            icon: "🚗",
            examples: ["Busy traffic", "Vacuum cleaner"],
            safetyLevel: .caution,
            maxExposureTime: nil
        ),
        SoundCategory(
            minDB: 80, maxDB: 85,
            name: "Loud restaurant",
            nameRu: "Громкий ресторан",
            icon: "🍽",
            examples: ["Loud restaurant", "Factory"],
            safetyLevel: .warning,
            maxExposureTime: 8 * 3600
        ),
        SoundCategory(
            minDB: 85, maxDB: 90,
            name: "Heavy traffic",
            nameRu: "Шумная дорога",
            icon: "🚚",
            examples: ["Heavy traffic", "Lawn mower"],
            safetyLevel: .warning,
            maxExposureTime: 8 * 3600
        ),
        SoundCategory(
            minDB: 90, maxDB: 95,
            name: "Motorcycle",
            nameRu: "Мотоцикл",
            icon: "🏍",
            examples: ["Motorcycle", "Power drill"],
            safetyLevel: .danger,
            maxExposureTime: 4 * 3600
        ),
        SoundCategory(
            minDB: 95, maxDB: 100,
            name: "Power tools",
            nameRu: "Электроинструменты",
            icon: "🔧",
            examples: ["Power tools", "Subway train"],
            safetyLevel: .danger,
            maxExposureTime: 2 * 3600
        ),
        SoundCategory(
            minDB: 100, maxDB: 105,
            name: "Nightclub",
            nameRu: "Ночной клуб",
            icon: "🎵",
            examples: ["Nightclub", "Chainsaw"],
            safetyLevel: .danger,
            maxExposureTime: 1 * 3600
        ),
        SoundCategory(
            minDB: 105, maxDB: 110,
            name: "Rock concert",
            nameRu: "Рок-концерт",
            icon: "🎸",
            examples: ["Rock concert", "Jackhammer"],
            safetyLevel: .extreme,
            maxExposureTime: 30 * 60
        ),
        SoundCategory(
            minDB: 110, maxDB: 120,
            name: "Thunder / Siren",
            nameRu: "Гром / Сирена",
            icon: "⚡️",
            examples: ["Thunder", "Emergency siren"],
            safetyLevel: .extreme,
            maxExposureTime: 15 * 60
        ),
        SoundCategory(
            minDB: 120, maxDB: 150,
            name: "Jet engine",
            nameRu: "Реактивный двигатель",
            icon: "✈️",
            examples: ["Jet engine at takeoff", "Gunshot"],
            safetyLevel: .extreme,
            maxExposureTime: 60
        )
    ]

    static func category(for level: Double) -> SoundCategory {
        return allCategories.first { $0.contains(level: level) } ?? allCategories.last!
    }

    static func safetyMessage(for level: Double) -> String {
        let category = category(for: level)

        switch category.safetyLevel {
        case .safe:
            return LocalizedString.SafetyMessage.safeExtended
        case .caution:
            return LocalizedString.SafetyMessage.cautionAdvised
        case .warning:
            if let time = category.maxExposureTime {
                return LocalizedString.SafetyMessage.safeFor(formatTime(time))
            }
            return LocalizedString.SafetyMessage.limitedExposure
        case .danger:
            if let time = category.maxExposureTime {
                return LocalizedString.SafetyMessage.maxExposure(formatTime(time))
            }
            return LocalizedString.SafetyMessage.hearingDamageRisk
        case .extreme:
            return LocalizedString.SafetyMessage.immediateRisk
        }
    }

    private static func formatTime(_ seconds: TimeInterval) -> String {
        if seconds >= 3600 {
            let hours = Int(seconds / 3600)
            return "\(hours) hour\(hours > 1 ? "s" : "")"
        } else {
            let minutes = Int(seconds / 60)
            return "\(minutes) min"
        }
    }
}
