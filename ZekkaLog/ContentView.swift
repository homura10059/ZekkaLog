//
//  ContentView.swift
//  ZekkaLog
//
//  Created by 大村勇人 on 2026/02/23.
//

import SwiftUI
import SwiftData
import UserNotifications

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                MedicationSelectionView()
            }
            .tabItem {
                Label("服薬", systemImage: "pills.fill")
            }

            NavigationStack {
                RecordListView()
            }
            .tabItem {
                Label("履歴", systemImage: "list.bullet")
            }
        }
        .task {
            _ = try? await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: MedicationRecord.self, inMemory: true)
}
