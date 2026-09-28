# Design System & UI/UX Specification
## Hermanos Ledgr

> **Version:** 1.0 · **Last Updated:** 2026-09-28
> **Status:** Planning

---

## 1. Design Philosophy

Clean, fast, and functional. The app should feel like a premium native Android app — not a toy, not an enterprise dashboard. Inspired by Tarsi's polished look, but stripped down to what matters: **getting data in fast and reading it clearly**.

### Design Priorities (ordered)
1. **Speed of input** — Logging an expense must be frictionless
2. **Clarity of data** — Balances, charts, and lists must be instantly readable
3. **Visual comfort** — Dark mode by default; easy on the eyes during nighttime use
4. **Microinteraction** — 
5. **Consistency** — Material Design 3 everywhere, no custom one-off widgets

---

## 2. Color System

Based on Material Design 3 dynamic color with a **custom seed color**.

### 2.1 Brand Seed Color

```
Primary Seed: #2E7D32 (Forest Green — money/finance association)
```

The entire M3 tonal palette is generated from this seed. The app uses `ColorScheme.fromSeed()` for automatic light/dark palette generation.

### 2.2 Semantic Colors

| Role | Light Mode | Dark Mode | Usage |
|---|---|---|---|
| **Income** | `#2E7D32` (Green 800) | `#81C784` (Green 300) | Income amounts, positive changes |
| **Expense** | `#C62828` (Red 800) | `#EF9A9A` (Red 200) | Expense amounts, negative changes |
| **Transfer** | `#1565C0` (Blue 800) | `#64B5F6` (Blue 300) | Account transfers |
| **Warning** | `#E65100` (Orange 900) | `#FFB74D` (Orange 300) | Budget overspend, due dates |
| **Surface** | M3 auto | M3 auto | Cards, sheets, dialogs |

### 2.3 Category Colors

Each transaction category gets a distinct hue from the M3 tonal palette. Categories are visually identified by both an icon and a color dot.

---

## 3. Typography

### 3.1 Font Family

**Google Fonts — Inter** (variable weight)
- Clean, highly legible at small sizes
- Excellent number readability (critical for a finance app)
- Fallback: Roboto (system default)

### 3.2 Type Scale (M3)

| Role | Size | Weight | Usage |
|---|---|---|---|
| Display Large | 57sp | 400 | — (unused) |
| Display Medium | 45sp | 400 | — (unused) |
| Display Small | 36sp | 400 | Net worth hero number |
| Headline Large | 32sp | 400 | Screen titles |
| Headline Medium | 28sp | 400 | Section headers |
| Headline Small | 24sp | 400 | Card titles |
| Title Large | 22sp | 500 | — |
| Title Medium | 16sp | 500 | List item primary text |
| Title Small | 14sp | 500 | Tabs, chips |
| Body Large | 16sp | 400 | Descriptions, notes |
| Body Medium | 14sp | 400 | Default body text |
| Body Small | 12sp | 400 | Captions, timestamps |
| Label Large | 14sp | 500 | Buttons |
| Label Medium | 12sp | 500 | Chips, badges |
| Label Small | 11sp | 500 | Micro labels |

### 3.3 Number Formatting

- Currency: **₱** prefix, comma-separated thousands, 2 decimal places
- Example: `₱12,345.67`
- Negative amounts: `-₱1,234.56` (red colored)
- Shortened: `₱12.3K`, `₱1.2M` for dashboard hero numbers

---

## 4. Iconography

- **Primary:** Material Symbols (Rounded, weight 400, filled for selected state)
- **Category icons:** Curated set of ~30 icons mapped to default categories
- **Account type icons:** Bank, wallet, credit card, cash, e-wallet brand logos

---

## 5. Layout & Navigation

### 5.1 Navigation Structure

**Bottom Navigation Bar** (Material 3 `NavigationBar`) with 5 destinations:

| Tab | Icon | Label | Screen |
|---|---|---|---|
| 1 | `home` | Home | Dashboard / Net Worth overview |
| 2 | `receipt_long` | Transactions | Transaction history with filters |
| 3 | `add_circle` | Log | Quick add expense/income (centered FAB-style) |
| 4 | `account_balance_wallet` | Budget | Budgets, goals, cashflow |
| 5 | `chat` | AI | Chat interface for natural language logging |

### 5.2 Screen Layout Patterns

| Pattern | Used For |
|---|---|
| **Dashboard Cards** | Home screen — stacked cards with key metrics |
| **Scrollable List** | Transactions, debts, receivables |
| **Bottom Sheet** | Quick add transaction, filters, account selector |
| **Full-Screen Dialog** | Edit transaction, budget setup, goal creation |
| **Tab Bar + Content** | Budget screen (Budgets / Goals / Forecast tabs) |
| **Chat Interface** | AI assistant — message bubbles with action cards |

### 5.3 Responsive Design

- Single column layout (phone only — no tablet/desktop needed)
- Content width: full device width with 16dp horizontal padding
- Cards: 12dp corner radius, 1dp elevation
- Bottom sheet: 28dp top corner radius

---

## 6. Components

### 6.1 Transaction Card

```
┌─────────────────────────────────────────┐
│ 🍔  Food & Dining        -₱250.00      │
│     Jollibee lunch         Today 12:34  │
│     💳 GCash                            │
└─────────────────────────────────────────┘
```

- Category icon (colored circle) + name on the left
- Amount on the right (green for income, red for expense)
- Note and timestamp below
- Account indicator with icon
- Swipe actions: Edit (left), Delete (right)

### 6.2 Account Card (Dashboard)

```
┌─────────────────────────────────────────┐
│ 🏦  BDO Savings                         │
│     ₱45,230.50                          │
│     ▲ ₱2,300.00 this month              │
└─────────────────────────────────────────┘
```

### 6.3 Budget Progress Card

```
┌─────────────────────────────────────────┐
│ 🍔  Food & Dining                       │
│     ₱3,200 / ₱5,000                     │
│     ████████████░░░░░░░░  64%           │
│     ₱1,800 remaining · 12 days left     │
└─────────────────────────────────────────┘
```

- Progress bar color: green (<75%), orange (75-100%), red (>100%)

### 6.4 AI Chat Bubble

```
┌─ User ──────────────────────────────────┐
│ Starbucks 250 from GCash                │
└─────────────────────────────────────────┘

┌─ AI ────────────────────────────────────┐
│ Got it! Logged:                         │
│ ┌─────────────────────────────────────┐ │
│ │ ☕ Coffee & Drinks    -₱250.00      │ │
│ │    Starbucks · Today · GCash        │ │
│ │    [✓ Confirm]  [✏️ Edit]  [✕ Undo] │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

---

## 7. Motion & Animation

| Element | Animation | Duration |
|---|---|---|
| Screen transitions | Shared axis (horizontal) | 300ms |
| Bottom sheet | Slide up + fade | 250ms |
| Card tap | Subtle scale (0.98) + ripple | 100ms |
| Progress bar fill | Animated width | 400ms ease-out |
| Number changes | Count-up animation | 300ms |
| List item add | Slide in from right + fade | 200ms |
| List item delete | Slide out left + fade | 200ms |
| FAB tap | Scale bounce | 150ms |
| Page transitions | Material 3 predictive back | System |

---

## 8. Dark Mode

- **Default mode** — app launches in dark mode on first install
- Follows system preference via `ThemeMode.system`
- Manual override in Settings
- Dark mode uses M3 surface tones (Surface Dim, Surface Container)
- AMOLED-friendly: true black (`#000000`) option for the Samsung AMOLED display

---

## 9. Spacing System

Based on 4dp grid:

| Token | Value | Usage |
|---|---|---|
| `xs` | 4dp | Icon-to-text gaps |
| `sm` | 8dp | Intra-component spacing |
| `md` | 12dp | Between related elements |
| `lg` | 16dp | Screen padding, card padding |
| `xl` | 24dp | Between sections |
| `xxl` | 32dp | Top-level section gaps |

---

## 10. Accessibility

- Minimum touch target: 48×48dp
- Contrast ratio: ≥ 4.5:1 for text (WCAG AA)
- All icons have semantic labels
- Screen reader support via Flutter's built-in Semantics
- Dynamic text scaling support (up to 1.5x)

---

## 11. Key Screens (Wireframe Reference)

1. **Home / Dashboard** — Net worth, account cards, recent transactions, quick actions
2. **Transaction List** — Date-grouped list with search bar and filter chips
3. **Add Transaction** — Bottom sheet with amount keypad, category picker, account selector
4. **Budget Overview** — Category budgets with progress, monthly summary chart
5. **Savings Goals** — Goal cards with progress rings
6. **Cashflow Forecast** — Calendar/timeline of upcoming payments and income
7. **Debt Tracker** — Debt cards with payoff progress bars
8. **AI Chat** — Chat interface with message bubbles and transaction action cards
9. **Account Detail** — Transaction history for a single account
10. **Settings** — Theme, backup/restore, profiles, model management
