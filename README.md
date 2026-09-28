# Hermanos Ledgr

<div align="center">

**A calm, offline-first personal finance tracker with on-device local AI.**  
*Crafted for Android & optimized for Samsung Galaxy Super AMOLED displays.*

[![Platform](https://img.shields.io/badge/Platform-Android%2012%2B%20(API%2031%2B)-3DDC84?style=flat-square&logo=android&logoColor=white)](https://android.com)
[![Target Device](https://img.shields.io/badge/Target-Samsung%20Galaxy%20A36%205G-1428A0?style=flat-square&logo=samsung&logoColor=white)](https://samsung.com)
[![Flutter](https://img.shields.io/badge/Flutter-3.44%2B-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Design](https://img.shields.io/badge/Design-Material%20Design%203-2E7D32?style=flat-square)](DESIGN.md)
[![Privacy](https://img.shields.io/badge/Privacy-100%25%20On--Device%20(Zero%20Cloud)-brightgreen?style=flat-square)](#privacy--security)

</div>

---

## 📖 Overview

**Hermanos Ledgr** is a personal-use Android finance tracker. It delivers the sleekness and intelligence of top-tier finance apps without monthly subscriptions, account logins, cloud dependencies, or tracking.

The app is built around the **"Calm Finance"** philosophy: an uncluttered, high-craft interface where numbers are clear heroes, typography is stabilized with tabular figures, and repetitive actions take under 3 seconds.

---

## 🌟 Key Principles

| Principle | Detail |
|---|---|
| **Zero-Cloud Privacy** | All database tables, preferences, and backups live strictly on your device. Zero telemetry, zero analytics, zero external network requests. |
| **On-Device Local AI** | Natural language logging powered by a cascaded hybrid pipeline (Tier 1 fast classifier < 30 MB + Tier 2 Sub-1B Light LLM `Qwen 2.5 0.5B` ~350 MB) running on-chip via `flutter_llama` (llama.cpp FFI). |
| **Optimized for Samsung AMOLED** | Dedicated **AMOLED Black** mode (`#000000`) designed specifically for Samsung Galaxy Super AMOLED displays to maximize battery life, alongside modern M3 tonal dark and light modes. |
| **Philippine-Centric Presets** | Hardcoded Philippine Peso (`₱`) formatting and native presets for Philippine financial accounts: **GCash**, **Maya**, **BDO Unibank**, **BPI**, and cash wallets. |
| **No Paywalls or Subscriptions** | Every feature—unlimited transaction logging, cashflow forecasting, custom budgets, and AI parsing—is unlocked from day one. |

---

## 📱 App Experience & Feature Modules

### 1. First-Run Onboarding Flow
* **Interactive Walkthrough**: Introduces the offline-first philosophy and privacy guarantees.
* **Live Theme Selection**: Preview and toggle immediately between **Dark Mode** (M3 tonal surfaces), **AMOLED Black** (pure black `#000000`), and **Light Mode**.
* **Personalized Setup**: Set your profile name and select default starter accounts (GCash, Cash, BDO, Maya, etc.).
* **Replayable**: Access the onboarding anytime via the book icon in the top AppBar for review or re-configuration.

### 2. Home Dashboard
* **Net Worth Hero Card**: High-contrast hero balance with count-up animation (`Curves.easeOutCubic`) and month-over-month indicators.
* **Asset & Liability Breakdown**: Clean separation of positive balances and credit liabilities.
* **Scrollable Accounts Carousel**: Card-based overview of all banks, e-wallets, and credit cards with monthly balance change tags.
* **Quick Actions**: One-tap access to log expenses, income, or transfers.
* **Recent Activity**: Quick review of the latest transactions with swipe-to-delete support.

### 3. Rapid Transaction Logging (Quick Add)
* **28dp Rounded Bottom Sheet**: Accessible via the prominent center **Log** destination or quick action buttons.
* **Custom Numerical Keypad**: Ergonomic 12dp touch buttons and quick amount chips (`+₱100`, `+₱500`, `+₱1,000`, `+₱5,000`) designed for fast one-handed entry without keyboard jumping.
* **Philippine Category Picker**: Visual grid of categorized chips with curated icons and colors.
* **5-Second Undo Toast**: Floating snackbar with an `[Undo]` button displayed after every add, edit, or delete action to prevent accidental entries.

### 4. Transactions Ledger
* **Sticky-Style Date Headers**: Clean chronological grouping (`TODAY`, `YESTERDAY`, specific dates).
* **Live Search & Filter**: Real-time filtering across titles, notes, accounts, or categories.
* **Type Chips**: Filter instantly by `All`, `Expense`, `Income`, or `Transfer`.
* **Tabular Figures**: Every amount is rendered with `FontFeature.tabularFigures()` so digits maintain fixed horizontal widths.

### 5. Budget & Financial Planning
* **Monthly Overview**: Track monthly spending against target limits with an overall status progress bar.
* **Spending Breakdown Chart**: Interactive donut chart powered by `fl_chart` with slice-touch tooltips.
* **Category Progress Cards**: 6dp slim progress bars with 3dp fully rounded ends and visual status indicators:
  * 🟢 **Safe** (< 75% limit)
  * 🟠 **Caution** (75% – 100% limit)
  * 🔴 **Over Budget** (> 100% limit)
* **Savings Goal Preview**: Track target dates and progress rings for emergency funds or long-term goals.

### 6. Hermanos AI Assistant (Cascaded Hybrid AI)
* **Cascaded Two-Tier Pipeline**:
  * **Tier 1 (Fast Classifier & Extractor)**: Ultra-fast on-device decision model (< 30 MB) executing in `< 20ms` with calibrated confidence—resolves ~90% of daily transactions without waking heavy LLM isolates.
  * **Tier 2 (Sub-1B Light LLM)**: Compact `Qwen 2.5 0.5B Instruct` (~350 MB GGUF) via `flutter_llama` with Qualcomm Adreno GPU acceleration, invoked only for complex multi-item splits, conversational queries, and daily spending summaries.
* **Natural Language Logging**: Type or speak naturally:
  * *"Starbucks 250 GCash"*
  * *"Salary 35k BDO"*
  * *"Paid electric 3820 from Maya"*
  * *"Transfer 5k from BDO to GCash"*
* **Structured Action Cards**: The model extracts the title, amount, category, and source account into a confirmation card.
* **User Confirmation**: Transactions are never committed silently; you review and tap **[Confirm]** before it touches your ledger.

---

## 🎨 Design System Tokens

Hermanos Ledgr follows the specifications defined in [`DESIGN.md`](DESIGN.md) and [`.agents/skills/flutter-m3-premium-design/SKILL.md`](.agents/skills/flutter-m3-premium-design/SKILL.md):

* **Seed Color**: `#2E7D32` (Forest Green)
* **Font Family**: [Google Fonts Inter](https://fonts.google.com/specimen/Inter)
* **Cards**: Corner radius `16dp`, elevation `0`, background `surfaceContainer`.
* **Touch Targets**: Minimum `48 × 48dp` (WCAG compliance), primary CTA buttons `52–56dp`.
* **Spacing Scale**: 4dp base unit (`xs: 4`, `sm: 8`, `md: 12`, `lg: 16`, `xl: 24`, `xxl: 32`, `xxxl: 48`).

---

## 🏗️ Architecture & Directory Structure

Follows a **feature-first modular architecture** combined with **Clean Architecture** layering:

```
lib/
├── app/                        # App shell, navigation, and theme definitions
│   ├── app.dart                # MaterialApp.router root with theme binding
│   ├── router.dart             # GoRouter configuration & route guards
│   ├── shell_scaffold.dart     # 5-destination NavigationBar & top actions
│   └── theme/
│       ├── app_theme.dart      # M3 Light, Dark, and AMOLED ThemeData
│       ├── color_tokens.dart   # SemanticColors & Spacing scale
│       └── text_theme.dart     # Inter typography & tabular figures helper
│
├── core/                       # Shared models, constants, and utilities
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── category_defaults.dart
│   ├── models/
│   │   └── result.dart         # Sealed Result<T> pattern
│   ├── providers/
│   │   ├── onboarding_provider.dart
│   │   └── theme_provider.dart
│   └── utils/
│       └── currency_formatter.dart
│
├── features/                   # Self-contained feature modules
│   ├── accounts/
│   ├── ai_assistant/
│   ├── budget/
│   ├── dashboard/
│   ├── onboarding/
│   └── transactions/
│
└── shared/                     # Reusable UI widgets adhering to design skill
    └── widgets/
        ├── custom_keypad.dart
        ├── empty_state_view.dart
        ├── hero_amount_display.dart
        ├── m3_card.dart
        ├── shimmer_card.dart
        └── undo_snackbar.dart
```

---

## 🚀 Getting Started & Running

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.44+
* Dart 3.12+
* Android Studio or VS Code with Flutter extension
* Android Device running Android 12+ (API 31+) or Android Emulator

### Installation

```bash
# Clone the repository
git clone https://github.com/johncarlangelo/hermanos-ledgr.git
cd hermanos-ledgr

# Fetch Flutter dependencies
flutter pub get
```

### Running the App

#### 1. On your connected Android Device or Emulator
```bash
# Verify connected devices
flutter devices

# Run on Android
flutter run
```

#### 2. Instant Local Preview in Chrome
For rapid UI and styling review on desktop:
```bash
flutter run -d chrome
```
> **Tip for Chrome Preview**: Open Developer Tools (`F12`), toggle the device toolbar (`Ctrl+Shift+M`), and select **Samsung Galaxy S20 / A-series** (`412 × 915`) to preview the exact mobile layout and scaling.

### Verification & Testing

```bash
# Run static analysis (0 warnings / 0 errors)
flutter analyze

# Run unit and widget tests
flutter test
```

---

## 🔒 Privacy & Philosophy

Hermanos Ledgr is developed as personal-use software. It will never include:
* ❌ Cloud synchronization or telemetry
* ❌ Third-party trackers or advertising SDKs
* ❌ Account sign-ups or subscription paywalls
* ❌ Gamification badges or frivolous confetti animations

Your financial data is private, confidential, and completely yours.
