//
//  ContentView.swift
//  ZekkaLog
//
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

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("設定", systemImage: "gearshape.fill")
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
