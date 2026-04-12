//
//  SettingsView.swift
//  ZekkaLog
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("medicationTarget") private var medicationTarget: MedicationTarget = .both

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
        }
        .navigationTitle("設定")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
