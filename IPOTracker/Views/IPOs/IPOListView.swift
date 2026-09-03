import SwiftUI

public struct IPOListView: View {
    @StateObject private var viewModel = IPOListViewModel()
    @State private var selectedIPOForAllotment: IPO?
    @State private var isSearchPresented: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top Level: Primary Category Tabs (Ongoing, Upcoming, Closed)
                HStack(spacing: 0) {
                    ForEach(IPOCategory.allCases) { category in
                        let isSelected = viewModel.selectedCategory == category
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.selectedCategory = category
                            }
                        } label: {
                            VStack(spacing: 8) {
                                HStack(spacing: 5) {
                                    Text(category.rawValue)
                                        .font(.subheadline.weight(isSelected ? .bold : .medium))
                                    
                                    Text("\(viewModel.countForCategory(category))")
                                        .font(.caption2.weight(.bold))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(
                                            isSelected ?
                                            Color.accentColor.opacity(0.18) :
                                            Color.secondary.opacity(0.12)
                                        )
                                        .foregroundColor(isSelected ? .accentColor : .secondary)
                                        .clipShape(Capsule())
                                }
                                .foregroundColor(isSelected ? .primary : .secondary)
                                .frame(maxWidth: .infinity)
                                
                                // Sliding Underline Indicator
                                Rectangle()
                                    .fill(isSelected ? Color.accentColor : Color.clear)
                                    .frame(height: 2.5)
                                    .cornerRadius(2)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 10)
                .background(Color(UIColor.systemBackground))
                
                Divider()
                
                // Second Level: Sub-Segment Filters (All, Mainboard, SME) with generous whitespace
                HStack(spacing: 10) {
                    Spacer()
                    ForEach(IPOSegmentFilter.allCases) { segment in
                        let isSelected = viewModel.selectedSegment == segment
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.selectedSegment = segment
                            }
                        } label: {
                            Text(segment.rawValue)
                                .font(.caption.weight(isSelected ? .semibold : .medium))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(
                                    isSelected ?
                                    Color.accentColor :
                                    Color(UIColor.secondarySystemBackground)
                                )
                                .foregroundColor(isSelected ? .white : .primary)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(UIColor.systemBackground))
                
                // Content Area
                ScrollView {
                    LazyVStack(spacing: 14) {
                        if viewModel.isLoading && viewModel.ipos.isEmpty {
                            ForEach(0..<4, id: \.self) { _ in
                                SkeletonCard()
                            }
                        } else if viewModel.filteredIPOs.isEmpty {
                            VStack(spacing: 14) {
                                Image(systemName: "tray")
                                    .font(.system(size: 44))
                                    .foregroundColor(.secondary)
                                Text("No \(viewModel.selectedCategory.rawValue) IPOs")
                                    .font(.headline)
                                Text("No IPOs match your selected segment or search query.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 70)
                            .padding(.horizontal)
                        } else {
                            ForEach(viewModel.filteredIPOs) { ipo in
                                NavigationLink(destination: IPODetailView(ipo: ipo)) {
                                    IPOCard(ipo: ipo) {
                                        selectedIPOForAllotment = ipo
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("IPOs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isSearchPresented.toggle()
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.subheadline.weight(.semibold))
                    }
                }
            }
            .searchable(
                text: $viewModel.searchText,
                isPresented: $isSearchPresented,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "Search company, symbol, or industry"
            )
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
