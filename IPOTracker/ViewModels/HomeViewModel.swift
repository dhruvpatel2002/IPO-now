import Foundation
import SwiftUI

@MainActor
public final class HomeViewModel: ObservableObject {
    @Published public var ipos: [IPO] = []
    @Published public var featuredIPO: IPO?
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    
    private let ipoService: IPOService
    
    public init(ipoService: IPOService = MockIPOService.shared) {
        self.ipoService = ipoService
    }
    
    public var openCount: Int {
        ipos.filter { $0.status == .open }.count
    }
    
    public var closingSoonCount: Int {
        ipos.filter { ipo in
            guard ipo.status == .open else { return false }
            let startOfCloseDay = Calendar.current.startOfDay(for: ipo.closingDate)
            let endOfCloseDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfCloseDay)?.addingTimeInterval(-1) ?? ipo.closingDate
            let hoursUntilClose = endOfCloseDay.timeIntervalSince(Date()) / 3600
            return hoursUntilClose <= 48 && hoursUntilClose > 0
        }.count
    }
    
    public var allotmentTodayCount: Int {
        ipos.filter { ipo in
            Calendar.current.isDateInToday(ipo.allotmentDate) || ipo.status == .allotmentOut
        }.count
    }
    
    public var upcomingCount: Int {
        ipos.filter { $0.status == .upcoming }.count
    }
    
    public func loadData() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await ipoService.fetchIPOs()
            self.ipos = fetched
            self.featuredIPO = fetched.first(where: { $0.status == .open }) ?? fetched.first
        } catch {
            self.errorMessage = "Failed to load IPO data."
        }
        isLoading = false
    }
}
