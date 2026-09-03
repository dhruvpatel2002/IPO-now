import SwiftUI

public struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("notifyOpen") private var notifyOpen = true
    @AppStorage("notifyAllotment") private var notifyAllotment = true
    @AppStorage("appAppearance") private var appAppearance = "System"
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("Alert Preferences") {
                    Toggle("Enable Push Notifications", isOn: $notificationsEnabled)
                    if notificationsEnabled {
                        Toggle("IPO Opening Alerts", isOn: $notifyOpen)
                        Toggle("Allotment Publication Alerts", isOn: $notifyAllotment)
                    }
                }
                
                Section("Appearance") {
                    Picker("Theme", selection: $appAppearance) {
                        Text("System").tag("System")
                        Text("Light").tag("Light")
                        Text("Dark").tag("Dark")
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Privacy & Security") {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(.green)
                        Text("PAN Data Policy")
                    }
                    Text("This app processes PAN numbers strictly in volatile memory to query allotment registrar systems. No PAN details are stored in persistent databases or analytics pipelines.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                Section("About IPOnow") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Market")
                        Spacer()
                        Text("India (NSE / BSE / SME / SSE)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
