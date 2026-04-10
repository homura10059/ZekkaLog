//
//  TimerView.swift
//  ZekkaLog
//

import SwiftUI
import SwiftData
import UserNotifications

struct TimerView: View {
    let medicationType: MedicationType

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    @State private var timeRemaining: Int = 60
    @State private var isCompleted = false
    @State private var notificationRequestId = UUID().uuidString
    @State private var endDate: Date? = nil

    private let totalSeconds = 60

    var body: some View {
        VStack(spacing: 40) {
            Text(medicationType.displayName)
                .font(.title)
                .fontWeight(.bold)

            ZStack {
                Circle()
                    .stroke(Color(uiColor: .systemGray5), lineWidth: 16)

                Circle()
                    .trim(from: 0, to: CGFloat(timeRemaining) / CGFloat(totalSeconds))
                    .stroke(
                        isCompleted ? Color.green : Color.accentColor,
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: timeRemaining)

                VStack(spacing: 8) {
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.green)
                    } else {
                        Text("\(timeRemaining)")
                            .font(.system(size: 64, weight: .thin, design: .rounded))
                        Text("秒")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(width: 240, height: 240)

            if isCompleted {
                Text("服薬完了！")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)

                Button("閉じる") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            } else {
                Text("薬を舌の下に置いて、\n溶けるまでそのままにしてください")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button("キャンセル") {
                    dismiss()
                }
                .foregroundStyle(.red)
            }
        }
        .padding(32)
        .navigationTitle("服薬タイマー")
        .navigationBarBackButtonHidden(true)
        .task {
            scheduleNotification()
            await runTimer()
        }
        .onDisappear {
            if !isCompleted {
                cancelNotification()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active, !isCompleted, let deadline = endDate else { return }
            let remaining = max(0, Int(deadline.timeIntervalSince(Date())))
            if remaining == 0 {
                completeTimer()
            } else {
                timeRemaining = remaining
            }
        }
    }

    private func runTimer() async {
        let deadline = Date().addingTimeInterval(TimeInterval(totalSeconds))
        endDate = deadline

        while true {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            let remaining = max(0, Int(deadline.timeIntervalSince(Date())))
            timeRemaining = remaining
            if remaining == 0 { break }
        }
        completeTimer()
    }

    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "服薬完了"
        content.body = "\(medicationType.displayName) の服薬が完了しました"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(totalSeconds), repeats: false)
        let request = UNNotificationRequest(identifier: notificationRequestId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationRequestId])
    }

    private func completeTimer() {
        guard !isCompleted else { return }
        isCompleted = true
        modelContext.insert(MedicationRecord(type: medicationType))
    }
}

#Preview {
    NavigationStack {
        TimerView(medicationType: .cedar)
    }
    .modelContainer(for: MedicationRecord.self, inMemory: true)
}
