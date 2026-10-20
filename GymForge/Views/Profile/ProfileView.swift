import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

struct ProfileView: View {
    @Query private var profiles: [UserProfile]
    @Environment(\.modelContext) private var context

    @State private var name = "Athlete"
    @State private var height = "175"
    @State private var weight = "95"
    @State private var units = "kg"
    @State private var distanceUnit = "km"
    @AppStorage("notifications_enabled") private var notificationsEnabled = true
    @AppStorage("reduce_motion") private var reduceMotion = false

    @State private var showSavedAlert = false
    @State private var showResetConfirmation = false

    private var profile: UserProfile? { profiles.first }

    private var characterImage: UIImage? {
        #if canImport(UIKit)
        if let img = UIImage(named: "character_certificate") { return img }
        if let path = Bundle.main.path(forResource: "character_certificate", ofType: "png", inDirectory: "Assets"),
           let img = UIImage(contentsOfFile: path) { return img }
        if let path = Bundle.main.path(forResource: "character_certificate", ofType: "png", inDirectory: "Assets/Character"),
           let img = UIImage(contentsOfFile: path) { return img }
        if let path = Bundle.main.path(forResource: "character_certificate", ofType: "png"),
           let img = UIImage(contentsOfFile: path) { return img }
        return nil
        #else
        return nil
        #endif
    }

    var body: some View {
        Form {
            Section {
                VStack(spacing: 12) {
                    #if canImport(UIKit)
                    if let image = characterImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 104, height: 104)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(GFTheme.accent, lineWidth: 2))
                            .shadow(color: GFTheme.accent.opacity(0.3), radius: 8)
                    } else {
                        Image(systemName: "figure.strengthtraining.traditional.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(GFTheme.accent)
                    }
                    #else
                    Image(systemName: "figure.strengthtraining.traditional.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(GFTheme.accent)
                    #endif

                    Text("GYM CHARACTER")
                        .font(.headline.bold())
                    Text("Train. Track. Transform.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }

            Section("Profile") {
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("Name", text: $name)
                        .multilineTextAlignment(.trailing)
                }

                HStack {
                    Text("Height (cm)")
                    Spacer()
                    TextField("Height", text: $height)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .multilineTextAlignment(.trailing)
                }

                HStack {
                    Text("Weight (\(units))")
                    Spacer()
                    TextField("Weight", text: $weight)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .multilineTextAlignment(.trailing)
                }

                Text("Goal: Lean • Strong • Aesthetic")
                    .foregroundStyle(.secondary)
                Text("Training: 6 Days / Week")
                    .foregroundStyle(.secondary)
                Text("Cardio: Treadmill Daily")
                    .foregroundStyle(.secondary)
            }

            Section("Preferences") {
                Picker("Weight Units", selection: $units) {
                    Text("kg").tag("kg")
                    Text("lb").tag("lb")
                }

                Picker("Distance Units", selection: $distanceUnit) {
                    Text("km").tag("km")
                    Text("miles").tag("miles")
                }

                Toggle("Notifications", isOn: $notificationsEnabled)
                Toggle("Reduce Motion", isOn: $reduceMotion)
            }

            Section("Data Management") {
                Button("Save Profile") {
                    save()
                }
                .tint(GFTheme.accent)

                Button("Reset Workout Data", role: .destructive) {
                    showResetConfirmation = true
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(GFTheme.bg)
        .navigationTitle("Profile")
        .alert("Profile Saved", isPresented: $showSavedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your profile information has been saved successfully.")
        }
        .alert("Reset All Workout Data?", isPresented: $showResetConfirmation) {
            Button("Reset Everything", role: .destructive) {
                resetAllData()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently remove all logged workout sessions, exercise sets, treadmill sessions, and body measurements.")
        }
        .onAppear {
            loadProfile()
        }
    }

    private func loadProfile() {
        if let p = profile {
            name = p.name
            height = "\(Int(p.heightCM))"
            weight = "\(Int(p.weightKG))"
            units = p.units
            distanceUnit = p.distanceUnit
        } else {
            let newProfile = UserProfile()
            context.insert(newProfile)
            try? context.save()
        }
    }

    private func save() {
        let p = profile ?? UserProfile()
        p.name = name
        p.heightCM = Double(height) ?? 175
        p.weightKG = Double(weight) ?? 95
        p.units = units
        p.distanceUnit = distanceUnit

        if profile == nil {
            context.insert(p)
        }
        try? context.save()
        showSavedAlert = true

        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }

    private func resetAllData() {
        do {
            try context.delete(model: WorkoutSession.self)
            try context.delete(model: ExerciseSet.self)
            try context.delete(model: TreadmillSession.self)
            try context.delete(model: BodyMeasurement.self)
            try context.save()
        } catch {
            print("Failed to reset data: \(error)")
        }
    }
}
