import SwiftUI

public struct AllotmentResultView: View {
    public let result: AllotmentResult
    public var onDismiss: () -> Void
    
    public var body: some View {
        VStack(spacing: 24) {
            // Status Icon & Title
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(statusBackgroundColor)
                        .frame(width: 72, height: 72)
                    
                    Image(systemName: statusIconName)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(statusForegroundColor)
                }
                
                Text(result.status.rawValue)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.primary)
                
                Text(result.ipoName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 12)
            
            // Result Summary Card
            VStack(spacing: 16) {
                if result.status == .allotted || result.status == .partiallyAllotted {
                    HStack {
                        Text("Shares Allotted")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(result.sharesAllotted)")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.green)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Application Status")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(result.applicationStatus)
                            .font(.headline)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Allotted Amount")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("₹\(Int(result.amount))")
                            .font(.headline.weight(.bold))
                    }
                }
                
                Text(result.message)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
            .padding(16)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
            
            Spacer()
            
            PrimaryButton(title: "Done", action: onDismiss)
        }
        .padding(20)
    }
    
    private var statusBackgroundColor: Color {
        switch result.status {
        case .allotted, .partiallyAllotted:
            return Color.green.opacity(0.15)
        case .notAllotted:
            return Color.secondary.opacity(0.15)
        case .notAvailable:
            return Color.orange.opacity(0.15)
        case .invalidPan, .error:
            return Color.red.opacity(0.15)
        }
    }
    
    private var statusForegroundColor: Color {
        switch result.status {
        case .allotted, .partiallyAllotted:
            return .green
        case .notAllotted:
            return .secondary
        case .notAvailable:
            return .orange
        case .invalidPan, .error:
            return .red
        }
    }
    
    private var statusIconName: String {
        switch result.status {
        case .allotted:
            return "checkmark.circle.fill"
        case .partiallyAllotted:
            return "checkmark.circle"
        case .notAllotted:
            return "xmark.circle"
        case .notAvailable:
            return "clock.badge.questionmark"
        case .invalidPan, .error:
            return "exclamationmark.triangle.fill"
        }
    }
}
