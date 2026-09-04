import SwiftUI

public struct IPOCard: View {
    public let ipo: IPO
    public var onCheckAllotment: (() -> Void)? = nil
    
    public init(ipo: IPO, onCheckAllotment: (() -> Void)? = nil) {
        self.ipo = ipo
        self.onCheckAllotment = onCheckAllotment
    }
    
    private var formattedTimeline: String {
        if ipo.priceLow == 0 && ipo.priceHigh == 0 && ipo.status == .upcoming {
            return "TBA"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return "\(formatter.string(from: ipo.openingDate)) – \(formatter.string(from: ipo.closingDate))"
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header: Name, Type, Status Badge
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ipo.companyName)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        Text(ipo.ipoType.rawValue)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.12))
                            .cornerRadius(4)
                        
                        Text(ipo.exchange)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                StatusBadge(status: ipo.status)
            }
            
            Divider()
            
            // Key Info Grid: Price, Lot Size, Issue Size, Dates
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("PRICE BAND")
                        .font(.caption2.weight(.medium))
                        .foregroundColor(.secondary)
                    Text(ipo.displayPriceBand)
                        .font(.subheadline.weight(.semibold))
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("LOT SIZE")
                        .font(.caption2.weight(.medium))
                        .foregroundColor(.secondary)
                    Text(ipo.displayLotSize)
                        .font(.subheadline.weight(.semibold))
                }
                
                if ipo.issueSizeInCr > 0 {
                    Spacer()
                    VStack(alignment: .leading, spacing: 3) {
                        Text("ISSUE SIZE")
                            .font(.caption2.weight(.medium))
                            .foregroundColor(.secondary)
                        Text(ipo.displayIssueSize)
                            .font(.subheadline.weight(.semibold))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 3) {
                    Text("TIMELINE")
                        .font(.caption2.weight(.medium))
                        .foregroundColor(.secondary)
                    Text(formattedTimeline)
                        .font(.subheadline.weight(.medium))
                }
            }
            
            // Footer: GMP & Subscription + Optional Allotment CTA
            HStack(spacing: 8) {
                if ipo.gmp > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.caption2)
                            .foregroundColor(.green)
                        Text("GMP: +₹\(Int(ipo.gmp)) (\(String(format: "%.1f", ipo.gmpPercentage))%)")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(6)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "chart.line.flattrend.xyaxis")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("GMP: 0%")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(6)
                }
                
                if ipo.totalSubscription > 0 {
                    HStack(spacing: 3) {
                        Text("🔥")
                            .font(.caption2)
                        Text("\(String(format: "%.1f", ipo.totalSubscription))x")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.12))
                    .cornerRadius(6)
                }
                
                Spacer()
                
                if (ipo.status == .allotmentOut || ipo.status == .closed), let onCheckAllotment {
                    Button(action: onCheckAllotment) {
                        HStack(spacing: 4) {
                            Text("Check Allotment")
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}
