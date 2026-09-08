import SwiftUI

public struct IPOCard: View {
    public let ipo: IPO
    public var onCheckAllotment: (() -> Void)? = nil
    
    public init(ipo: IPO, onCheckAllotment: (() -> Void)? = nil) {
        self.ipo = ipo
        self.onCheckAllotment = onCheckAllotment
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
    
    private var timelineProgress: Double {
        let now = Date().timeIntervalSince1970
        let start = ipo.openingDate.timeIntervalSince1970
        let end = ipo.closingDate.timeIntervalSince1970
        if now < start {
            return 0.15
        } else if now > end {
            return ipo.status == .listed ? 1.0 : 0.85
        } else {
            let total = max(end - start, 1)
            let elapsed = max(now - start, 0)
            let ratio = elapsed / total
            return min(max(ratio * 0.7 + 0.15, 0.2), 0.85)
        }
    }
    
    private var progressColor: Color {
        switch ipo.status {
        case .open: return Color(hex: "22C55E")
        case .upcoming: return .brandPrimary
        case .allotmentOut: return Color(hex: "F27A24")
        case .closed: return .secondary
        case .listed: return Color(hex: "8B5CF6")
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 1. Header: Company Name + Type + Simple Colored Status (with pulse dot)
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ipo.companyName)
                        .font(.helvetica(18, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text("\(ipo.ipoType.rawValue) • \(ipo.exchange)")
                        .font(.helvetica(12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: ipo.status)
            }
            
            // 2. Main Financial Metrics (Ample whitespace & clean hierarchy)
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("PRICE BAND")
                        .font(.helvetica(10, weight: .semibold))
                        .foregroundColor(.secondary)
                    Text(ipo.displayPriceBand)
                        .font(.helvetica(15, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("LOT SIZE")
                        .font(.helvetica(10, weight: .semibold))
                        .foregroundColor(.secondary)
                    Text(ipo.displayLotSize)
                        .font(.helvetica(15, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                if ipo.issueSizeInCr > 0 {
                    Spacer()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ISSUE SIZE")
                            .font(.helvetica(10, weight: .semibold))
                            .foregroundColor(.secondary)
                        Text(ipo.displayIssueSize)
                            .font(.helvetica(15, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
            }
            
            // 3. Tags & Actions Row (Solid Green GMP badge, Subscription, CTA)
            HStack(spacing: 8) {
                if ipo.gmp > 0 {
                    Text("GMP +₹\(Int(ipo.gmp)) (\(String(format: "%.1f", ipo.gmpPercentage))%)")
                        .font(.helvetica(11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4.5)
                        .background(Color(hex: "16A34A"))
                        .cornerRadius(6)
                } else if let lp = ipo.listedPrice, lp > 0, let lg = ipo.listingGainPercentage {
                    Text("Listed ₹\(Int(lp)) (\(String(format: "%@%.1f%%", lg >= 0 ? "+" : "", lg)))")
                        .font(.helvetica(11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4.5)
                        .background(lg >= 0 ? Color(hex: "16A34A") : Color.red)
                        .cornerRadius(6)
                } else {
                    Text("GMP 0%")
                        .font(.helvetica(11, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4.5)
                        .background(Color.primary.opacity(0.06))
                        .cornerRadius(6)
                }
                
                if ipo.totalSubscription > 0 {
                    Text("🔥 \(String(format: "%.1f", ipo.totalSubscription))x")
                        .font(.helvetica(11, weight: .bold))
                        .foregroundColor(Color(hex: "F27A24"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4.5)
                        .background(Color(hex: "F27A24").opacity(0.12))
                        .cornerRadius(6)
                }
                
                Spacer()
                
                if (ipo.status == .allotmentOut || ipo.status == .closed), let onCheckAllotment {
                    Button(action: onCheckAllotment) {
                        HStack(spacing: 3) {
                            Text("Allotment")
                            Image(systemName: "chevron.right")
                                .font(.helvetica(9, weight: .bold))
                        }
                        .font(.helvetica(11, weight: .bold))
                        .foregroundColor(.brandPrimary)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4.5)
                        .background(Color.brandPrimary.opacity(0.12))
                        .cornerRadius(6)
                    }
                }
            }
            
            // 4. Timeline Progress Bar UI Element along lower bottom
            VStack(spacing: 5) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.primary.opacity(0.06))
                            .frame(height: 4)
                        
                        Capsule()
                            .fill(progressColor)
                            .frame(width: max(geo.size.width * timelineProgress, 12), height: 4)
                    }
                }
                .frame(height: 4)
                
                HStack {
                    Text("Opens \(formatDate(ipo.openingDate))")
                        .font(.helvetica(10, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Closes \(formatDate(ipo.closingDate))")
                        .font(.helvetica(10, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 2)
        }
        .padding(18)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
}
