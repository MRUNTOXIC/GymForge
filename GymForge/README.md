# GymForge

Native SwiftUI iPhone fitness planner for iOS 18+.

## Open in Xcode
1. Open `GymForge.xcodeproj`.
2. Select your iPhone as the run destination.
3. In **Signing & Capabilities**, select your Apple Developer Team and use a unique bundle identifier if needed.
4. Press **Run**.

## Local exercise media
Put silent MP4 demonstrations in `GymForge/Assets/Exercises/` using the exercise IDs used by the app, for example `incline_db_press.mp4`. The app falls back to a local SwiftUI exercise illustration when a matching MP4/image is absent.

The character identity area is ready for the supplied character illustration. Add it as an asset named `character_certificate` to use it in the profile screen.

## Offline
All workout catalog data is compiled into the app. SwiftData stores profile, sessions, sets, treadmill records and body measurements locally. No network service is required.
