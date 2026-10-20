import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

struct TreadmillCard: View {
    @Binding var completed: Bool
    @Environment(\.modelContext) private var context

    @State private var duration = "20:00"
    @State private var distance = "2.1"
    @State private var speed = "6.3"
    @State private var incline = "8"
    @State private var calories = "180"

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Header
            HStack {
                Label("Treadmill", systemImage: "figure.run")
                    .font(.headline.bold())

                Spacer()

                Text("DAILY")
                    .font(.caption.bold())
                    .foregroundStyle(GFTheme.accent)
            }

            Text("Your everyday cardio requirement")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // First row
            HStack(spacing: 10) {
                field("Duration", text: $duration, keyboard: .numbersAndPunctuation)
                field("Distance (km)", text: $distance, keyboard: .decimalPad)
                field("Speed (km/h)", text: $speed, keyboard: .decimalPad)
            }

            // Second row
            HStack(spacing: 10) {
                field("Incline %", text: $incline, keyboard: .decimalPad)
                field("Calories", text: $calories, keyboard: .numberPad)

                Spacer()
            }

            // Complete button
            PrimaryButton(
                title: completed
                    ? "✓ DAILY TREADMILL COMPLETE"
                    : "COMPLETE TREADMILL",
                systemImage: completed
                    ? "checkmark"
                    : "figure.run"
            ) {
                logTreadmill()
            }
        }
        .gfCard()
    }

    private func logTreadmill() {
        completed = true

        let durationSecs: Int = {
            let parts = duration.split(separator: ":").compactMap { Int($0) }
            if parts.count == 2 {
                return (parts[0] * 60) + parts[1]
            } else if let mins = Int(duration) {
                return mins * 60
            }
            return 1200
        }()

        let session = TreadmillSession(
            date: .now,
            durationSeconds: durationSecs,
            distanceKM: Double(distance) ?? 0,
            speedKPH: Double(speed) ?? 0,
            incline: Double(incline) ?? 0,
            calories: Double(calories) ?? 0,
            completed: true
        )
        context.insert(session)
        try? context.save()

        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }

    @ViewBuilder
    private func field(
        _ title: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField("0", text: text)
                #if os(iOS)
                .keyboardType(keyboard)
                #endif
                .textFieldStyle(.roundedBorder)
        }
        .frame(maxWidth: .infinity)
    }
}
