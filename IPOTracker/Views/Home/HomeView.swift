import SwiftUI

public struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedIPOForAllotment: IPO?
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // 1. Market Dashboard (Bento Snapshot Cards)
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Market Dashboard")
                                    .font(.title2.weight(.bold))
                                Text("Real-time Indian primary market overview")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if viewModel.openCount > 0 {
                                HStack(spacing: 5) {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 7, height: 7)
                                    Text("\(viewModel.openCount) LIVE")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.green)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.12))
                                .cornerRadius(8)
                            }
                        }
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
                    
                    // 2. Recent Live Actions
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Recent Live Actions")
                                    .font(.title3.weight(.bold))
                                Text("Latest subscriptions & market bids")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("\(viewModel.ipos.count) Total")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        if viewModel.ipos.isEmpty && viewModel.isLoading {
                            VStack(spacing: 12) {
                                ProgressView()
                                Text("Loading live market actions...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            ForEach(viewModel.ipos) { ipo in
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

