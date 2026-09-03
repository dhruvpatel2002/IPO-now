import Foundation
import SwiftData

@Model
public final class SavedPAN: Identifiable {
    public var id: String
    public var name: String
    public var panNumber: String
    public var addedDate: Date
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        panNumber: String,
        addedDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.panNumber = panNumber.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        self.addedDate = addedDate
    }
    
    public var maskedPAN: String {
        guard panNumber.count == 10 else { return panNumber }
        let prefix = panNumber.prefix(5)
        let suffix = panNumber.suffix(1)
        return "\(prefix)••••\(suffix)"
    }
}
