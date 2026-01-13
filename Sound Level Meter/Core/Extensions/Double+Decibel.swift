//
//  Double+Decibel.swift
//  Sound Level Meter
//
//  Расширения для работы с децибелами
//

import Foundation

extension Double {

    /// Форматирует значение dB для отображения
    var formattedDecibel: String {
        return String(format: "%.0f", self)
    }

    /// Форматирует значение dB с одним знаком после запятой
    var formattedDecibelPrecise: String {
        return String(format: "%.1f", self)
    }

    /// Ограничивает значение dB в допустимых пределах
    var clampedDecibel: Double {
        return max(Constants.Audio.minDecibelLevel, min(Constants.Audio.maxDecibelLevel, self))
    }

    /// Нормализует значение dB в диапазон 0...1 для визуализации
    var normalizedDecibel: Double {
        let clamped = self.clampedDecibel
        return (clamped - Constants.Audio.minDecibelLevel) /
               (Constants.Audio.maxDecibelLevel - Constants.Audio.minDecibelLevel)
    }

    /// Возвращает максимальное безопасное время воздействия (в часах) по NIOSH
    var safeExposureHours: Double? {
        guard self >= 85 else { return nil }
        return 8 / pow(2, (self - 85) / 3)
    }

    /// Форматирует время безопасного воздействия
    var formattedExposureTime: String? {
        guard let hours = safeExposureHours else { return nil }

        if hours >= 1 {
            let h = Int(hours)
            return "\(h) hour\(h > 1 ? "s" : "")"
        } else {
            let minutes = Int(hours * 60)
            if minutes >= 1 {
                return "\(minutes) min"
            } else {
                let seconds = Int(hours * 3600)
                return "\(seconds) sec"
            }
        }
    }
}
