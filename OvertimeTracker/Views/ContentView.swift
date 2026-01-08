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
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.0, green: 0.48, blue: 1.0),
                        Color(red: 0.34, green: 0.63, blue: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header with weekly total
                        weeklyTotalHeader
                            .padding(.top, 20)

                        // Daily entries list
                        VStack(spacing: 12) {
                            ForEach(viewModel.getCurrentWeekEntries()) { entry in
                                DayRow(entry: entry)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedEntry = entry
                                        showingEntrySheet = true
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Overtime")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.clear, for: .navigationBar)
            .sheet(item: $selectedEntry) { entry in
                DailyEntryView(entry: entry)
                    .environmentObject(viewModel)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var weeklyTotalHeader: some View {
        VStack(spacing: 4) {
            Text("THIS WEEK")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .tracking(1.2)
                .foregroundColor(.white.opacity(0.8))

            Text(viewModel.formatHours(viewModel.getCurrentWeekTotal()))
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(currentWeekRange())
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
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
        HStack(spacing: 0) {
            // Colored accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(accentColor)
                .frame(width: 4)
                .padding(.vertical, 8)

            HStack(spacing: 16) {
                // Day label with icon
                HStack(spacing: 12) {
                    Image(systemName: isToday ? "calendar.circle.fill" : "calendar")
                        .font(.system(size: 24))
                        .foregroundColor(accentColor)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.dayOfWeek)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)

                        Text(entry.shortDate)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Hours display
                VStack(alignment: .trailing, spacing: 2) {
                    Text(viewModel.formatHours(entry.totalHours))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(entry.totalHours > 0 ? accentColor : Color(.systemGray3))

                    if entry.totalHours > 0 {
                        HStack(spacing: 8) {
                            if entry.beforeContractedHours > 0 {
                                HStack(spacing: 3) {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color(red: 0.2, green: 0.78, blue: 0.35))
                                    Text(viewModel.formatHours(entry.beforeContractedHours))
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                            }

                            if entry.afterContractedHours > 0 {
                                HStack(spacing: 3) {
                                    Image(systemName: "arrow.down.circle.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color(red: 1.0, green: 0.58, blue: 0.0))
                                    Text(viewModel.formatHours(entry.afterContractedHours))
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    } else {
                        Text("No overtime")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }

                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(.systemGray4))
                    .padding(.leading, 4)
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.vertical, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
    }

    private var accentColor: Color {
        if isToday {
            return Color(red: 1.0, green: 0.27, blue: 0.23)
        } else if entry.totalHours > 0 {
            return Color(red: 0.0, green: 0.48, blue: 1.0)
        } else {
            return Color(.systemGray4)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(OvertimeViewModel())
    }
}
