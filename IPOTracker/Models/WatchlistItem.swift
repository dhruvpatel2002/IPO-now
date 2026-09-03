import Foundation
import SwiftData

@Model
public final class WatchlistItem: Identifiable {
    public var id: String
    public var ipoId: String
    public var addedDate: Date
    public var notifyOpen: Bool
    public var notifyClose: Bool
    public var notifyAllotment: Bool
    public var notifyListing: Bool
    
    public init(
        id: String = UUID().uuidString,
        ipoId: String,
        addedDate: Date = Date(),
        notifyOpen: Bool = true,
        notifyClose: Bool = true,
        notifyAllotment: Bool = true,
        notifyListing: Bool = true
    ) {
        self.id = id
        self.ipoId = ipoId
        self.addedDate = addedDate
        self.notifyOpen = notifyOpen
        self.notifyClose = notifyClose
        self.notifyAllotment = notifyAllotment
        self.notifyListing = notifyListing
    }
}
