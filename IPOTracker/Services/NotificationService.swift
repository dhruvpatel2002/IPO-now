import Foundation
import UserNotifications

public final class AppNotificationService: NotificationService {
    public static let shared = AppNotificationService()
    
    private init() {}
    
    public func requestAuthorization() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        return granted
    }
    
    public func scheduleIPOReminders(for ipo: IPO, item: WatchlistItem) async throws {
        let center = UNUserNotificationCenter.current()
        
        if item.notifyOpen && ipo.openingDate > Date() {
            let content = UNMutableNotificationContent()
            content.title = "\(ipo.companyName) IPO Opens Today"
            content.body = "Price band: ₹\(Int(ipo.priceLow)) - ₹\(Int(ipo.priceHigh)). Applications are now open."
            content.sound = .default
            
            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: ipo.openingDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            let req = UNNotificationRequest(identifier: "\(ipo.id)-open", content: content, trigger: trigger)
            try? await center.add(req)
        }
        
        if item.notifyAllotment && ipo.allotmentDate > Date() {
            let content = UNMutableNotificationContent()
            content.title = "\(ipo.companyName) Allotment Today"
            content.body = "Basis of allotment expected today. Tap to check your status."
            content.sound = .default
            
            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: ipo.allotmentDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            let req = UNNotificationRequest(identifier: "\(ipo.id)-allotment", content: content, trigger: trigger)
            try? await center.add(req)
        }
    }
    
    public func cancelReminders(for ipoId: String) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [
            "\(ipoId)-open",
            "\(ipoId)-close",
            "\(ipoId)-allotment",
            "\(ipoId)-listing"
        ])
    }
}
