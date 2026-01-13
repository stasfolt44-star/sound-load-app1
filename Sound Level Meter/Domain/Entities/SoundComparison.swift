//
//  SoundComparison.swift
//  Sound Level Meter
//
//  Забавные сравнения уровней звука с реальными ситуациями
//

import Foundation

struct SoundComparison: Identifiable, Equatable {
    let id = UUID()
    let minDB: Double
    let maxDB: Double
    let emoji: String
    let title: String
    let description: String

    static func == (lhs: SoundComparison, rhs: SoundComparison) -> Bool {
        return lhs.title == rhs.title && lhs.description == rhs.description
    }

    // Хранилище последних показанных вариантов
    private static var recentlyShown: [String] = []
    private static let maxRecent = 10

    static func forLevel(_ db: Double) -> SoundComparison? {
        // Находим все подходящие варианты для данного уровня
        var suitable = allComparisons.filter { db >= $0.minDB && db < $0.maxDB }

        // Если вариантов больше одного, исключаем недавно показанные
        if suitable.count > 1 {
            let notRecent = suitable.filter { !recentlyShown.contains($0.title) }
            if !notRecent.isEmpty {
                suitable = notRecent
            }
        }

        // Выбираем случайный вариант
        guard let selected = suitable.randomElement() else { return nil }

        // Добавляем в список недавних
        recentlyShown.append(selected.title)
        if recentlyShown.count > maxRecent {
            recentlyShown.removeFirst()
        }

        return selected
    }

    // Сброс истории (для тестирования)
    static func resetHistory() {
        recentlyShown.removeAll()
    }

    static let allComparisons: [SoundComparison] = [
        // 20-30 dB - очень тихие звуки
        SoundComparison(minDB: 20, maxDB: 30, emoji: "🍃", title: "Шёпот влюблённых", description: "Или листья падают в библиотеке"),
        SoundComparison(minDB: 20, maxDB: 30, emoji: "🌙", title: "Тишина в 3 ночи", description: "Когда даже соседи спят"),
        SoundComparison(minDB: 20, maxDB: 30, emoji: "🦗", title: "Сверчок на даче", description: "Самый громкий звук вокруг"),
        SoundComparison(minDB: 20, maxDB: 30, emoji: "💭", title: "Звук ваших мыслей", description: "Практически полная тишина"),

        // 30-40 dB - тихие звуки
        SoundComparison(minDB: 30, maxDB: 40, emoji: "😴", title: "Сонная библиотека", description: "Даже мышь не пискнет"),
        SoundComparison(minDB: 30, maxDB: 40, emoji: "📚", title: "Шелест страниц книги", description: "Идеальная тишина для чтения"),
        SoundComparison(minDB: 30, maxDB: 40, emoji: "🌾", title: "Ветер в поле", description: "Едва слышное дуновение"),
        SoundComparison(minDB: 30, maxDB: 40, emoji: "❄️", title: "Падающий снег", description: "Зимняя тишина"),

        // 40-50 dB - спокойные звуки
        SoundComparison(minDB: 40, maxDB: 50, emoji: "☕️", title: "Тихая кофейня", description: "Где все работают за MacBook'ами"),
        SoundComparison(minDB: 40, maxDB: 50, emoji: "🏠", title: "Тихая квартира", description: "Соседи ещё не начали ремонт"),
        SoundComparison(minDB: 40, maxDB: 50, emoji: "💻", title: "Офис рано утром", description: "До прихода коллег"),
        SoundComparison(minDB: 40, maxDB: 50, emoji: "🌧️", title: "Лёгкий дождик", description: "Приятный фоновый шум"),

        // 50-60 dB - нормальные звуки
        SoundComparison(minDB: 50, maxDB: 60, emoji: "💬", title: "Обычный разговор", description: "Два программиста обсуждают баг"),
        SoundComparison(minDB: 50, maxDB: 60, emoji: "🖥️", title: "Офисная суета", description: "Стук клавиатур и разговоры"),
        SoundComparison(minDB: 50, maxDB: 60, emoji: "🍽️", title: "Ресторан средней шумности", description: "Слышны соседние столики"),
        SoundComparison(minDB: 50, maxDB: 60, emoji: "🚶", title: "Людная улица", description: "Обычный городской фон"),
        SoundComparison(minDB: 50, maxDB: 60, emoji: "🌊", title: "Шум прибоя", description: "Волны на пляже"),

        // 60-70 dB - заметные звуки
        SoundComparison(minDB: 60, maxDB: 70, emoji: "🍳", title: "Злой повар", description: "Жарит стейк и ругается на официантов"),
        SoundComparison(minDB: 60, maxDB: 70, emoji: "🎹", title: "Пианино в соседней квартире", description: "Опять играют Бетховена"),
        SoundComparison(minDB: 60, maxDB: 70, emoji: "📺", title: "Громкий телевизор", description: "Бабушка смотрит новости"),
        SoundComparison(minDB: 60, maxDB: 70, emoji: "🚿", title: "Душ в полную силу", description: "Массажная струя работает"),
        SoundComparison(minDB: 60, maxDB: 70, emoji: "🔔", title: "Школьная перемена", description: "Дети бегают и кричат"),

        // 70-75 dB - громкие звуки
        SoundComparison(minDB: 70, maxDB: 75, emoji: "🚗", title: "Пробка на МКАД", description: "Все сигналят, но никто не едет"),
        SoundComparison(minDB: 70, maxDB: 75, emoji: "🎤", title: "Караоке-бар", description: "Кто-то поёт Цоя"),
        SoundComparison(minDB: 70, maxDB: 75, emoji: "🏪", title: "Торговый центр", description: "Все кассы работают одновременно"),
        SoundComparison(minDB: 70, maxDB: 75, emoji: "🚌", title: "Автобус изнутри", description: "Дизельный двигатель гудит"),

        // 75-80 dB - очень громкие звуки
        SoundComparison(minDB: 75, maxDB: 80, emoji: "🧹", title: "Пылесос-монстр", description: "Соседский Dyson в воскресенье в 8 утра"),
        SoundComparison(minDB: 75, maxDB: 80, emoji: "📢", title: "Учитель физкультуры", description: "Орёт через весь спортзал"),
        SoundComparison(minDB: 75, maxDB: 80, emoji: "🚚", title: "Грузовик под окном", description: "Разгружают стройматериалы"),
        SoundComparison(minDB: 75, maxDB: 80, emoji: "🔧", title: "Автомастерская", description: "Гайковёрт в действии"),
        SoundComparison(minDB: 75, maxDB: 80, emoji: "⚡", title: "Блендер на максималках", description: "Готовим смузи до апокалипсиса"),

        // 80-85 dB - болезненно громкие
        SoundComparison(minDB: 80, maxDB: 85, emoji: "🏃", title: "Несущийся поезд", description: "В метро на Таганской в час пик"),
        SoundComparison(minDB: 80, maxDB: 85, emoji: "🚨", title: "Полицейская сирена", description: "Мимо проезжает патруль"),
        SoundComparison(minDB: 80, maxDB: 85, emoji: "🏭", title: "Заводской цех", description: "Станки работают в три смены"),
        SoundComparison(minDB: 80, maxDB: 85, emoji: "🎺", title: "Духовой оркестр", description: "Репетируют на парадную площадь"),
        SoundComparison(minDB: 80, maxDB: 85, emoji: "⚠️", title: "Пожарная тревога", description: "Учебная эвакуация в офисе"),

        // 85-90 dB - опасно громкие
        SoundComparison(minDB: 85, maxDB: 90, emoji: "🏗️", title: "Ремонт у соседей", description: "Перфоратор с утра до вечера"),
        SoundComparison(minDB: 85, maxDB: 90, emoji: "🎪", title: "Детский праздник", description: "20 детей орут одновременно"),
        SoundComparison(minDB: 85, maxDB: 90, emoji: "🌪️", title: "Мощный фен", description: "В парикмахерской у самого уха"),
        SoundComparison(minDB: 85, maxDB: 90, emoji: "🛵", title: "Мопед без глушителя", description: "Пацаны гоняют во дворе"),

        // 90-95 dB - очень опасные
        SoundComparison(minDB: 90, maxDB: 95, emoji: "🏍️", title: "Байкеры на светофоре", description: "Ревут моторами для понтов"),
        SoundComparison(minDB: 90, maxDB: 95, emoji: "🪚", title: "Бензопила в действии", description: "Дачники спиливают дерево"),
        SoundComparison(minDB: 90, maxDB: 95, emoji: "⚙️", title: "Промышленная дрель", description: "Сверлим бетонную стену"),
        SoundComparison(minDB: 90, maxDB: 95, emoji: "🛠️", title: "Отбойный молоток", description: "Дорожные работы у дома"),

        // 95-100 dB - критически громкие
        SoundComparison(minDB: 95, maxDB: 100, emoji: "🎸", title: "Рок-концерт в гараже", description: "Соседские дети учатся играть металл"),
        SoundComparison(minDB: 95, maxDB: 100, emoji: "🥁", title: "Барабанная установка", description: "Без шумоизоляции, конечно"),
        SoundComparison(minDB: 95, maxDB: 100, emoji: "📯", title: "Духовой фестиваль", description: "Все трубы играют форте"),
        SoundComparison(minDB: 95, maxDB: 100, emoji: "🏎️", title: "Гонки Formula 1", description: "Болиды проносятся мимо"),

        // 100-105 dB - экстремально громкие
        SoundComparison(minDB: 100, maxDB: 105, emoji: "📣", title: "Футбольный стадион", description: "ГОЛ!!! Все орут как безумные"),
        SoundComparison(minDB: 100, maxDB: 105, emoji: "🔔", title: "Церковный колокол", description: "Прямо на звоннице"),
        SoundComparison(minDB: 100, maxDB: 105, emoji: "💥", title: "Петарды во дворе", description: "Новый год круглый год"),
        SoundComparison(minDB: 100, maxDB: 105, emoji: "🚂", title: "Гудок поезда", description: "Вы стоите рядом с локомотивом"),

        // 105-110 dB - опасность для слуха
        SoundComparison(minDB: 105, maxDB: 110, emoji: "🎵", title: "Дискотека глухих", description: "Басы так долбят, что трясутся стены"),
        SoundComparison(minDB: 105, maxDB: 110, emoji: "🎛️", title: "DJ-пульт на максимуме", description: "Сабвуфер на все деньги"),
        SoundComparison(minDB: 105, maxDB: 110, emoji: "🎪", title: "Цирковая пушка", description: "Человека-ядро запускают"),
        SoundComparison(minDB: 105, maxDB: 110, emoji: "⚡", title: "Удар грома", description: "Молния ударила в соседний дом"),

        // 110-115 dB - немедленная опасность
        SoundComparison(minDB: 110, maxDB: 115, emoji: "🔊", title: "Отбойный молоток", description: "Прямо под вашим окном, конечно"),
        SoundComparison(minDB: 110, maxDB: 115, emoji: "📻", title: "Сирена воздушной тревоги", description: "Учения МЧС"),
        SoundComparison(minDB: 110, maxDB: 115, emoji: "🚁", title: "Винт вертолёта", description: "Зависает прямо над вами"),
        SoundComparison(minDB: 110, maxDB: 115, emoji: "🎺", title: "Vuvuzela на стадионе", description: "Тысячи труб одновременно"),

        // 115-120 dB - физическая боль
        SoundComparison(minDB: 115, maxDB: 120, emoji: "🚁", title: "Вертолёт над головой", description: "Или очень злой сосед с газонокосилкой"),
        SoundComparison(minDB: 115, maxDB: 120, emoji: "🎤", title: "Обратная связь микрофона", description: "ПИИИИИИИИИИИИИИ"),
        SoundComparison(minDB: 115, maxDB: 120, emoji: "🚀", title: "Ракетный двигатель", description: "SpaceX запускает Falcon"),
        SoundComparison(minDB: 115, maxDB: 120, emoji: "💣", title: "Взрыв петарды рядом", description: "Прощайте, барабанные перепонки"),

        // 120-130 dB - катастрофа
        SoundComparison(minDB: 120, maxDB: 130, emoji: "✈️", title: "Взлёт самолёта", description: "Вы стоите у турбины. Зачем?"),
        SoundComparison(minDB: 120, maxDB: 130, emoji: "🚀", title: "Старт шаттла", description: "NASA запускает Space Shuttle"),
        SoundComparison(minDB: 120, maxDB: 130, emoji: "⚡", title: "Удар молнии рядом", description: "Буквально в соседнее дерево"),
        SoundComparison(minDB: 120, maxDB: 130, emoji: "🧨", title: "Мощная пиротехника", description: "Профессиональный фейерверк"),
        SoundComparison(minDB: 120, maxDB: 130, emoji: "🌋", title: "Извержение вулкана", description: "Лучше уходите отсюда"),

        // 130+ dB - конец света
        SoundComparison(minDB: 130, maxDB: 200, emoji: "💥", title: "АПОКАЛИПСИС", description: "Уберите микрофон от колонки!"),
        SoundComparison(minDB: 130, maxDB: 200, emoji: "☄️", title: "Падение метеорита", description: "Динозавры именно так вымерли"),
        SoundComparison(minDB: 130, maxDB: 200, emoji: "💀", title: "Разрыв звукового барьера", description: "F-16 пролетел над головой"),
        SoundComparison(minDB: 130, maxDB: 200, emoji: "🌪️", title: "Торнадо в 10 метрах", description: "Срочно в подвал!")
    ]
}
