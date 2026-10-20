import SwiftUI
import SwiftData

struct RootView: View {
    @AppStorage("didOnboard") private var didOnboard = false
    var body: some View { Group { if didOnboard { MainTabView() } else { OnboardingView() } }.preferredColorScheme(.dark) }
}

struct OnboardingView: View {
    @AppStorage("didOnboard") private var didOnboard = false
    @State private var page = 0
    let pages = [("GYMFORGE","Train. Track. Transform.","figure.strengthtraining.traditional"),("YOUR WORKOUT PLAN","6 training days + recovery day","calendar"),("DAILY TREADMILL","Treadmill is part of your everyday routine.","figure.run"),("TRACK YOUR PROGRESS","Weight • Strength • Volume • Streak","chart.line.uptrend.xyaxis")]
    var body: some View { ZStack { GFTheme.bg.ignoresSafeArea(); VStack { Spacer(); Image(systemName: pages[page].2).font(.system(size: 90)).foregroundStyle(GFTheme.accent); Text(pages[page].0).font(.largeTitle.bold()).padding(.top, 28); Text(pages[page].1).font(.title3).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal, 30); Spacer(); HStack { ForEach(0..<pages.count, id:\.self) { i in Circle().fill(i == page ? GFTheme.accent : .white.opacity(0.2)).frame(width: 8, height: 8) } }.padding(); PrimaryButton(title: page == pages.count - 1 ? "LET'S TRAIN" : "CONTINUE", systemImage: page == pages.count - 1 ? "bolt.fill" : "arrow.right") { if page == pages.count - 1 { didOnboard=true } else { withAnimation { page += 1 } } }.padding(.horizontal, 24).padding(.bottom, 20) }.padding(.top, 40) } }
}

struct MainTabView: View {
    var body: some View { TabView { NavigationStack { HomeView() }.tabItem { Label("Home", systemImage:"house.fill") }; NavigationStack { WorkoutView() }.tabItem { Label("Workout", systemImage:"dumbbell.fill") }; NavigationStack { ExerciseLibraryView() }.tabItem { Label("Exercises", systemImage:"figure.strengthtraining.traditional") }; NavigationStack { ProgressViewScreen() }.tabItem { Label("Progress", systemImage:"chart.xyaxis.line") }; NavigationStack { ProfileView() }.tabItem { Label("Profile", systemImage:"person.fill") } }.tint(GFTheme.accent) }
}
