import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab = 0
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            IPOListView()
                .tabItem {
                    Label {
                        Text("IPOs")
                    } icon: {
                        Image("IPOTabIcon")
                    }
                }
                .tag(0)
            
            AllotmentTabView()
                .tabItem {
                    Label("Allotment", systemImage: "doc.text.magnifyingglass")
                }
                .tag(1)
            
            SavedPANsView()
                .tabItem {
                    Label("PANs", systemImage: "person.text.rectangle.fill")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
    }
}
