import SwiftUI
import SwiftData
import UserNotifications

@main
struct GymForgeApp: App {
    init() {
        NotificationManager.shared.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [UserProfile.self, WorkoutSession.self, ExerciseSet.self, TreadmillSession.self, BodyMeasurement.self])
    }
}

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func scheduleRestTimerNotification(seconds: Int) {
        cancelRestTimerNotification()
        let content = UNMutableNotificationContent()
        content.title = "Rest Time Over! 🔔"
        content.body = "60-second compulsory rest complete. Ready for your next set!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(max(1, seconds)), repeats: false)
        let request = UNNotificationRequest(identifier: "gymforge.rest.timer", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelRestTimerNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["gymforge.rest.timer"])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .list])
    }
}
