//
//  OvertimeViewModel.swift
//  OvertimeTracker
//
//  View model for managing overtime data
//

import Foundation
import Combine

class OvertimeViewModel: ObservableObject {
    @Published var entries: [OvertimeEntry] = []

    private let storageKey = "overtimeEntries"

    init() {
        loadEntries()
    }

    // MARK: - Current Week

    func getCurrentWeekEntries() -> [OvertimeEntry] {
        let calendar = Calendar.current
        let today = Date()

        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)),
              let adjustedWeekStart = calendar.date(byAdding: .day, value: 1, to: weekStart) else {
            return []
        }

        let weekEnd = calendar.date(byAdding: .day, value: 6, to: adjustedWeekStart)!

        var weekEntries: [OvertimeEntry] = []

        for dayOffset in 0...6 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: adjustedWeekStart) {
                let normalizedDate = calendar.startOfDay(for: date)

                if let existingEntry = entries.first(where: { calendar.isDate($0.date, inSameDayAs: normalizedDate) }) {
                    weekEntries.append(existingEntry)
                } else {
                    weekEntries.append(OvertimeEntry(date: normalizedDate))
                }
            }
        }

        return weekEntries
    }

    func getCurrentWeekTotal() -> Double {
        getCurrentWeekEntries().reduce(0) { $0 + $1.totalHours }
    }

    // MARK: - CRUD Operations

    func updateEntry(_ entry: OvertimeEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
        } else {
            entries.append(entry)
        }
        saveEntries()
    }

    func deleteEntry(_ entry: OvertimeEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }

    // MARK: - Persistence

    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([OvertimeEntry].self, from: data) {
            entries = decoded
        }
    }

    // MARK: - Helper Methods

    func formatHours(_ hours: Double) -> String {
        if hours == 0 {
            return "0h"
        }

        let wholeHours = Int(hours)
        let minutes = Int((hours - Double(wholeHours)) * 60)

        if minutes == 0 {
            return "\(wholeHours)h"
        } else {
            return "\(wholeHours)h \(minutes)m"
        }
    }
}
