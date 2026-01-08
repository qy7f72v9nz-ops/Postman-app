//
//  OvertimeEntry.swift
//  OvertimeTracker
//
//  Data model for daily overtime entries
//

import Foundation

struct OvertimeEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    var beforeContractedHours: Double  // Hours worked before contracted time
    var afterContractedHours: Double   // Hours worked after contracted time

    init(id: UUID = UUID(), date: Date, beforeContractedHours: Double = 0, afterContractedHours: Double = 0) {
        self.id = id
        self.date = date
        self.beforeContractedHours = beforeContractedHours
        self.afterContractedHours = afterContractedHours
    }

    var totalHours: Double {
        beforeContractedHours + afterContractedHours
    }

    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

struct WeekData: Identifiable {
    let id = UUID()
    let startDate: Date
    let endDate: Date
    var entries: [OvertimeEntry]

    var weekTotal: Double {
        entries.reduce(0) { $0 + $1.totalHours }
    }

    var weekLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}
