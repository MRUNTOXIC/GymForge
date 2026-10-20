import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]
    @Query(sort: \TreadmillSession.date, order: .reverse) private var treadmills: [TreadmillSession]

    private var today: WorkoutDay { WorkoutCatalog.day() }

    private var isWorkoutDoneToday: Bool {
        sessions.contains { Calendar.current.isDateInToday($0.date) && $0.completed }
    }

    private var isTreadmillDoneToday: Bool {
        treadmills.contains { Calendar.current.isDateInToday($0.date) && $0.completed }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Routine Header
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(today.day)
                            .font(.caption.bold())
                            .foregroundStyle(GFTheme.accent)

                        Spacer()

                        if isWorkoutDoneToday {
                            Label("COMPLETED", systemImage: "checkmark.circle.fill")
                                .font(.caption.bold())
                                .foregroundStyle(GFTheme.success)
                        } else {
                            Text("60s Rest Compulsory")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Text(today.name)
                        .font(.largeTitle.bold())

                    Text(today.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Set-by-Set Routine Sequence
                VStack(alignment: .leading, spacing: 10) {
                    Text("TODAY'S SET-BY-SET SEQUENCE")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)

                    VStack(spacing: 8) {
                        // Exercise sequence
                        ForEach(Array(today.exercises.enumerated()), id: \.element.id) { idx, ex in
                            HStack(spacing: 12) {
                                Text("\(idx + 1)")
                                    .font(.caption.bold())
                                    .foregroundStyle(GFTheme.accent)
                                    .frame(width: 24, height: 24)
                                    .background(GFTheme.accent.opacity(0.12))
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(ex.name)
                                        .font(.subheadline.bold())

                                    Text("\(ex.sets) sets × \(ex.reps) reps • \(ex.muscle)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text("60s Rest")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(GFTheme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Final Step: Treadmill (Compulsory at the end of the workout)
                        HStack(spacing: 12) {
                            Image(systemName: "figure.run")
                                .font(.caption.bold())
                                .foregroundStyle(GFTheme.accent)
                                .frame(width: 24, height: 24)
                                .background(GFTheme.accent.opacity(0.15))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Final Station: Treadmill")
                                    .font(.subheadline.bold())

                                Text(today.isRecovery ? "Recovery Treadmill • Easy/Light" : "Post-Workout Cardio • Cooldown")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text("COMPULSORY")
                                .font(.caption2.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(GFTheme.accent.opacity(0.15))
                                .foregroundStyle(GFTheme.accent)
                                .clipShape(Capsule())
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(GFTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(GFTheme.accent.opacity(0.3), lineWidth: 1)
                        )
                    }
                }

                // Single Action to Launch Routine
                NavigationLink {
                    WorkoutSessionView(day: today)
                } label: {
                    HStack {
                        Spacer()
                        Label(
                            isWorkoutDoneToday ? "LOG ROUTINE AGAIN" : (today.isRecovery ? "START RECOVERY TREADMILL" : "START TODAY'S ROUTINE"),
                            systemImage: isWorkoutDoneToday ? "arrow.clockwise" : "play.fill"
                        )
                        .font(.headline.bold())
                        Spacer()
                    }
                    .padding()
                    .background(isWorkoutDoneToday ? GFTheme.card : GFTheme.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isWorkoutDoneToday ? GFTheme.success : .clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            .padding()
        }
        .background(GFTheme.bg)
        .navigationTitle("Today")
    }
}
