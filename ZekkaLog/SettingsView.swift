//
//  SettingsView.swift
//  ZekkaLog
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("medicationTarget") private var medicationTarget: MedicationTarget = .both
    @AppStorage("intervalMinutes") private var intervalMinutes: Int = 5

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
                    ForEach([1, 2, 3, 5, 10, 15, 20, 30], id: \.self) { min in
                        Text("\(min)分").tag(min)
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
