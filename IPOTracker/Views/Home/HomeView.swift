import SwiftUI

public struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedIPOForAllotment: IPO?
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    // Header Subtitle
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Discover. Analyze. Check allotment.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Dashboard Metrics
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        MetricCard(
                            title: "Open Now",
                            value: "\(viewModel.openCount)",
                            iconName: "circle.fill",
                            accentColor: .green
                        )
                        MetricCard(
                            title: "Closing Soon",
                            value: "\(viewModel.closingSoonCount)",
                            iconName: "clock.badge.exclamationmark.fill",
                            accentColor: .orange
                        )
                        MetricCard(
                            title: "Allotment Today",
                            value: "\(viewModel.allotmentTodayCount)",
                            iconName: "doc.text.magnifyingglass",
                            accentColor: .blue
                        )
                        MetricCard(
                            title: "Upcoming",
                            value: "\(viewModel.upcomingCount)",
                            iconName: "calendar",
                            accentColor: .purple
                        )
                    }
                    .padding(.horizontal)
                    
                    // Featured IPO Card
                    if let featured = viewModel.featuredIPO {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Featured IPO")
                                .font(.title3.weight(.bold))
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
                    
                    // Open & Upcoming Sections
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Current Market Action")
                                .font(.title3.weight(.bold))
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        ForEach(viewModel.ipos.prefix(3)) { ipo in
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
                .padding(.vertical)
            }
            .navigationTitle("IPOs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "bell.badge")
                        .foregroundColor(.primary)
                }
            }
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
