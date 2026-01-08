//
//  DailyEntryView.swift
//  OvertimeTracker
//
//  View for editing daily overtime entries
//

import SwiftUI

struct DailyEntryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: OvertimeViewModel

    let entry: OvertimeEntry

    @State private var beforeHours: Int = 0
    @State private var beforeMinutes: Int = 0
    @State private var afterHours: Int = 0
    @State private var afterMinutes: Int = 0

    init(entry: OvertimeEntry) {
        self.entry = entry

        _beforeHours = State(initialValue: Int(entry.beforeContractedHours))
        _beforeMinutes = State(initialValue: Int((entry.beforeContractedHours - Double(Int(entry.beforeContractedHours))) * 60))

        _afterHours = State(initialValue: Int(entry.afterContractedHours))
        _afterMinutes = State(initialValue: Int((entry.afterContractedHours - Double(Int(entry.afterContractedHours))) * 60))
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Date header card
                        VStack(spacing: 8) {
                            Image(systemName: Calendar.current.isDateInToday(entry.date) ? "calendar.circle.fill" : "calendar")
                                .font(.system(size: 40))
                                .foregroundColor(Calendar.current.isDateInToday(entry.date) ?
                                    Color(red: 1.0, green: 0.27, blue: 0.23) :
                                    Color(red: 0.0, green: 0.48, blue: 1.0))

                            Text(entry.dayOfWeek)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)

                            Text(entry.shortDate)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        // Before contracted hours card
                        TimePickerCard(
                            title: "Before Shift",
                            icon: "arrow.up.circle.fill",
                            iconColor: Color(red: 0.2, green: 0.78, blue: 0.35),
                            description: "Overtime before your regular shift",
                            hours: $beforeHours,
                            minutes: $beforeMinutes
                        )

                        // After contracted hours card
                        TimePickerCard(
                            title: "After Shift",
                            icon: "arrow.down.circle.fill",
                            iconColor: Color(red: 1.0, green: 0.58, blue: 0.0),
                            description: "Overtime after your regular shift",
                            hours: $afterHours,
                            minutes: $afterMinutes
                        )

                        // Total card
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))

                                Text("Total Overtime")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)

                                Spacer()
                            }

                            Text(viewModel.formatHours(calculateTotal()))
                                .font(.system(size: 52, weight: .bold, design: .rounded))
                                .foregroundColor(calculateTotal() > 0 ?
                                    Color(red: 0.0, green: 0.48, blue: 1.0) :
                                    Color(.systemGray3))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Edit Overtime")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                            Text("Cancel")
                        }
                        .foregroundColor(.red)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        saveEntry()
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Text("Save")
                            Image(systemName: "checkmark.circle.fill")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.2, green: 0.78, blue: 0.35))
                    }
                }
            }
        }
    }

    private func calculateTotal() -> Double {
        let before = Double(beforeHours) + (Double(beforeMinutes) / 60.0)
        let after = Double(afterHours) + (Double(afterMinutes) / 60.0)
        return before + after
    }

    private func saveEntry() {
        var updatedEntry = entry
        updatedEntry.beforeContractedHours = Double(beforeHours) + (Double(beforeMinutes) / 60.0)
        updatedEntry.afterContractedHours = Double(afterHours) + (Double(afterMinutes) / 60.0)
        viewModel.updateEntry(updatedEntry)
    }
}

struct TimePickerCard: View {
    let title: String
    let icon: String
    let iconColor: Color
    let description: String
    @Binding var hours: Int
    @Binding var minutes: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)

                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()
            }

            Text(description)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.top, -8)

            // Time pickers
            HStack(spacing: 8) {
                Spacer()

                // Hours picker
                VStack(spacing: 4) {
                    Text("HOURS")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)

                    Picker("Hours", selection: $hours) {
                        ForEach(0...23, id: \.self) { hour in
                            Text("\(hour)")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .tag(hour)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 70, height: 120)
                    .clipped()
                }

                Text(":")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.secondary)
                    .padding(.top, 20)

                // Minutes picker
                VStack(spacing: 4) {
                    Text("MINUTES")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)

                    Picker("Minutes", selection: $minutes) {
                        ForEach(0..<60, id: \.self) { minute in
                            Text(String(format: "%02d", minute))
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .tag(minute)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 70, height: 120)
                    .clipped()
                }

                Spacer()
            }
            .padding(.vertical, 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
    }
}

struct DailyEntryView_Previews: PreviewProvider {
    static var previews: some View {
        DailyEntryView(entry: OvertimeEntry(date: Date()))
            .environmentObject(OvertimeViewModel())
    }
}
