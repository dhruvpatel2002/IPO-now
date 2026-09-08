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
                                        .fill(Color.brandPrimary)
                                        .frame(width: 6, height: 6)
                                    Text("\(viewModel.openCount) LIVE")
                                        .font(.system(size: 10, weight: .heavy))
                                        .foregroundColor(.brandPrimary)
                                }
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
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            BlockMetricCard(
                                title: "Active Issues",
                                value: "\(viewModel.openCount)",
                                subtitle: "Bidding open today",
                                iconName: "flame.fill",
                                blockColor: .brandPrimary,
                                visualType: .bars,
                                isLive: viewModel.openCount > 0
                            )
                            
                            BlockMetricCard(
                                title: "Closing Soon",
                                value: "\(viewModel.closingSoonCount)",
                                subtitle: "Within 48 hours",
                                iconName: "clock.badge.exclamationmark.fill",
                                blockColor: Color(hex: "F27A24"),
                                visualType: .meter
                            )
                            
                            BlockMetricCard(
                                title: "Allotment Out",
                                value: "\(viewModel.allotmentTodayCount)",
                                subtitle: "Check results now",
                                iconName: "checkmark.seal.fill",
                                blockColor: Color(hex: "8CA858"),
                                visualType: .ring
                            )
                            
                            BlockMetricCard(
                                title: "Pipeline",
                                value: "\(viewModel.upcomingCount)",
                                subtitle: "Upcoming this month",
                                iconName: "calendar.badge.clock",
                                blockColor: Color(hex: "8B5CF6"),
                                visualType: .dots
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

