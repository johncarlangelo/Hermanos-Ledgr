# Hermanos Ledgr

<div align="center">

**A calm, offline-first personal finance tracker with on-device local AI.**  
*Crafted for Android & optimized for Samsung Galaxy Super AMOLED displays.*

[![Platform](https://img.shields.io/badge/Platform-Android%2012%2B%20(API%2031%2B)-3DDC84?style=flat-square&logo=android&logoColor=white)](https://android.com)
[![Target Device](https://img.shields.io/badge/Target-Samsung%20Galaxy%20A36%20%2F%20A55-1428A0?style=flat-square&logo=samsung&logoColor=white)](https://samsung.com)
[![Flutter](https://img.shields.io/badge/Flutter-3.44%2B-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Version](https://img.shields.io/badge/Version-v0.18.9--alpha-00897B?style=flat-square)](pubspec.yaml)
[![Design](https://img.shields.io/badge/Design-Material%20Design%203%20(Stash%20Teal)-7FB8AE?style=flat-square)](DESIGN.md)
[![Privacy](https://img.shields.io/badge/Privacy-100%25%20On--Device%20(Zero%20Cloud)-brightgreen?style=flat-square)](#-privacy--security)

</div>

---

## 📖 Overview

**Hermanos Ledgr** is a personal-use Android finance tracker built with Flutter. It delivers the sleekness, speed, and intelligence of modern finance apps without monthly subscriptions, cloud servers, telemetry, or account logins.

The app is built around the **"Calm Finance"** philosophy: an uncluttered, high-craft interface where numbers are clear heroes, typography is stabilized with tabular figures, repetitive actions take under 3 seconds, and your personal financial data remains strictly on your device.

---

## 🌟 Key Principles

| Principle | Detail |
|---|---|
| **Zero-Cloud Privacy** | All database tables, preferences, and backups live strictly on your device in an encrypted/local SQLite database powered by Drift. Zero telemetry, zero analytics, zero external network requests. |
| **Hermanos-Stash Design** | Bespoke dark UI hierarchy (`base`, `shell`, `surface`, `raised`, `overlay`) paired with **Stash Teal** accents (`#7FB8AE`), 16dp rounded cards, 28dp sheets, and zero generic stock Android components. |
| **Optimized for Samsung AMOLED** | Dedicated **AMOLED Black** mode (`#000000`) designed specifically for Samsung Galaxy Super AMOLED displays to maximize battery life, alongside modern M3 tonal dark and light modes. |
| **On-Device Local AI** | Natural language logging powered by a cascaded hybrid pipeline (Tier 1 fast regex/heuristic classifier < 20ms + Tier 2 Sub-1B Light LLM `Qwen 2.5 0.5B` ~350 MB) running on-chip via `flutter_llama` (llama.cpp FFI). |
| **Camera & Receipt OCR** | Instant receipt scanning powered by Google ML Kit on-device text recognition, extracting merchant names, dates, amounts, and line items without sending photos to any cloud API. |
| **Philippine-Centric Presets** | Hardcoded Philippine Peso (`₱`) formatting and native presets for Philippine financial accounts: **GCash**, **Maya**, **BDO Unibank**, **BPI**, **UnionBank**, and cash wallets. |
| **In-App OTA Updates** | Automatic release checking and silent background APK downloads via GitHub Releases, sideloading updates directly without Google Play Store dependency. |
| **No Paywalls or Subscriptions** | Every feature—unlimited transaction logging, cashflow forecasting, custom budgets, debt tracking, bill splitting, and AI parsing—is completely free and unlocked. |

---

## 📱 App Experience & Feature Modules

### 1. First-Run Onboarding Flow
* **Interactive Walkthrough**: Introduces the offline-first philosophy, architecture, and privacy guarantees.
* **Live Theme Selection**: Preview and toggle immediately between **Dark Mode** (M3 tonal surfaces), **AMOLED Black** (pure black `#000000`), and **Light Mode**.
* **Personalized Setup**: Set your profile name and select default starter accounts (GCash, Cash, BDO, Maya, etc.).
* **Replayable**: Access the onboarding walkthrough anytime via the book icon in the top AppBar for review or re-configuration.

### 2. Home Dashboard
* **Net Worth Hero Card**: High-contrast hero balance with count-up animation (`Curves.easeOutCubic`) and month-over-month indicators.
* **Asset & Liability Breakdown**: Clean separation of positive balances and credit liabilities.
* **Scrollable Accounts Carousel**: Card-based overview of all banks, e-wallets, and credit cards with monthly balance change tags and card network badges.
* **Cash Flow Summary**: Quick comparative view of monthly income vs. monthly expenses.
* **Quick Actions**: One-tap speed dials to log expenses, income, transfers, or open the camera receipt scanner.
* **Recent Activity**: Quick review of the latest transactions with swipe-to-delete support and 5-second undo toast.

### 3. Rapid Transaction Logging (Quick Add)
* **28dp Rounded Modal Bottom Sheet**: Accessible via the prominent center **Log** destination or quick action buttons.
* **Custom Numerical Keypad**: Ergonomic 12dp touch buttons and quick amount increment chips (`+₱100`, `+₱500`, `+₱1,000`, `+₱5,000`) designed for fast one-handed entry without keyboard jumping.
* **Philippine Category Picker**: Visual grid of categorized chips with curated icons, colors, and subcategories.
* **System Navigation Safe Area**: Dynamic padding respecting 3-button system navigation bars on Samsung Galaxy devices.
* **5-Second Undo Toast**: Floating `UndoSnackbar` pill card with an `[Undo]` button displayed after every add, edit, or delete action to prevent accidental entries.

### 4. Transactions Ledger
* **Sticky-Style Date Headers**: Clean chronological grouping (`TODAY`, `YESTERDAY`, specific dates).
* **Live Search & Filter**: Real-time filtering across titles, notes, accounts, or categories.
* **Type Chips**: Filter instantly by `All`, `Expense`, `Income`, or `Transfer`.
* **Tabular Figures**: Every amount is rendered with `FontFeature.tabularFigures()` so digits maintain fixed horizontal widths without visual jitter.
* **Date Range Filtering**: Custom bottom sheet date selector to review statements across custom calendar periods.

### 5. Accounts & Personalized Cards
* **Multi-Account Tracking**: Manage checking accounts, savings, credit cards, digital e-wallets, and cash.
* **Personalized Card Styling**: Custom gradients, card designs, account nicknames, and card network logos (Visa, Mastercard, JCB, GCash, Maya).
* **Direct Account Transfers**: Dedicated flow to log balance transfers between accounts with linked double-entry ledger records.
* **Balance Adjustments**: Easily correct balances with automatic reconciliation transactions.

### 6. Budget & Financial Planning
* **Monthly Overview**: Track monthly spending against target limits with an overall status progress bar.
* **Spending Breakdown Chart**: Interactive donut chart powered by `fl_chart` with slice-touch tooltips and legends.
* **Category Progress Cards**: 6dp slim progress bars with 3dp fully rounded ends and visual status indicators:
  * 🟢 **Safe** (< 75% limit)
  * 🟠 **Caution** (75% – 100% limit)
  * 🔴 **Over Budget** (> 100% limit)
* **Editable Category Budgets**: Custom bottom sheet to set or adjust category spending thresholds on the fly.

### 7. Recurring Commitments & Subscriptions
* **Flexible Frequencies**: Schedule bills, subscriptions, rent, and recurring income across Daily, Weekly, Bi-weekly, Monthly, or Yearly cadences.
* **Cash Flow Forecast**: Preview projected recurring commitments due over the next 30 days.
* **Due Date Reminders**: Local notification alerts before upcoming payment deadlines.
* **Auto-Logging**: Quickly convert recurring rules into logged transactions upon payment confirmation.

### 8. Debts, Loans & Bill Splitter
* **Receivables & Payables Tracking**: Track money lent to friends or money owed with due dates and contact notes.
* **Partial & Full Repayments**: Record repayments via custom bottom sheets with automatic balance adjustments.
* **Built-in Bill Splitter**: Calculate equal or custom split shares, compute tips, and directly convert split shares into tracked debts or logged transactions.

### 9. Savings Goals & Milestones
* **Goal Progress Rings**: Visualize progress towards emergency funds, vacations, or major purchases.
* **Target Dates & Projections**: Calculates required monthly savings needed to hit milestones on schedule.
* **Contributions Sheet**: Log deposits towards goals with automated deductions from selected funding accounts.

### 10. Receipt OCR Camera Scanner
* **On-Device Vision Recognition**: Extracts text from paper receipts and invoices using Google ML Kit.
* **Smart Parsing Engine**: Heuristically extracts merchant names, total transaction amounts, dates, and line items.
* **Interactive Review Sheet**: Verify extracted details before saving directly into your ledger.

### 11. Hermanos AI Assistant (Cascaded Hybrid AI)
* **Two-Tier Processing Pipeline**:
  * **Tier 1 (Fast Classifier & Extractor)**: Ultra-fast on-device regex & heuristic model executing in `< 20ms` for standard logs (`"Coffee 150 GCash"`).
  * **Tier 2 (Sub-1B Light LLM)**: Compact `Qwen 2.5 0.5B Instruct` (~350 MB GGUF) via `flutter_llama` with Qualcomm Adreno GPU acceleration, invoked for conversational financial summaries and complex split items.
* **Structured Action Cards**: The assistant parses inputs into editable transaction confirmation cards.
* **Explicit User Confirmation**: Transactions are never saved silently; you review and confirm before writing to SQLite.

### 12. Settings, Data Portability & OTA Updater
* **Theme Modes**: Instantly switch between System, Light, Dark (Stash), and AMOLED Black.
* **Full Database Backup & Restore**: Export complete SQLite database snapshots or restore from previous backups.
* **CSV & JSON Export**: Export your entire transaction ledger or category budgets for analysis in Excel, Google Sheets, or custom scripts.
* **GitHub In-App OTA Updater**: Checks `api.github.com/repos/johncarlangelo/hermanos-ledgr/releases/latest`, downloads release APKs in the background, and prompts for one-tap sideload install.
* **Danger Zone**: One-tap data reset with confirmation sheets to wipe sample data or reset to default configurations.

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
│       ├── color_tokens.dart   # StashColors, SemanticColors & Spacing scale
│       └── text_theme.dart     # Inter typography & tabular figures helper
│
├── core/                       # Shared models, constants, database, and utilities
│   ├── constants/
│   │   ├── app_constants.dart  # Version, build number, app metadata
│   │   └── category_defaults.dart
│   ├── database/
│   │   ├── app_database.dart   # Drift SQLite database instance
│   │   ├── daos/               # 9 specialized Drift DAOs (accounts, transactions, budgets, etc.)
│   │   ├── database_mappers.dart
│   │   └── tables/             # Drift table definitions
│   ├── models/
│   │   └── result.dart         # Sealed Result<T> pattern
│   ├── providers/              # Core global providers (database, onboarding, theme)
│   └── utils/
│       └── currency_formatter.dart
│
├── features/                   # Self-contained feature modules
│   ├── accounts/               # Account cards, balances, transfers, card network logos
│   ├── ai_assistant/           # Hybrid cascaded AI, llama.cpp FFI integration
│   ├── backup/                 # SQLite database export/import, CSV/JSON exporters
│   ├── budget/                 # Category budgets, fl_chart spending donut, edit sheet
│   ├── dashboard/              # Net worth hero, account carousel, quick actions
│   ├── debts/                  # Receivables, payables, repayments, bill splitter
│   ├── goals/                  # Savings goals, target dates, contribution logging
│   ├── notes/                  # Financial memos & transaction notes
│   ├── onboarding/             # Interactive intro walkthrough & theme selector
│   ├── profile/                # User profile personalization
│   ├── receipt_scanner/        # Google ML Kit camera OCR receipt scanner
│   ├── recurring/              # Recurring rules, subscriptions, cash flow forecast
│   ├── settings/               # Appearance, OTA updater, export, danger zone
│   ├── splash/                 # Splash loading screen & database hydration
│   └── transactions/           # Transaction ledger, search/filter, quick add keypad
│
└── shared/                     # Reusable UI widgets adhering to design skill
    └── widgets/
        ├── custom_keypad.dart
        ├── empty_state_view.dart
        ├── hero_amount_display.dart
        ├── m3_card.dart
        ├── shimmer_card.dart
        ├── undo_snackbar.dart
        └── version_pill.dart
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

# Generate Drift database code and Riverpod models (if modified)
dart run build_runner build --delete-conflicting-outputs
```

### Running the App

#### 1. On your connected Android Device or Emulator
```bash
# Verify connected devices
flutter devices

# Run on Android
flutter run
```

#### 2. Building Release APK (for Sideloading)
```bash
flutter build apk --release
```
The compiled APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

### Verification & Testing

```bash
# Run static analysis (0 warnings / 0 errors)
flutter analyze

# Run the automated test suite (148+ tests)
flutter test
```

---

## 🔒 Privacy & Philosophy

Hermanos Ledgr is developed as personal-use software. It guarantees:
* ❌ **No Cloud Sync or Remote Storage**: Your data never leaves your device.
* ❌ **No Telemetry, Analytics, or Tracking**: Zero tracking SDKs or background beacons.
* ❌ **No Account Sign-Ups or Logins**: No emails, passwords, phone numbers, or third-party auth.
* ❌ **No Ads or Subscription Paywalls**: Completely free and fully featured forever.

Your financial records belong exclusively to you.
