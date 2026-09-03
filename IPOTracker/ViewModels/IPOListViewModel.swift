import Foundation
import SwiftUI

public enum IPOCategory: String, CaseIterable, Identifiable {
    case ongoing = "Ongoing"
    case upcoming = "Upcoming"
    case closed = "Closed"
    
    public var id: String { rawValue }
}

public enum IPOSegmentFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case mainboard = "Mainboard"
    case sme = "SME"
    
    public var id: String { rawValue }
}

public enum IPOSortOption: String, CaseIterable, Identifiable {
    case openingDate = "Opening Date"
    case closingDate = "Closing Date"
    case listingDate = "Listing Date"
    
    public var id: String { rawValue }
}

@MainActor
public final class IPOListViewModel: ObservableObject {
    @Published public var ipos: [IPO] = []
    @Published public var searchText: String = ""
    @Published public var selectedCategory: IPOCategory = .ongoing
    @Published public var selectedSegment: IPOSegmentFilter = .all
    @Published public var sortOption: IPOSortOption = .openingDate
    @Published public var isLoading: Bool = false
    
    private let ipoService: IPOService
    
    public init(ipoService: IPOService = UpvalyIPOService.shared) {
        self.ipoService = ipoService
    }
    
    public func countForCategory(_ category: IPOCategory) -> Int {
        ipos.filter { ipo in
            matchCategory(ipo: ipo, category: category)
        }.count
    }
    
    private func matchCategory(ipo: IPO, category: IPOCategory) -> Bool {
        switch category {
        case .ongoing:
            return ipo.status == .open
        case .upcoming:
            return ipo.status == .upcoming
        case .closed:
            return ipo.status == .closed || ipo.status == .allotmentOut || ipo.status == .listed
        }
    }
    
    public var filteredIPOs: [IPO] {
        var results = ipos
        
        // 1. Category Filter (Ongoing / Upcoming / Closed)
        results = results.filter { ipo in
            matchCategory(ipo: ipo, category: selectedCategory)
        }
        
        // 2. Segment Filter (All / Mainboard / SME)
        switch selectedSegment {
        case .all:
            break
        case .mainboard:
            results = results.filter { $0.ipoType == .mainboard }
        case .sme:
            results = results.filter { $0.ipoType == .sme || $0.ipoType == .sse }
        }
        
        // 3. Search query
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            results = results.filter {
                $0.companyName.lowercased().contains(query) ||
                $0.symbol.lowercased().contains(query) ||
                $0.industry.lowercased().contains(query)
            }
        }
        
        // 4. Sorting
        switch sortOption {
        case .openingDate:
            results.sort { $0.openingDate > $1.openingDate }
        case .closingDate:
            results.sort { $0.closingDate > $1.closingDate }
        case .listingDate:
            results.sort { $0.listingDate > $1.listingDate }
        }
        
        return results
    }
    
    public func loadData() async {
        if ipos.isEmpty {
            isLoading = true
        }
        do {
            let fetched = try await ipoService.fetchIPOs()
            if !fetched.isEmpty {
                self.ipos = fetched
            }
        } catch {
            print("Error loading IPOs: \(error)")
        }
        isLoading = false
    }
}
