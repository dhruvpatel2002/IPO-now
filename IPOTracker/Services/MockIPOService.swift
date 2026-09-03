import Foundation

public final class MockIPOService: IPOService {
    public static let shared = MockIPOService()
    private var cachedIPOs: [IPO] = []
    
    public init() {}
    
    public func fetchIPOs() async throws -> [IPO] {
        if !cachedIPOs.isEmpty {
            return cachedIPOs
        }
        
        guard let url = Bundle.main.url(forResource: "MockData", withExtension: "json") ??
              Bundle(for: Self.self).url(forResource: "MockData", withExtension: "json") else {
            // Fallback to built-in programmatic sample if file not found in test bundle
            let generated = Self.generateFallbackData()
            self.cachedIPOs = generated
            return generated
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let ipos = try decoder.decode([IPO].self, from: data)
        self.cachedIPOs = ipos
        return ipos
    }
    
    public func fetchIPODetail(id: String) async throws -> IPO? {
        let list = try await fetchIPOs()
        return list.first { $0.id == id }
    }
    
    private static func generateFallbackData() -> [IPO] {
        let calendar = Calendar.current
        let now = Date()
        
        return [
            IPO(
                id: "ipo-001",
                companyName: "ABC Technologies Ltd",
                symbol: "ABCTECH",
                ipoType: .mainboard,
                exchange: "NSE / BSE",
                status: .open,
                priceLow: 120.0,
                priceHigh: 125.0,
                lotSize: 120,
                issueSizeInCr: 2500.0,
                freshIssueInCr: 1500.0,
                offerForSaleInCr: 1000.0,
                faceValue: 10.0,
                openingDate: calendar.date(byAdding: .day, value: -2, to: now)!,
                closingDate: calendar.date(byAdding: .day, value: 2, to: now)!,
                allotmentDate: calendar.date(byAdding: .day, value: 5, to: now)!,
                refundDate: calendar.date(byAdding: .day, value: 6, to: now)!,
                dematDate: calendar.date(byAdding: .day, value: 6, to: now)!,
                listingDate: calendar.date(byAdding: .day, value: 7, to: now)!,
                retailSubscription: 2.45,
                niiSubscription: 8.21,
                qibSubscription: 12.34,
                employeeSubscription: 1.52,
                totalSubscription: 7.85,
                gmp: 45.0,
                expectedListingPrice: 170.0,
                companyDescription: "ABC Technologies is a leading cloud migration and enterprise AI transformation provider.",
                industry: "Technology",
                headquarters: "Mumbai, India",
                promoterDetails: "Vikram Mehta & Family",
                revenueInCr: 1250.0,
                profitInCr: 180.0,
                eps: 12.40,
                peRatio: 10.08,
                roe: 18.2,
                debtInCr: 240.0,
                strengths: ["Strong revenue CAGR of 32%", "Low debt to equity", "Expanding global clients"],
                risks: ["Client concentration risk", "Currency fluctuations"],
                ipoObjective: ["Expansion of cloud infrastructure", "Debt repayment", "General corporate purposes"]
            ),
            IPO(
                id: "ipo-002",
                companyName: "Zenith Healthcare & Diagnostics",
                symbol: "ZENHEALTH",
                ipoType: .mainboard,
                exchange: "NSE / BSE",
                status: .allotmentOut,
                priceLow: 310.0,
                priceHigh: 325.0,
                lotSize: 46,
                issueSizeInCr: 1400.0,
                freshIssueInCr: 900.0,
                offerForSaleInCr: 500.0,
                faceValue: 5.0,
                openingDate: calendar.date(byAdding: .day, value: -6, to: now)!,
                closingDate: calendar.date(byAdding: .day, value: -3, to: now)!,
                allotmentDate: calendar.date(byAdding: .day, value: -1, to: now)!,
                refundDate: calendar.date(byAdding: .day, value: 0, to: now)!,
                dematDate: calendar.date(byAdding: .day, value: 0, to: now)!,
                listingDate: calendar.date(byAdding: .day, value: 1, to: now)!,
                retailSubscription: 14.8,
                niiSubscription: 45.2,
                qibSubscription: 88.6,
                employeeSubscription: 3.1,
                totalSubscription: 52.3,
                gmp: 110.0,
                expectedListingPrice: 435.0,
                companyDescription: "Zenith operates super-speciality hospitals and regional pathology diagnostic centers.",
                industry: "Healthcare",
                headquarters: "Bengaluru, India",
                promoterDetails: "Dr. Rajesh Sharma & Dr. Priya Sharma",
                revenueInCr: 890.0,
                profitInCr: 134.0,
                eps: 18.2,
                peRatio: 17.85,
                roe: 22.4,
                debtInCr: 110.0,
                strengths: ["76% operational bed occupancy", "Specialized cancer care facilities"],
                risks: ["High competition in metro cities", "Retention of senior surgeons"],
                ipoObjective: ["New 350-bed hospital in Pune", "Advanced diagnostic equipment"]
            )
        ]
    }
}
