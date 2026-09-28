---
name: flutter-m3-premium-design
description: >
  Comprehensive Flutter UI/UX design system skill for building premium,
  Apple-quality Android apps using Material Design 3. Covers design tokens,
  component patterns, dark mode, motion, data visualization, typography,
  spacing, glassmorphism, and finance-specific UX patterns. Optimized for
  AMOLED displays (Samsung Galaxy A-series) with a "calm finance" aesthetic.
---

# Flutter M3 Premium Design System Skill

## Purpose

This skill ensures every screen, widget, and interaction in Hermanos Ledgr
feels **premium, polished, and intentional** — comparable to the best finance
apps on iOS and Android. It translates vague concepts like "make it look
premium" into concrete, actionable design rules.

---

## 1. Design Philosophy: "Calm Finance"

The app should feel like a **trusted financial advisor's desk** — clean,
organized, confident, and never overwhelming.

### Core Principles

| # | Principle | What It Means |
|---|---|---|
| 1 | **Trust through clarity** | Show the most important number (balance, net worth) large and confident. Hide complexity until requested. |
| 2 | **Progressive disclosure** | Dashboard → Summary → Detail. Never dump everything on one screen. |
| 3 | **Purposeful motion** | Every animation communicates something (confirmation, transition, progress). No decorative animation. |
| 4 | **Data as hero** | Numbers are the UI. Typography, spacing, and color exist to make data readable. |
| 5 | **Calm over flashy** | Muted, sophisticated palettes. No neon. No gamification confetti. Quiet confidence. |
| 6 | **Thumb-zone aware** | Primary actions in the bottom third. Viewing in the top two-thirds. |

---

## 2. Color System

### 2.1 Generating the Palette

```dart
// In app_theme.dart
final lightScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF2E7D32), // Forest Green
  brightness: Brightness.light,
);

final darkScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF2E7D32),
  brightness: Brightness.dark,
);
```

### 2.2 Surface Tones (Dark Mode)

Do NOT use pure black (`#000000`) as default background. Use M3's tonal
surface system for depth hierarchy:

| Surface Level | Token | Usage |
|---|---|---|
| Background | `surface` | Main screen background |
| Level 1 | `surfaceContainer` | Cards, list items |
| Level 2 | `surfaceContainerHigh` | Elevated cards, dialogs |
| Level 3 | `surfaceContainerHighest` | Modal sheets, menus |

**AMOLED Mode Exception:** When AMOLED mode is enabled, override `surface`
with `Color(0xFF000000)` and reduce other surface tones by 1 level.

### 2.3 Semantic Colors (Finance-Specific)

```dart
// color_tokens.dart
class SemanticColors {
  // Income — always positive, hopeful
  static const incomeLight = Color(0xFF2E7D32);  // Green 800
  static const incomeDark  = Color(0xFF81C784);   // Green 300

  // Expense — not alarming red, but clear
  static const expenseLight = Color(0xFFC62828); // Red 800
  static const expenseDark  = Color(0xFFEF9A9A); // Red 200

  // Transfer — neutral action
  static const transferLight = Color(0xFF1565C0); // Blue 800
  static const transferDark  = Color(0xFF64B5F6); // Blue 300

  // Warning — approaching limit
  static const warningLight = Color(0xFFE65100); // Orange 900
  static const warningDark  = Color(0xFFFFB74D); // Orange 300

  // Budget progress
  static const budgetSafe    = Color(0xFF66BB6A); // < 75%
  static const budgetCaution = Color(0xFFFFA726); // 75-100%
  static const budgetOver    = Color(0xFFEF5350); // > 100%
}
```

### 2.4 Color Usage Rules

- ❌ Never use raw `Colors.red` / `Colors.green` — always use semantic tokens
- ❌ Never use more than 3 accent colors on one screen
- ✅ Use `colorScheme.primary` for interactive elements
- ✅ Use `colorScheme.onSurface` for body text
- ✅ Use `colorScheme.onSurfaceVariant` for secondary/caption text
- ✅ Income amounts get `SemanticColors.income*`; expense gets `SemanticColors.expense*`

---

## 3. Typography

### 3.1 Font Configuration

```dart
// text_theme.dart
import 'package:google_fonts/google_fonts.dart';

TextTheme buildTextTheme(TextTheme base) {
  return GoogleFonts.interTextTheme(base).copyWith(
    // Hero numbers (net worth, big balance)
    displaySmall: GoogleFonts.inter(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
    ),
    // Screen titles
    headlineLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
    ),
    // Section headers
    headlineMedium: GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w500,
    ),
    // Card titles
    titleLarge: GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w500,
    ),
    // List item titles
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    // Buttons, tabs
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
  );
}
```

### 3.2 Number Typography Rules

Numbers are the most important element in a finance app:

- **Large amounts** (net worth, total balance): `displaySmall` + `FontWeight.w600`
- **Card amounts** (account balance): `titleLarge` + `FontWeight.w600`
- **List amounts** (transaction amount): `titleMedium` + `FontWeight.w600`
- **Small amounts** (change indicator): `bodySmall` + `FontWeight.w500`
- **Always right-aligned** in lists (scan pattern: left=what, right=how much)
- **Always monospaced-feel**: Use `fontFeatures: [FontFeature.tabularFigures()]`
  to prevent numbers from jumping around during animations

### 3.3 Currency Formatting

```dart
// ALWAYS format like this:
// ₱12,345.67        (normal)
// -₱1,234.56        (negative, colored red/expense)
// +₱500.00          (positive change indicator)
// ₱12.3K            (shortened for hero numbers when > 100K)
// ₱1.2M             (shortened for hero numbers when > 1M)
```

---

## 4. Spacing & Layout

### 4.1 Spacing Scale

Based on a 4dp base unit. Use these tokens exclusively — never raw numbers:

```dart
class Spacing {
  static const double xs  = 4;   // Icon-to-text gap
  static const double sm  = 8;   // Intra-component spacing
  static const double md  = 12;  // Between related elements
  static const double lg  = 16;  // Screen padding, card padding
  static const double xl  = 24;  // Between sections
  static const double xxl = 32;  // Major section gaps
  static const double xxxl = 48; // Top-level separators
}
```

### 4.2 Screen Padding

```
┌──────────────────────────────────────────────┐
│ ← 16dp →                        ← 16dp →    │
│                                              │
│   [Content Area]                             │
│                                              │
│ ← 16dp →                        ← 16dp →    │
└──────────────────────────────────────────────┘
```

- Horizontal screen padding: **16dp** (always)
- Vertical spacing between sections: **24dp**
- Card internal padding: **16dp** (all sides)
- List item vertical padding: **12dp**

### 4.3 Card Design

```dart
// Standard card
Card(
  elevation: 0,              // Flat cards (premium feel)
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),  // Slightly larger than M3 default
  ),
  color: colorScheme.surfaceContainer,
  child: Padding(
    padding: EdgeInsets.all(Spacing.lg),
    child: ...
  ),
)
```

**Premium card rules:**
- ✅ Zero elevation + surface tint for depth (not shadows)
- ✅ 16dp corner radius (softer than M3's default 12dp)
- ✅ Generous internal padding (16dp)
- ❌ No visible borders/outlines (rely on surface tone contrast)
- ❌ No heavy drop shadows (subtle only if needed)

### 4.4 Touch Targets

- Minimum: **48 × 48dp** (Material standard)
- Recommended for primary actions: **56 × 56dp**
- FAB: **56dp** diameter
- Bottom nav items: **64dp** height minimum

---

## 5. Component Patterns

### 5.1 Hero Number Display

The most important element in the app. Used for net worth, total balance.

```
┌──────────────────────────────────────────────┐
│                                              │
│        Your Net Worth                        │   ← bodyMedium, onSurfaceVariant
│        ₱245,678.90                           │   ← displaySmall, w600, onSurface
│        ▲ ₱12,345 this month                  │   ← bodySmall, green, w500
│                                              │
└──────────────────────────────────────────────┘
```

Rules:
- Label above the number (not below)
- Number is the largest text on the screen
- Change indicator below with arrow icon + color
- Animate number changes with count-up effect (300ms, easeOutCubic)

### 5.2 Account Card

```
┌──────────────────────────────────────────────┐
│  🏦                                          │
│  BDO Savings                  ₱45,230.50     │
│  Bank Account                 ▲ ₱2,300       │
└──────────────────────────────────────────────┘
```

Rules:
- Icon in top-left (24dp, colored circle background)
- Name left-aligned, amount right-aligned (baseline aligned)
- Type/subtitle below name, change indicator below amount
- Horizontal scroll for multiple accounts (snap to card)
- Card width: 200dp minimum

### 5.3 Transaction List Item

```
┌──────────────────────────────────────────────┐
│  [🍔]  Food & Dining              -₱250.00  │
│        Jollibee lunch     Today 12:34 PM     │
│        💳 GCash                              │
└──────────────────────────────────────────────┘
```

Rules:
- Category icon: 40dp circle with category color at 12% opacity as background
- Amount right-aligned, colored (red expense, green income, blue transfer)
- Note and timestamp on second line, muted color
- Account indicator on third line (optional, show when filtered by "All")
- Divider: thin (0.5dp) `colorScheme.outlineVariant`
- Date group headers: sticky, `labelLarge`, uppercase, surface background

### 5.4 Budget Progress Card

```
┌──────────────────────────────────────────────┐
│  [🍔]  Food & Dining                        │
│        ₱3,200 / ₱5,000                64%   │
│        ████████████░░░░░░░░░                 │
│        ₱1,800 remaining · 12 days left       │
└──────────────────────────────────────────────┘
```

Progress bar rules:
- Height: **6dp** (thin and elegant, not chunky)
- Corner radius: **3dp** (half height = fully rounded)
- Background: `surfaceContainerHigh`
- Fill color: `budgetSafe` / `budgetCaution` / `budgetOver`
- Animate fill width on load (400ms, easeOutCubic)
- Percentage text right-aligned to the progress bar

### 5.5 Bottom Sheet

```
┌──────────────────────────────────────────────┐
│                 ─────                        │  ← drag handle
│                                              │
│  Add Expense                                 │  ← headlineMedium
│                                              │
│  ┌────────────────────────────────────────┐  │
│  │  ₱ 0.00                               │  │  ← amount input (hero size)
│  └────────────────────────────────────────┘  │
│                                              │
│  [Category]  [Account]  [Date]               │  ← chip selectors
│                                              │
│  ┌──────────────────────────────────────┐    │
│  │  Note (optional)                     │    │  ← text field
│  └──────────────────────────────────────┘    │
│                                              │
│  ┌──────────────────────────────────────┐    │
│  │         [   Save   ]                 │    │  ← FilledButton, full width
│  └──────────────────────────────────────┘    │
└──────────────────────────────────────────────┘
```

Rules:
- Top corner radius: **28dp**
- Drag handle: 32×4dp, `onSurfaceVariant` at 40%
- Max height: 92% of screen
- Background: `surfaceContainerHigh`
- Slide up + fade animation: 250ms

### 5.6 Glassmorphism (Selective Use)

Use translucent glass effect **ONLY** for:
- Modal overlays
- Floating action sections
- Header bar when scrolling content behind it

```dart
// Glass container
ClipRRect(
  borderRadius: BorderRadius.circular(16),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
    child: Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: ...,
    ),
  ),
)
```

**DO NOT** use glassmorphism for:
- Regular cards (use solid surface tones)
- List items
- Input fields
- Any element where text readability is critical

---

## 6. Motion & Animation

### 6.1 Timing Curves

```dart
// Standard ease for most transitions
const standardCurve = Curves.easeOutCubic;

// For entrances (items appearing)
const entranceCurve = Curves.easeOutQuart;

// For exits (items leaving)
const exitCurve = Curves.easeInCubic;

// For emphasis (bouncy feedback)
const emphasisCurve = Curves.elasticOut;
```

### 6.2 Duration Scale

| Type | Duration | Usage |
|---|---|---|
| Micro | 100ms | Button press feedback, ripple |
| Short | 200ms | Chip toggle, icon change |
| Medium | 300ms | Page transition, card expand |
| Long | 400ms | Progress bar fill, number count-up |
| Extended | 500ms+ | Complex multi-element orchestration |

### 6.3 Required Animations

| Element | Animation | Spec |
|---|---|---|
| **Number change** | Count-up from old → new | 300ms, easeOutCubic |
| **Screen transition** | Shared axis X (horizontal) | 300ms, M3 standard |
| **Bottom sheet** | Slide up + fade in | 250ms, easeOutCubic |
| **Card appear** | Fade in + slide up 8dp | 200ms, staggered 50ms per item |
| **Progress bar** | Width fill from 0 | 400ms, easeOutCubic |
| **Delete item** | Slide out left + fade | 200ms, easeInCubic |
| **Add item** | Slide in from right + fade | 200ms, easeOutCubic |
| **Tab switch** | Cross-fade content | 200ms |
| **Pull to refresh** | M3 standard indicator | System |
| **FAB press** | Scale 0.95 → 1.0 | 100ms |

### 6.4 Stagger Pattern

When multiple cards load on screen (dashboard, budget list):

```dart
// Stagger each card's entrance by 50ms
AnimatedList with:
  - Item 0: delay 0ms,   duration 200ms
  - Item 1: delay 50ms,  duration 200ms
  - Item 2: delay 100ms, duration 200ms
  - Item 3: delay 150ms, duration 200ms
```

This creates a "cascade" effect that feels alive without being slow.

---

## 7. Dark Mode Rules

### 7.1 Surface Hierarchy

```
Darkest ─────────────────────────── Lightest
  │                                    │
  Background    Cards    Elevated    Sheets
  surface      surfaceC  surfaceCH  surfaceCHi
```

### 7.2 Text Contrast

| Content Type | Color Token | Opacity |
|---|---|---|
| Primary text | `onSurface` | 100% |
| Secondary text | `onSurfaceVariant` | 100% |
| Disabled text | `onSurface` | 38% |
| Hint text | `onSurfaceVariant` | 60% |

### 7.3 Dark Mode Don'ts

- ❌ Pure white text on pure black (too harsh — use `onSurface` which is slightly warm)
- ❌ Saturated colors at full brightness (they vibrate on dark backgrounds)
- ❌ Thin light borders (barely visible; use surface tone contrast instead)
- ❌ White icons (use `onSurface` or `onSurfaceVariant`)

---

## 8. Premium Polish Checklist

Before considering any screen "done," check:

- [ ] **Hero data** is the largest, most prominent element
- [ ] **Numbers are right-aligned** in all lists
- [ ] **Tabular figures** enabled for all financial numbers
- [ ] **Semantic colors** used (never raw `Colors.xxx`)
- [ ] **Loading states** use shimmer placeholders (not spinners)
- [ ] **Empty states** have illustration + helpful message + action button
- [ ] **Touch targets** ≥ 48dp
- [ ] **Contrast ratio** ≥ 4.5:1 for all text
- [ ] **Card corners** are 16dp (not 12dp)
- [ ] **Section spacing** uses `Spacing.xl` (24dp)
- [ ] **Animations** are present for all state changes
- [ ] **No janky frames** during transitions
- [ ] **Dark mode** tested and looks correct
- [ ] **AMOLED mode** tested with true black background

---

## 9. Icon & Illustration Style

### 9.1 Icons
- Use **Material Symbols Rounded** (weight 400)
- Selected state: **filled**
- Unselected state: **outlined**
- Size: 24dp (standard), 20dp (in chips/tags), 28dp (in nav bar)
- Color: `onSurface` for standard, `primary` for interactive

### 9.2 Empty States
Every empty list/screen must have:
1. A relevant Material icon (48dp, `onSurfaceVariant` at 40%)
2. A short, friendly message (e.g., "No transactions yet")
3. A call-to-action button (e.g., "Add your first expense")

Do NOT leave empty screens blank.

### 9.3 Shimmer Loading
Replace loading spinners with shimmer placeholders that match the layout:

```dart
// Use shimmer_animation or similar package
// Shimmer colors:
//   base: surfaceContainer
//   highlight: surfaceContainerHigh
```

---

## 10. Finance-Specific UX Patterns

### 10.1 Amount Input

- Show a large, centered amount field (not a small text input)
- Auto-add decimal separator
- Show currency symbol (₱) as prefix, non-editable
- Use custom number keypad (not system keyboard) for faster input
- Include quick-amount buttons: ₱100, ₱500, ₱1000, ₱5000

### 10.2 Category Selection

- Grid layout (3-4 columns)
- Each cell: icon (in colored circle) + label below
- Recently used categories shown first
- "More" row at bottom for less common categories
- Smooth scroll, no pagination

### 10.3 Date Picker

- Default to "Today" (pre-selected)
- Quick options: "Yesterday", "Last Friday", "Custom"
- Full calendar picker for custom dates
- Never force the user to pick a date for same-day transactions

### 10.4 Transaction Confirmation

After saving a transaction, show:
1. Brief success snackbar with the transaction summary
2. "Undo" action button (5-second window)
3. Auto-dismiss after 5 seconds

### 10.5 Destructive Actions

- Swipe-to-delete with red background + trash icon
- Always show confirmation dialog for delete
- Show what will be affected (e.g., "This will also update your GCash balance")

---

## 11. Chart & Data Visualization

### 11.1 Chart Style

```dart
// Use fl_chart with these defaults:
// Grid: hidden (clean look)
// Axis labels: bodySmall, onSurfaceVariant
// Data colors: use semantic colors (income green, expense red)
// Line thickness: 2dp
// Dot indicators: 4dp radius, filled
// Touch: show tooltip with exact value on touch
// Background: transparent (card provides the background)
```

### 11.2 Chart Types

| Data | Chart Type | Notes |
|---|---|---|
| Monthly spending trend | Line chart | 12 months, smooth curves |
| Category breakdown | Donut chart | Max 6 slices + "Other" |
| Budget vs. actual | Horizontal bar | Paired bars per category |
| Income vs. expense | Grouped bar | Monthly comparison |
| Account distribution | Horizontal stacked bar | Assets / Liabilities |

### 11.3 Chart Colors

Use the category's assigned color for category breakdowns.
For trend charts, use `primary` for the main line and `primaryContainer` for the fill area.

---

## 12. Accessibility

### 12.1 Required

- All interactive elements have `Semantics` labels
- All images have `semanticLabel`
- Screen reader announces amounts with "pesos" (e.g., "two hundred fifty pesos")
- Dynamic type support up to 1.5×
- Sufficient color contrast (WCAG AA: 4.5:1 for text, 3:1 for UI)

### 12.2 Color Blindness

- Never use color alone to convey information
- Income/expense differentiated by BOTH color AND icon/prefix (+/-)
- Budget progress uses BOTH color AND percentage text
