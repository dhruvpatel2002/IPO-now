import Foundation

public protocol IPOService {
    func fetchIPOs() async throws -> [IPO]
    func fetchIPODetail(id: String) async throws -> IPO?
}

public protocol AllotmentService {
    func checkAllotment(ipo: IPO, pan: String) async throws -> AllotmentResult
}

public protocol NotificationService {
    func requestAuthorization() async throws -> Bool
    func scheduleIPOReminders(for ipo: IPO, item: WatchlistItem) async throws
    func cancelReminders(for ipoId: String) async
}
