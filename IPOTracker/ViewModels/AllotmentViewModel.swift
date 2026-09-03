import Foundation
import SwiftUI

@MainActor
public final class AllotmentViewModel: ObservableObject {
    @Published public var ipos: [IPO] = []
    @Published public var selectedIPO: IPO?
    @Published public var panNumber: String = ""
    @Published public var isLoading: Bool = false
    @Published public var allotmentResult: AllotmentResult?
    @Published public var validationError: String?
    
    private let ipoService: IPOService
    private let allotmentService: AllotmentService
    
    public init(
        ipoService: IPOService = UpvalyIPOService.shared,
        allotmentService: AllotmentService = MockAllotmentService.shared
    ) {
        self.ipoService = ipoService
        self.allotmentService = allotmentService
    }
    
    public var recentAllotmentIPOs: [IPO] {
        ipos.filter { $0.status == .allotmentOut || $0.status == .closed || $0.status == .listed }
    }
    
    public func loadData() async {
        do {
            self.ipos = try await ipoService.fetchIPOs()
            if selectedIPO == nil {
                self.selectedIPO = recentAllotmentIPOs.first ?? ipos.first
            }
        } catch {
            print("Error loading allotment data: \(error)")
        }
    }
    
    public func validateAndCheckAllotment() async {
        validationError = nil
        allotmentResult = nil
        
        let cleanedPan = panNumber.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        let panRegex = "^[A-Z]{5}[0-9]{4}[A-Z]{1}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", panRegex)
        guard predicate.evaluate(with: cleanedPan) else {
            self.validationError = "Enter a valid 10-character PAN (e.g. ABCDE1234F)"
            return
        }
        
        guard let ipo = selectedIPO else {
            self.validationError = "Please select an IPO"
            return
        }
        
        isLoading = true
        do {
            let result = try await allotmentService.checkAllotment(ipo: ipo, pan: cleanedPan)
            self.allotmentResult = result
        } catch {
            self.allotmentResult = AllotmentResult(
                status: .error,
                ipoId: ipo.id,
                ipoName: ipo.companyName,
                sharesAllotted: 0,
                applicationStatus: "Service Unavailable",
                amount: 0,
                message: "Unable to check allotment right now. Please try again later."
            )
        }
        isLoading = false
    }
    
    public func clearForm() {
        self.panNumber = ""
        self.allotmentResult = nil
        self.validationError = nil
    }
}
