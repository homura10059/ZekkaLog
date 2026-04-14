//
//  RecordListView.swift
//  ZekkaLog
//

import SwiftUI
import SwiftData

// MARK: - Calendar extension

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}

// MARK: - RecordListView

struct RecordListView: View {
    @Query(sort: \MedicationRecord.takenAt, order: .reverse)
    private var records: [MedicationRecord]

    @State private var displayedMonth: Date = Calendar.current.startOfMonth(for: Date())
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())

    private let calendar = Calendar.current

    // MARK: Computed: month navigation

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: displayedMonth)
    }

    // MARK: Computed: calendar grid

    /// [Date?] array, length is a multiple of 7. nil = empty cell (before/after month).
    private var calendarDays: [Date?] {
        let firstDay = displayedMonth
        let weekday = calendar.component(.weekday, from: firstDay) // Sun=1 … Sat=7
        let leadingPad = (weekday - 2 + 7) % 7 // Mon=0 … Sun=6
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstDay)!.count
        let total = ((leadingPad + daysInMonth + 6) / 7) * 7

        var cells: [Date?] = Array(repeating: nil, count: leadingPad)
        for i in 0..<daysInMonth {
            cells.append(calendar.date(byAdding: .day, value: i, to: firstDay))
        }
        while cells.count < total {
            cells.append(nil)
        }
        return cells
    }

    // MARK: Computed: records

    private var recordsInDisplayedMonth: [MedicationRecord] {
        records.filter {
            calendar.isDate($0.takenAt, equalTo: displayedMonth, toGranularity: .month)
        }
    }

    private var recordTypesByDay: [Date: Set<MedicationType>] {
        var result: [Date: Set<MedicationType>] = [:]
        for record in recordsInDisplayedMonth {
            let day = calendar.startOfDay(for: record.takenAt)
            result[day, default: []].insert(record.type)
        }
        return result
    }

    private var recordsForSelectedDate: [MedicationRecord] {
        records.filter {
            calendar.startOfDay(for: $0.takenAt) == selectedDate
        }
    }

    private var selectedDateTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: selectedDate)
    }

    // MARK: Navigation

    private func goToPreviousMonth() {
        guard let prev = calendar.date(byAdding: .month, value: -1, to: displayedMonth) else { return }
        displayedMonth = prev
        resetSelectedDate(to: prev)
    }

    private func goToNextMonth() {
        guard let next = calendar.date(byAdding: .month, value: 1, to: displayedMonth) else { return }
        displayedMonth = next
        resetSelectedDate(to: next)
    }

    private func resetSelectedDate(to month: Date) {
        let today = calendar.startOfDay(for: Date())
        if calendar.isDate(today, equalTo: month, toGranularity: .month) {
            selectedDate = today
        } else {
            selectedDate = month
        }
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                CalendarHeaderView(
                    monthTitle: monthTitle,
                    onPrevious: goToPreviousMonth,
                    onNext: goToNextMonth
                )
                .padding(.top, 8)

                WeekdayHeaderRow()

                CalendarGridView(
                    days: calendarDays,
                    recordTypesByDay: recordTypesByDay,
                    selectedDate: selectedDate,
                    today: calendar.startOfDay(for: Date()),
                    onSelect: { day in selectedDate = day }
                )
                .padding(.bottom, 8)

                Divider()

                DayRecordSection(
                    title: selectedDateTitle,
                    records: recordsForSelectedDate
                )
            }
        }
        .navigationTitle("服薬履歴")
    }
}

// MARK: - CalendarHeaderView

private struct CalendarHeaderView: View {
    let monthTitle: String
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .frame(minWidth: 44, minHeight: 44)
            }
            Spacer()
            Text(monthTitle)
                .font(.title3)
                .fontWeight(.semibold)
            Spacer()
            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .frame(minWidth: 44, minHeight: 44)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - WeekdayHeaderRow

private struct WeekdayHeaderRow: View {
    private let labels = ["月", "火", "水", "木", "金", "土", "日"]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(labels, id: \.self) { label in
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
    }
}

// MARK: - CalendarGridView

private struct CalendarGridView: View {
    let days: [Date?]
    let recordTypesByDay: [Date: Set<MedicationType>]
    let selectedDate: Date
    let today: Date
    let onSelect: (Date) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(0..<days.count, id: \.self) { i in
                if let day = days[i] {
                    CalendarDayCell(
                        day: day,
                        types: recordTypesByDay[day] ?? [],
                        isSelected: day == selectedDate,
                        isToday: day == today,
                        onTap: { onSelect(day) }
                    )
                } else {
                    Color.clear
                        .frame(height: 50)
                }
            }
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - CalendarDayCell

private struct CalendarDayCell: View {
    let day: Date
    let types: Set<MedicationType>
    let isSelected: Bool
    let isToday: Bool
    let onTap: () -> Void

    private var dayNumber: String {
        String(Calendar.current.component(.day, from: day))
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text(dayNumber)
                    .font(.body)
                    .fontWeight(isToday ? .semibold : .regular)
                    .foregroundStyle(textColor)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.accentColor : Color.clear)
                    )

                HStack(spacing: 3) {
                    ForEach(MedicationType.allCases) { type in
                        if types.contains(type) {
                            Circle()
                                .fill(dotColor(for: type))
                                .frame(width: 5, height: 5)
                        }
                    }
                }
                .frame(height: 6)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var textColor: Color {
        if isSelected { return .white }
        if isToday { return .accentColor }
        return .primary
    }

    private func dotColor(for type: MedicationType) -> Color {
        switch type {
        case .cedar: return .green
        case .dustMite: return .accentColor
        }
    }
}

// MARK: - DayRecordSection

private struct DayRecordSection: View {
    let title: String
    let records: [MedicationRecord]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.vertical, 10)

            if records.isEmpty {
                Text("この日の記録はありません")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                ForEach(records) { record in
                    RecordRow(record: record)
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                    if record.persistentModelID != records.last?.persistentModelID {
                        Divider()
                            .padding(.leading, 56)
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

// MARK: - RecordRow

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
                .foregroundStyle(.tint)
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
