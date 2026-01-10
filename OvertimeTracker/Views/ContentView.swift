//
//  ContentView.swift
//  OvertimeTracker
//
//  Glass Dashboard design - iOS Control Center inspired
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: OvertimeViewModel
    @State private var selectedEntry: OvertimeEntry?
    @State private var showingEntrySheet = false
    @State private var animateRing = false

    // Dynamic color based on weekly overtime
    private var weeklyColor: Color {
        let total = viewModel.getCurrentWeekTotal()
        if total == 0 {
            return Color(.systemGray)
        } else if total < 5 {
            return Color(red: 0.2, green: 0.78, blue: 0.35) // Green
        } else if total < 10 {
            return Color(red: 1.0, green: 0.76, blue: 0.03) // Amber
        } else {
            return Color(red: 1.0, green: 0.27, blue: 0.23) // Red
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Mesh gradient background
                MeshGradientBackground()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Weekly total ring card
                        WeeklyTotalCard(
                            total: viewModel.getCurrentWeekTotal(),
                            weekRange: currentWeekRange(),
                            color: weeklyColor,
                            animate: animateRing,
                            formatHours: viewModel.formatHours
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                        // Section header
                        HStack {
                            Text("THIS WEEK")
                                .font(.system(size: 13, weight: .semibold, design: .default))
                                .tracking(1.5)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 8)

                        // Daily entries
                        VStack(spacing: 12) {
                            ForEach(viewModel.getCurrentWeekEntries()) { entry in
                                GlassDayCard(entry: entry, viewModel: viewModel)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedEntry = entry
                                        showingEntrySheet = true
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Overtime")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedEntry) { entry in
                DailyEntryView(entry: entry)
                    .environmentObject(viewModel)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                    animateRing = true
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
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

        return "\(formatter.string(from: adjustedWeekStart)) – \(formatter.string(from: weekEnd))"
    }
}

// MARK: - Mesh Gradient Background

struct MeshGradientBackground: View {
    var body: some View {
        ZStack {
            // Base gray gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.12, green: 0.12, blue: 0.14),
                    Color(red: 0.08, green: 0.08, blue: 0.10)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            // Subtle colored orbs for mesh effect
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.3, green: 0.5, blue: 0.9).opacity(0.15),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: -100, y: -200)

            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.6, green: 0.3, blue: 0.8).opacity(0.1),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 250
                    )
                )
                .frame(width: 500, height: 500)
                .offset(x: 150, y: 300)

            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.7, blue: 0.6).opacity(0.08),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .offset(x: 100, y: -100)
        }
    }
}

// MARK: - Weekly Total Card with Ring

struct WeeklyTotalCard: View {
    let total: Double
    let weekRange: String
    let color: Color
    let animate: Bool
    let formatHours: (Double) -> String

    private var progress: Double {
        min(total / 20.0, 1.0) // Cap at 20 hours for full ring
    }

    var body: some View {
        ZStack {
            // Glass background
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )

            VStack(spacing: 20) {
                // Ring chart
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 12)
                        .frame(width: 140, height: 140)

                    // Progress ring
                    Circle()
                        .trim(from: 0, to: animate ? progress : 0)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    color.opacity(0.6),
                                    color,
                                    color.opacity(0.8)
                                ]),
                                center: .center,
                                startAngle: .degrees(-90),
                                endAngle: .degrees(270)
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: color.opacity(0.5), radius: 8, x: 0, y: 0)

                    // Center content
                    VStack(spacing: 2) {
                        Text(formatHours(total))
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .monospacedDigit()

                        Text("TOTAL")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(1.2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.top, 8)

                // Week range
                Text(weekRange)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 4)
            }
            .padding(.vertical, 24)
        }
        .frame(height: 240)
    }
}

// MARK: - Glass Day Card

struct GlassDayCard: View {
    let entry: OvertimeEntry
    let viewModel: OvertimeViewModel

    private var isToday: Bool {
        Calendar.current.isDateInToday(entry.date)
    }

    private var dayColor: Color {
        if isToday {
            return Color(red: 1.0, green: 0.27, blue: 0.23)
        } else if entry.totalHours > 0 {
            return dynamicColor(for: entry.totalHours)
        } else {
            return Color(.systemGray)
        }
    }

    private func dynamicColor(for hours: Double) -> Color {
        if hours < 2 {
            return Color(red: 0.2, green: 0.78, blue: 0.35) // Green
        } else if hours < 4 {
            return Color(red: 1.0, green: 0.76, blue: 0.03) // Amber
        } else {
            return Color(red: 1.0, green: 0.27, blue: 0.23) // Red
        }
    }

    var body: some View {
        ZStack {
            // Glass background
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(isToday ? 0.4 : 0.15),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )

            HStack(spacing: 16) {
                // Day icon with gradient
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [dayColor.opacity(0.8), dayColor.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)

                    Image(systemName: isToday ? "calendar.circle.fill" : "calendar")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }

                // Day info
                VStack(alignment: .leading, spacing: 3) {
                    Text(entry.dayOfWeek)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)

                    Text(entry.shortDate)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()

                // Hours and gauges
                if entry.totalHours > 0 {
                    HStack(spacing: 12) {
                        // Mini gauges
                        VStack(spacing: 6) {
                            MiniGauge(
                                value: entry.beforeContractedHours,
                                maxValue: 4,
                                color: Color(red: 0.2, green: 0.78, blue: 0.35),
                                icon: "sunrise.fill"
                            )

                            MiniGauge(
                                value: entry.afterContractedHours,
                                maxValue: 4,
                                color: Color(red: 1.0, green: 0.58, blue: 0.0),
                                icon: "sunset.fill"
                            )
                        }

                        // Total hours
                        Text(viewModel.formatHours(entry.totalHours))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(dayColor)
                    }
                } else {
                    Text("—")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white.opacity(0.3))
                }

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .frame(height: 76)
    }
}

// MARK: - Mini Gauge

struct MiniGauge: View {
    let value: Double
    let maxValue: Double
    let color: Color
    let icon: String

    private var progress: Double {
        guard value > 0 else { return 0 }
        return min(value / maxValue, 1.0)
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 14)

            // Gauge bar
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 40, height: 4)

                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 40 * progress, height: 4)
            }
        }
        .opacity(value > 0 ? 1 : 0.3)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(OvertimeViewModel())
    }
}
