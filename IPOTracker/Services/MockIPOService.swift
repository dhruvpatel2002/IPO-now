import Foundation

public final class MockIPOService: IPOService {
    public static let shared = MockIPOService()
    private var cachedIPOs: [IPO] = []
    
    public init() {}
    
    public func fetchIPOs() async throws -> [IPO] {
        if !cachedIPOs.isEmpty {
            return cachedIPOs
        }
        
        guard let url = Bundle.main.url(forResource: "MockData", withExtension: "json") else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let ipos = try decoder.decode([IPO].self, from: data)
            self.cachedIPOs = ipos
            return ipos
        } catch {
            print("[MockIPOService] Error decoding bundled data: \(error)")
            return []
        }
    }
    
    public func fetchIPODetail(id: String) async throws -> IPO? {
        let list = try await fetchIPOs()
        return list.first { $0.id == id || $0.symbol == id }
    }
}
