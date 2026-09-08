import SwiftUI
import SwiftData

@main
struct IPOTrackerApp: App {
    @AppStorage("appAppearance") private var appAppearance = "System"
    
    private var colorScheme: ColorScheme? {
        switch appAppearance {
        case "Light": return .light
        case "Dark": return .dark
        default: return nil // Follows system setting
        }
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            IPO.self,
            WatchlistItem.self,
            SavedPAN.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(colorScheme)
        }
        .modelContainer(sharedModelContainer)
    }
}
