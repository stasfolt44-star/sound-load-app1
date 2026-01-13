//
//  HistoryManager.swift
//  Sound Level Meter
//
//  Менеджер для сохранения и загрузки истории измерений
//

import Foundation
import Combine

@MainActor
final class HistoryManager: ObservableObject {

    static let shared = HistoryManager()

    @Published private(set) var sessions: [MeasurementSession] = []

    private let storageKey = "measurement_sessions"
    private let maxSessions = 100 // Максимум сохранённых сессий

    private init() {
        loadSessions()
    }

    // MARK: - Public Methods

    func saveSession(_ session: MeasurementSession) {
        sessions.insert(session, at: 0) // Новые сверху

        // Ограничиваем количество сохранённых сессий
        if sessions.count > maxSessions {
            sessions = Array(sessions.prefix(maxSessions))
        }

        persistSessions()
    }

    func deleteSession(_ session: MeasurementSession) {
        sessions.removeAll { $0.id == session.id }
        persistSessions()
    }

    func deleteAllSessions() {
        sessions.removeAll()
        persistSessions()
    }

    func getSession(by id: UUID) -> MeasurementSession? {
        return sessions.first { $0.id == id }
    }

    // MARK: - Private Methods

    private func loadSessions() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            sessions = try decoder.decode([MeasurementSession].self, from: data)
        } catch {
            print("Failed to load sessions: \(error)")
            sessions = []
        }
    }

    private func persistSessions() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(sessions)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save sessions: \(error)")
        }
    }
}
