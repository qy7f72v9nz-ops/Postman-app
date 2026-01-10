//
//  DailyEntryView.swift
//  OvertimeTracker
//
//  Glass Dashboard style entry view
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

    private var isToday: Bool {
        Calendar.current.isDateInToday(entry.date)
    }

    private var totalHours: Double {
        let before = Double(beforeHours) + (Double(beforeMinutes) / 60.0)
        let after = Double(afterHours) + (Double(afterMinutes) / 60.0)
        return before + after
    }

    private var dynamicColor: Color {
        if totalHours == 0 {
            return Color(.systemGray)
        } else if totalHours < 2 {
            return Color(red: 0.2, green: 0.78, blue: 0.35) // Green
        } else if totalHours < 4 {
            return Color(red: 1.0, green: 0.76, blue: 0.03) // Amber
        } else {
            return Color(red: 1.0, green: 0.27, blue: 0.23) // Red
        }
    }

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
                // Mesh gradient background
                MeshGradientBackground()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Date header card
                        dateHeaderCard
                            .padding(.top, 16)

                        // Before shift picker
                        GlassTimePickerCard(
                            title: "Before Shift",
                            subtitle: "Early morning overtime",
                            icon: "sunrise.fill",
                            iconColors: [
                                Color(red: 0.2, green: 0.78, blue: 0.35),
                                Color(red: 0.4, green: 0.85, blue: 0.45)
                            ],
                            hours: $beforeHours,
                            minutes: $beforeMinutes
                        )

                        // After shift picker
                        GlassTimePickerCard(
                            title: "After Shift",
                            subtitle: "Evening overtime",
                            icon: "sunset.fill",
                            iconColors: [
                                Color(red: 1.0, green: 0.58, blue: 0.0),
                                Color(red: 1.0, green: 0.72, blue: 0.3)
                            ],
                            hours: $afterHours,
                            minutes: $afterMinutes
                        )

                        // Total display card
                        totalCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle(entry.dayOfWeek)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 18))
                            Text("Cancel")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.red.opacity(0.9), Color.red.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        saveEntry()
                        dismiss()
                    }) {
                        HStack(spacing: 6) {
                            Text("Save")
                                .font(.system(size: 16, weight: .semibold))
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18))
                        }
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.2, green: 0.78, blue: 0.35),
                                    Color(red: 0.3, green: 0.85, blue: 0.45)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
            }
        }
    }

    // MARK: - Date Header Card

    private var dateHeaderCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )

            HStack(spacing: 16) {
                // Date icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isToday ?
                                    [Color.red.opacity(0.8), Color.red.opacity(0.5)] :
                                    [Color.blue.opacity(0.8), Color.blue.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)

                    Image(systemName: isToday ? "calendar.circle.fill" : "calendar")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.dayOfWeek)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)

                    Text(entry.shortDate)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()

                if isToday {
                    Text("TODAY")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.red.opacity(0.3))
                        )
                }
            }
            .padding(20)
        }
    }

    // MARK: - Total Card

    private var totalCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [dynamicColor.opacity(0.5), dynamicColor.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )

            VStack(spacing: 16) {
                // Ring indicator
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 8)
                        .frame(width: 100, height: 100)

                    Circle()
                        .trim(from: 0, to: min(totalHours / 8.0, 1.0))
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    dynamicColor.opacity(0.6),
                                    dynamicColor,
                                    dynamicColor.opacity(0.8)
                                ]),
                                center: .center,
                                startAngle: .degrees(-90),
                                endAngle: .degrees(270)
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: dynamicColor.opacity(0.5), radius: 6, x: 0, y: 0)
                        .animation(.easeOut(duration: 0.3), value: totalHours)

                    VStack(spacing: 0) {
                        Text(viewModel.formatHours(totalHours))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(.white)
                    }
                }

                // Label
                HStack {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [dynamicColor, dynamicColor.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    Text("TOTAL OVERTIME")
                        .font(.system(size: 13, weight: .semibold))
                        .tracking(1)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.vertical, 28)
        }
        .frame(height: 200)
    }

    private func saveEntry() {
        var updatedEntry = entry
        updatedEntry.beforeContractedHours = Double(beforeHours) + (Double(beforeMinutes) / 60.0)
        updatedEntry.afterContractedHours = Double(afterHours) + (Double(afterMinutes) / 60.0)
        viewModel.updateEntry(updatedEntry)
    }
}

// MARK: - Glass Time Picker Card

struct GlassTimePickerCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColors: [Color]
    @Binding var hours: Int
    @Binding var minutes: Int

    private var totalValue: Double {
        Double(hours) + (Double(minutes) / 60.0)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )

            VStack(spacing: 20) {
                // Header
                HStack {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: iconColors.map { $0.opacity(0.3) },
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)

                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: iconColors,
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)

                        Text(subtitle)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                    }

                    Spacer()

                    // Current value badge
                    if totalValue > 0 {
                        Text(String(format: "%.0fh %02dm", floor(totalValue), Int((totalValue.truncatingRemainder(dividingBy: 1)) * 60)))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(iconColors[0])
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(iconColors[0].opacity(0.2))
                            )
                    }
                }

                // Time pickers
                HStack(spacing: 0) {
                    Spacer()

                    // Hours
                    VStack(spacing: 6) {
                        Text("HOURS")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1)
                            .foregroundColor(.white.opacity(0.5))

                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                                .frame(width: 80, height: 120)

                            Picker("Hours", selection: $hours) {
                                ForEach(0...12, id: \.self) { hour in
                                    Text("\(hour)")
                                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .tag(hour)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 80, height: 120)
                            .clipped()
                        }
                    }

                    Text(":")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.3))
                        .padding(.horizontal, 8)
                        .padding(.top, 24)

                    // Minutes
                    VStack(spacing: 6) {
                        Text("MINUTES")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1)
                            .foregroundColor(.white.opacity(0.5))

                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                                .frame(width: 80, height: 120)

                            Picker("Minutes", selection: $minutes) {
                                ForEach(0..<60, id: \.self) { minute in
                                    Text(String(format: "%02d", minute))
                                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .tag(minute)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 80, height: 120)
                            .clipped()
                        }
                    }

                    Spacer()
                }
            }
            .padding(20)
        }
    }
}

struct DailyEntryView_Previews: PreviewProvider {
    static var previews: some View {
        DailyEntryView(entry: OvertimeEntry(date: Date()))
            .environmentObject(OvertimeViewModel())
    }
}
