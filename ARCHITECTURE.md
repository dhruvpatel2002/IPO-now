# IPO Tracker & Allotment Checker — Architecture & Specification

## Overview
A native iOS application built with **Swift 5.9+ / SwiftUI** and **SwiftData** targeted at Indian IPO discovery, research, and allotment status verification.

---

## Architectural Principles
- **MVVM Pattern**: Separation of concerns between UI (`Views`), state/business logic (`ViewModels`), and data layer (`Services` / `Models`).
- **Protocol-Driven Services**: `IPOService`, `AllotmentService`, and `NotificationService` define testable interfaces.
- **Upvaly Live API**: `UpvalyIPOService` fetches live Indian IPO data from `https://finapi.upvaly.com/api/ipo` via `X-API-Key` headers, with date/price range parser and offline fallback.
- **Privacy First**: PAN numbers are validated in-memory, never stored locally in SwiftData/UserDefaults, never logged, and cleared post-verification.
- **Apple-Native Design**: SF Symbols, dynamic type, HIG colors, semantic materials, and responsive layouts for iPhone/iPad.

---

## Navigation Structure (4 Tabs)
1. **IPOs** (Primary): Category tabs (**Ongoing**, **Upcoming**, **Closed**) with sub-segment chips (**All**, **Mainboard**, **SME**), skeleton loading, and live pull-to-refresh.
2. **Allotment**: Allotment checking with 1-tap saved PAN profile integration.
3. **PANs**: Local profile management for multiple PAN cards (Self, Family, HUF).
4. **Settings**: Notifications and app preferences.

---

## Data Models
- [`IPO.swift`](file:///Users/dhruvpatel/Projects/IPOapp/IPOTracker/Models/IPO.swift): Mainboard, SME, SSE listings with price bands, lot size, and lifecycle dates.
- [`SavedPAN.swift`](file:///Users/dhruvpatel/Projects/IPOapp/IPOTracker/Models/SavedPAN.swift): Local user PAN profiles with masked views.
- [`AllotmentResult.swift`](file:///Users/dhruvpatel/Projects/IPOapp/IPOTracker/Models/AllotmentResult.swift): Standardized allotment response DTO.
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
