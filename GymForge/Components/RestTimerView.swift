import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct RestTimerView: View {
    @Environment(\.dismiss) private var dismiss
    private let totalSeconds = 60
    @State private var seconds = 60
    @State private var running = false
    @State private var timer: Timer?

    private var progress: CGFloat {
        guard totalSeconds > 0 else { return 0 }
        return CGFloat(seconds) / CGFloat(totalSeconds)
    }

    private var formattedTime: String {
        let mins = seconds / 60
        let secs = seconds % 60
        if mins > 0 {
            return String(format: "%d:%02d", mins, secs)
        } else {
            return "\(secs)"
        }
    }

    var body: some View {
        VStack(spacing: 28) {
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                    Text("60s COMPULSORY REST")
                        .font(.caption.bold())
                }
                .foregroundStyle(GFTheme.accent)

                Text(seconds > 0 ? "Compulsory recovery before next set" : "Rest complete! Time to lift.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ZStack {
                Circle()
                    .stroke(.white.opacity(0.08), lineWidth: 18)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        seconds > 0 ? GFTheme.accent : GFTheme.success,
                        style: StrokeStyle(lineWidth: 18, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.25), value: progress)

                VStack(spacing: 6) {
                    if seconds > 0 {
                        Text(formattedTime)
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .monospacedDigit()
                        Text("seconds remaining")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 54))
                            .foregroundStyle(GFTheme.success)
                        Text("READY!")
                            .font(.title3.bold())
                            .foregroundStyle(GFTheme.success)
                    }
                }
            }
            .frame(width: 240, height: 240)

            VStack(spacing: 12) {
                if seconds > 0 {
                    HStack(spacing: 16) {
                        Button(running ? "PAUSE" : "RESUME") {
                            toggle()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(running ? .orange : GFTheme.accent)
                    }

                    Text("Compulsory rest cannot be skipped early.")
                        .font(.caption2)
                        .foregroundStyle(.secondary.opacity(0.8))
                } else {
                    Button {
                        stop()
                        dismiss()
                    } label: {
                        Text("START NEXT SET")
                            .font(.headline.bold())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(GFTheme.success)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(24)
        .presentationDetents([.medium])
        .interactiveDismissDisabled(seconds > 0)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stop()
        }
    }

    private func startTimer() {
        running = true
        NotificationManager.shared.scheduleRestTimerNotification(seconds: seconds)
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if seconds > 1 {
                seconds -= 1
            } else {
                seconds = 0
                #if canImport(UIKit)
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                #endif
                stop()
            }
        }
    }

    private func toggle() {
        if running {
            timer?.invalidate()
            timer = nil
            running = false
            NotificationManager.shared.cancelRestTimerNotification()
        } else {
            startTimer()
        }
    }

    private func stop() {
        timer?.invalidate()
        timer = nil
        running = false
        NotificationManager.shared.cancelRestTimerNotification()
    }
}
