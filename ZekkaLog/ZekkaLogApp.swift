//
//  ZekkaLogApp.swift
//  ZekkaLog
//
//

import SwiftUI
import SwiftData

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

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
