import SwiftUI
import SwiftData

struct ExerciseLibraryView: View {
    @State private var query = ""
    @State private var selectedMuscle: String? = nil
    @State private var selectedExercise: ExerciseInfo? = nil

    private var filteredExercises: [ExerciseInfo] {
        var list = WorkoutCatalog.allExercises
        if let selectedMuscle {
            list = list.filter { $0.muscle == selectedMuscle }
        }
        if !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            list = list.filter {
                $0.name.localizedCaseInsensitiveContains(query) ||
                $0.muscle.localizedCaseInsensitiveContains(query) ||
                $0.equipment.localizedCaseInsensitiveContains(query)
            }
        }
        return list
    }

    private let muscleGroups = ["Chest", "Back", "Legs", "Shoulders", "Arms", "Abs", "Cardio"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button(action: { selectedMuscle = nil }) {
                            Text("All")
                                .font(.caption.bold())
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(selectedMuscle == nil ? GFTheme.accent : GFTheme.card)
                                .foregroundStyle(selectedMuscle == nil ? .white : .primary)
                                .clipShape(Capsule())
                        }

                        ForEach(muscleGroups, id: \.self) { muscle in
                            Button(action: {
                                selectedMuscle = (selectedMuscle == muscle ? nil : muscle)
                            }) {
                                Text(muscle)
                                    .font(.caption.bold())
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(selectedMuscle == muscle ? GFTheme.accent : GFTheme.card)
                                    .foregroundStyle(selectedMuscle == muscle ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }

                // Exercise List
                List(filteredExercises) { exercise in
                    Button(action: {
                        selectedExercise = exercise
                    }) {
                        HStack(spacing: 14) {
                            Circle()
                                .fill(GFTheme.accent.opacity(0.15))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: "dumbbell.fill")
                                        .foregroundStyle(GFTheme.accent)
                                        .font(.subheadline)
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(exercise.name)
                                    .font(.body.bold())
                                    .foregroundStyle(.primary)

                                HStack(spacing: 6) {
                                    Text(exercise.muscle)
                                        .font(.caption2.bold())
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(GFTheme.accent.opacity(0.12))
                                        .foregroundStyle(GFTheme.accent)
                                        .clipShape(Capsule())

                                    Text(exercise.equipment)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            Text("\(exercise.sets) × \(exercise.reps)")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(GFTheme.card)
                }
                .scrollContentBackground(.hidden)
                .background(GFTheme.bg)
            }
            .background(GFTheme.bg)
            .navigationTitle("Exercise Library")
            .searchable(text: $query, prompt: "Search exercises, muscle, equipment")
            .sheet(item: $selectedExercise) { exercise in
                NavigationStack {
                    ExerciseDetailView(exercise: exercise)
                }
            }
        }
    }
}

struct ExerciseDetailView: View {
    let exercise: ExerciseInfo
    @Environment(\.dismiss) private var dismiss
    @Query private var previousSets: [ExerciseSet]
    @State private var showLogSheet = false

    private var filteredSets: [ExerciseSet] {
        previousSets.filter { $0.exerciseID == exercise.id }
    }

    private var lastRecordedSet: ExerciseSet? {
        filteredSets.sorted(by: { $0.sessionDate > $1.sessionDate }).first
    }

    private var localProgressionGuidance: String {
        guard let last = lastRecordedSet else {
            return "No previous logs yet. Start with a conservative weight where you can achieve \(exercise.reps) reps with perfect form."
        }
        let targetReps = Int(exercise.reps.filter { $0.isNumber }) ?? 10
        if last.reps >= targetReps && last.weight > 0 {
            return "Target reps achieved on last session (\(Int(last.weight)) kg × \(last.reps)). Consider increasing the weight slightly next session."
        } else if last.reps < max(6, targetReps - 2) {
            return "Reps were below target last session (\(Int(last.weight)) kg × \(last.reps)). Try the same weight next session to build volume."
        } else {
            return "Good consistency (\(Int(last.weight)) kg × \(last.reps)). Try to maintain your current weight and focus on maximum control."
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Media / Visual
                ExerciseMediaView(exerciseID: exercise.id)

                // Title & Badges
                VStack(alignment: .leading, spacing: 8) {
                    Text(exercise.name)
                        .font(.title.bold())

                    HStack(spacing: 8) {
                        MuscleTag(text: exercise.muscle)
                        MuscleTag(text: exercise.equipment)
                        if !exercise.secondary.isEmpty {
                            Text(exercise.secondary)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.08))
                                .clipShape(Capsule())
                        }
                    }
                }

                // Prescribed Sets & Reps
                HStack(spacing: 16) {
                    StatCard(title: "Prescribed Sets", value: "\(exercise.sets)", icon: "square.stack.fill")
                    StatCard(title: "Rep Range", value: exercise.reps, icon: "repeat")
                    StatCard(title: "Rest Period", value: exercise.rest, icon: "timer")
                }

                // Deterministic Training Guidance
                VStack(alignment: .leading, spacing: 8) {
                    Label("TRAINING GUIDANCE", systemImage: "chart.line.uptrend.xyaxis")
                        .font(.caption.bold())
                        .foregroundStyle(GFTheme.accent)

                    Text(localProgressionGuidance)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .gfCard()

                // Form Instructions
                if !exercise.instructions.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("HOW TO PERFORM", systemImage: "list.number")
                            .font(.caption.bold())
                            .foregroundStyle(GFTheme.accent)

                        ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { idx, step in
                            HStack(alignment: .top, spacing: 10) {
                                Text("\(idx + 1)")
                                    .font(.caption.bold())
                                    .frame(width: 20, height: 20)
                                    .background(GFTheme.accent.opacity(0.2))
                                    .foregroundStyle(GFTheme.accent)
                                    .clipShape(Circle())
                                Text(step)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                    .gfCard()
                }

                // Common Mistakes
                if !exercise.commonMistakes.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("COMMON MISTAKES TO AVOID", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption.bold())
                            .foregroundStyle(.orange)

                        ForEach(exercise.commonMistakes, id: \.self) { mistake in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.red)
                                    .font(.caption)
                                    .padding(.top, 2)
                                Text(mistake)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .gfCard()
                }

                PrimaryButton(title: "LOG THIS EXERCISE", systemImage: "plus") {
                    showLogSheet = true
                }
            }
            .padding()
        }
        .background(GFTheme.bg)
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
        .sheet(isPresented: $showLogSheet) {
            NavigationStack {
                ExerciseLoggingView(exercise: exercise)
            }
        }
    }
}

struct MuscleTag: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(GFTheme.accent.opacity(0.15))
            .foregroundStyle(GFTheme.accent)
            .clipShape(Capsule())
    }
}

struct ExerciseLoggingView: View {
    let exercise: ExerciseInfo
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var count = 3
    @State private var weight = Array(repeating: "", count: 4)
    @State private var reps = Array(repeating: "10", count: 4)
    @State private var notes = ""

    private var allWeightsValid: Bool {
        for i in 0..<count {
            let trimmed = weight[i].trimmingCharacters(in: .whitespacesAndNewlines)
            guard let w = Double(trimmed), w > 0 else { return false }
        }
        return true
    }

    var body: some View {
        Form {
            ForEach(0..<count, id: \.self) { i in
                Section("SET \(i + 1)") {
                    TextField("Weight kg (compulsory)", text: $weight[i])
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                    TextField("Reps", text: $reps[i])
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                }
            }

            Section("Notes") {
                TextField("Optional notes", text: $notes, axis: .vertical)
            }

            Section {
                Button("Save Exercise") {
                    guard allWeightsValid else { return }
                    for i in 0..<count {
                        let w = Double(weight[i].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
                        let r = Int(reps[i]) ?? 10
                        context.insert(ExerciseSet(exerciseID: exercise.id, setNumber: i + 1, weight: w, reps: r, notes: notes))
                    }
                    try? context.save()
                    dismiss()
                }
                .disabled(!allWeightsValid)

                if !allWeightsValid {
                    Text("⚠️ Weight is compulsory for every set before saving.")
                        .font(.caption.bold())
                        .foregroundStyle(.orange)
                }
            }
        }
        .navigationTitle("Log Exercise")
    }
}
