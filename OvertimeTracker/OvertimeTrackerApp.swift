//
//  OvertimeTrackerApp.swift
//  OvertimeTracker
//
//  Created by Claude for Postman Overtime Tracking
//

import SwiftUI

@main
struct OvertimeTrackerApp: App {
    @StateObject private var viewModel = OvertimeViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
