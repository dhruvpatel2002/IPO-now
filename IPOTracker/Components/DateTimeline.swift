import SwiftUI

public struct DateTimeline: View {
    public let ipo: IPO
    
    public init(ipo: IPO) {
        self.ipo = ipo
    }
    
    private struct Milestone: Identifiable {
        let id = UUID()
        let title: String
        let date: Date
        let isCompleted: Bool
        let isCurrent: Bool
    }
    
    private var milestones: [Milestone] {
        let now = Date()
        let items: [(String, Date)] = [
            ("IPO Opens", ipo.openingDate),
            ("IPO Closes", ipo.closingDate),
            ("Basis of Allotment", ipo.allotmentDate),
            ("Refunds Initiation", ipo.refundDate),
            ("Demat Transfer", ipo.dematDate),
            ("Listing on Exchange", ipo.listingDate)
        ]
        
        return items.enumerated().map { index, item in
            let isPast = now >= item.1
            let isNextUpcoming = !isPast && (index == 0 || now >= items[index - 1].1)
            return Milestone(
                title: item.0,
                date: item.1,
                isCompleted: isPast,
                isCurrent: isNextUpcoming
            )
        }
    }
    
    private func formattedMilestoneDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: date)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(milestones.indices, id: \.self) { index in
                let item = milestones[index]
                HStack(alignment: .top, spacing: 14) {
                    // Node & connector
                    VStack(spacing: 0) {
                        Circle()
                            .fill(item.isCurrent ? Color.accentColor : (item.isCompleted ? Color.green : Color.secondary.opacity(0.3)))
                            .frame(width: 14, height: 14)
                            .overlay(
                                Circle()
                                    .stroke(item.isCurrent ? Color.accentColor.opacity(0.3) : Color.clear, lineWidth: 4)
                            )
                        
                        if index < milestones.count - 1 {
                            Rectangle()
                                .fill(item.isCompleted ? Color.green : Color.secondary.opacity(0.2))
                                .frame(width: 2, height: 34)
                        }
                    }
                    
                    // Milestone title & date
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(item.title)
                                .font(.subheadline.weight(item.isCurrent ? .bold : .medium))
                                .foregroundColor(item.isCurrent ? .primary : (item.isCompleted ? .primary : .secondary))
                            
                            if item.isCurrent {
                                Text("NEXT")
                                    .font(.system(size: 9, weight: .bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.accentColor.opacity(0.15))
                                    .foregroundColor(.accentColor)
                                    .cornerRadius(4)
                            }
                        }
                        
                        Text(formattedMilestoneDate(item.date))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}
