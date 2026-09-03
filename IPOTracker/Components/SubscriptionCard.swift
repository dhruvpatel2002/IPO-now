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
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(String(format: "%.2f", ipo.totalSubscription))x")
                    .font(.headline.weight(.bold))
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
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}

private struct SubscriptionItem: View {
    let category: String
    let multiple: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(category)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("\(String(format: "%.2f", multiple))x")
                .font(.subheadline.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color(UIColor.tertiarySystemBackground))
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
