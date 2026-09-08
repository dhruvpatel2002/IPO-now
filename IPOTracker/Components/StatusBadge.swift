import SwiftUI

public struct StatusBadge: View {
    public let status: IPOStatus
    
    public init(status: IPOStatus) {
        self.status = status
    }
    
    private var badgeColor: Color {
        switch status {
        case .open:
            return .green
        case .upcoming:
            return .blue
        case .closed:
            return .secondary
        case .allotmentOut:
            return .orange
        case .listed:
            return .purple
        }
    }
    
    public var body: some View {
        Text(status.rawValue)
            .font(.helvetica(11, weight: .bold))
            .foregroundColor(badgeColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(badgeColor.opacity(0.12))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(badgeColor.opacity(0.24), lineWidth: 1)
            )
    }
}
