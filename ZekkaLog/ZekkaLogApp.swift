//
//  ZekkaLogApp.swift
//  ZekkaLog
//
//  Created by 大村勇人 on 2026/02/23.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct ZekkaLogApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MedicationRecord.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
