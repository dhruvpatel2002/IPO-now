import SwiftUI

public struct StatusBadge: View {
    public let status: IPOStatus
    @State private var isPulsing = false
    
    public init(status: IPOStatus) {
        self.status = status
    }
    
    private var displayTitle: String {
        switch status {
        case .open:
            return "Open"
        case .upcoming:
            return "Upcoming"
        case .closed:
            return "Closed"
        case .allotmentOut:
            return "Allotment Out"
        case .listed:
            return "Listed"
        }
    }
    
    private var badgeColor: Color {
        switch status {
        case .open:
            return Color(hex: "22C55E")
        case .upcoming:
            return .brandPrimary
        case .closed:
            return .secondary
        case .allotmentOut:
            return Color(hex: "F27A24")
        case .listed:
            return Color(hex: "8B5CF6")
        }
    }
    
    public var body: some View {
        HStack(spacing: 5) {
            if status == .open {
                ZStack {
                    Circle()
                        .fill(badgeColor.opacity(0.45))
                        .frame(width: 12, height: 12)
                        .scaleEffect(isPulsing ? 1.5 : 0.7)
                        .opacity(isPulsing ? 0 : 0.9)
                    
                    Circle()
                        .fill(badgeColor)
                        .frame(width: 6, height: 6)
                }
                .frame(width: 12, height: 12)
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 1.2)
                        .repeatForever(autoreverses: false)
                    ) {
                        isPulsing = true
                    }
                }
            } else {
                Circle()
                    .fill(badgeColor)
                    .frame(width: 6, height: 6)
            }
            
            Text(displayTitle)
                .font(.helvetica(12, weight: .bold))
                .foregroundColor(badgeColor)
        }
    }
}
