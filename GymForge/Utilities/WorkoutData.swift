import Foundation

struct ExerciseInfo: Identifiable, Hashable {
    let id: String
    let name: String
    let muscle: String
    let secondary: String
    let equipment: String
    let difficulty: String
    let sets: String
    let reps: String
    let rest: String
    let category: String
    let instructions: [String]
    let commonMistakes: [String]

    var image: String? { id }
    var video: String? { id }

    init(
        id: String,
        name: String,
        muscle: String,
        secondary: String,
        equipment: String,
        difficulty: String,
        sets: String,
        reps: String,
        rest: String,
        category: String,
        instructions: [String] = [],
        commonMistakes: [String] = []
    ) {
        self.id = id
        self.name = name
        self.muscle = muscle
        self.secondary = secondary
        self.equipment = equipment
        self.difficulty = difficulty
        self.sets = sets
        self.reps = reps
        self.rest = rest
        self.category = category
        self.instructions = instructions.isEmpty ? WorkoutCatalog.defaultInstructions(for: name, muscle: muscle) : instructions
        self.commonMistakes = commonMistakes.isEmpty ? WorkoutCatalog.defaultMistakes(for: name) : commonMistakes
    }

    var initialSetCount: Int {
        if sets.contains("4") { return 4 }
        if sets.contains("3") { return 3 }
        return 3
    }

    var suggestedRepValue: String {
        if reps.contains("40") { return "40" }
        if reps.contains("30") { return "30" }
        if reps.contains("20") { return "20" }
        if reps.contains("15") { return "12" }
        if reps.contains("12") { return "10" }
        if reps.contains("10") { return "8" }
        return "10"
    }
}

struct WorkoutDay: Identifiable, Hashable {
    let id: String
    let day: String
    let name: String
    let subtitle: String
    let exercises: [ExerciseInfo]
    let isRecovery: Bool
}

enum WorkoutCatalog {
    static func defaultInstructions(for name: String, muscle: String) -> [String] {
        [
            "Set up your starting position with a stable base and neutral spine.",
            "Engage your core and initiate movement through the \(muscle.lowercased()).",
            "Perform the concentric phase with smooth control without jerking.",
            "Pause briefly at peak contraction for maximum tension.",
            "Lower the resistance with a deliberate 2–3 second eccentric phase."
        ]
    }

    static func defaultMistakes(for name: String) -> [String] {
        [
            "Using momentum or swinging instead of controlled muscular contraction.",
            "Cutting range of motion short at top or bottom.",
            "Sacrificing joint alignment and posture to move heavier load."
        ]
    }

    static let allExercises: [ExerciseInfo] = [
        // MONDAY: Chest, Shoulders, Biceps
        .init(
            id: "incline_db_press",
            name: "Incline Dumbbell Press",
            muscle: "Upper Chest",
            secondary: "Front Delts • Triceps",
            equipment: "Dumbbells + Bench",
            difficulty: "Intermediate",
            sets: "3–4",
            reps: "8–12",
            rest: "60 sec",
            category: "Chest",
            instructions: [
                "Set bench to 30–45 degrees angle.",
                "Keep back and glutes pressed flat against the bench pad.",
                "Maintain neutral wrists directly stacked over elbows.",
                "Lower dumbbells toward upper chest in a controlled arc.",
                "Press upward smoothly, avoiding clanking at the top."
            ],
            commonMistakes: [
                "Using too steep of an incline angle (>45°).",
                "Excessive elbow flare putting strain on anterior shoulder.",
                "Excessive arching of lower back off the pad."
            ]
        ),
        .init(
            id: "flat_bench_press",
            name: "Flat Barbell Bench Press",
            muscle: "Chest",
            secondary: "Triceps • Front Delts",
            equipment: "Barbell + Bench",
            difficulty: "Intermediate",
            sets: "3–4",
            reps: "6–10",
            rest: "60 sec",
            category: "Chest",
            instructions: [
                "Lie flat with eyes directly under the racked barbell.",
                "Plant feet firmly into the floor and retract shoulder blades.",
                "Grip the bar slightly wider than shoulder width.",
                "Lower the bar to mid-sternum with elbows tucked at ~45°.",
                "Drive through the chest and triceps to lockout over chest."
            ],
            commonMistakes: [
                "Bouncing the barbell off the chest.",
                "Lifting hips/glutes off the bench during the press.",
                "Flaring elbows at 90 degrees."
            ]
        ),
        .init(
            id: "pec_deck",
            name: "Pec Deck Fly",
            muscle: "Chest",
            secondary: "Front Delts",
            equipment: "Pec Deck Machine",
            difficulty: "Beginner",
            sets: "3",
            reps: "10–15",
            rest: "60 sec",
            category: "Chest",
            instructions: [
                "Adjust seat so handles align with mid-chest level.",
                "Keep chest proud, back flat against pad, and slight bend in elbows.",
                "Bring handles together across chest, squeezing pectorals at peak.",
                "Return under control until a comfortable chest stretch is felt."
            ],
            commonMistakes: [
                "Letting shoulders roll forward at the end of the fly.",
                "Bending and straightening elbows during the rep.",
                "Using excessive weight causing jerking."
            ]
        ),
        .init(
            id: "decline_db_press",
            name: "Decline Dumbbell Press",
            muscle: "Lower Chest",
            secondary: "Triceps",
            equipment: "Dumbbells + Bench",
            difficulty: "Intermediate",
            sets: "3",
            reps: "8–12",
            rest: "60 sec",
            category: "Chest"
        ),
        .init(
            id: "shoulder_press",
            name: "Dumbbell Shoulder Press",
            muscle: "Shoulders",
            secondary: "Triceps",
            equipment: "Dumbbells",
            difficulty: "Intermediate",
            sets: "3",
            reps: "8–12",
            rest: "60 sec",
            category: "Shoulders",
            instructions: [
                "Sit upright with dumbbells at ear level, palms facing forward.",
                "Press upward overhead until arms are extended but not hyperextended.",
                "Lower slowly under control to ear level."
            ],
            commonMistakes: [
                "Over-arching the lower back.",
                "Pressing too far forward instead of overhead."
            ]
        ),
        .init(
            id: "lateral_raise",
            name: "Dumbbell Lateral Raise",
            muscle: "Side Delts",
            secondary: "Traps",
            equipment: "Dumbbells",
            difficulty: "Beginner",
            sets: "3",
            reps: "12–15",
            rest: "60 sec",
            category: "Shoulders",
            instructions: [
                "Stand tall with slight forward hinge and soft knees.",
                "Raise dumbbells out to sides leading with elbows until parallel to floor.",
                "Pause at top, then lower with a controlled 2-second negative."
            ],
            commonMistakes: [
                "Swinging hips or using leg drive.",
                "Shrugging traps up to ears."
            ]
        ),
        .init(
            id: "incline_curl",
            name: "Incline Dumbbell Curl",
            muscle: "Biceps",
            secondary: "Brachialis",
            equipment: "Dumbbells + Bench",
            difficulty: "Intermediate",
            sets: "3",
            reps: "8–12",
            rest: "60 sec",
            category: "Biceps"
        ),
        .init(
            id: "spider_curl",
            name: "Spider Curl",
            muscle: "Biceps",
            secondary: "Brachialis",
            equipment: "Bench + Dumbbells",
            difficulty: "Intermediate",
            sets: "3",
            reps: "10–15",
            rest: "60 sec",
            category: "Biceps"
        ),
        .init(
            id: "hammer_curl",
            name: "Cross-Body Hammer Curl",
            muscle: "Brachialis",
            secondary: "Biceps • Forearms",
            equipment: "Dumbbells",
            difficulty: "Beginner",
            sets: "3",
            reps: "10–15",
            rest: "60 sec",
            category: "Biceps"
        ),

        // TUESDAY: Back, Traps, Triceps
        .init(
            id: "wide_lat_pulldown",
            name: "Wide-Grip Lat Pulldown",
            muscle: "Lats",
            secondary: "Biceps • Upper Back",
            equipment: "Cable Machine",
            difficulty: "Beginner",
            sets: "3–4",
            reps: "8–12",
            rest: "60 sec",
            category: "Back",
            instructions: [
                "Secure thighs firmly under pads with torso upright.",
                "Grip bar wider than shoulder width.",
                "Pull bar down to upper chest while depressing shoulder blades.",
                "Control the return all the way to a full lat stretch."
            ],
            commonMistakes: [
                "Leaning back excessively to turn into a row.",
                "Pulling behind the neck."
            ]
        ),
        .init(
            id: "close_lat_pulldown",
            name: "Close-Grip Lat Pulldown",
            muscle: "Lats",
            secondary: "Biceps",
            equipment: "Cable Machine",
            difficulty: "Beginner",
            sets: "3",
            reps: "8–12",
            rest: "60 sec",
            category: "Back"
        ),
        .init(
            id: "one_arm_row",
            name: "One-Arm Dumbbell Row",
            muscle: "Lats",
            secondary: "Rhomboids • Biceps",
            equipment: "Dumbbell + Bench",
            difficulty: "Intermediate",
            sets: "3",
            reps: "8–12",
            rest: "60 sec",
            category: "Back"
        ),
        .init(
            id: "seated_cable_row",
            name: "Seated Cable Row",
            muscle: "Mid Back",
            secondary: "Lats • Biceps",
            equipment: "Cable Machine",
            difficulty: "Beginner",
            sets: "3",
            reps: "8–12",
            rest: "60 sec",
            category: "Back"
        ),
        .init(
            id: "db_pullover",
            name: "Dumbbell Pullover",
            muscle: "Lats",
            secondary: "Chest • Serratus",
            equipment: "Dumbbell + Bench",
            difficulty: "Intermediate",
            sets: "3",
            reps: "8–12",
            rest: "60 sec",
            category: "Back"
        ),
        .init(
            id: "shrugs",
            name: "Dumbbell Shrugs",
            muscle: "Traps",
            secondary: "Forearms",
            equipment: "Dumbbells",
            difficulty: "Beginner",
            sets: "3",
            reps: "10–15",
            rest: "60 sec",
            category: "Back"
        ),
        .init(
            id: "overhead_extension",
            name: "Overhead Triceps Extension",
            muscle: "Triceps",
            secondary: "Long Head",
            equipment: "Dumbbell / Cable",
            difficulty: "Beginner",
            sets: "3",
            reps: "8–12",
            rest: "60 sec",
            category: "Triceps"
        ),
        .init(
            id: "pushdown",
            name: "Triceps Pushdown",
            muscle: "Triceps",
            secondary: "Forearms",
            equipment: "Cable Machine",
            difficulty: "Beginner",
            sets: "3",
            reps: "8–12",
            rest: "60 sec",
            category: "Triceps"
        ),
        .init(
            id: "dips",
            name: "Dips",
            muscle: "Triceps",
            secondary: "Chest • Front Delts",
            equipment: "Dip Station",
            difficulty: "Intermediate",
            sets: "3",
            reps: "8–12",
            rest: "60 sec",
            category: "Triceps"
        ),

        // WEDNESDAY: Abs + Cardio Circuit
        .init(
            id: "crunch",
            name: "Normal Crunches",
            muscle: "Abs",
            secondary: "Core",
            equipment: "Bodyweight",
            difficulty: "Beginner",
            sets: "3",
            reps: "15–20",
            rest: "60 sec",
            category: "Abs"
        ),
        .init(
            id: "reverse_crunch",
            name: "Reverse Crunches",
            muscle: "Lower Abs",
            secondary: "Core",
            equipment: "Bodyweight",
            difficulty: "Beginner",
            sets: "3",
            reps: "15–20",
            rest: "60 sec",
            category: "Abs"
        ),
        .init(
            id: "russian_twist",
            name: "Russian Twists",
            muscle: "Obliques",
            secondary: "Core",
            equipment: "Bodyweight / Plate",
            difficulty: "Beginner",
            sets: "3",
            reps: "20–25",
            rest: "60 sec",
            category: "Abs"
        ),
        .init(
            id: "jumping_jacks",
            name: "Jumping Jacks",
            muscle: "Cardio",
            secondary: "Full Body",
            equipment: "Bodyweight",
            difficulty: "Beginner",
            sets: "3–4",
            reps: "40 sec",
            rest: "60 sec",
            category: "Cardio"
        ),
        .init(
            id: "mountain_climbers",
            name: "Mountain Climbers",
            muscle: "Cardio • Core",
            secondary: "Shoulders",
            equipment: "Bodyweight",
            difficulty: "Beginner",
            sets: "3–4",
            reps: "30 sec",
            rest: "60 sec",
            category: "Cardio"
        ),
        .init(
            id: "high_knees",
            name: "High Knees",
            muscle: "Cardio",
            secondary: "Quads • Calves",
            equipment: "Bodyweight",
            difficulty: "Beginner",
            sets: "3–4",
            reps: "30 sec",
            rest: "60 sec",
            category: "Cardio"
        ),
        .init(
            id: "cardio_squats",
            name: "Bodyweight Squats (Cardio)",
            muscle: "Quads • Glutes",
            secondary: "Cardio",
            equipment: "Bodyweight",
            difficulty: "Beginner",
            sets: "3–4",
            reps: "40 sec",
            rest: "60 sec",
            category: "Cardio"
        ),

        // THURSDAY / FRIDAY / SATURDAY: Upper Body, Arms, Forearms, Legs
        .init(
            id: "barbell_curl",
            name: "Barbell Curl",
            muscle: "Biceps",
            secondary: "Forearms",
            equipment: "Barbell",
            difficulty: "Intermediate",
            sets: "3",
            reps: "8–12",
            rest: "60 sec",
            category: "Biceps"
        ),
        .init(
            id: "reverse_curl",
            name: "Reverse Curl",
            muscle: "Brachioradialis",
            secondary: "Biceps",
            equipment: "Barbell",
            difficulty: "Beginner",
            sets: "3",
            reps: "10–15",
            rest: "60 sec",
            category: "Forearms"
        ),
        .init(
            id: "ez_skull",
            name: "Overhead Cable EZ-Bar Skull Crusher",
            muscle: "Triceps",
            secondary: "Long Head",
            equipment: "Cable + EZ Bar",
            difficulty: "Intermediate",
            sets: "3",
            reps: "8–12",
            rest: "60 sec",
            category: "Triceps"
        ),
        .init(
            id: "straight_pushdown",
            name: "Straight-Bar Pushdown",
            muscle: "Triceps",
            secondary: "Forearms",
            equipment: "Cable Machine",
            difficulty: "Beginner",
            sets: "3",
            reps: "10–15",
            rest: "60 sec",
            category: "Triceps"
        ),
        .init(
            id: "wrist_curl",
            name: "Wrist Curl",
            muscle: "Wrist Flexors",
            secondary: "Forearms",
            equipment: "Dumbbell / Barbell",
            difficulty: "Beginner",
            sets: "3",
            reps: "12–20",
            rest: "60 sec",
            category: "Forearms"
        ),
        .init(
            id: "wrist_flexors",
            name: "Wrist Flexors",
            muscle: "Forearms",
            secondary: "Grip",
            equipment: "Dumbbell",
            difficulty: "Beginner",
            sets: "3",
            reps: "12–20",
            rest: "60 sec",
            category: "Forearms"
        ),
        .init(
            id: "reverse_wrist_curl",
            name: "Reverse Wrist Curl",
            muscle: "Wrist Extensors",
            secondary: "Forearms",
            equipment: "Dumbbell / Barbell",
            difficulty: "Beginner",
            sets: "3",
            reps: "12–20",
            rest: "60 sec",
            category: "Forearms"
        ),
        .init(
            id: "wrist_extensors",
            name: "Wrist Extensors",
            muscle: "Forearms",
            secondary: "Grip",
            equipment: "Dumbbell",
            difficulty: "Beginner",
            sets: "3",
            reps: "12–20",
            rest: "60 sec",
            category: "Forearms"
        ),
        .init(
            id: "leg_press",
            name: "Leg Press",
            muscle: "Quads",
            secondary: "Glutes • Hamstrings",
            equipment: "Leg Press Machine",
            difficulty: "Beginner",
            sets: "3–4",
            reps: "8–12",
            rest: "60 sec",
            category: "Legs"
        ),
        .init(
            id: "bodyweight_squat",
            name: "Bodyweight Squats",
            muscle: "Quads",
            secondary: "Glutes • Core",
            equipment: "Bodyweight",
            difficulty: "Beginner",
            sets: "3",
            reps: "12–20",
            rest: "60 sec",
            category: "Legs"
        ),
        .init(
            id: "rdl",
            name: "Romanian Deadlift (RDL)",
            muscle: "Hamstrings",
            secondary: "Glutes • Lower Back",
            equipment: "Barbell / Dumbbells",
            difficulty: "Intermediate",
            sets: "3–4",
            reps: "8–12",
            rest: "60 sec",
            category: "Legs"
        ),
        .init(
            id: "leg_curl",
            name: "Seated Leg Curl",
            muscle: "Hamstrings",
            secondary: "Calves",
            equipment: "Leg Curl Machine",
            difficulty: "Beginner",
            sets: "3",
            reps: "10–15",
            rest: "60 sec",
            category: "Legs"
        ),
        .init(
            id: "leg_extension",
            name: "Leg Extension",
            muscle: "Quads",
            secondary: "Knee Extensors",
            equipment: "Leg Extension Machine",
            difficulty: "Beginner",
            sets: "3",
            reps: "10–15",
            rest: "60 sec",
            category: "Legs"
        ),
        .init(
            id: "hip_thrust",
            name: "Hip Thrust",
            muscle: "Glutes",
            secondary: "Hamstrings",
            equipment: "Barbell / Machine",
            difficulty: "Intermediate",
            sets: "3",
            reps: "8–12",
            rest: "60 sec",
            category: "Legs"
        ),
        .init(
            id: "calf_raise",
            name: "Calf Raise Machine",
            muscle: "Calves",
            secondary: "Soleus",
            equipment: "Calf Machine",
            difficulty: "Beginner",
            sets: "3",
            reps: "12–20",
            rest: "60 sec",
            category: "Legs"
        )
    ]

    static let days: [WorkoutDay] = [
        .init(
            id: "monday",
            day: "MONDAY",
            name: "Push + Biceps",
            subtitle: "Chest • Shoulders • Biceps • Compulsory Treadmill",
            exercises: ids([
                "incline_db_press",
                "flat_bench_press",
                "pec_deck",
                "decline_db_press",
                "shoulder_press",
                "lateral_raise",
                "incline_curl",
                "spider_curl",
                "hammer_curl"
            ]),
            isRecovery: false
        ),
        .init(
            id: "tuesday",
            day: "TUESDAY",
            name: "Back + Traps + Triceps",
            subtitle: "Back • Traps • Triceps • Compulsory Treadmill",
            exercises: ids([
                "wide_lat_pulldown",
                "close_lat_pulldown",
                "one_arm_row",
                "seated_cable_row",
                "db_pullover",
                "shrugs",
                "overhead_extension",
                "pushdown",
                "dips"
            ]),
            isRecovery: false
        ),
        .init(
            id: "wednesday",
            day: "WEDNESDAY",
            name: "Abs + Cardio Circuit",
            subtitle: "Abs • 4-Exercise Circuit • Compulsory Treadmill",
            exercises: ids([
                "crunch",
                "reverse_crunch",
                "russian_twist",
                "jumping_jacks",
                "mountain_climbers",
                "high_knees",
                "cardio_squats"
            ]),
            isRecovery: false
        ),
        .init(
            id: "thursday",
            day: "THURSDAY",
            name: "Upper Body (Progressive Overload)",
            subtitle: "Chest • Back • Shoulders • Arms • Compulsory Treadmill",
            exercises: ids([
                "incline_db_press",
                "wide_lat_pulldown",
                "shoulder_press",
                "seated_cable_row",
                "overhead_extension",
                "barbell_curl"
            ]),
            isRecovery: false
        ),
        .init(
            id: "friday",
            day: "FRIDAY",
            name: "Arms + Forearms",
            subtitle: "Biceps • Triceps • Forearms • Compulsory Treadmill",
            exercises: ids([
                "incline_curl",
                "barbell_curl",
                "spider_curl",
                "reverse_curl",
                "ez_skull",
                "straight_pushdown",
                "dips",
                "wrist_curl",
                "wrist_flexors",
                "reverse_wrist_curl",
                "wrist_extensors"
            ]),
            isRecovery: false
        ),
        .init(
            id: "saturday",
            day: "SATURDAY",
            name: "Legs",
            subtitle: "Quads • Hamstrings • Glutes • Calves • Compulsory Treadmill",
            exercises: ids([
                "leg_press",
                "bodyweight_squat",
                "rdl",
                "leg_curl",
                "leg_extension",
                "hip_thrust",
                "calf_raise"
            ]),
            isRecovery: false
        ),
        .init(
            id: "sunday",
            day: "SUNDAY",
            name: "Rest + Recovery",
            subtitle: "Light Recovery Treadmill • Compulsory",
            exercises: [],
            isRecovery: true
        )
    ]

    static func ids(_ ids: [String]) -> [ExerciseInfo] {
        ids.compactMap { wanted in allExercises.first(where: { $0.id == wanted }) }
    }

    static func day(for date: Date = .now) -> WorkoutDay {
        let i = Calendar.current.component(.weekday, from: date) - 2
        let index = i < 0 ? 6 : i
        return days[index]
    }

    static func exercise(id: String) -> ExerciseInfo? {
        allExercises.first { $0.id == id }
    }
}
