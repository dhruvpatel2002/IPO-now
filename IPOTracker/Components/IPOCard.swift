import SwiftUI

public struct IPOCard: View {
    public let ipo: IPO
    public var onCheckAllotment: (() -> Void)? = nil
    
    public init(ipo: IPO, onCheckAllotment: (() -> Void)? = nil) {
        self.ipo = ipo
        self.onCheckAllotment = onCheckAllotment
    }
    
    private var companyInitials: String {
        let clean = ipo.companyName
            .replacingOccurrences(of: "Limited", with: "")
            .replacingOccurrences(of: "Ltd", with: "")
            .replacingOccurrences(of: "India", with: "")
            .trimmingCharacters(in: .whitespaces)
        let words = clean.components(separatedBy: " ").filter { !$0.isEmpty }
        if words.count >= 2, let first = words[0].first, let second = words[1].first {
            return "\(first)\(second)".uppercased()
        } else if let first = clean.first {
            return String(first).uppercased()
        }
        return "IP"
    }
    
    private var companyAvatarColor: Color {
        let colors: [Color] = [
            Color(hex: "00A6ED"),
            Color(hex: "8B5CF6"),
            Color(hex: "10B981"),
            Color(hex: "F27A24"),
            Color(hex: "EC4899"),
            Color(hex: "6366F1")
        ]
        let hash = abs(ipo.companyName.hashValue)
        return colors[hash % colors.count]
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 1. Header: Company Logo Avatar + Name + Subtitle (Mainboard/SME) + Status Badge
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(companyAvatarColor.opacity(0.14))
                        .frame(width: 44, height: 44)
                    
                    Text(companyInitials)
                        .font(.helvetica(15, weight: .bold))
                        .foregroundColor(companyAvatarColor)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(ipo.companyName)
                        .font(.helvetica(17, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(ipo.ipoType.rawValue)
                        .font(.helvetica(12, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: ipo.status)
            }
            
            // 2. Three Horizontal Stats: Issue Price, Subscription, and GMP Card
            HStack(alignment: .center, spacing: 10) {
                // Stat 1: Issue Price
                VStack(alignment: .leading, spacing: 4) {
                    Text("ISSUE PRICE")
                        .font(.helvetica(10, weight: .semibold))
                        .foregroundColor(.secondary)
                    Text(ipo.displayPriceBand)
                        .font(.helvetica(15, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Stat 2: Subscription
                VStack(alignment: .leading, spacing: 4) {
                    Text("SUBSCRIPTION")
                        .font(.helvetica(10, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    if ipo.totalSubscription > 0 {
                        Text("\(String(format: "%.2f", ipo.totalSubscription))x")
                            .font(.helvetica(15, weight: .bold))
                            .foregroundColor(ipo.totalSubscription >= 1.0 ? Color(hex: "22C55E") : .primary)
                    } else {
                        Text("—")
                            .font(.helvetica(15, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Stat 3: GMP Mini Card (Solid Green Tag with Big Amount & Smaller Percent)
                if ipo.gmp > 0 {
                    VStack(spacing: 1) {
                        Text("+₹\(Int(ipo.gmp))")
                            .font(.helvetica(15, weight: .heavy))
                            .foregroundColor(.white)
                        Text("\(String(format: "%.1f", ipo.gmpPercentage))%")
                            .font(.helvetica(10, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color(hex: "16A34A"))
                    .cornerRadius(10)
                } else if let lp = ipo.listedPrice, lp > 0, let lg = ipo.listingGainPercentage {
                    VStack(spacing: 1) {
                        Text("₹\(Int(lp))")
                            .font(.helvetica(15, weight: .heavy))
                            .foregroundColor(.white)
                        Text("\(String(format: "%@%.1f%%", lg >= 0 ? "+" : "", lg))")
                            .font(.helvetica(10, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(lg >= 0 ? Color(hex: "16A34A") : Color.red)
                    .cornerRadius(10)
                } else {
                    VStack(spacing: 1) {
                        Text("₹0")
                            .font(.helvetica(14, weight: .bold))
                            .foregroundColor(.secondary)
                        Text("0.0%")
                            .font(.helvetica(10, weight: .medium))
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.primary.opacity(0.06))
                    .cornerRadius(10)
                }
            }
        }
        .padding(18)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
}
