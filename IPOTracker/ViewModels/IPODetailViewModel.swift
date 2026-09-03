import Foundation
import SwiftUI

@MainActor
public final class IPODetailViewModel: ObservableObject {
    @Published public var ipo: IPO
    @Published public var isWatchlisted: Bool = false
    @Published public var showAllotmentSheet: Bool = false
    
    public init(ipo: IPO) {
        self.ipo = ipo
    }
}
