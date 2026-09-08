import SwiftUI

public struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedIPOForAllotment: IPO?
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    
                    // 1. Featured Spotlight Issue
                    if let featured = viewModel.featuredIPO {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 8, height: 8)
                                        .shadow(color: Color.green.opacity(0.8), radius: 4, x: 0, y: 0)
                                    Text("SPOTLIGHT ISSUE")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.green)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.12))
                                .cornerRadius(8)
                                
                                Spacer()
                                
                                if featured.gmp > 0 {
                                    Text("Top GMP Demand")
                                        .font(.caption2.weight(.semibold))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal)
                            
                            NavigationLink(destination: IPODetailView(ipo: featured)) {
                                IPOCard(ipo: featured) {
                                    selectedIPOForAllotment = featured
                                }
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                        }
                    }
                    
                    // 2. Bento Key Metrics Grid (4 Subtle Gradient Cards)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Market Snapshot")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            GradientMetricCard(
                                title: "Active Issues",
                                value: "\(viewModel.openCount)",
                                subtitle: "Bidding open today",
                                iconName: "flame.fill",
                                gradientColors: [Color.green, Color.teal],
                                isLive: viewModel.openCount > 0
                            )
                            
                            GradientMetricCard(
                                title: "Closing Soon",
                                value: "\(viewModel.closingSoonCount)",
                                subtitle: "Within 48 hours",
                                iconName: "clock.badge.exclamationmark.fill",
                                gradientColors: [Color.orange, Color.red]
                            )
                            
                            GradientMetricCard(
                                title: "Allotment Out",
                                value: "\(viewModel.allotmentTodayCount)",
                                subtitle: "Check results now",
                                iconName: "checkmark.seal.fill",
                                gradientColors: [Color.blue, Color.cyan]
                            )
                            
                            GradientMetricCard(
                                title: "Pipeline",
                                value: "\(viewModel.upcomingCount)",
                                subtitle: "Upcoming this month",
                                iconName: "calendar.badge.clock",
                                gradientColors: [Color.purple, Color.indigo]
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // 3. Top GMP Gainers (Horizontal Card Feed)
                    if !viewModel.topGMPGainers.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Top GMP Buzz")
                                    .font(.headline)
                                Spacer()
                                Text("Grey Market Leaders")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.topGMPGainers.prefix(6)) { ipo in
                                        NavigationLink(destination: IPODetailView(ipo: ipo)) {
                                            VStack(alignment: .leading, spacing: 10) {
                                                HStack(alignment: .top) {
                                                    Text(ipo.companyName)
                                                        .font(.subheadline.weight(.semibold))
                                                        .foregroundColor(.primary)
                                                        .lineLimit(1)
                                                    Spacer()
                                                    Text(ipo.ipoType.rawValue)
                                                        .font(.system(size: 10, weight: .bold))
                                                        .padding(.horizontal, 6)
                                                        .padding(.vertical, 2)
                                                        .background(Color.secondary.opacity(0.12))
                                                        .cornerRadius(4)
                                                }
                                                
                                                Divider()
                                                
                                                HStack {
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text("PRICE")
                                                            .font(.system(size: 9, weight: .bold))
                                                            .foregroundColor(.secondary)
                                                        Text(ipo.displayPriceBand)
                                                            .font(.caption.weight(.semibold))
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                    VStack(alignment: .trailing, spacing: 2) {
                                                        Text("EXP. GAIN")
                                                            .font(.system(size: 9, weight: .bold))
                                                            .foregroundColor(.green)
                                                        Text("+\(String(format: "%.1f", ipo.gmpPercentage))%")
                                                            .font(.caption.weight(.bold))
                                                            .foregroundColor(.green)
                                                    }
                                                }
                                            }
                                            .padding(14)
                                            .frame(width: 220)
                                            .background(
                                                LinearGradient(
                                                    colors: [
                                                        Color.green.opacity(0.08),
                                                        Color(UIColor.secondarySystemBackground)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .cornerRadius(14)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(Color.green.opacity(0.2), lineWidth: 1)
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // 4. Recent Live Actions
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recent Live Actions")
                                .font(.headline)
                            Spacer()
                            Text("Latest market updates")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        ForEach(viewModel.ipos.prefix(6)) { ipo in
                            NavigationLink(destination: IPODetailView(ipo: ipo)) {
                                IPOCard(ipo: ipo) {
                                    selectedIPOForAllotment = ipo
                                }
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical, 12)
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedIPOForAllotment) { ipo in
                AllotmentCheckerSheet(ipo: ipo)
            }
            .task {
                await viewModel.loadData()
            }
            .refreshable {
                await viewModel.loadData()
            }
        }
    }
}
