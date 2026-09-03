import Foundation

public final class UpvalyIPOService: IPOService {
    public static let shared = UpvalyIPOService()
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func fetchIPOs() async throws -> [IPO] {
        // 1. Fetch from live scraper backend (hosted on Render/Railway or local Mac IP)
        for backendURL in AppConfig.scraperBackendURLs {
            guard !backendURL.isEmpty, let scraperURL = URL(string: "\(backendURL)/api/ipos") else { continue }
            
            var scraperReq = URLRequest(url: scraperURL, timeoutInterval: 4.0)
            scraperReq.httpMethod = "GET"
            scraperReq.setValue("application/json", forHTTPHeaderField: "Accept")
            
            if let (data, response) = try? await session.data(for: scraperReq),
               let httpResp = response as? HTTPURLResponse, (200...299).contains(httpResp.statusCode) {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                if let decoded = try? decoder.decode([IPO].self, from: data), !decoded.isEmpty {
                    print("[IPOnow Service] Successfully fetched \(decoded.count) live IPOs from \(backendURL)")
                    return decoded
                }
            }
        }
        
        // 2. Fallback to local offline cache if no network/backend
        return try await MockIPOService.shared.fetchIPOs()
    }
    
    public func fetchIPODetail(id: String) async throws -> IPO? {
        let all = try await fetchIPOs()
        return all.first { $0.id == id || $0.symbol == id }
    }
}
