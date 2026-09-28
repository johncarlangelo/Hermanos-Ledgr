# Design System & UI/UX Specification
## Hermanos Ledgr

> **Version:** 2.0 · **Last Updated:** 2026-09-28
> **Status:** Planning · **Companion Skill:** `.agents/skills/flutter-m3-premium-design/SKILL.md`

---

## 1. Design Philosophy: "Calm Finance"

The app feels like a **trusted financial advisor's desk** — clean, organized, confident, and never overwhelming. Inspired by the sleek polish of Tarsi and Apple Human Interface Guidelines, but adapted strictly for Material Design 3 and Samsung AMOLED displays.

### 1.1 Core Principles

| # | Principle | Meaning |
|---|---|---|
| 1 | **Trust through clarity** | Key metrics (net worth, balances) are shown large, confident, and uncrowded. |
| 2 | **Progressive disclosure** | Dashboard → Summary → Drill-down. Complexity is revealed only when requested. |
| 3 | **Data as hero** | Numbers are the UI. Typography, spacing, and subtle tones exist to make numbers readable. |
| 4 | **Purposeful motion** | Every transition and count-up animation communicates state change. Zero frivolous animations. |
| 5 | **Calm over flashy** | Harmonious M3 tonal palettes, muted semantic accents, zero gamified badges or confetti. |
| 6 | **Thumb-zone aware** | Primary actions in the bottom third of the screen; viewing in the top two-thirds. |

### 1.2 Design Priorities (Ordered)
1. **Speed of input** — Frictionless logging in under 3 taps
2. **Clarity of data** — Instant scannability of balances, charts, and lists
3. **Visual comfort** — Dark mode by default with true black AMOLED option
4. **Microinteractions** — Haptic feedback, count-ups, and smooth card transitions
5. **Consistency** — Strictly Material Design 3 tokens and components

---

## 2. Color System

Based on Material Design 3 dynamic color generated with a **custom seed color**.

### 2.1 Brand Seed Color

```
Primary Seed: #2E7D32 (Forest Green — finance, growth, stability)
```

The entire M3 tonal palette is generated from this seed using `ColorScheme.fromSeed(seedColor: Color(0xFF2E7D32))`.

### 2.2 Semantic Colors (Finance Specific)

| Role | Light Mode | Dark Mode | Usage |
|---|---|---|---|
| **Income** | `#2E7D32` (Green 800) | `#81C784` (Green 300) | Income amounts, positive cashflow indicators |
| **Expense** | `#C62828` (Red 800) | `#EF9A9A` (Red 200) | Expense amounts, negative cashflow indicators |
| **Transfer** | `#1565C0` (Blue 800) | `#64B5F6` (Blue 300) | Account transfers, balance adjustments |
| **Warning / Due** | `#E65100` (Orange 900) | `#FFB74D` (Orange 300) | Approaching budget, upcoming debt dues |
| **Budget Safe (<75%)** | `#2E7D32` | `#66BB6A` | Normal spending on track |
| **Budget Caution (75-100%)** | `#EF6C00` | `#FFA726` | Approaching limit |
| **Budget Over (>100%)** | `#C62828` | `#EF5350` | Over-budget alert |

### 2.3 Surface Tones (Dark Mode Hierarchy)

Rather than raw black, M3 dark mode uses tonal surfaces to create natural depth:

| Level | Token | Usage |
|---|---|---|
| **Base** | `surface` | Main scaffold background (`#111411` approx) |
| **Level 1** | `surfaceContainer` | Standard cards, transaction list items |
| **Level 2** | `surfaceContainerHigh` | Elevated cards, action dialogues |
| **Level 3** | `surfaceContainerHighest` | Bottom sheets, popover menus |

**AMOLED Mode Rule:** When AMOLED mode is enabled, `surface` is overridden with `#000000` (true black for Samsung AMOLED power saving), and container levels shift down by 1 step.

### 2.4 Color Usage Rules
- ❌ Never use raw `Colors.red` or `Colors.green` — always use defined semantic tokens.
- ❌ Maximum 3 accent colors per screen to prevent visual fatigue.
- ✅ Always pair colored indicators with text or icons for color-blind accessibility.

---

## 3. Typography

### 3.1 Font Family
**Google Fonts — Inter** (variable weight)
- Clean geometry with excellent legibility at small sizes.
- **Tabular Figures Required:** All monetary amounts MUST use `fontFeatures: [FontFeature.tabularFigures()]` so digits share uniform width, preventing text jump during count-ups or list scrolling.
- Fallback: `Roboto` (system default).

### 3.2 Type Scale (M3 Extended)

| Role | Size | Weight | Tracking | Usage |
|---|---|---|---|---|
| **Display Small** | 36sp | 600 (SemiBold) | -0.5 | Net worth hero number, big total |
| **Headline Large** | 32sp | 600 (SemiBold) | -0.25 | Screen headers |
| **Headline Medium**| 28sp | 500 (Medium) | 0.0 | Section headers |
| **Headline Small** | 24sp | 500 (Medium) | 0.0 | Group headers, bottom sheet titles |
| **Title Large** | 22sp | 500 (Medium) | 0.0 | Account card balances |
| **Title Medium**| 16sp | 500 (Medium) | 0.1 | Transaction list amounts, card titles |
| **Title Small** | 14sp | 500 (Medium) | 0.1 | Category labels, chip text |
| **Body Large** | 16sp | 400 (Regular) | 0.5 | Form inputs, notes |
| **Body Medium**| 14sp | 400 (Regular) | 0.25 | Secondary list text, timestamps |
| **Body Small** | 12sp | 400 (Regular) | 0.4 | Micro-captions, percentage text |
| **Label Large**| 14sp | 500 (Medium) | 0.1 | Buttons, action links |
| **Label Small**| 11sp | 500 (Medium) | 0.5 | Badges, micro tags |

### 3.3 Number Formatting
- Currency: **₱** prefix, comma-separated thousands, 2 decimal places (`₱12,345.67`)
- Negative amounts: `-₱1,234.56` (rendered with expense color)
- Positive changes: `+₱500.00` (rendered with income color)
- Shortened hero numbers (> ₱100K): `₱125.4K`, `₱1.25M` on small widgets

---

## 4. Spacing & Touch Targets

Based on a strict 4dp grid system:

| Token | Value | Application |
|---|---|---|
| `xs` | 4dp | Icon-to-label gaps, badge padding |
| `sm` | 8dp | Inner component padding, chip spacing |
| `md` | 12dp | List item vertical spacing, form field gaps |
| `lg` | 16dp | Screen horizontal padding, card internal padding |
| `xl` | 24dp | Vertical spacing between major sections |
| `xxl`| 32dp | Top-level layout separators |
| `xxxl`| 48dp| Screen bottom padding / FAB buffer |

### Touch Targets
- Minimum touch area: **48 × 48dp** (WCAG standard)
- Primary CTA buttons: **56dp** height
- Floating Action Button (FAB): **56 × 56dp**
- Bottom Navigation Items: **64dp** height minimum

---

## 5. Navigation & Layout

### 5.1 Bottom Navigation Bar (5 Destinations)
Using Material 3 `NavigationBar`:

| Tab | Icon | Label | Destination Screen |
|---|---|---|---|
| 1 | `home` | Home | Net worth, quick accounts, recent transactions |
| 2 | `receipt_long` | Transactions | Date-grouped list, filters, search |
| 3 | `add_circle` | Log | Quick Add Bottom Sheet (centered highlight) |
| 4 | `account_balance_wallet` | Budget | Budgets, Savings Goals, Forecast |
| 5 | `chat` | AI | On-device LLM natural language log & chat |

### 5.2 Card Architecture
- Corner radius: **16dp** (softer, premium feel compared to default 12dp)
- Elevation: **0** (flat aesthetic relying on tonal contrast `surfaceContainer`)
- Borders: No hard outline borders; separation achieved via surface tone depth
- Padding: **16dp** all around

---

## 6. Component Specifications

### 6.1 Hero Number Display (Dashboard)
```
┌──────────────────────────────────────────────┐
│        Net Worth                             │  ← bodyMedium, onSurfaceVariant
│        ₱245,678.90                           │  ← displaySmall (36sp), w600, tabular
│        ▲ +₱12,345.00 this month              │  ← bodySmall, income color, w500
└──────────────────────────────────────────────┘
```
- Label positioned *above* the figure.
- Animated count-up effect on initial load (300ms, `Curves.easeOutCubic`).

### 6.2 Transaction List Item
```
┌──────────────────────────────────────────────┐
│  [🍔]  Food & Dining              -₱250.00  │  ← titleMedium, tabular, right-aligned
│        Jollibee lunch     Today 12:34 PM     │  ← bodyMedium, muted
│        💳 GCash                              │  ← micro tag (labelSmall)
└──────────────────────────────────────────────┘
```
- Category icon: 40dp circle with category color at 12% opacity.
- Amount always right-aligned (`titleMedium`, tabular figures).
- Date grouping headers: sticky headers, uppercase `labelLarge`.
- Swipe actions: Edit (swipe right, blue), Delete (swipe left, red with trash icon).

### 6.3 Budget Progress Card
```
┌──────────────────────────────────────────────┐
│  [🍔]  Food & Dining                        │
│        ₱3,200.00 / ₱5,000.00          64%   │  ← bodyMedium & percentage
│        ████████████░░░░░░░░░                 │  ← 6dp height, 3dp rounded corners
│        ₱1,800.00 remaining · 12 days left   │  ← bodySmall, onSurfaceVariant
└──────────────────────────────────────────────┘
```
- Progress bar height: **6dp** (slim, elegant).
- Fully rounded ends (3dp radius).
- Fill animation: 400ms `Curves.easeOutCubic`.

### 6.4 Bottom Sheet (Quick Add)
- Corner radius: **28dp** top corners.
- Drag handle: 32×4dp centered (`onSurfaceVariant` at 40%).
- Max height: 92% of viewport.
- Custom numerical keypad for rapid one-handed expense logging.
- Quick amount chips: `+₱100`, `+₱500`, `+₱1,000`, `+₱5,000`.

### 6.5 AI Chat Bubble & Action Card
```
┌─ User ──────────────────────────────────────┐
│ Starbucks 250 from GCash                    │
└─────────────────────────────────────────────┘

┌─ Hermanos AI ───────────────────────────────┐
│ Logged the expense for you:                 │
│ ┌─────────────────────────────────────────┐ │
│ │ ☕ Coffee & Drinks       -₱250.00       │ │
│ │    Starbucks · Today · GCash            │ │
│ │    [✓ Confirm]   [✏️ Edit]   [✕ Undo]   │ │
│ └─────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

### 6.6 Selective Glassmorphism
- Translucent backdrop blur (`ImageFilter.blur(sigmaX: 20, sigmaY: 20)`) is used **strictly for**:
  1. Sticky top navigation headers with scrolling content behind
  2. Modal overlays and floating bottom bars
- **Never** applied to card backgrounds or text fields where readability would suffer.

---

## 7. Motion & Animation

| Motion Type | Duration | Curve | Purpose |
|---|---|---|---|
| **Micro (Press)** | 100ms | `Curves.easeInOut` | Card tap, button scale bounce (0.98x) |
| **Short (Toggle)** | 200ms | `Curves.easeOutCubic` | Chip selection, icon state change |
| **Medium (Transition)** | 300ms | `Curves.easeOutCubic` | Shared Axis horizontal screen transition |
| **Long (Progress/Number)**| 400ms | `Curves.easeOutCubic` | Progress bar fill, count-up numbers |
| **Card Cascade** | 200ms (50ms stagger) | `Curves.easeOutQuart` | Dashboard cards sliding up into place |

---

## 8. Finance-Specific UX Patterns

1. **Custom Keypad:** Custom in-sheet keypad with large tap targets, avoiding system keyboard jumps.
2. **5-Second Undo Toast:** Whenever a transaction is saved, edited, or deleted, a SnackBar with an `[Undo]` button persists for 5 seconds.
3. **Category Grid:** 3–4 column grid of circular icon chips with the 4 most recently used categories shown first.
4. **Shimmer Loading:** Skeleton loading cards matching the exact layout of data cards (never bare spinners).
5. **Polished Empty States:** Every empty list contains an icon (48dp, 40% opacity), a friendly explanation, and an immediate CTA button.

---

## 9. Charts & Data Visualization (`fl_chart`)

- **Grid Lines:** Hidden by default for a minimal, clean aesthetic.
- **Background:** Transparent (the surrounding card provides container tone).
- **Line Thickness:** 2dp with 4dp filled point dots.
- **Donut Slices:** Maximum 6 distinct categories; remaining grouped into "Other" (`#9E9E9E`).
- **Interactive Tooltips:** Show exact ₱ amount and percentage on touch.

---

## 10. Implementation Reference

All UI components, tokens, and layouts must adhere to the detailed implementation guide in:
👉 [`.agents/skills/flutter-m3-premium-design/SKILL.md`](file:///d:/Comsci%20things/Hermanos%20Ledgr%20-%20Budget%20Tracking%20app/hermanos-ledgr/.agents/skills/flutter-m3-premium-design/SKILL.md)
