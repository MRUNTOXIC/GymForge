import SwiftUI
import AVKit
import ImageIO
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Exercise DTOs (Static Media Asset Metadata)

public struct ExerciseDTO: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let slug: String
    public let name: String
    public let muscle: String
    public let bodyPart: String?
    public let equipment: String?
    public let category: String?
    public let secondaryMuscles: [String]?
    public let instructions: [String]?
    public let file: String?
    public let gifUrl: String

    public init(
        id: String,
        slug: String,
        name: String,
        muscle: String,
        bodyPart: String? = nil,
        equipment: String? = nil,
        category: String? = nil,
        secondaryMuscles: [String]? = nil,
        instructions: [String]? = nil,
        file: String? = nil,
        gifUrl: String
    ) {
        self.id = id
        self.slug = slug
        self.name = name
        self.muscle = muscle
        self.bodyPart = bodyPart
        self.equipment = equipment
        self.category = category
        self.secondaryMuscles = secondaryMuscles
        self.instructions = instructions
        self.file = file
        self.gifUrl = gifUrl
    }
}

public struct ExerciseGlobalIndexDTO: Codable, Sendable {
    public let name: String?
    public let baseUrl: String?
    public let languages: [String]?
    public let defaultLanguage: String?
}

public struct ExerciseLanguageIndexDTO: Codable, Sendable {
    public let name: String?
    public let language: String?
    public let baseUrl: String?
    public let muscles: [MuscleSummaryDTO]?
}

public struct MuscleSummaryDTO: Codable, Identifiable, Sendable {
    public var id: String { muscle }
    public let muscle: String
    public let count: Int?
    public let endpoint: String?
}

public struct MuscleDetailDTO: Codable, Sendable {
    public let muscle: String
    public let count: Int?
    public let exercises: [ExerciseDTO]
}

public struct EquipmentSummaryDTO: Codable, Identifiable, Sendable {
    public var id: String { equipment }
    public let equipment: String
    public let count: Int?
    public let endpoint: String?
}

public struct BodyPartSummaryDTO: Codable, Identifiable, Sendable {
    public var id: String { bodyPart }
    public let bodyPart: String
    public let count: Int?
    public let endpoint: String?
}

public struct ExercisesContainerDTO: Codable, Sendable {
    public let count: Int?
    public let exercises: [ExerciseDTO]
}

// MARK: - Native Media Asset Client

public final class ExerciseAPIClient: Sendable {
    public static let shared = ExerciseAPIClient()
    public static let cdnBase = "https://cdn.jsdelivr.net/gh/JahelCuadrado/ExerciseGymGifsDB@v1.1.0"

    public init() {}

    private func fetchData<T: Decodable>(from endpoint: String) async throws -> T {
        let cleanEndpoint = endpoint.hasPrefix("/") ? String(endpoint.dropFirst()) : endpoint
        let urlString = "\(Self.cdnBase)/\(cleanEndpoint)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        request.setValue("GymForge/1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    public func fetchGlobalIndex() async throws -> ExerciseGlobalIndexDTO {
        try await fetchData(from: "api/index.json")
    }

    public func fetchLanguageIndex(lang: String = "en") async throws -> ExerciseLanguageIndexDTO {
        try await fetchData(from: "api/\(lang)/index.json")
    }

    public func fetchMuscles(lang: String = "en") async throws -> [MuscleSummaryDTO] {
        try await fetchData(from: "api/\(lang)/muscles.json")
    }

    public func fetchMuscleDetail(muscle: String, lang: String = "en") async throws -> MuscleDetailDTO {
        try await fetchData(from: "api/\(lang)/muscles/\(muscle).json")
    }

    public func fetchEquipment(lang: String = "en") async throws -> [EquipmentSummaryDTO] {
        try await fetchData(from: "api/\(lang)/equipment.json")
    }

    public func fetchBodyParts(lang: String = "en") async throws -> [BodyPartSummaryDTO] {
        try await fetchData(from: "api/\(lang)/bodyparts.json")
    }

    public func fetchExercises(lang: String = "en") async throws -> ExercisesContainerDTO {
        try await fetchData(from: "api/\(lang)/exercises.json")
    }

    public func fetchExerciseDetail(muscle: String, slug: String, lang: String = "en") async throws -> ExerciseDTO {
        try await fetchData(from: "api/\(lang)/exercises/\(muscle)/\(slug).json")
    }
}

// MARK: - Exercise GIF Service & Local Cache (Actor-isolated)

public actor ExerciseGIFService {
    public static let shared = ExerciseGIFService()

    private let memoryCache = NSCache<NSString, NSData>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    // Verified mappings from GymForge exercise ID to asset (muscle, slug)
    private let verifiedMapping: [String: (muscle: String, slug: String)] = [
        // Chest & Shoulders
        "incline_db_press": ("pectorals", "dumbbell-incline-bench-press"),
        "flat_bench_press": ("pectorals", "barbell-bench-press"),
        "pec_deck": ("pectorals", "lever-seated-fly"),
        "decline_db_press": ("pectorals", "dumbbell-decline-bench-press"),
        "shoulder_press": ("delts", "dumbbell-seated-shoulder-press"),
        "lateral_raise": ("delts", "dumbbell-lateral-raise"),

        // Biceps & Triceps
        "incline_curl": ("biceps", "dumbbell-incline-curl"),
        "spider_curl": ("biceps", "ez-barbell-spider-curl"),
        "hammer_curl": ("biceps", "dumbbell-cross-body-hammer-curl-v-2"),
        "barbell_curl": ("biceps", "barbell-curl"),
        "reverse_curl": ("biceps", "barbell-reverse-curl"),
        "overhead_extension": ("triceps", "cable-overhead-triceps-extension-rope-attachment"),
        "pushdown": ("triceps", "cable-pushdown"),
        "straight_pushdown": ("triceps", "cable-reverse-grip-pushdown"),
        "ez_skull": ("triceps", "barbell-lying-triceps-extension-skull-crusher"),
        "dips": ("triceps", "ring-dips"),

        // Back & Traps
        "wide_lat_pulldown": ("lats", "cable-pulldown"),
        "close_lat_pulldown": ("lats", "band-close-grip-pulldown"),
        "one_arm_row": ("upper-back", "dumbbell-one-arm-bent-over-row"),
        "seated_cable_row": ("upper-back", "cable-seated-row"),
        "db_pullover": ("pectorals", "dumbbell-pullover"),
        "shrugs": ("traps", "dumbbell-shrug"),

        // Core
        "crunch": ("abs", "decline-crunch"),
        "reverse_crunch": ("abs", "reverse-crunch"),
        "russian_twist": ("abs", "russian-twist"),

        // Forearms
        "wrist_curl": ("forearms", "band-wrist-curl"),
        "reverse_wrist_curl": ("forearms", "band-reverse-wrist-curl"),

        // Legs
        "leg_press": ("glutes", "sled-45-leg-press"),
        "rdl": ("glutes", "barbell-romanian-deadlift"),
        "leg_curl": ("hamstrings", "lever-seated-leg-curl"),
        "leg_extension": ("quads", "lever-leg-extension"),
        "hip_thrust": ("glutes", "barbell-glute-bridge"),
        "calf_raise": ("calves", "lever-standing-calf-raise")
    ]

    private var dtoMemoryCache: [String: ExerciseDTO] = [:]

    private init() {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let root = paths.first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let folder = root.appendingPathComponent("ExerciseGIFs", isDirectory: true)
        if !fileManager.fileExists(atPath: folder.path) {
            try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        self.cacheDirectory = folder
        self.memoryCache.countLimit = 60
        self.memoryCache.totalCostLimit = 120 * 1024 * 1024
    }

    public func verifiedMatch(for gymForgeID: String) -> (muscle: String, slug: String)? {
        verifiedMapping[gymForgeID]
    }

    public func directGIFURL(for gymForgeID: String) -> String? {
        guard let mapping = verifiedMapping[gymForgeID] else { return nil }
        return "\(ExerciseAPIClient.cdnBase)/\(mapping.muscle)/\(mapping.slug).gif"
    }

    public func fetchVerifiedDTO(for gymForgeID: String) async -> ExerciseDTO? {
        if let cached = dtoMemoryCache[gymForgeID] {
            return cached
        }

        guard let mapping = verifiedMapping[gymForgeID] else {
            return nil
        }

        do {
            let dto = try await ExerciseAPIClient.shared.fetchExerciseDetail(muscle: mapping.muscle, slug: mapping.slug)
            dtoMemoryCache[gymForgeID] = dto
            return dto
        } catch {
            return nil
        }
    }

    public func loadGIF(from urlString: String) async -> Data? {
        guard let url = URL(string: urlString) else { return nil }
        let key = NSString(string: url.lastPathComponent)

        // 1. Check memory cache
        if let cachedData = memoryCache.object(forKey: key) {
            return cachedData as Data
        }

        // 2. Check disk cache
        let fileURL = cacheDirectory.appendingPathComponent(url.lastPathComponent)
        if let diskData = try? Data(contentsOf: fileURL) {
            memoryCache.setObject(diskData as NSData, forKey: key, cost: diskData.count)
            return diskData
        }

        // 3. Download if connected
        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 10
            request.setValue("GymForge/1.0", forHTTPHeaderField: "User-Agent")

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                return nil
            }

            memoryCache.setObject(data as NSData, forKey: key, cost: data.count)
            try? data.write(to: fileURL, options: .atomic)
            return data
        } catch {
            return nil
        }
    }
}

// MARK: - Exercise Media View Model

@MainActor
public final class ExerciseMediaViewModel: ObservableObject {
    public enum State: Equatable {
        case idle
        case loading
        case loaded
        case fallback

        public static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.loading, .loading), (.loaded, .loaded), (.fallback, .fallback):
                return true
            default:
                return false
            }
        }
    }

    @Published public var state: State = .idle
    @Published public var gifData: Data?

    public init() {}

    public func load(for exerciseID: String) async {
        guard let directURL = await ExerciseGIFService.shared.directGIFURL(for: exerciseID) else {
            state = .fallback
            return
        }

        state = .loading

        let loadedGIF = await ExerciseGIFService.shared.loadGIF(from: directURL)
        if let loadedGIF = loadedGIF {
            self.gifData = loadedGIF
            self.state = .loaded
        } else {
            self.state = .fallback
        }
    }
}

// MARK: - Native GIF View with White Background Removal

#if canImport(UIKit)
final class ProcessedGIFCache: @unchecked Sendable {
    static let shared = ProcessedGIFCache()
    private let cache = NSCache<NSString, ProcessedGIFEntry>()

    final class ProcessedGIFEntry {
        let images: [UIImage]
        let duration: TimeInterval
        init(images: [UIImage], duration: TimeInterval) {
            self.images = images
            self.duration = duration
        }
    }

    func entry(forKey key: String) -> ProcessedGIFEntry? {
        cache.object(forKey: NSString(string: key))
    }

    func setEntry(_ entry: ProcessedGIFEntry, forKey key: String) {
        cache.setObject(entry, forKey: NSString(string: key))
    }
}

struct NativeGIFView: UIViewRepresentable {
    let gifData: Data
    let isPlaying: Bool

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)

        configureGIF(data: gifData, on: imageView, play: isPlaying)
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        let hash = gifData.hashValue
        if uiView.tag != hash {
            uiView.tag = hash
            configureGIF(data: gifData, on: uiView, play: isPlaying)
        } else {
            if isPlaying {
                if !uiView.isAnimating, let count = uiView.animationImages?.count, count > 1 {
                    uiView.startAnimating()
                }
            } else {
                if uiView.isAnimating {
                    uiView.stopAnimating()
                }
            }
        }
    }

    private func configureGIF(data: Data, on imageView: UIImageView, play: Bool) {
        let cacheKey = String(data.hashValue)
        let entry: ProcessedGIFCache.ProcessedGIFEntry

        if let cached = ProcessedGIFCache.shared.entry(forKey: cacheKey) {
            entry = cached
        } else {
            let processed = decodeAndRemoveWhite(from: data)
            entry = ProcessedGIFCache.ProcessedGIFEntry(images: processed.images, duration: processed.duration)
            ProcessedGIFCache.shared.setEntry(entry, forKey: cacheKey)
        }

        if let first = entry.images.first {
            imageView.image = first
        }

        if entry.images.count > 1 {
            imageView.animationImages = entry.images
            imageView.animationDuration = entry.duration > 0 ? entry.duration : Double(entry.images.count) * 0.1
            imageView.animationRepeatCount = 0

            if play {
                imageView.startAnimating()
            } else {
                imageView.stopAnimating()
            }
        }
    }

    private func decodeAndRemoveWhite(from data: Data) -> (images: [UIImage], duration: TimeInterval) {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return ([], 0) }
        let count = CGImageSourceGetCount(source)
        guard count > 0 else { return ([], 0) }

        var images: [UIImage] = []
        var totalDuration: TimeInterval = 0

        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let transparentCG = removeWhite(from: cgImage) ?? cgImage
                images.append(UIImage(cgImage: transparentCG))

                var frameDuration: TimeInterval = 0.1
                if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [CFString: Any],
                   let gifProps = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] {
                    if let unclamped = gifProps[kCGImagePropertyGIFUnclampedDelayTime] as? TimeInterval, unclamped > 0 {
                        frameDuration = unclamped
                    } else if let delay = gifProps[kCGImagePropertyGIFDelayTime] as? TimeInterval, delay > 0 {
                        frameDuration = delay
                    }
                }
                totalDuration += frameDuration
            }
        }

        return (images, totalDuration)
    }

    private func removeWhite(from cgImage: CGImage) -> CGImage? {
        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8

        var rawData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        guard let context = CGContext(
            data: &rawData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else {
            return nil
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        let threshold: UInt8 = 238
        let totalBytes = rawData.count
        var idx = 0
        while idx < totalBytes {
            let r = rawData[idx]
            let g = rawData[idx + 1]
            let b = rawData[idx + 2]
            if r >= threshold && g >= threshold && b >= threshold {
                rawData[idx + 3] = 0
            }
            idx += 4
        }

        return context.makeImage()
    }
}
#endif

// MARK: - ExerciseMediaView

public struct ExerciseMediaView: View {
    public let exerciseID: String
    @StateObject private var viewModel = ExerciseMediaViewModel()
    @State private var showInstructions = false
    @State private var isDemonstrationVisible = false

    public init(exerciseID: String) {
        self.exerciseID = exerciseID
    }

    private var localVideoURL: URL? {
        Bundle.main.url(forResource: exerciseID, withExtension: "mp4", subdirectory: "Exercises")
            ?? Bundle.main.url(forResource: exerciseID, withExtension: "mp4")
    }

    private var exerciseInfo: ExerciseInfo? {
        WorkoutCatalog.exercise(id: exerciseID)
    }

    public var body: some View {
        VStack(spacing: 8) {
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isDemonstrationVisible.toggle()
                }
            }) {
                mediaContent
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)
                    .background(GFTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isDemonstrationVisible ? GFTheme.accent.opacity(0.4) : Color.white.opacity(0.08),
                                lineWidth: isDemonstrationVisible ? 1.5 : 1
                            )
                    )
            }
            .buttonStyle(.plain)

            // Local deterministic instructions from pre-defined database
            if let instructions = exerciseInfo?.instructions, !instructions.isEmpty {
                DisclosureGroup(
                    isExpanded: $showInstructions,
                    content: {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(Array(instructions.enumerated()), id: \.offset) { idx, step in
                                HStack(alignment: .top, spacing: 6) {
                                    Text("\(idx + 1).")
                                        .font(.caption.bold())
                                        .foregroundStyle(GFTheme.accent)
                                    Text(step)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.top, 4)
                    },
                    label: {
                        HStack {
                            Image(systemName: "list.bullet.clipboard")
                                .font(.caption)
                            Text("Form Cues & Instructions")
                                .font(.caption.bold())
                        }
                        .foregroundStyle(GFTheme.accent)
                    }
                )
                .padding(.horizontal, 4)
            }
        }
        .task(id: exerciseID) {
            isDemonstrationVisible = false
            await viewModel.load(for: exerciseID)
        }
        .accessibilityLabel("Exercise demonstration for \(exerciseID)")
    }

    @ViewBuilder
    private var mediaContent: some View {
        if let url = localVideoURL {
            VideoPlayer(player: AVPlayer(url: url))
                .overlay(alignment: .topTrailing) {
                    silentBadge
                }
        } else if !isDemonstrationVisible {
            // Default: Empty section with the steady stick figure, completely offline & local
            originalEmptySection
        } else {
            // Only when user clicks: show the demonstration movement
            switch viewModel.state {
            case .idle, .loading:
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(GFTheme.card)
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(GFTheme.accent)
                        Text("Loading demonstration...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

            case .loaded:
                #if canImport(UIKit)
                if let data = viewModel.gifData {
                    ZStack {
                        NativeGIFView(gifData: data, isPlaying: true)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(12)

                        // Top controls overlay
                        VStack {
                            HStack {
                                HStack(spacing: 5) {
                                    Circle()
                                        .fill(GFTheme.accent)
                                        .frame(width: 6, height: 6)
                                    Text("PLAYING")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(GFTheme.accent)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.75))
                                .clipShape(Capsule())

                                Spacer()

                                HStack(spacing: 6) {
                                    silentBadge

                                    Label("HIDE", systemImage: "xmark.circle.fill")
                                        .font(.system(size: 9, weight: .bold))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.black.opacity(0.75))
                                        .foregroundStyle(.white)
                                        .clipShape(Capsule())
                                }
                            }
                            Spacer()
                        }
                        .padding(10)
                    }
                } else {
                    originalEmptySection
                }
                #else
                originalEmptySection
                #endif

            case .fallback:
                #if canImport(UIKit)
                if let image = UIImage(named: exerciseID) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 240)
                } else {
                    originalEmptySection
                }
                #else
                originalEmptySection
                #endif
            }
        }
    }

    private var silentBadge: some View {
        Label("SILENT DEMO", systemImage: "speaker.slash.fill")
            .font(.system(size: 9, weight: .bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.black.opacity(0.75))
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }

    private var originalEmptySection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(GFTheme.card)

            VStack(spacing: 12) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 52))
                    .foregroundStyle(GFTheme.accent)

                Text(exerciseDisplayName)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text("Standard gym form demonstration")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 6) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 13, weight: .bold))
                    Text("Tap to View Movement")
                        .font(.caption.bold())
                }
                .foregroundStyle(GFTheme.accent)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(GFTheme.accent.opacity(0.12))
                .clipShape(Capsule())
                .padding(.top, 2)
            }
            .padding(24)
        }
    }

    private var exerciseDisplayName: String {
        exerciseInfo?.name ?? exerciseID.replacingOccurrences(of: "_", with: " ").capitalized
    }
}
