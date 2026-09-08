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
                // Theme & Appearance Section (3 Little Cards in Same Row)
                Section("Appearance & Theme") {
                    HStack(spacing: 10) {
                        ThemeOptionCard(
                            title: "System",
                            subtitle: "Auto",
                            iconName: "circle.lefthalf.filled",
                            isSelected: appAppearance == "System"
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                appAppearance = "System"
                            }
                        }
                        
                        ThemeOptionCard(
                            title: "Light",
                            subtitle: "Daylight",
                            iconName: "sun.max.fill",
                            isSelected: appAppearance == "Light"
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                appAppearance = "Light"
                            }
                        }
                        
                        ThemeOptionCard(
                            title: "Dark",
                            subtitle: "Midnight",
                            iconName: "moon.stars.fill",
                            isSelected: appAppearance == "Dark"
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                appAppearance = "Dark"
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    .listRowInsets(EdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 14))
                    .listRowBackground(Color.clear)
                }
                
                Section("Alert Preferences") {
                    Toggle("Enable Push Notifications", isOn: $notificationsEnabled)
                    if notificationsEnabled {
                        Toggle("IPO Opening Alerts", isOn: $notifyOpen)
                        Toggle("Allotment Publication Alerts", isOn: $notifyAllotment)
                    }
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
                        Text("India (NSE / BSE / SME)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct ThemeOptionCard: View {
    let title: String
    let subtitle: String
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.accentColor.opacity(0.18) : Color.primary.opacity(0.06))
                        .frame(width: 36, height: 36)
                    Image(systemName: iconName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(isSelected ? .accentColor : .secondary)
                }
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.caption.weight(isSelected ? .bold : .medium))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(isSelected ? .accentColor : .secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ? Color.accentColor : Color.primary.opacity(0.08),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: isSelected ? Color.accentColor.opacity(0.12) : Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}
