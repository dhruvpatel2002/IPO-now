import Foundation

public enum AllotmentStatus: String, Codable, CaseIterable {
    case allotted = "Allotted"
    case partiallyAllotted = "Partially Allotted"
    case notAllotted = "Not Allotted"
    case notAvailable = "Allotment Not Available Yet"
    case invalidPan = "Invalid PAN"
    case error = "Error"
}

public struct AllotmentResult: Identifiable, Codable {
    public var id = UUID()
    public var status: AllotmentStatus
    public var ipoId: String
    public var ipoName: String
    public var sharesAllotted: Int
    public var applicationStatus: String
    public var amount: Double
    public var message: String
    public var timestamp: Date
    
    public init(
        id: UUID = UUID(),
        status: AllotmentStatus,
        ipoId: String,
        ipoName: String,
        sharesAllotted: Int,
        applicationStatus: String,
        amount: Double,
        message: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.status = status
        self.ipoId = ipoId
        self.ipoName = ipoName
        self.sharesAllotted = sharesAllotted
        self.applicationStatus = applicationStatus
        self.amount = amount
        self.message = message
        self.timestamp = timestamp
    }
}
