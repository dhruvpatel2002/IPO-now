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
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(companyAvatarColor)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(ipo.companyName)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(ipo.ipoType.rawValue)
                        .font(.system(size: 12, weight: .semibold))
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
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                    Text(ipo.displayPriceBand)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Stat 2: Subscription (Normal clean primary/white color)
                VStack(alignment: .leading, spacing: 4) {
                    Text("SUBSCRIPTION")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    if ipo.totalSubscription > 0 {
                        Text("\(String(format: "%.2f", ipo.totalSubscription))x")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.primary)
                    } else {
                        Text("—")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Stat 3: GMP Mini Card (Bigger, Subtle Green Shade with Big Amount & Smaller Percent)
                if ipo.gmp > 0 {
                    VStack(spacing: 2) {
                        Text("+₹\(Int(ipo.gmp))")
                            .font(.system(size: 16, weight: .heavy))
                            .foregroundColor(.white)
                        Text("\(String(format: "%.1f", ipo.gmpPercentage))%")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.92))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color(hex: "10B981"))
                    .cornerRadius(12)
                } else if let lp = ipo.listedPrice, lp > 0, let lg = ipo.listingGainPercentage {
                    VStack(spacing: 2) {
                        Text("₹\(Int(lp))")
                            .font(.system(size: 16, weight: .heavy))
                            .foregroundColor(.white)
                        Text("\(String(format: "%@%.1f%%", lg >= 0 ? "+" : "", lg))")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.92))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(lg >= 0 ? Color(hex: "10B981") : Color.red.opacity(0.85))
                    .cornerRadius(12)
                } else {
                    VStack(spacing: 2) {
                        Text("₹0")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.secondary)
                        Text("0.0%")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.primary.opacity(0.06))
                    .cornerRadius(12)
                }
            }
        }
        .padding(18)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
}

// MARK: - Half Screen Quick Summary Sheet
public struct IPOQuickSummarySheet: View {
    public let ipo: IPO
    public var onOpenFullDetail: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    public init(ipo: IPO, onOpenFullDetail: @escaping () -> Void) {
        self.ipo = ipo
        self.onOpenFullDetail = onOpenFullDetail
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: date)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header: Logo + Name + Category + Status
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.brandPrimary.opacity(0.14))
                        .frame(width: 48, height: 48)
                    
                    Text(String(ipo.companyName.prefix(2)).uppercased())
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.brandPrimary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(ipo.companyName)
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(ipo.ipoType.rawValue)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: ipo.status)
            }
            .padding(.top, 10)
            
            // Key Information Bento Grid (2x2)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                QuickInfoBox(title: "Price Range", value: ipo.displayPriceBand, subtitle: "Per share")
                QuickInfoBox(title: "Lot Size", value: "\(ipo.lotSize) Shares", subtitle: "Min ₹\(Int(ipo.minimumInvestment))")
                QuickInfoBox(title: "Issue Size", value: ipo.issueSizeInCr > 0 ? "₹\(Int(ipo.issueSizeInCr)) Cr" : "TBA", subtitle: "Total offer")
                QuickInfoBox(
                    title: "Est. Profit (1 Lot)",
                    value: ipo.gmp > 0 ? "+₹\(Int(Double(ipo.lotSize) * ipo.gmp))" : "₹0",
                    subtitle: ipo.gmp > 0 ? "\(String(format: "%.1f", ipo.gmpPercentage))% GMP gain" : "0% GMP",
                    valueColor: ipo.gmp > 0 ? Color(hex: "10B981") : .primary
                )
            }
            
            // Important Dates Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Important Timeline Dates")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
                
                VStack(spacing: 8) {
                    DateRow(label: "Opening Date", dateString: formatDate(ipo.openingDate), icon: "calendar.badge.clock")
                    DateRow(label: "Closing Date", dateString: formatDate(ipo.closingDate), icon: "clock.badge.exclamationmark")
                    DateRow(label: "Allotment Date", dateString: formatDate(ipo.allotmentDate), icon: "checkmark.seal")
                    DateRow(label: "Listing Date", dateString: formatDate(ipo.listingDate), icon: "chart.line.uptrend.xyaxis")
                }
                .padding(12)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(14)
            }
            
            Spacer()
            
            // Bottom Button: View Full IPO Details
            Button {
                dismiss()
                onOpenFullDetail()
            } label: {
                HStack(spacing: 8) {
                    Text("IPO Details")
                        .font(.system(size: 16, weight: .bold))
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 17))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.brandPrimary)
                .foregroundColor(.white)
                .cornerRadius(14)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .background(Color(UIColor.systemGroupedBackground))
        .presentationDetents([.fraction(0.68), .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
    }
}

private struct QuickInfoBox: View {
    let title: String
    let value: String
    let subtitle: String
    var valueColor: Color = .primary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(valueColor)
                .lineLimit(1)
            
            Text(subtitle)
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(.secondary.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

private struct DateRow: View {
    let label: String
    let dateString: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .frame(width: 18)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            Spacer()
            Text(dateString)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.primary)
        }
    }
}
