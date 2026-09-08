import SwiftUI

public struct IPOListView: View {
    @StateObject private var viewModel = IPOListViewModel()
    @State private var selectedIPOForAllotment: IPO?
    @State private var isSearchPresented: Bool = false
    @FocusState private var isSearchFocused: Bool
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header Area with Expanding Native iOS Glass Search Bar
                HStack(spacing: 12) {
                    if !isSearchPresented {
                        Text("IPOs")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.primary)
                            .transition(.opacity.combined(with: .move(edge: .leading)))
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                isSearchPresented = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isSearchFocused = true
                            }
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                                .frame(width: 38, height: 38)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                        }
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        // Expanded Native iOS Glass Search Bar
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            TextField("Search company, symbol, or industry", text: $viewModel.searchText)
                                .textFieldStyle(.plain)
                                .font(.subheadline)
                                .focused($isSearchFocused)
                                .autocorrectionDisabled()
                            
                            Button {
                                if !viewModel.searchText.isEmpty {
                                    viewModel.searchText = ""
                                } else {
                                    isSearchFocused = false
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        isSearchPresented = false
                                    }
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .background(Color(UIColor.systemBackground))
                
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
                .padding(.top, 4)
                .background(Color(UIColor.systemBackground))
                
                Divider()
                
                // Second Level: Sub-Segment Filters (All, Mainboard, SME)
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
            .navigationBarHidden(true)
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
