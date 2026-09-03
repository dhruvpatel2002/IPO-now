# Design System & UI Specification

## Typography & Hierarchy
- **Title 1 / Large Title**: Section headers & Navigation bars (`.font(.title2.bold())`, `.font(.largeTitle.bold())`)
- **Headline**: Card titles, company names (`.font(.headline)`)
- **Subheadline**: IPO type, status badges, secondary metadata (`.font(.subheadline)`)
- **Monospaced Digit**: Monetary figures, subscription multiples, PAN input (`.font(.system(.body, design: .monospaced))`)

---

## Color Palette (Apple HIG Semantic)
- **Primary Tint**: Electric Sky Blue (`#38B6FF` / `Color.accentColor`)
- **Success / Positive**: `Color.green` (Allotted, positive GMP)
- **Warning**: `Color.orange` (Closing soon, awaiting allotment)
- **Destructive**: `Color.red` (Not allotted, closed)
- **Backgrounds**: `Color(.systemBackground)`, `Color(.secondarySystemBackground)`, `Color(.tertiarySystemBackground)`

---

## Component Guidelines
1. **Cards**: 16pt corner radius, secondary system background, subtle 1pt border (`Color.primary.opacity(0.06)`), 12pt internal padding.
2. **Badges**: Rounded caps (`Capsule()`), 6pt vertical / 10pt horizontal padding, background opacity 0.15.
3. **PAN Input Field**: Monospaced font, auto-capitalization, regex validation `^[A-Z]{5}[0-9]{4}[A-Z]{1}$`, clear action, zero local caching.
4. **Allotment Status States**:
   - `allotted`: Green hero card with confetti/celebratory haptics.
   - `notAllotted`: Neutral/Subdued card with refund timeline note.
   - `notAvailable`: Awaiting allotment badge with notification opt-in button.
   - `error`: Warning prompt with retry CTA.
