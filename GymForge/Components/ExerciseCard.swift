import SwiftUI

struct ExerciseCard: View {
    let exercise: ExerciseInfo
    var body: some View { NavigationLink { ExerciseDetailView(exercise: exercise) } label: { HStack(spacing: 14) { ZStack { RoundedRectangle(cornerRadius: 12).fill(GFTheme.accent.opacity(0.15)); Image(systemName: "figure.strengthtraining.traditional").foregroundStyle(GFTheme.accent) }.frame(width: 52, height: 52); VStack(alignment: .leading, spacing: 4) { Text(exercise.name).font(.headline); Text("\(exercise.muscle) • \(exercise.sets) sets • \(exercise.reps) reps").font(.caption).foregroundStyle(.secondary) }; Spacer(); Image(systemName: "chevron.right").foregroundStyle(.tertiary) }.padding(12).background(GFTheme.card).clipShape(RoundedRectangle(cornerRadius: 16)) }.buttonStyle(.plain) }
}
