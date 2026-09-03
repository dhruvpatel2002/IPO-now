# IPOnow — Indian IPO Tracker & Allotment Checker (iOS)

A native iOS app built with **SwiftUI + SwiftData** designed specifically for tracking Indian IPOs (Mainboard & SME) and checking allotment statuses via PAN.

---

## 📱 Features

- **Home Dashboard**: Market-wide pulse tracking (Open Now, Closing Soon, Allotment Today, Upcoming) and Featured IPO cards.
- **IPO Discovery & Filter**: Search by company name/symbol/sector, filter by Mainboard/SME, and sort by issue size or dates.
- **Deep IPO Research**: Price band, lot size, subscription breakdowns (Retail, NII, QIB, Employee), GMP indicator, financials (Revenue, Profit, EPS, P/E, ROE, Debt), strengths, risks, and issue objectives.
- **Timeline Tracking**: Visual horizontal/vertical milestone tracker from opening date to listing day.
- **Privacy-First Allotment Checker**: Instant PAN verification with strict in-memory lifecycle (no local persistence or tracking).

---

## 🛠 Tech Stack & Architecture

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI (iOS 17+)
- **Persistence**: SwiftData
- **Architecture**: MVVM + Protocol-oriented Service layer (`IPOService`, `AllotmentService`, `NotificationService`)
- **Design Language**: Apple Human Interface Guidelines (SF Symbols, Dynamic Materials, Semantic Colors)

---

## 📁 Project Structure

```text
IPOTracker/
├── App/
│   ├── IPOTrackerApp.swift
│   └── MainTabView.swift
├── Models/
│   ├── IPO.swift
│   ├── AllotmentResult.swift
│   └── WatchlistItem.swift
├── Views/
│   ├── Home/
│   │   └── HomeView.swift
│   ├── IPOs/
│   │   ├── IPOListView.swift
│   │   └── FilterSheetView.swift
│   ├── IPODetail/
│   │   └── IPODetailView.swift
│   ├── Allotment/
│   │   ├── AllotmentCheckerSheet.swift
│   │   ├── AllotmentResultView.swift
│   │   └── AllotmentTabView.swift
│   └── Settings/
│       └── SettingsView.swift
├── Components/
│   ├── DateTimeline.swift
│   ├── FinancialMetricGrid.swift
│   ├── IPOCard.swift
│   ├── MetricCard.swift
│   ├── PrimaryButton.swift
│   ├── StatusBadge.swift
│   └── SubscriptionCard.swift
├── Services/
│   ├── AllotmentService.swift
│   ├── IPOService.swift
│   ├── MockAllotmentService.swift
│   ├── MockIPOService.swift
│   └── NotificationService.swift
├── ViewModels/
│   ├── AllotmentViewModel.swift
│   ├── HomeViewModel.swift
│   ├── IPODetailViewModel.swift
│   └── IPOListViewModel.swift
└── Resources/
    └── MockData.json
```

---

## 🚀 Getting Started

1. Open Xcode 15+ and create/open an iOS App project targeting iOS 17+.
2. Drag and drop the `IPOTracker` folder into your Xcode project.
3. Ensure `MockData.json` is added to your target's **Copy Bundle Resources** build phase.
4. Run on any iPhone simulator or physical device.
