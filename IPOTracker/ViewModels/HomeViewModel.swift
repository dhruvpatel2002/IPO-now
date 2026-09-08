import Foundation
import SwiftUI

@MainActor
public final class HomeViewModel: ObservableObject {
    @Published public var ipos: [IPO] = []
    @Published public var featuredIPO: IPO?
    @Published public var topGMPGainers: [IPO] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    
    private let ipoService: IPOService
    
    public init(ipoService: IPOService = UpvalyIPOService.shared) {
        self.ipoService = ipoService
    }
    
    public var openCount: Int {
        ipos.filter { $0.status == .open }.count
    }
    
    public var closingTodayCount: Int {
        let count = ipos.filter { ipo in
            guard ipo.status == .open else { return false }
            return Calendar.current.isDateInToday(ipo.closingDate)
        }.count
        return count > 0 ? count : closingSoonCount
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
    
    public var avgGMPPercentage: Double {
        let activeWithGMP = ipos.filter { ($0.status == .open || $0.status == .upcoming) && $0.gmp > 0 }
        guard !activeWithGMP.isEmpty else { return 0.0 }
        let total = activeWithGMP.reduce(0.0) { $0 + $1.gmpPercentage }
        return total / Double(activeWithGMP.count)
    }
    
    public func loadData() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await ipoService.fetchIPOs()
            self.ipos = fetched.sorted {
                if $0.openingDate != $1.openingDate {
                    return $0.openingDate < $1.openingDate
                }
                return $0.closingDate < $1.closingDate
            }
            
            // Top GMP Gainers
            self.topGMPGainers = fetched
                .filter { $0.gmp > 0 }
                .sorted { $0.gmpPercentage > $1.gmpPercentage }
            
            // Featured IPO: Highest GMP open or upcoming IPO
            self.featuredIPO = self.topGMPGainers.first(where: { $0.status == .open })
                ?? self.topGMPGainers.first
                ?? fetched.first(where: { $0.status == .open })
                ?? fetched.first
        } catch {
            self.errorMessage = "Failed to load IPO data."
        }
        isLoading = false
    }
}
