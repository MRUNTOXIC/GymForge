import SwiftUI
import SwiftData

struct WorkoutSessionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let day: WorkoutDay
    @State private var index = 0
    @State private var completedSets = 0
    @State private var setCount = 3
    @State private var currentSetIndex = 0
    @State private var weights = Array(repeating: "", count: 8)
    @State private var reps = Array(repeating: "10", count: 8)
    @State private var showRest = false
    @State private var accumulatedVolume: Double = 0
    @State private var startDate = Date()
    @State private var sessionFinished = false
    @State private var showCancelConfirmation = false
    @State private var onTreadmillStation = false
    @State private var treadmillCompleted = false

    private var current: ExerciseInfo? {
        guard index < day.exercises.count else { return nil }
        return day.exercises[index]
    }

    private var isCurrentWeightValid: Bool {
        guard currentSetIndex < weights.count else { return false }
        let trimmed = weights[currentSetIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        guard let w = Double(trimmed), w > 0 else { return false }
        return true
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GFTheme.bg.ignoresSafeArea()

                if onTreadmillStation {
                    treadmillTransitionView
                } else if sessionFinished {
                    sessionSummaryView
                } else {
                    activeSessionContent
                }
            }
            .navigationTitle(day.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Exit") {
                        showCancelConfirmation = true
                    }
                    .foregroundStyle(.secondary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(GFTheme.accent)
                        Text("\(Int(accumulatedVolume)) kg")
                            .font(.caption.bold())
                    }
                }
            }
            .alert("Leave Workout?", isPresented: $showCancelConfirmation) {
                Button("Exit Workout", role: .destructive) {
                    dismiss()
                }
                Button("Keep Training", role: .cancel) { }
            } message: {
                Text("Your progress in this workout so far will not be completed.")
            }
            .sheet(isPresented: $showRest) {
                RestTimerView()
            }
            .onAppear {
                setupCurrentExercise()
            }
        }
    }

    private var activeSessionContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Exercise Progress Bar
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("EXERCISE \(index + 1) OF \(day.exercises.count)")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(Double(index) / Double(day.exercises.count) * 100))% Complete")
                            .font(.caption.bold())
                            .foregroundStyle(GFTheme.accent)
                    }
                    ProgressView(value: Double(index), total: Double(day.exercises.count))
                        .tint(GFTheme.accent)
                }

                if let current {
                    // Exercise Demonstration Media
                    ExerciseMediaView(exerciseID: current.id)

                    // Exercise Title & Tags
                    VStack(alignment: .leading, spacing: 6) {
                        Text(current.name)
                            .font(.title2.bold())
                        HStack {
                            MuscleTag(text: current.muscle)
                            MuscleTag(text: current.equipment)
                            Spacer()
                            Text("Target: \(current.sets) × \(current.reps)")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Active Set Card with Single Set Focus
                    if completedSets < setCount {
                        activeSetCard(current: current)
                    } else {
                        exerciseCompletedCard(current: current)
                    }
                }
            }
            .padding()
        }
    }

    private func activeSetCard(current: ExerciseInfo) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SET \(currentSetIndex + 1) OF \(setCount)")
                        .font(.title2.bold())
                        .foregroundStyle(GFTheme.accent)
                    Text("Enter weight manually • Reps pre-set from plan")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if currentSetIndex > 0 && !weights[currentSetIndex - 1].isEmpty {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("LAST SET")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.secondary)
                        Text("\(weights[currentSetIndex - 1]) kg × \(reps[currentSetIndex - 1])")
                            .font(.caption.bold())
                            .foregroundStyle(GFTheme.success)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(GFTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Text("WEIGHT (kg)")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        Text("*")
                            .font(.caption.bold())
                            .foregroundStyle(.red)
                    }
                    TextField("Enter kg", text: $weights[currentSetIndex])
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .textFieldStyle(.roundedBorder)
                        .font(.title3.bold())
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(isCurrentWeightValid ? Color.clear : Color.red.opacity(0.8), lineWidth: 1)
                        )
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("REPS")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    TextField("Reps", text: $reps[currentSetIndex])
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        .textFieldStyle(.roundedBorder)
                        .font(.title3.bold())
                }
            }

            if !isCurrentWeightValid {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Text("Weight is compulsory before logging this set.")
                        .font(.caption.bold())
                        .foregroundStyle(.orange)
                }
            }

            HStack(spacing: 12) {
                Button("− Set") {
                    if setCount > 1 {
                        setCount -= 1
                        if currentSetIndex >= setCount {
                            currentSetIndex = max(0, setCount - 1)
                        }
                    }
                }
                .buttonStyle(.bordered)
                .disabled(setCount <= 1)

                Button("+ Set") {
                    if setCount < 8 {
                        setCount += 1
                        if reps[setCount - 1].isEmpty {
                            reps[setCount - 1] = current.suggestedRepValue
                        }
                    }
                }
                .buttonStyle(.bordered)
                .disabled(setCount >= 8)

                Spacer()

                Text("Set \(currentSetIndex + 1) of \(setCount)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            PrimaryButton(
                title: isCurrentWeightValid
                    ? "LOG SET \(currentSetIndex + 1) & REST 60s"
                    : "ENTER WEIGHT TO LOG SET",
                systemImage: isCurrentWeightValid ? "stopwatch.fill" : "lock.fill",
                isEnabled: isCurrentWeightValid
            ) {
                completeActiveSet()
            }
        }
        .padding(18)
        .background(GFTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isCurrentWeightValid ? GFTheme.accent.opacity(0.35) : Color.orange.opacity(0.4), lineWidth: 1.5)
        )
    }

    @ViewBuilder
    private func exerciseCompletedCard(current: ExerciseInfo) -> some View {
        let isLastExercise = index == day.exercises.count - 1
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 48))
                .foregroundStyle(GFTheme.success)

            VStack(spacing: 4) {
                Text("\(current.name) Completed")
                    .font(.headline.bold())
                Text("All \(setCount) sets logged successfully")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            PrimaryButton(
                title: isLastExercise ? "CONTINUE TO TREADMILL" : "NEXT EXERCISE",
                systemImage: isLastExercise ? "figure.run" : "arrow.right"
            ) {
                advanceToNextExercise()
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(GFTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func setupCurrentExercise() {
        guard let current else { return }
        setCount = current.initialSetCount
        currentSetIndex = 0
        completedSets = 0
        weights = Array(repeating: "", count: 8)
        reps = Array(repeating: current.suggestedRepValue, count: 8)
    }

    private func completeActiveSet() {
        guard let current, isCurrentWeightValid else { return }
        let s = currentSetIndex
        let w = Double(weights[s].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        guard w > 0 else { return }

        let rDigits = reps[s].filter { $0.isNumber }
        let r = Int(rDigits) ?? (Int(current.suggestedRepValue) ?? 10)
        accumulatedVolume += (w * Double(r))

        let setRecord = ExerciseSet(
            exerciseID: current.id,
            sessionDate: startDate,
            setNumber: s + 1,
            weight: w,
            reps: r,
            notes: ""
        )
        context.insert(setRecord)
        try? context.save()

        completedSets += 1
        currentSetIndex += 1

        // Pre-fill next set's weight with this set's weight
        if currentSetIndex < setCount && weights[currentSetIndex].isEmpty {
            weights[currentSetIndex] = weights[s]
        }

        // Trigger compulsory 60s rest
        showRest = true
    }

    private func advanceToNextExercise() {
        if index < day.exercises.count - 1 {
            index += 1
            setupCurrentExercise()
        } else {
            // Automatically transition to compulsory Treadmill at the end of the workout
            onTreadmillStation = true
        }
    }

    private func finish() {
        let session = WorkoutSession(
            date: startDate,
            day: day.day,
            workoutName: day.name,
            durationSeconds: max(1, Int(Date().timeIntervalSince(startDate))),
            totalVolume: accumulatedVolume
        )
        context.insert(session)
        try? context.save()
        sessionFinished = true
    }

    // MARK: - Post-Workout Treadmill Transition

    private var treadmillTransitionView: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Text("WEIGHT TRAINING COMPLETE")
                        .font(.caption.bold())
                        .foregroundStyle(GFTheme.success)
                    Text("Final Station: Compulsory Treadmill")
                        .font(.title2.bold())
                    Text("Finish your workout strong with compulsory 10–20 min cardio")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 8)

                TreadmillCard(completed: $treadmillCompleted)

                Button("Finish Workout") {
                    finish()
                }
                .font(.headline)
                .foregroundStyle(GFTheme.accent)
                .padding(.top, 12)
            }
            .padding()
        }
    }

    // MARK: - Final Summary View

    private var sessionSummaryView: some View {
        VStack(spacing: 24) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 64))
                .foregroundStyle(GFTheme.accent)

            VStack(spacing: 6) {
                Text("WORKOUT COMPLETE")
                    .font(.title.bold())
                Text("\(day.name) — Routine Finished")
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 12) {
                StatCard(
                    title: "Total Volume",
                    value: "\(Int(accumulatedVolume)) kg",
                    icon: "scalemass.fill"
                )
                StatCard(
                    title: "Duration",
                    value: formatDuration(Int(Date().timeIntervalSince(startDate))),
                    icon: "clock.fill"
                )
                StatCard(
                    title: "Exercises Completed",
                    value: "\(day.exercises.count)",
                    icon: "checkmark.circle.fill"
                )
            }

            PrimaryButton(title: "FINISH & SAVE", systemImage: "checkmark") {
                dismiss()
            }
        }
        .padding()
    }

    private func formatDuration(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d min", mins, secs)
    }
}
