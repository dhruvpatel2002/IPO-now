import SwiftUI
import SwiftData

@main
struct IPOTrackerApp: App {
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
        }
        .modelContainer(sharedModelContainer)
    }
}
