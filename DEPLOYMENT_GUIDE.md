# IPOnow Backend Deployment Guide (100% Free Hosting)

This guide shows how to deploy your **FastAPI Playwright Live Scraper** to the cloud so that it automatically runs 24/7 and refreshes IPO data twice daily (at **9:30 AM** and **6:30 PM** IST).

---

## Option 1: Deploy to Render.com (Recommended — 100% Free)

1. Push your repository to **GitHub**.
2. Go to [https://dashboard.render.com](https://dashboard.render.com) and sign in.
3. Click **New +** ➔ **Web Service**.
4. Select your **GitHub repository**.
5. Render will automatically detect `backend/Dockerfile`.
6. Set:
   * **Name**: `iponow-api`
   * **Region**: `Singapore` (or nearest)
   * **Instance Type**: `Free`
7. Click **Deploy Web Service**.
8. In ~2 minutes, Render gives you a live HTTPS URL:
   `https://iponow-api.onrender.com`

---

## Option 2: Deploy to Railway.app

1. Go to [https://railway.app](https://railway.app).
2. Click **New Project** ➔ **Deploy from GitHub repo**.
3. Select your `IPOapp` repository and set root directory to `backend`.
4. Click **Deploy**. Railway will build the Docker container and provide a live URL.

---

## Connect Your Hosted Backend to the iOS App:

Once deployed, open [`IPOTracker/Services/AppConfig.swift`](file:///Users/dhruvpatel/Projects/IPOapp/IPOTracker/Services/AppConfig.swift) and set your deployed cloud URL:

```swift
public enum AppConfig {
    public static var scraperBackendURLs: [String] = [
        "https://iponow-api.onrender.com",  // <-- Your deployed cloud URL here
        "http://192.168.1.6:8000",          // Local Wi-Fi Mac fallback
        "http://127.0.0.1:8000"             // Simulator fallback
    ]
}
```

Now your iOS app will pull live data from the cloud globally on any Wi-Fi or cellular network without needing your Mac running!
