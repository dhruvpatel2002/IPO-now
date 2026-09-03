import SwiftUI

public struct MetricCard: View {
    public let title: String
    public let value: String
    public var subtitle: String? = nil
    public var iconName: String? = nil
    public var accentColor: Color = .blue
    
    public init(
        title: String,
        value: String,
        subtitle: String? = nil,
        iconName: String? = nil,
        accentColor: Color = .blue
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.iconName = iconName
        self.accentColor = accentColor
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                if let iconName {
                    Image(systemName: iconName)
                        .font(.caption)
                        .foregroundColor(accentColor)
                }
            }
            
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundColor(.primary)
            
            if let subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.04), lineWidth: 1)
        )
    }
}

public struct PrimaryButton: View {
    public let title: String
    public var iconName: String? = nil
    public var isLoading: Bool = false
    public let action: () -> Void
    
    public init(
        title: String,
        iconName: String? = nil,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.iconName = iconName
        self.isLoading = isLoading
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    if let iconName {
                        Image(systemName: iconName)
                            .font(.headline)
                    }
                    Text(title)
                        .font(.headline.weight(.semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(14)
        }
        .disabled(isLoading)
    }
}
