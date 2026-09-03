import SwiftUI

public struct IPODetailView: View {
    public let ipo: IPO
    @StateObject private var viewModel: IPODetailViewModel
    @State private var showObjectiveExpanded = false
    
    public init(ipo: IPO) {
        self.ipo = ipo
        _viewModel = StateObject(wrappedValue: IPODetailViewModel(ipo: ipo))
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Banner
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(ipo.companyName)
                            .font(.title2.weight(.bold))
                        Spacer()
                        StatusBadge(status: ipo.status)
                    }
                    
                    HStack(spacing: 8) {
                        Text(ipo.ipoType.rawValue)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.secondary.opacity(0.12))
                            .cornerRadius(6)
                        
                        Text(ipo.exchange)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(ipo.industry)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // Primary Allotment CTA if applicable
                if ipo.status == .allotmentOut || ipo.status == .closed {
                    PrimaryButton(
                        title: "Check Allotment Status",
                        iconName: "magnifyingglass.circle.fill"
                    ) {
                        viewModel.showAllotmentSheet = true
                    }
                    .padding(.horizontal)
                }
                
                // Key IPO Overview
                VStack(alignment: .leading, spacing: 12) {
                    Text("IPO Overview")
                        .font(.headline)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        MetricCard(title: "Price Band", value: ipo.displayPriceBand)
                        MetricCard(title: "Lot Size", value: ipo.displayLotSize)
                        MetricCard(title: "Min. Investment", value: ipo.displayMinimumInvestment)
                        MetricCard(title: "Issue Size", value: ipo.displayIssueSize)
                        MetricCard(title: "Fresh Issue", value: ipo.freshIssueInCr > 0 ? "₹\(Int(ipo.freshIssueInCr)) Cr" : "TBA")
                        MetricCard(title: "Offer For Sale", value: ipo.offerForSaleInCr > 0 ? "₹\(Int(ipo.offerForSaleInCr)) Cr" : "TBA")
                    }
                }
                .padding(.horizontal)
                
                // Important Dates Timeline
                VStack(alignment: .leading, spacing: 12) {
                    Text("Important Dates & Timeline")
                        .font(.headline)
                    DateTimeline(ipo: ipo)
                }
                .padding(.horizontal)
                
                // Subscription Info
                VStack(alignment: .leading, spacing: 12) {
                    Text("Subscription Status")
                        .font(.headline)
                    SubscriptionCard(ipo: ipo)
                }
                .padding(.horizontal)
                
                // Grey Market Premium (GMP)
                if ipo.gmp > 0 {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Grey Market Premium (GMP)")
                            .font(.headline)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Current GMP")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("₹\(Int(ipo.gmp))")
                                    .font(.title3.weight(.bold))
                                    .foregroundColor(.green)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Est. Listing Price")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("₹\(Int(ipo.expectedListingPrice)) (+\(String(format: "%.1f", ipo.gmpPercentage))%)")
                                    .font(.title3.weight(.bold))
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(Color.green.opacity(0.08))
                        .cornerRadius(14)
                        
                        Text("⚠️ GMP is an unofficial indicator based on grey market trades and does not guarantee listing returns.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
                
                // Company & Promoter Information
                VStack(alignment: .leading, spacing: 12) {
                    Text("Company Background")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(ipo.companyDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Divider()
                        
                        HStack {
                            Text("Headquarters")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(ipo.headquarters)
                                .font(.caption.weight(.medium))
                        }
                        
                        HStack {
                            Text("Promoters")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(ipo.promoterDetails)
                                .font(.caption.weight(.medium))
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                }
                .padding(.horizontal)
                
                // Financial Metrics
                VStack(alignment: .leading, spacing: 12) {
                    Text("Key Financials")
                        .font(.headline)
                    FinancialMetricGrid(ipo: ipo)
                }
                .padding(.horizontal)
                
                // IPO Objectives
                VStack(alignment: .leading, spacing: 12) {
                    Text("Objects of the Issue")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(ipo.ipoObjective, id: \.self) { objective in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle")
                                    .font(.caption)
                                    .foregroundColor(.accentColor)
                                Text(objective)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                }
                .padding(.horizontal)
                
                // Strengths & Risks
                VStack(alignment: .leading, spacing: 14) {
                    Text("Strengths & Risks")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Strengths")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.green)
                        ForEach(ipo.strengths, id: \.self) { strength in
                            HStack(alignment: .top, spacing: 6) {
                                Text("•")
                                    .foregroundColor(.green)
                                Text(strength)
                                    .font(.caption)
                            }
                        }
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        Text("Risks")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.red)
                        ForEach(ipo.risks, id: \.self) { risk in
                            HStack(alignment: .top, spacing: 6) {
                                Text("•")
                                    .foregroundColor(.red)
                                Text(risk)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .padding(.top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showAllotmentSheet) {
            AllotmentCheckerSheet(ipo: ipo)
        }
    }
}
