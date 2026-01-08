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
            Form {
                // Date section
                Section {
                    HStack {
                        Text("Date")
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(entry.dayOfWeek), \(entry.shortDate)")
                            .foregroundColor(.secondary)
                    }
                }

                // Before contracted hours
                Section {
                    HStack {
                        Text("Hours")
                        Spacer()
                        Picker("Hours", selection: $beforeHours) {
                            ForEach(0...23, id: \.self) { hour in
                                Text("\(hour)").tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80, height: 120)
                        .clipped()

                        Text("h")
                            .foregroundColor(.secondary)

                        Picker("Minutes", selection: $beforeMinutes) {
                            ForEach([0, 15, 30, 45], id: \.self) { minute in
                                Text("\(minute)").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80, height: 120)
                        .clipped()

                        Text("m")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Before Contracted Hours")
                } footer: {
                    Text("Overtime worked before your regular shift")
                }

                // After contracted hours
                Section {
                    HStack {
                        Text("Hours")
                        Spacer()
                        Picker("Hours", selection: $afterHours) {
                            ForEach(0...23, id: \.self) { hour in
                                Text("\(hour)").tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80, height: 120)
                        .clipped()

                        Text("h")
                            .foregroundColor(.secondary)

                        Picker("Minutes", selection: $afterMinutes) {
                            ForEach([0, 15, 30, 45], id: \.self) { minute in
                                Text("\(minute)").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80, height: 120)
                        .clipped()

                        Text("m")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("After Contracted Hours")
                } footer: {
                    Text("Overtime worked after your regular shift")
                }

                // Total section
                Section {
                    HStack {
                        Text("Total Overtime")
                            .font(.headline)
                        Spacer()
                        Text(viewModel.formatHours(calculateTotal()))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Edit Overtime")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                        dismiss()
                    }
                    .fontWeight(.semibold)
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

struct DailyEntryView_Previews: PreviewProvider {
    static var previews: some View {
        DailyEntryView(entry: OvertimeEntry(date: Date()))
            .environmentObject(OvertimeViewModel())
    }
}
