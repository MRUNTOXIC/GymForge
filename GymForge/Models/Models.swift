import Foundation
import SwiftData

@Model final class UserProfile {
    var name: String
    var heightCM: Double
    var weightKG: Double
    var goal: String
    var units: String
    var distanceUnit: String
    var createdAt: Date
    init(name: String = "Athlete", heightCM: Double = 175, weightKG: Double = 95, goal: String = "Lean • Strong • Aesthetic", units: String = "kg", distanceUnit: String = "km") {
        self.name = name; self.heightCM = heightCM; self.weightKG = weightKG; self.goal = goal; self.units = units; self.distanceUnit = distanceUnit; self.createdAt = .now
    }
}

@Model final class WorkoutSession {
    var date: Date
    var day: String
    var workoutName: String
    var durationSeconds: Int
    var completed: Bool
    var treadmillCompleted: Bool
    var totalVolume: Double
    init(date: Date = .now, day: String, workoutName: String, durationSeconds: Int = 0, completed: Bool = false, treadmillCompleted: Bool = false, totalVolume: Double = 0) {
        self.date = date; self.day = day; self.workoutName = workoutName; self.durationSeconds = durationSeconds; self.completed = completed; self.treadmillCompleted = treadmillCompleted; self.totalVolume = totalVolume
    }
}

@Model final class ExerciseSet {
    var exerciseID: String
    var sessionDate: Date
    var setNumber: Int
    var weight: Double
    var reps: Int
    var notes: String
    init(exerciseID: String, sessionDate: Date = .now, setNumber: Int, weight: Double = 0, reps: Int = 0, notes: String = "") {
        self.exerciseID = exerciseID; self.sessionDate = sessionDate; self.setNumber = setNumber; self.weight = weight; self.reps = reps; self.notes = notes
    }
}

@Model final class TreadmillSession {
    var date: Date
    var durationSeconds: Int
    var distanceKM: Double
    var speedKPH: Double
    var incline: Double
    var calories: Double
    var completed: Bool
    init(date: Date = .now, durationSeconds: Int = 0, distanceKM: Double = 0, speedKPH: Double = 0, incline: Double = 0, calories: Double = 0, completed: Bool = false) {
        self.date = date; self.durationSeconds = durationSeconds; self.distanceKM = distanceKM; self.speedKPH = speedKPH; self.incline = incline; self.calories = calories; self.completed = completed
    }
}

@Model final class BodyMeasurement {
    var date: Date
    var weightKG: Double
    var waistCM: Double?
    init(date: Date = .now, weightKG: Double, waistCM: Double? = nil) { self.date = date; self.weightKG = weightKG; self.waistCM = waistCM }
}
