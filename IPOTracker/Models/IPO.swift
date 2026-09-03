import Foundation
import SwiftData

public enum IPOType: String, Codable, CaseIterable {
    case mainboard = "Mainboard"
    case sme = "SME"
    case sse = "SSE"
}

public enum IPOStatus: String, Codable, CaseIterable {
    case upcoming = "Upcoming"
    case open = "Open Now"
    case closed = "Closed"
    case allotmentOut = "Allotment Out"
    case listed = "Listed"
}

@Model
public final class IPO: Identifiable, Codable {
    public var id: String
    public var companyName: String
    public var symbol: String
    public var logoURL: String?
    public var ipoTypeRaw: String
    public var exchange: String
    public var statusRaw: String
    public var priceLow: Double
    public var priceHigh: Double
    public var lotSize: Int
    public var issueSizeInCr: Double
    public var freshIssueInCr: Double
    public var offerForSaleInCr: Double
    public var faceValue: Double
    public var openingDate: Date
    public var closingDate: Date
    public var allotmentDate: Date
    public var refundDate: Date
    public var dematDate: Date
    public var listingDate: Date
    
    public var retailSubscription: Double
    public var niiSubscription: Double
    public var qibSubscription: Double
    public var employeeSubscription: Double
    public var totalSubscription: Double
    
    public var gmp: Double
    public var expectedListingPrice: Double
    
    public var companyDescription: String
    public var industry: String
    public var headquarters: String
    public var promoterDetails: String
    
    public var revenueInCr: Double
    public var profitInCr: Double
    public var eps: Double
    public var peRatio: Double
    public var roe: Double
    public var debtInCr: Double
    
    public var strengths: [String]
    public var risks: [String]
    public var ipoObjective: [String]
    
    public var ipoType: IPOType {
        get { IPOType(rawValue: ipoTypeRaw) ?? .mainboard }
        set { ipoTypeRaw = newValue.rawValue }
    }
    
    public var status: IPOStatus {
        get { IPOStatus(rawValue: statusRaw) ?? .upcoming }
        set { statusRaw = newValue.rawValue }
    }
    
    public var rawPriceRange: String? = nil
    
    public var displayPriceBand: String {
        if let raw = rawPriceRange, !raw.isEmpty, raw != "–" {
            return raw
        }
        if priceLow > 0 && priceHigh > 0 {
            if priceLow == priceHigh {
                return "₹\(Int(priceLow))"
            } else {
                return "₹\(Int(priceLow)) – ₹\(Int(priceHigh))"
            }
        }
        return "TBA"
    }
    
    public var displayIssueSize: String {
        if issueSizeInCr > 0 {
            return "₹\(Int(issueSizeInCr)) Cr"
        }
        return "TBA"
    }
    
    public var displayLotSize: String {
        if lotSize > 0 {
            return "\(lotSize) shares"
        }
        return "TBA"
    }
    
    public var minimumInvestment: Double {
        return Double(lotSize) * priceHigh
    }
    
    public var gmpPercentage: Double {
        guard priceHigh > 0 else { return 0 }
        return (gmp / priceHigh) * 100
    }
    
    public var displayMinimumInvestment: String {
        if minimumInvestment > 0 {
            return "₹\(Int(minimumInvestment))"
        }
        return "TBA"
    }
    
    public init(
        id: String = UUID().uuidString,
        companyName: String,
        symbol: String,
        logoURL: String? = nil,
        ipoType: IPOType,
        exchange: String,
        status: IPOStatus,
        priceLow: Double,
        priceHigh: Double,
        lotSize: Int,
        issueSizeInCr: Double,
        freshIssueInCr: Double,
        offerForSaleInCr: Double,
        faceValue: Double,
        openingDate: Date,
        closingDate: Date,
        allotmentDate: Date,
        refundDate: Date,
        dematDate: Date,
        listingDate: Date,
        retailSubscription: Double,
        niiSubscription: Double,
        qibSubscription: Double,
        employeeSubscription: Double,
        totalSubscription: Double,
        gmp: Double,
        expectedListingPrice: Double,
        companyDescription: String,
        industry: String,
        headquarters: String,
        promoterDetails: String,
        revenueInCr: Double,
        profitInCr: Double,
        eps: Double,
        peRatio: Double,
        roe: Double,
        debtInCr: Double,
        strengths: [String],
        risks: [String],
        ipoObjective: [String]
    ) {
        self.id = id
        self.companyName = companyName
        self.symbol = symbol
        self.logoURL = logoURL
        self.ipoTypeRaw = ipoType.rawValue
        self.exchange = exchange
        self.statusRaw = status.rawValue
        self.priceLow = priceLow
        self.priceHigh = priceHigh
        self.lotSize = lotSize
        self.issueSizeInCr = issueSizeInCr
        self.freshIssueInCr = freshIssueInCr
        self.offerForSaleInCr = offerForSaleInCr
        self.faceValue = faceValue
        self.openingDate = openingDate
        self.closingDate = closingDate
        self.allotmentDate = allotmentDate
        self.refundDate = refundDate
        self.dematDate = dematDate
        self.listingDate = listingDate
        self.retailSubscription = retailSubscription
        self.niiSubscription = niiSubscription
        self.qibSubscription = qibSubscription
        self.employeeSubscription = employeeSubscription
        self.totalSubscription = totalSubscription
        self.gmp = gmp
        self.expectedListingPrice = expectedListingPrice
        self.companyDescription = companyDescription
        self.industry = industry
        self.headquarters = headquarters
        self.promoterDetails = promoterDetails
        self.revenueInCr = revenueInCr
        self.profitInCr = profitInCr
        self.eps = eps
        self.peRatio = peRatio
        self.roe = roe
        self.debtInCr = debtInCr
        self.strengths = strengths
        self.risks = risks
        self.ipoObjective = ipoObjective
    }
    
    // MARK: - Codable Conformance
    enum CodingKeys: String, CodingKey {
        case id, companyName, symbol, logoURL, ipoTypeRaw, exchange, statusRaw
        case priceLow, priceHigh, lotSize, issueSizeInCr, freshIssueInCr, offerForSaleInCr, faceValue
        case openingDate, closingDate, allotmentDate, refundDate, dematDate, listingDate
        case retailSubscription, niiSubscription, qibSubscription, employeeSubscription, totalSubscription
        case gmp, expectedListingPrice, companyDescription, industry, headquarters, promoterDetails
        case revenueInCr, profitInCr, eps, peRatio, roe, debtInCr, strengths, risks, ipoObjective
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container.decode(String.self, forKey: .id)) ?? UUID().uuidString
        self.companyName = (try? container.decode(String.self, forKey: .companyName)) ?? "Unknown IPO"
        self.symbol = (try? container.decode(String.self, forKey: .symbol)) ?? "IPO"
        self.logoURL = try? container.decodeIfPresent(String.self, forKey: .logoURL)
        self.ipoTypeRaw = (try? container.decode(String.self, forKey: .ipoTypeRaw)) ?? "Mainboard"
        self.exchange = (try? container.decode(String.self, forKey: .exchange)) ?? "NSE / BSE"
        self.statusRaw = (try? container.decode(String.self, forKey: .statusRaw)) ?? "Upcoming"
        let pLow = (try? container.decode(Double.self, forKey: .priceLow)) ?? 0.0
        let pHigh = (try? container.decode(Double.self, forKey: .priceHigh)) ?? 0.0
        self.priceLow = pLow
        self.priceHigh = pHigh
        self.lotSize = (try? container.decode(Int.self, forKey: .lotSize)) ?? 50
        self.issueSizeInCr = (try? container.decode(Double.self, forKey: .issueSizeInCr)) ?? 0.0
        self.freshIssueInCr = (try? container.decode(Double.self, forKey: .freshIssueInCr)) ?? 0.0
        self.offerForSaleInCr = (try? container.decode(Double.self, forKey: .offerForSaleInCr)) ?? 0.0
        self.faceValue = (try? container.decode(Double.self, forKey: .faceValue)) ?? 10.0
        
        let now = Date()
        self.openingDate = (try? container.decode(Date.self, forKey: .openingDate)) ?? now
        self.closingDate = (try? container.decode(Date.self, forKey: .closingDate)) ?? now.addingTimeInterval(86400 * 3)
        self.allotmentDate = (try? container.decode(Date.self, forKey: .allotmentDate)) ?? now.addingTimeInterval(86400 * 4)
        self.refundDate = (try? container.decode(Date.self, forKey: .refundDate)) ?? now.addingTimeInterval(86400 * 5)
        self.dematDate = (try? container.decode(Date.self, forKey: .dematDate)) ?? now.addingTimeInterval(86400 * 5)
        self.listingDate = (try? container.decode(Date.self, forKey: .listingDate)) ?? now.addingTimeInterval(86400 * 6)
        
        self.retailSubscription = (try? container.decode(Double.self, forKey: .retailSubscription)) ?? 0.0
        self.niiSubscription = (try? container.decode(Double.self, forKey: .niiSubscription)) ?? 0.0
        self.qibSubscription = (try? container.decode(Double.self, forKey: .qibSubscription)) ?? 0.0
        self.employeeSubscription = (try? container.decode(Double.self, forKey: .employeeSubscription)) ?? 0.0
        self.totalSubscription = (try? container.decode(Double.self, forKey: .totalSubscription)) ?? 0.0
        
        let gmpVal = (try? container.decode(Double.self, forKey: .gmp)) ?? 0.0
        self.gmp = gmpVal
        self.expectedListingPrice = (try? container.decode(Double.self, forKey: .expectedListingPrice)) ?? (pHigh + gmpVal)
        
        self.companyDescription = (try? container.decode(String.self, forKey: .companyDescription)) ?? ""
        self.industry = (try? container.decode(String.self, forKey: .industry)) ?? "Commercial"
        self.headquarters = (try? container.decode(String.self, forKey: .headquarters)) ?? "India"
        self.promoterDetails = (try? container.decode(String.self, forKey: .promoterDetails)) ?? ""
        self.revenueInCr = (try? container.decode(Double.self, forKey: .revenueInCr)) ?? 0.0
        self.profitInCr = (try? container.decode(Double.self, forKey: .profitInCr)) ?? 0.0
        self.eps = (try? container.decode(Double.self, forKey: .eps)) ?? 0.0
        self.peRatio = (try? container.decode(Double.self, forKey: .peRatio)) ?? 0.0
        self.roe = (try? container.decode(Double.self, forKey: .roe)) ?? 0.0
        self.debtInCr = (try? container.decode(Double.self, forKey: .debtInCr)) ?? 0.0
        self.strengths = (try? container.decode([String].self, forKey: .strengths)) ?? []
        self.risks = (try? container.decode([String].self, forKey: .risks)) ?? []
        self.ipoObjective = (try? container.decode([String].self, forKey: .ipoObjective)) ?? []
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(companyName, forKey: .companyName)
        try container.encode(symbol, forKey: .symbol)
        try container.encodeIfPresent(logoURL, forKey: .logoURL)
        try container.encode(ipoTypeRaw, forKey: .ipoTypeRaw)
        try container.encode(exchange, forKey: .exchange)
        try container.encode(statusRaw, forKey: .statusRaw)
        try container.encode(priceLow, forKey: .priceLow)
        try container.encode(priceHigh, forKey: .priceHigh)
        try container.encode(lotSize, forKey: .lotSize)
        try container.encode(issueSizeInCr, forKey: .issueSizeInCr)
        try container.encode(freshIssueInCr, forKey: .freshIssueInCr)
        try container.encode(offerForSaleInCr, forKey: .offerForSaleInCr)
        try container.encode(faceValue, forKey: .faceValue)
        try container.encode(openingDate, forKey: .openingDate)
        try container.encode(closingDate, forKey: .closingDate)
        try container.encode(allotmentDate, forKey: .allotmentDate)
        try container.encode(refundDate, forKey: .refundDate)
        try container.encode(dematDate, forKey: .dematDate)
        try container.encode(listingDate, forKey: .listingDate)
        try container.encode(retailSubscription, forKey: .retailSubscription)
        try container.encode(niiSubscription, forKey: .niiSubscription)
        try container.encode(qibSubscription, forKey: .qibSubscription)
        try container.encode(employeeSubscription, forKey: .employeeSubscription)
        try container.encode(totalSubscription, forKey: .totalSubscription)
        try container.encode(gmp, forKey: .gmp)
        try container.encode(expectedListingPrice, forKey: .expectedListingPrice)
        try container.encode(companyDescription, forKey: .companyDescription)
        try container.encode(industry, forKey: .industry)
        try container.encode(headquarters, forKey: .headquarters)
        try container.encode(promoterDetails, forKey: .promoterDetails)
        try container.encode(revenueInCr, forKey: .revenueInCr)
        try container.encode(profitInCr, forKey: .profitInCr)
        try container.encode(eps, forKey: .eps)
        try container.encode(peRatio, forKey: .peRatio)
        try container.encode(roe, forKey: .roe)
        try container.encode(debtInCr, forKey: .debtInCr)
        try container.encode(strengths, forKey: .strengths)
        try container.encode(risks, forKey: .risks)
        try container.encode(ipoObjective, forKey: .ipoObjective)
    }
}
