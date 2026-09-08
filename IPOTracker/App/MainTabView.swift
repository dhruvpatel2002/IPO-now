import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab = 0
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2.fill")
                }
                .tag(0)
            
            IPOListView()
                .tabItem {
                    Label("IPOs", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(1)
            
            AllotmentTabView()
                .tabItem {
                    Label("Allotment", systemImage: "doc.text.magnifyingglass")
                }
                .tag(2)
            
            SavedPANsView()
                .tabItem {
                    Label("PANs", systemImage: "person.text.rectangle.fill")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
    }
}
