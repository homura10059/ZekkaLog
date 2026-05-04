//
//  SettingsView.swift
//  ZekkaLog
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("medicationTarget") private var medicationTarget: MedicationTarget = .both
    @AppStorage("intervalMinutes") private var intervalMinutes: Int = 5

    private func intervalLabel(for minutes: Int) -> String {
        minutes >= 60 ? "\(minutes / 60)時間" : "\(minutes)分"
    }

    var body: some View {
        Form {
            Section("服薬対象") {
                Picker("服薬対象", selection: $medicationTarget) {
                    ForEach(MedicationTarget.allCases, id: \.self) { target in
                        Text(target.displayName).tag(target)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            Section("インターバル時間") {
                Picker("インターバル時間", selection: $intervalMinutes) {
                    ForEach([5, 720], id: \.self) { min in
                        Text(intervalLabel(for: min)).tag(min)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
        }
        .navigationTitle("設定")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
