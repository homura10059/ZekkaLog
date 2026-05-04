//
//  TimerView.swift
//  ZekkaLog
//

import SwiftUI
import SwiftData
import UserNotifications

struct TimerView: View {
    let medicationType: MedicationType
    let needsInterval: Bool

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    @State private var timeRemaining: Int = 60
    @State private var isMedicationCompleted = false
    @State private var isIntervalCompleted = false
    @State private var isCancelled = false
    @State private var isInIntervalPhase = false

    @AppStorage("intervalMinutes") private var intervalMinutes: Int = 5

    @State private var medicationNotificationId = UUID().uuidString
    @State private var intervalNotificationId = UUID().uuidString
    @State private var medicationEndDate: Date? = nil
    @State private var intervalEndDate: Date? = nil

    private let totalMedicationSeconds = 60
    private var totalIntervalSeconds: Int { intervalMinutes * 60 }

    private var formattedTimeRemaining: String {
        if timeRemaining >= 3600 {
            let h = timeRemaining / 3600
            let m = (timeRemaining % 3600) / 60
            let s = timeRemaining % 60
            return String(format: "%d:%02d:%02d", h, m, s)
        } else if timeRemaining >= 60 {
            let m = timeRemaining / 60
            let s = timeRemaining % 60
            return String(format: "%d:%02d", m, s)
        } else {
            return "\(timeRemaining)"
        }
    }

    private var timeUnit: String {
        timeRemaining < 60 ? "秒" : ""
    }

    private var currentTotalSeconds: Int {
        isInIntervalPhase ? totalIntervalSeconds : totalMedicationSeconds
    }

    var body: some View {
        VStack(spacing: 40) {
            if isInIntervalPhase {
                VStack(spacing: 4) {
                    Text(medicationType.displayName)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("インターバル")
                        .font(.title)
                        .fontWeight(.bold)
                }
            } else {
                Text(medicationType.displayName)
                    .font(.title)
                    .fontWeight(.bold)
            }

            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 16)

                let isCurrentPhaseCompleted = isInIntervalPhase ? isIntervalCompleted : isMedicationCompleted
                Circle()
                    .trim(from: 0, to: CGFloat(timeRemaining) / CGFloat(currentTotalSeconds))
                    .stroke(
                        isCurrentPhaseCompleted ? Color.green : Color.accentColor,
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: timeRemaining)

                VStack(spacing: 8) {
                    if isCurrentPhaseCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(.largeTitle))
                            .imageScale(.large)
                            .foregroundStyle(.green)
                    } else {
                        Text(formattedTimeRemaining)
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.thin)
                            .monospacedDigit()
                        if !timeUnit.isEmpty {
                            Text(timeUnit)
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .frame(width: 240, height: 240)

            if isInIntervalPhase {
                if isIntervalCompleted {
                    Text("インターバル完了！")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                    Text("次の薬を服薬できます")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button("閉じる") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                } else {
                    Text("次の薬の服薬まで\nお待ちください")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Button("キャンセル") {
                        isCancelled = true
                        dismiss()
                    }
                    .foregroundStyle(.red)
                }
            } else {
                if isMedicationCompleted && !needsInterval {
                    Text("服薬完了！")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)

                    Button("閉じる") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                } else if !isMedicationCompleted {
                    Text("薬を舌の下に置いて、\n溶けるまでそのままにしてください")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Button("キャンセル") {
                        isCancelled = true
                        dismiss()
                    }
                    .foregroundStyle(.red)
                }
            }
        }
        .padding(32)
        .navigationTitle(isInIntervalPhase ? "インターバルタイマー" : "服薬タイマー")
        .navigationBarBackButtonHidden(true)
        .task(id: isInIntervalPhase) {
            if isInIntervalPhase {
                await runIntervalTimer()
            } else {
                await runMedicationTimer()
            }
        }
        .onDisappear {
            if isCancelled {
                if isInIntervalPhase {
                    cancelIntervalNotification()
                } else {
                    cancelMedicationNotification()
                }
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            if isInIntervalPhase {
                guard !isIntervalCompleted, let deadline = intervalEndDate else { return }
                let remaining = max(0, Int(deadline.timeIntervalSince(Date())))
                if remaining == 0 {
                    completeIntervalTimer()
                } else {
                    timeRemaining = remaining
                }
            } else {
                guard !isMedicationCompleted, let deadline = medicationEndDate else { return }
                let remaining = max(0, Int(deadline.timeIntervalSince(Date())))
                if remaining == 0 {
                    completeMedicationTimer()
                } else {
                    timeRemaining = remaining
                }
            }
        }
    }

    private func runMedicationTimer() async {
        let deadline: Date
        if let existing = medicationEndDate {
            deadline = existing
        } else {
            deadline = Date().addingTimeInterval(TimeInterval(totalMedicationSeconds))
            medicationEndDate = deadline
            scheduleMedicationNotification()
        }

        let initialRemaining = max(0, Int(deadline.timeIntervalSince(Date())))
        timeRemaining = initialRemaining
        if initialRemaining == 0 {
            completeMedicationTimer()
            return
        }

        while true {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            let remaining = max(0, Int(deadline.timeIntervalSince(Date())))
            timeRemaining = remaining
            if remaining == 0 { break }
        }
        completeMedicationTimer()
    }

    private func runIntervalTimer() async {
        let deadline: Date
        if let existing = intervalEndDate {
            deadline = existing
        } else {
            // フォールバック: completeMedicationTimer() が先に intervalEndDate を設定するため通常は通らない
            deadline = Date().addingTimeInterval(TimeInterval(totalIntervalSeconds))
            intervalEndDate = deadline
            scheduleIntervalNotification()
        }

        let initialRemaining = max(0, Int(deadline.timeIntervalSince(Date())))
        timeRemaining = initialRemaining
        if initialRemaining == 0 {
            completeIntervalTimer()
            return
        }

        while true {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            let remaining = max(0, Int(deadline.timeIntervalSince(Date())))
            timeRemaining = remaining
            if remaining == 0 { break }
        }
        completeIntervalTimer()
    }

    private func completeMedicationTimer() {
        guard !isMedicationCompleted else { return }
        isMedicationCompleted = true
        modelContext.insert(MedicationRecord(type: medicationType))
        if needsInterval {
            let medEnd = medicationEndDate ?? Date()
            let deadline = medEnd.addingTimeInterval(TimeInterval(totalIntervalSeconds))
            intervalEndDate = deadline
            scheduleIntervalNotification()
            timeRemaining = max(0, Int(deadline.timeIntervalSince(Date())))
            isInIntervalPhase = true
        }
    }

    private func completeIntervalTimer() {
        guard !isIntervalCompleted else { return }
        isIntervalCompleted = true
    }

    private func scheduleMedicationNotification() {
        let content = UNMutableNotificationContent()
        content.title = "服薬完了"
        content.body = "\(medicationType.displayName) の服薬が完了しました"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(totalMedicationSeconds), repeats: false)
        let request = UNNotificationRequest(identifier: medicationNotificationId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func cancelMedicationNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [medicationNotificationId])
    }

    private func scheduleIntervalNotification() {
        guard let deadline = intervalEndDate else { return }
        let delay = max(1, deadline.timeIntervalSince(Date()))

        let content = UNMutableNotificationContent()
        content.title = "インターバル完了"
        content.body = "次の薬を服薬できます"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: intervalNotificationId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func cancelIntervalNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [intervalNotificationId])
    }
}

#Preview {
    NavigationStack {
        TimerView(medicationType: .cedar, needsInterval: false)
    }
    .modelContainer(for: MedicationRecord.self, inMemory: true)
}
