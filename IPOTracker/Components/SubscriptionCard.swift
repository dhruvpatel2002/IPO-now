import SwiftUI

public struct SubscriptionCard: View {
    public let ipo: IPO
    
    public init(ipo: IPO) {
        self.ipo = ipo
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Total Subscription")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Text("\(String(format: "%.2f", ipo.totalSubscription))x")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(ipo.totalSubscription >= 1.0 ? .green : .orange)
            }
            
            Divider()
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                SubscriptionItem(category: "Retail (RII)", multiple: ipo.retailSubscription)
                SubscriptionItem(category: "Non-Institutional (NII)", multiple: ipo.niiSubscription)
                SubscriptionItem(category: "Qualified Institutional (QIB)", multiple: ipo.qibSubscription)
                SubscriptionItem(category: "Employee", multiple: ipo.employeeSubscription)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct SubscriptionItem: View {
    let category: String
    let multiple: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(category)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.secondary)
            Text("\(String(format: "%.2f", multiple))x")
                .font(.system(size: 14, weight: .bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .cornerRadius(8)
    }
}

public struct FinancialMetricGrid: View {
    public let ipo: IPO
    
    public init(ipo: IPO) {
        self.ipo = ipo
    }
    
    public var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            MetricCard(title: "Revenue", value: "₹\(Int(ipo.revenueInCr)) Cr")
            MetricCard(title: "Net Profit", value: "₹\(Int(ipo.profitInCr)) Cr", accentColor: .green)
            MetricCard(title: "EPS", value: "₹\(String(format: "%.2f", ipo.eps))")
            MetricCard(title: "P/E Ratio", value: "\(String(format: "%.2f", ipo.peRatio))x")
            MetricCard(title: "ROE", value: "\(String(format: "%.1f", ipo.roe))%")
            MetricCard(title: "Total Debt", value: "₹\(Int(ipo.debtInCr)) Cr", accentColor: .orange)
        }
    }
}
