//
//  RecordListView.swift
//  ZekkaLog
//

import SwiftUI
import SwiftData

struct RecordListView: View {
    @Query(sort: \MedicationRecord.takenAt, order: .reverse)
    private var records: [MedicationRecord]

    private var groupedRecords: [(String, [MedicationRecord])] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .full
        formatter.timeStyle = .none

        var groups: [(key: String, value: [MedicationRecord])] = []
        var seen: [String: Int] = [:]

        for record in records {
            let key = formatter.string(from: record.takenAt)
            if let index = seen[key] {
                groups[index].value.append(record)
            } else {
                seen[key] = groups.count
                groups.append((key: key, value: [record]))
            }
        }
        return groups.map { ($0.key, $0.value) }
    }

    var body: some View {
        Group {
            if records.isEmpty {
                ContentUnavailableView(
                    "服薬記録がありません",
                    systemImage: "pills",
                    description: Text("服薬タブから記録を開始してください")
                )
            } else {
                List {
                    ForEach(groupedRecords, id: \.0) { date, dayRecords in
                        Section(date) {
                            ForEach(dayRecords) { record in
                                RecordRow(record: record)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("服薬履歴")
    }
}

private struct RecordRow: View {
    let record: MedicationRecord

    private var timeText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: record.takenAt)
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: record.type.systemImage)
                .font(.title3)
                .foregroundStyle(.accent)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(record.type.displayName)
                    .font(.body)
                    .fontWeight(.medium)
                Text(timeText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        RecordListView()
    }
    .modelContainer(for: MedicationRecord.self, inMemory: true)
}
