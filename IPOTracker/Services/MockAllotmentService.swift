import Foundation

public final class MockAllotmentService: AllotmentService {
    public static let shared = MockAllotmentService()
    
    public init() {}
    
    public func checkAllotment(ipo: IPO, pan: String) async throws -> AllotmentResult {
        // Simulate network latency
        try await Task.sleep(nanoseconds: 700_000_000)
        
        let cleanedPan = pan.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        let panRegex = "^[A-Z]{5}[0-9]{4}[A-Z]{1}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", panRegex)
        guard predicate.evaluate(with: cleanedPan) else {
            return AllotmentResult(
                status: .invalidPan,
                ipoId: ipo.id,
                ipoName: ipo.companyName,
                sharesAllotted: 0,
                applicationStatus: "Invalid PAN",
                amount: 0,
                message: "Please enter a valid 10-digit PAN format (e.g. ABCDE1234F)."
            )
        }
        
        // Status checks
        if ipo.status == .upcoming || ipo.status == .open {
            return AllotmentResult(
                status: .notAvailable,
                ipoId: ipo.id,
                ipoName: ipo.companyName,
                sharesAllotted: 0,
                applicationStatus: "Not Published",
                amount: 0,
                message: "Allotment results for \(ipo.companyName) have not been published yet. Expected on \(Self.formattedDate(ipo.allotmentDate))."
            )
        }
        
        // Deterministic simulation based on last character of PAN
        if let lastChar = cleanedPan.last {
            if ["A", "E", "I", "M", "Q", "U", "Y"].contains(lastChar) {
                let shares = ipo.lotSize
                let amount = Double(shares) * ipo.priceHigh
                return AllotmentResult(
                    status: .allotted,
                    ipoId: ipo.id,
                    ipoName: ipo.companyName,
                    sharesAllotted: shares,
                    applicationStatus: "Allotted",
                    amount: amount,
                    message: "Congratulations! \(shares) shares have been allotted to your demat account."
                )
            } else if ["B", "K", "Z"].contains(lastChar) && ipo.lotSize > 100 {
                let shares = ipo.lotSize / 2
                let amount = Double(shares) * ipo.priceHigh
                return AllotmentResult(
                    status: .partiallyAllotted,
                    ipoId: ipo.id,
                    ipoName: ipo.companyName,
                    sharesAllotted: shares,
                    applicationStatus: "Partially Allotted",
                    amount: amount,
                    message: "Partial allotment of \(shares) shares. Remaining funds will be unblocked."
                )
            }
        }
        
        return AllotmentResult(
            status: .notAllotted,
            ipoId: ipo.id,
            ipoName: ipo.companyName,
            sharesAllotted: 0,
            applicationStatus: "Not Allotted",
            amount: 0,
            message: "No shares were allotted to this PAN. Blocked funds will be released per your bank/UPI mandate schedule."
        )
    }
    
    private static func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
