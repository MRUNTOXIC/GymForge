import SwiftUI

struct WorkoutView: View {
    private var today: WorkoutDay { WorkoutCatalog.day() }

    var body: some View {
        List {
            ForEach(WorkoutCatalog.days) { day in
                NavigationLink {
                    WorkoutDayDetailView(day: day)
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(day.day)
                                .font(.caption.bold())
                                .foregroundStyle(GFTheme.accent)

                            if day.id == today.id {
                                Text("TODAY")
                                    .font(.system(size: 10, weight: .bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(GFTheme.accent.opacity(0.2))
                                    .foregroundStyle(GFTheme.accent)
                                    .clipShape(Capsule())
                            }

                            Spacer()

                            Text("Treadmill • Daily")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Text(day.name)
                            .font(.headline)

                        Text(day.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(day.isRecovery ? "Active Recovery" : "\(day.exercises.count) exercises")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(GFTheme.bg)
        .navigationTitle("Workout Plan")
    }
}

struct WorkoutDayDetailView: View {
    let day: WorkoutDay
    @State private var treadmillCompleted = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(day.subtitle)
                    .foregroundStyle(.secondary)

                ForEach(day.exercises) { exercise in
                    ExerciseCard(exercise: exercise)
                }

                if day.id == "wednesday" {
                    cardioCircuit
                }

                TreadmillCard(completed: $treadmillCompleted)

                NavigationLink {
                    WorkoutSessionView(day: day)
                } label: {
                    Text(day.isRecovery ? "START RECOVERY" : "START WORKOUT")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(GFTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .font(.headline.bold())
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .background(GFTheme.bg)
        .navigationTitle(day.name)
    }

    private var cardioCircuit: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CARDIO CIRCUIT")
                .font(.headline)
            Text("Jumping Jacks 40s • Mountain Climbers 30s • High Knees 30s • Bodyweight Squats 40s • Rest 60s • 3–4 rounds")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .gfCard()
    }
}
