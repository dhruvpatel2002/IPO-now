import SwiftUI

public struct IPOListView: View {
    @StateObject private var viewModel: IPOListViewModel
    @State private var selectedIPOForSummary: IPO?
    @State private var selectedIPOForDetail: IPO?
    @State private var selectedIPOForAllotment: IPO?
    @State private var isSearchPresented: Bool = false
    @FocusState private var isSearchFocused: Bool
    
    public init(initialCategory: IPOCategory = .ongoing) {
        _viewModel = StateObject(wrappedValue: IPOListViewModel(initialCategory: initialCategory))
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // Search Bar & Filter Controls
                    VStack(spacing: 12) {
                        // Native Styled Search Bar
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            TextField("Search company, symbol, or industry", text: $viewModel.searchText)
                                .textFieldStyle(.plain)
                                .font(.subheadline)
                                .focused($isSearchFocused)
                                .autocorrectionDisabled()
                            
                            if !viewModel.searchText.isEmpty {
                                Button {
                                    viewModel.searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                        
                        // Primary Category Tabs (Ongoing, Upcoming, Closed)
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
                                                .font(.system(size: 11, weight: .bold))
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(
                                                    isSelected ?
                                                    Color.brandPrimary.opacity(0.18) :
                                                    Color.secondary.opacity(0.12)
                                                )
                                                .foregroundColor(isSelected ? .brandPrimary : .secondary)
                                                .cornerRadius(5)
                                        }
                                        .foregroundColor(isSelected ? .primary : .secondary)
                                        .frame(maxWidth: .infinity)
                                        
                                        // Sliding Indicator
                                        Rectangle()
                                            .fill(isSelected ? Color.brandPrimary : Color.clear)
                                            .frame(height: 2.5)
                                            .cornerRadius(2)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        // Sub-Segment Filter Chips (All, Mainboard, SME)
                        HStack(spacing: 8) {
                            Spacer()
                            ForEach(IPOSegmentFilter.allCases) { segment in
                                let isSelected = viewModel.selectedSegment == segment
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        viewModel.selectedSegment = segment
                                    }
                                } label: {
                                    Text(segment.rawValue)
                                        .font(.caption.weight(isSelected ? .bold : .medium))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            isSelected ?
                                            Color.brandPrimary :
                                            Color(UIColor.secondarySystemGroupedBackground)
                                        )
                                        .foregroundColor(isSelected ? .white : .primary)
                                        .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    
                    // IPO Card List
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
                            .padding(.top, 50)
                            .padding(.horizontal)
                        } else {
                            ForEach(viewModel.filteredIPOs) { ipo in
                                Button {
                                    selectedIPOForSummary = ipo
                                } label: {
                                    IPOCard(ipo: ipo) {
                                        selectedIPOForAllotment = ipo
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("IPOs")
            .sheet(item: $selectedIPOForSummary) { ipo in
                IPOQuickSummarySheet(ipo: ipo) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        selectedIPOForDetail = ipo
                    }
                }
            }
            .sheet(item: $selectedIPOForAllotment) { ipo in
                AllotmentCheckerSheet(ipo: ipo)
            }
            .navigationDestination(item: $selectedIPOForDetail) { ipo in
                IPODetailView(ipo: ipo)
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
