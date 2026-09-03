import Foundation

public enum AppConfig {
    // MARK: - API & Backend Configuration
    /// Scraper backend URLs to try (Wi-Fi LAN IP for iPhone, localhost for Simulator):
    public static var scraperBackendURLs: [String] = [
        "http://192.168.1.6:8000",
        "http://127.0.0.1:8000",
        "http://localhost:8000"
    ]
    
    /// Fallback Upvaly API Key:
    public static var upvalyApiKey: String = "fna_live_917d75e529fdc7b9-123aadd53eff9cea2ce745b48b9d94017b4938f92380e182"
}
