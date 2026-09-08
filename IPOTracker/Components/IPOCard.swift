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
            // Header: Company Name, Type Tag, Exchange & Status Badge
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(ipo.companyName)
                        .font(.helvetica(17, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        Text(ipo.ipoType.rawValue)
                            .font(.helvetica(10, weight: .bold))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.secondary.opacity(0.12))
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.secondary.opacity(0.18), lineWidth: 0.8)
                            )
                        
                        Text(ipo.exchange)
                            .font(.helvetica(11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                StatusBadge(status: ipo.status)
            }
            
            Divider()
                .opacity(0.6)
            
            // Key Info Grid: Price Band, Lot Size, Issue Size, Timeline
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("PRICE BAND")
                        .font(.helvetica(10, weight: .medium))
                        .foregroundColor(.secondary)
                    Text(ipo.displayPriceBand)
                        .font(.helvetica(14, weight: .bold))
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("LOT SIZE")
                        .font(.helvetica(10, weight: .medium))
                        .foregroundColor(.secondary)
                    Text(ipo.displayLotSize)
                        .font(.helvetica(14, weight: .bold))
                }
                
                if ipo.issueSizeInCr > 0 {
                    Spacer()
                    VStack(alignment: .leading, spacing: 3) {
                        Text("ISSUE SIZE")
                            .font(.helvetica(10, weight: .medium))
                            .foregroundColor(.secondary)
                        Text(ipo.displayIssueSize)
                            .font(.helvetica(14, weight: .bold))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 3) {
                    Text("TIMELINE")
                        .font(.helvetica(10, weight: .medium))
                        .foregroundColor(.secondary)
                    Text(formattedTimeline)
                        .font(.helvetica(13, weight: .bold))
                }
            }
            
            // Footer: GMP / Listed Return Badge + Subscription Multiplier + Action
            HStack(spacing: 8) {
                if let lp = ipo.listedPrice, lp > 0, let lg = ipo.listingGainPercentage {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right.circle.fill")
                            .font(.helvetica(11, weight: .regular))
                            .foregroundColor(lg >= 0 ? .green : .red)
                        Text("Listed: ₹\(Int(lp)) (\(String(format: "%@%.1f%%", lg >= 0 ? "+" : "", lg)))")
                            .font(.helvetica(11, weight: .bold))
                            .foregroundColor(lg >= 0 ? .green : .red)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background((lg >= 0 ? Color.green : Color.red).opacity(0.12))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke((lg >= 0 ? Color.green : Color.red).opacity(0.24), lineWidth: 1)
                    )
                } else if ipo.gmp > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.helvetica(11, weight: .regular))
                            .foregroundColor(.green)
                        Text("GMP: +₹\(Int(ipo.gmp)) (\(String(format: "%.1f", ipo.gmpPercentage))%)")
                            .font(.helvetica(11, weight: .bold))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.12))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.green.opacity(0.24), lineWidth: 1)
                    )
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "chart.line.flattrend.xyaxis")
                            .font(.helvetica(11, weight: .regular))
                            .foregroundColor(.secondary)
                        Text("GMP: 0%")
                            .font(.helvetica(11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.secondary.opacity(0.18), lineWidth: 0.8)
                    )
                }
                
                if ipo.totalSubscription > 0 {
                    HStack(spacing: 3) {
                        Text("🔥")
                            .font(.helvetica(11, weight: .regular))
                        Text("\(String(format: "%.1f", ipo.totalSubscription))x")
                            .font(.helvetica(11, weight: .bold))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.12))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.orange.opacity(0.24), lineWidth: 1)
                    )
                }
                
                Spacer()
                
                if (ipo.status == .allotmentOut || ipo.status == .closed), let onCheckAllotment {
                    Button(action: onCheckAllotment) {
                        HStack(spacing: 4) {
                            Text("Check Allotment")
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        .font(.helvetica(11, weight: .bold))
                        .foregroundColor(.brandPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.brandPrimary.opacity(0.12))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.brandPrimary.opacity(0.24), lineWidth: 1)
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
}
