//
//  ContentView.swift
//  OvertimeTracker
//
//  Main weekly overview screen
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: OvertimeViewModel
    @State private var selectedEntry: OvertimeEntry?
    @State private var showingEntrySheet = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with weekly total
                    weeklyTotalHeader

                    // Daily entries list
                    VStack(spacing: 1) {
                        ForEach(viewModel.getCurrentWeekEntries()) { entry in
                            DayRow(entry: entry)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedEntry = entry
                                    showingEntrySheet = true
                                }
                        }
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                }
                .padding(.bottom, 30)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Overtime Tracker")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedEntry) { entry in
                DailyEntryView(entry: entry)
                    .environmentObject(viewModel)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var weeklyTotalHeader: some View {
        VStack(spacing: 8) {
            Text("This Week")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(viewModel.formatHours(viewModel.getCurrentWeekTotal()))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text(currentWeekRange())
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }

    private func currentWeekRange() -> String {
        let calendar = Calendar.current
        let today = Date()

        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)),
              let adjustedWeekStart = calendar.date(byAdding: .day, value: 1, to: weekStart),
              let weekEnd = calendar.date(byAdding: .day, value: 6, to: adjustedWeekStart) else {
            return ""
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"

        return "\(formatter.string(from: adjustedWeekStart)) - \(formatter.string(from: weekEnd))"
    }
}

struct DayRow: View {
    let entry: OvertimeEntry
    @EnvironmentObject var viewModel: OvertimeViewModel

    private var isToday: Bool {
        Calendar.current.isDateInToday(entry.date)
    }

    var body: some View {
        HStack(spacing: 16) {
            // Day label
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.dayOfWeek)
                    .font(.system(size: 17, weight: isToday ? .semibold : .regular))
                    .foregroundColor(isToday ? .blue : .primary)

                Text(entry.shortDate)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Hours breakdown
            if entry.totalHours > 0 {
                VStack(alignment: .trailing, spacing: 4) {
                    if entry.beforeContractedHours > 0 {
                        HStack(spacing: 4) {
                            Text("Before:")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            Text(viewModel.formatHours(entry.beforeContractedHours))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.primary)
                        }
                    }

                    if entry.afterContractedHours > 0 {
                        HStack(spacing: 4) {
                            Text("After:")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            Text(viewModel.formatHours(entry.afterContractedHours))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.primary)
                        }
                    }
                }
            }

            // Total hours
            Text(viewModel.formatHours(entry.totalHours))
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(entry.totalHours > 0 ? .blue : .secondary)
                .frame(minWidth: 70, alignment: .trailing)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(.tertiaryLabel))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(OvertimeViewModel())
    }
}
