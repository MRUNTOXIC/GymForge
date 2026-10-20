import SwiftUI
import SwiftData

struct ProgressViewScreen: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \BodyMeasurement.date, order: .reverse) private var measurements: [BodyMeasurement]
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]
    @Query(sort: \TreadmillSession.date, order: .reverse) private var treadmills: [TreadmillSession]
    @Query private var profiles: [UserProfile]

    @State private var weight = ""
    @State private var waist = ""

    private var streakDays: Int {
        var streak = 0
        for session in sessions {
            if session.completed {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }

    private var totalVolumeKG: Int {
        Int(sessions.reduce(0) { $0 + $1.totalVolume })
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Your progress, locally tracked.")
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatCard(
                        title: "Workout streak",
                        value: "\(streakDays) days",
                        icon: "flame.fill"
                    )
                    StatCard(
                        title: "Treadmill sessions",
                        value: "\(treadmills.filter { $0.completed }.count)",
                        icon: "figure.run"
                    )
                    StatCard(
                        title: "Workouts logged",
                        value: "\(sessions.filter { $0.completed }.count)",
                        icon: "calendar"
                    )
                    StatCard(
                        title: "Total volume",
                        value: "\(totalVolumeKG) kg",
                        icon: "chart.bar.fill"
                    )
                }

                // Body measurement entry
                VStack(alignment: .leading, spacing: 12) {
                    Text("LOG BODY MEASUREMENTS")
                        .font(.headline)

                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Weight (kg)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            TextField("e.g. 94.5", text: $weight)
                                #if os(iOS)
                                .keyboardType(.decimalPad)
                                #endif
                                .textFieldStyle(.roundedBorder)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Waist (cm, optional)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            TextField("e.g. 86.0", text: $waist)
                                #if os(iOS)
                                .keyboardType(.decimalPad)
                                #endif
                                .textFieldStyle(.roundedBorder)
                        }
                    }

                    Button("Add Measurement") {
                        addMeasurement()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(GFTheme.accent)
                    .disabled(Double(weight.trimmingCharacters(in: .whitespaces)) == nil)
                }
                .gfCard()

                // Weight history
                VStack(alignment: .leading, spacing: 12) {
                    Text("WEIGHT HISTORY")
                        .font(.headline)

                    if measurements.isEmpty {
                        Text("No measurements recorded yet. Log your weight above to track changes over time.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(measurements) { m in
                            HStack {
                                Text(m.date, style: .date)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                if let waistVal = m.waistCM {
                                    Text("• Waist \(waistVal, specifier: "%.1f") cm")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }

                                Spacer()

                                Text("\(m.weightKG, specifier: "%.1f") kg")
                                    .font(.subheadline.bold())

                                Button {
                                    deleteMeasurement(m)
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.caption)
                                        .foregroundStyle(.red.opacity(0.7))
                                }
                                .buttonStyle(.borderless)
                                .padding(.leading, 8)
                            }
                            .padding(.vertical, 4)

                            if m.id != measurements.last?.id {
                                Divider()
                            }
                        }
                    }
                }
                .gfCard()
            }
            .padding()
        }
        .background(GFTheme.bg)
        .navigationTitle("Progress")
    }

    private func addMeasurement() {
        guard let w = Double(weight.trimmingCharacters(in: .whitespaces)) else { return }
        let waistVal = Double(waist.trimmingCharacters(in: .whitespaces))
        let measurement = BodyMeasurement(date: .now, weightKG: w, waistCM: waistVal)
        context.insert(measurement)

        if let profile = profiles.first {
            profile.weightKG = w
        }

        try? context.save()
        weight = ""
        waist = ""
    }

    private func deleteMeasurement(_ measurement: BodyMeasurement) {
        context.delete(measurement)
        try? context.save()
    }
}
