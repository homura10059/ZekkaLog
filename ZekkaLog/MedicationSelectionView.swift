//
//  MedicationSelectionView.swift
//  ZekkaLog
//

import SwiftUI
import SwiftData

struct MedicationSelectionView: View {
    @Query(sort: \MedicationRecord.takenAt, order: .reverse)
    private var records: [MedicationRecord]

    @AppStorage("medicationTarget") private var medicationTarget: MedicationTarget = .both
    @State private var selectedType: MedicationType? = nil

    private var todayRecordTypes: Set<String> {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return Set(
            records
                .filter { calendar.startOfDay(for: $0.takenAt) == today }
                .map { $0.typeRawValue }
        )
    }

    private var targetedTypes: [MedicationType] {
        medicationTarget.includedTypes
    }

    private func needsIntervalAfter(_ type: MedicationType) -> Bool {
        guard medicationTarget == .both else { return false }
        let otherType: MedicationType = type == .cedar ? .dustMite : .cedar
        return !todayRecordTypes.contains(otherType.rawValue)
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("今日の服薬")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 16)

            Text("服薬する薬を選んでください")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 16) {
                ForEach(targetedTypes, id: \.self) { type in
                    MedicationButton(
                        type: type,
                        isTakenToday: todayRecordTypes.contains(type.rawValue),
                        action: { selectedType = type }
                    )
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("舌下免疫療法")
        .navigationDestination(item: $selectedType) { type in
            TimerView(medicationType: type, needsInterval: needsIntervalAfter(type))
        }
    }
}

private struct MedicationButton: View {
    let type: MedicationType
    let isTakenToday: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: type.systemImage)
                    .font(.system(size: 32))
                    .frame(width: 48)

                VStack(alignment: .leading, spacing: 4) {
                    Text(type.displayName)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text(isTakenToday ? "本日服薬済み" : "未服薬")
                        .font(.caption)
                        .foregroundStyle(isTakenToday ? .green : .secondary)
                }

                Spacer()

                if isTakenToday {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title2)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isTakenToday ? Color.green.opacity(0.1) : Color(uiColor: .secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isTakenToday ? Color.green.opacity(0.4) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .disabled(isTakenToday)
    }
}

#Preview {
    NavigationStack {
        MedicationSelectionView()
    }
    .modelContainer(for: MedicationRecord.self, inMemory: true)
}
