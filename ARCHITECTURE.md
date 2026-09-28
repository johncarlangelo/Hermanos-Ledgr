# Architecture Document
## Hermanos Ledgr

> **Version:** 1.0 · **Last Updated:** 2026-09-28
> **Status:** Planning

---

## 1. High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                    │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐   │
│  │  Screens  │ │  Widgets │ │  Dialogs │ │  Sheets  │   │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘   │
│       └─────────────┴────────────┴────────────┘         │
│                         │                                │
│              ┌──────────▼──────────┐                     │
│              │  Riverpod Providers │                     │
│              └──────────┬──────────┘                     │
├─────────────────────────┼───────────────────────────────┤
│                   APPLICATION LAYER                      │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐   │
│  │  UseCases │ │ Services │ │ Notifiers│ │Formatters│   │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘   │
│       └─────────────┴────────────┴────────────┘         │
│                         │                                │
├─────────────────────────┼───────────────────────────────┤
│                    DOMAIN LAYER                          │
│  ┌──────────┐ ┌──────────────┐ ┌──────────────────┐     │
│  │  Entities │ │  Repositories│ │ Value Objects    │     │
│  │  (Models) │ │  (Abstract)  │ │ (Money, DateRange)│    │
│  └──────────┘ └──────────────┘ └──────────────────┘     │
│                         │                                │
├─────────────────────────┼───────────────────────────────┤
│                 INFRASTRUCTURE LAYER                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐   │
│  │  Drift DB│ │  LLM     │ │  OCR     │ │  File    │   │
│  │  (SQLite)│ │  Engine  │ │  Service │ │  System  │   │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

## 2. Architecture Pattern

**Feature-First Modular Architecture** with **Clean Architecture** layering within each feature.

### Why Feature-First?
- Each feature is a self-contained module with its own screens, providers, models, and repository implementations
- Easy to add/remove features without touching unrelated code
- Clear ownership: "Where does budget logic live?" → `lib/features/budget/`

### Layer Rules

| Layer | Can Depend On | Cannot Depend On |
|---|---|---|
| **Presentation** | Application, Domain | Infrastructure |
| **Application** | Domain | Infrastructure, Presentation |
| **Domain** | Nothing | Anything |
| **Infrastructure** | Domain | Presentation, Application |

---

## 3. Directory Structure

```
lib/
├── app/
│   ├── app.dart                    # MaterialApp root
│   ├── router.dart                 # GoRouter configuration
│   └── theme/
│       ├── app_theme.dart          # ThemeData (light + dark)
│       ├── color_tokens.dart       # Semantic color definitions
│       └── text_theme.dart         # Typography config
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart      # App-wide constants
│   │   └── category_defaults.dart  # Default categories & icons
│   ├── database/
│   │   ├── app_database.dart       # Drift database definition
│   │   ├── app_database.g.dart     # Generated
│   │   └── tables/                 # Table definitions
│   │       ├── accounts_table.dart
│   │       ├── transactions_table.dart
│   │       ├── budgets_table.dart
│   │       ├── goals_table.dart
│   │       ├── debts_table.dart
│   │       ├── categories_table.dart
│   │       ├── recurring_table.dart
│   │       ├── notes_table.dart
│   │       └── profiles_table.dart
│   ├── extensions/
│   │   ├── date_extensions.dart
│   │   ├── number_extensions.dart
│   │   └── string_extensions.dart
│   ├── models/
│   │   ├── money.dart              # Value object for currency
│   │   ├── date_range.dart         # Value object for date ranges
│   │   └── result.dart             # Result<T> type for error handling
│   ├── providers/
│   │   ├── database_provider.dart
│   │   ├── theme_provider.dart
│   │   └── profile_provider.dart
│   └── utils/
│       ├── currency_formatter.dart
│       ├── date_formatter.dart
│       └── validators.dart
│
├── features/
│   ├── dashboard/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── dashboard_screen.dart
│   │   │   └── widgets/
│   │   │       ├── net_worth_card.dart
│   │   │       ├── account_summary_card.dart
│   │   │       ├── recent_transactions.dart
│   │   │       └── quick_actions_row.dart
│   │   └── providers/
│   │       └── dashboard_provider.dart
│   │
│   ├── transactions/
│   │   ├── data/
│   │   │   └── transaction_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── transaction_entity.dart
│   │   │   └── transaction_repository.dart
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── transaction_list_screen.dart
│   │   │   │   └── transaction_detail_screen.dart
│   │   │   └── widgets/
│   │   │       ├── transaction_card.dart
│   │   │       ├── transaction_form.dart
│   │   │       ├── add_transaction_sheet.dart
│   │   │       ├── filter_chips_bar.dart
│   │   │       └── amount_keypad.dart
│   │   └── providers/
│   │       ├── transaction_list_provider.dart
│   │       └── transaction_form_provider.dart
│   │
│   ├── accounts/
│   │   ├── data/
│   │   │   └── account_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── account_entity.dart
│   │   │   └── account_repository.dart
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── accounts_screen.dart
│   │   │   │   └── account_detail_screen.dart
│   │   │   └── widgets/
│   │   │       ├── account_card.dart
│   │   │       └── account_form.dart
│   │   └── providers/
│   │       └── account_provider.dart
│   │
│   ├── budget/
│   │   ├── data/
│   │   │   └── budget_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── budget_entity.dart
│   │   │   └── budget_repository.dart
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── budget_overview_screen.dart
│   │   │   │   └── budget_detail_screen.dart
│   │   │   └── widgets/
│   │   │       ├── budget_progress_card.dart
│   │   │       ├── budget_form.dart
│   │   │       └── spending_chart.dart
│   │   └── providers/
│   │       └── budget_provider.dart
│   │
│   ├── goals/
│   │   ├── data/
│   │   │   └── goal_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── goal_entity.dart
│   │   │   └── goal_repository.dart
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── goals_screen.dart
│   │   │   └── widgets/
│   │   │       ├── goal_card.dart
│   │   │       ├── goal_progress_ring.dart
│   │   │       └── goal_form.dart
│   │   └── providers/
│   │       └── goal_provider.dart
│   │
│   ├── debts/
│   │   ├── data/
│   │   │   └── debt_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── debt_entity.dart
│   │   │   ├── receivable_entity.dart
│   │   │   └── debt_repository.dart
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── debts_screen.dart
│   │   │   │   └── receivables_screen.dart
│   │   │   └── widgets/
│   │   │       ├── debt_card.dart
│   │   │       ├── receivable_card.dart
│   │   │       └── debt_form.dart
│   │   └── providers/
│   │       └── debt_provider.dart
│   │
│   ├── forecast/
│   │   ├── data/
│   │   │   └── forecast_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── forecast_entity.dart
│   │   │   └── forecast_repository.dart
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── forecast_screen.dart
│   │   │   └── widgets/
│   │   │       ├── forecast_timeline.dart
│   │   │       └── upcoming_payments.dart
│   │   └── providers/
│   │       └── forecast_provider.dart
│   │
│   ├── recurring/
│   │   ├── data/
│   │   │   └── recurring_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── recurring_entity.dart
│   │   │   └── recurring_repository.dart
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── recurring_screen.dart
│   │   │   └── widgets/
│   │   │       ├── recurring_card.dart
│   │   │       └── recurring_form.dart
│   │   └── providers/
│   │       └── recurring_provider.dart
│   │
│   ├── ai_assistant/
│   │   ├── data/
│   │   │   ├── classifier_service.dart   # Tier 1 fast decision model & entity extractor (<30MB)
│   │   │   ├── llm_service.dart          # Tier 2 flutter_llama wrapper (sub-1B GGUF)
│   │   │   ├── model_manager.dart        # Download, load, manage GGUF models
│   │   │   └── nlp_parser.dart           # Parse hybrid output → ParsedTransaction
│   │   ├── domain/
│   │   │   ├── chat_message.dart
│   │   │   ├── parsed_transaction.dart
│   │   │   └── ai_repository.dart
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── chat_screen.dart
│   │   │   └── widgets/
│   │   │       ├── chat_bubble.dart
│   │   │       ├── transaction_action_card.dart
│   │   │       ├── voice_input_button.dart
│   │   │       └── model_download_dialog.dart
│   │   └── providers/
│   │       ├── chat_provider.dart
│   │       ├── classifier_provider.dart
│   │       └── llm_provider.dart
│   │
│   ├── receipt_scanner/
│   │   ├── data/
│   │   │   └── ocr_service.dart          # ML Kit wrapper
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── scanner_screen.dart
│   │   │   └── widgets/
│   │   │       ├── camera_preview.dart
│   │   │       └── scan_result_card.dart
│   │   └── providers/
│   │       └── scanner_provider.dart
│   │
│   ├── backup/
│   │   ├── data/
│   │   │   ├── backup_service.dart       # JSON export/import
│   │   │   └── csv_export_service.dart   # CSV export
│   │   ├── presentation/
│   │   │   └── screens/
│   │   │       └── backup_screen.dart
│   │   └── providers/
│   │       └── backup_provider.dart
│   │
│   └── settings/
│       ├── presentation/
│       │   ├── screens/
│       │   │   ├── settings_screen.dart
│       │   │   └── profile_manager_screen.dart
│       │   └── widgets/
│       │       └── settings_tile.dart
│       └── providers/
│           └── settings_provider.dart
│
├── shared/
│   └── widgets/
│       ├── category_icon.dart
│       ├── account_icon.dart
│       ├── amount_display.dart
│       ├── empty_state.dart
│       ├── loading_indicator.dart
│       └── confirm_dialog.dart
│
└── main.dart
```

---

## 4. State Management — Riverpod

### 4.1 Provider Types

| Type | Usage |
|---|---|
| `Provider` | Simple computed values (formatters, constants) |
| `StateProvider` | Simple UI state (selected filter, active tab) |
| `FutureProvider` | One-shot async data (initial load) |
| `StreamProvider` | Reactive data from Drift (transaction list, account balances) |
| `NotifierProvider` | Complex state with business logic (form state, chat history) |
| `AsyncNotifierProvider` | Complex async state (LLM inference, backup operations) |

### 4.2 Provider Scoping

- **Global providers:** Database instance, theme, active profile
- **Feature providers:** Scoped to each feature module
- **Family providers:** Parameterized (e.g., `accountProvider(accountId)`)

---

## 5. Database Schema (Drift/SQLite)

### 5.1 Core Tables

```sql
-- Profiles
CREATE TABLE profiles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Accounts
CREATE TABLE accounts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  profile_id INTEGER NOT NULL REFERENCES profiles(id),
  name TEXT NOT NULL,
  type TEXT NOT NULL,           -- cash, bank, ewallet, credit_card
  icon TEXT,
  color TEXT,
  initial_balance REAL NOT NULL DEFAULT 0,
  is_archived INTEGER NOT NULL DEFAULT 0,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Categories
CREATE TABLE categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  profile_id INTEGER NOT NULL REFERENCES profiles(id),
  name TEXT NOT NULL,
  icon TEXT NOT NULL,
  color TEXT NOT NULL,
  parent_id INTEGER REFERENCES categories(id),  -- NULL = top-level
  type TEXT NOT NULL,           -- expense, income, both
  is_system INTEGER NOT NULL DEFAULT 0,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
);

-- Transactions
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  profile_id INTEGER NOT NULL REFERENCES profiles(id),
  type TEXT NOT NULL,            -- expense, income, transfer
  amount REAL NOT NULL,
  category_id INTEGER REFERENCES categories(id),
  account_id INTEGER NOT NULL REFERENCES accounts(id),
  to_account_id INTEGER REFERENCES accounts(id),  -- for transfers
  note TEXT,
  date INTEGER NOT NULL,
  image_path TEXT,
  recurring_id INTEGER REFERENCES recurring_rules(id),
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Budgets
CREATE TABLE budgets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  profile_id INTEGER NOT NULL REFERENCES profiles(id),
  category_id INTEGER NOT NULL REFERENCES categories(id),
  amount REAL NOT NULL,
  period TEXT NOT NULL DEFAULT 'monthly',  -- monthly, weekly
  start_date INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Savings Goals
CREATE TABLE goals (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  profile_id INTEGER NOT NULL REFERENCES profiles(id),
  name TEXT NOT NULL,
  target_amount REAL NOT NULL,
  current_amount REAL NOT NULL DEFAULT 0,
  target_date INTEGER,
  icon TEXT,
  color TEXT,
  is_completed INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Debts & Receivables
CREATE TABLE debts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  profile_id INTEGER NOT NULL REFERENCES profiles(id),
  type TEXT NOT NULL,              -- debt, receivable
  person_name TEXT NOT NULL,
  original_amount REAL NOT NULL,
  remaining_amount REAL NOT NULL,
  note TEXT,
  due_date INTEGER,
  is_settled INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Debt Payments
CREATE TABLE debt_payments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  debt_id INTEGER NOT NULL REFERENCES debts(id),
  amount REAL NOT NULL,
  date INTEGER NOT NULL,
  note TEXT,
  created_at INTEGER NOT NULL
);

-- Recurring Rules
CREATE TABLE recurring_rules (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  profile_id INTEGER NOT NULL REFERENCES profiles(id),
  type TEXT NOT NULL,              -- expense, income
  amount REAL NOT NULL,
  category_id INTEGER REFERENCES categories(id),
  account_id INTEGER NOT NULL REFERENCES accounts(id),
  note TEXT NOT NULL,
  frequency TEXT NOT NULL,         -- daily, weekly, biweekly, monthly, yearly
  start_date INTEGER NOT NULL,
  end_date INTEGER,
  next_due_date INTEGER NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Quick Notes
CREATE TABLE notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  profile_id INTEGER NOT NULL REFERENCES profiles(id),
  content TEXT NOT NULL,
  is_done INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Chat History (AI)
CREATE TABLE chat_messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  profile_id INTEGER NOT NULL REFERENCES profiles(id),
  role TEXT NOT NULL,               -- user, assistant
  content TEXT NOT NULL,
  transaction_id INTEGER REFERENCES transactions(id),
  created_at INTEGER NOT NULL
);
```

### 5.2 Indexes

```sql
CREATE INDEX idx_transactions_date ON transactions(date);
CREATE INDEX idx_transactions_category ON transactions(category_id);
CREATE INDEX idx_transactions_account ON transactions(account_id);
CREATE INDEX idx_transactions_profile ON transactions(profile_id);
CREATE INDEX idx_recurring_next_due ON recurring_rules(next_due_date);
CREATE INDEX idx_debts_profile ON debts(profile_id);
CREATE INDEX idx_budgets_period ON budgets(profile_id, category_id, period);
```

---

## 6. Cascaded Hybrid AI Architecture (Tier 1 Classifier + Tier 2 Light LLM)

To ensure zero UI latency (< 50ms), minimal battery consumption, and a lightweight download footprint on the Samsung Galaxy A36 (Snapdragon 6 Gen 3, 6–8 GB RAM), Hermanos Ledgr uses a **two-tier cascaded architecture**:

```
┌─────────────────────────────────────────────────────────────┐
│                       Chat / Voice Input                    │
│           User types: "Jollibee 250 GCash"                  │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                 Chat Provider (Riverpod)                    │
│   Evaluates input complexity & passes to Tier 1 Classifier   │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│         Tier 1: Fast Classifier & Entity Extractor          │
│   - Lightweight non-autoregressive decision model (< 30 MB) │
│   - Execution time: < 20 ms, RAM: < 30 MB                   │
│   - Extracts amount, date, matches account & category       │
│   - Calibrated Confidence Score >= Threshold (e.g. 0.85)?   │
└──────────────────────────────┬──────────────────────────────┘
                               │
            ┌──────────────────┴──────────────────┐
     [High Confidence]                     [Low Confidence /
      (Single expense,                      Complex split,
     obvious entities)                      conversational,
            │                               daily summary]
            │                                     │
            ▼                                     ▼
 ┌──────────────────────┐              ┌──────────────────────┐
 │  Instant Direct Map  │              │  Tier 2: Light LLM   │
 │  Produces            │              │  (Qwen 2.5 0.5B /    │
 │  ParsedTransaction   │              │   SmolLM 2 360M)     │
 │  in < 50ms           │              │  - Runs via          │
 └──────────┬───────────┘              │    flutter_llama     │
            │                          │  - Background Isolate│
            │                          │  - Generates JSON    │
            │                          └──────────┬───────────┘
            │                                     │
            └──────────────────┬──────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                    NLP Parser / Normalizer                  │
│       Standardizes output into structured ParsedTransaction │
│          {type, amount, category, account, date, note}       │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                Transaction Action Card (UI)                 │
│         Show parsed transaction for user confirmation       │
│             [✓ Confirm]   [✏️ Edit]   [✕ Discard]            │
└─────────────────────────────────────────────────────────────┘
```

### 6.1 Two-Tier Model Sizing & Lifecycle

| Tier | Component | Engine / Format | Download Size | RAM Usage | Latency | Primary Role |
|---|---|---|---|---|---|---|
| **Tier 1** | Fast Decision Model / Classifier | On-device model / compiled rules | < 30 MB (bundled or instant) | < 30 MB | < 20 ms | 90% of daily transactions ("Starbucks 250", "Salary 35k") |
| **Tier 2** | Sub-1B Light LLM (`Qwen 2.5 0.5B Instruct` / `SmolLM 2 360M`) | `flutter_llama` (llama.cpp FFI) / Q4_K_M GGUF | ~350 MB (~220 MB for SmolLM) | ~380 MB | < 1.5 s | Complex multi-item splits, conversational prompts, spending summaries |

- **Tier 1 (System 1):** Always active, instant response, runs on CPU without activating heavy GPU or high-memory isolates. Resolves ~90% of typical ledger entries.
- **Tier 2 (System 2):** Downloaded on first use or first complex query; loaded into a background isolate only when needed; automatically unloaded or suspended when navigating away from AI features.
- Models stored in app's internal storage (`getApplicationDocumentsDirectory()`).
- Support switching between models or purging model storage in Settings.

### 6.2 Tier 2 System Prompt Template

```
You are a personal finance assistant. Parse the user's message into a structured transaction.

Available categories: {categories_list}
Available accounts: {accounts_list}
Today's date: {today}

Respond ONLY with valid JSON:
{
  "type": "expense" | "income" | "transfer",
  "amount": number,
  "category": "category_name",
  "account": "account_name",
  "to_account": "account_name" (only for transfers),
  "date": "YYYY-MM-DD",
  "note": "description"
}

If you cannot parse the input, respond with:
{"error": "description of what's unclear"}
```

---

## 7. Backup & Migration Architecture

### 7.1 JSON Backup Format

```json
{
  "version": 1,
  "app": "hermanos_ledgr",
  "exported_at": "2026-09-28T15:00:00+08:00",
  "profile": {
    "name": "Personal",
    "accounts": [...],
    "categories": [...],
    "transactions": [...],
    "budgets": [...],
    "goals": [...],
    "debts": [...],
    "recurring_rules": [...],
    "notes": [...]
  }
}
```

### 7.2 Auto-Backup Strategy

- Trigger: Every 24 hours when app is opened
- Location: `Android/data/com.hermanos.ledgr/backups/`
- Retention: Keep last 7 daily backups, auto-delete older
- File naming: `backup_2026-09-28.json`

### 7.3 Migration Flow (New Phone)

1. Old phone → Settings → Export → Share JSON file (via Android Share sheet)
2. New phone → Install APK → Settings → Import → Pick JSON file
3. App validates JSON schema version, imports all data
4. If LLM model was downloaded, user re-downloads on new phone

---

## 8. Performance Considerations

| Concern | Strategy |
|---|---|
| **App startup** | Lazy-load features; only Dashboard loads eagerly |
| **Tier 1 Classifier** | Instantaneous (< 20 ms), tiny memory (< 30 MB), zero battery drain for 90% of entries |
| **LLM loading** | Load sub-1B model (~350 MB GGUF) only when invoked or in chat tab; unload or sleep when idle |
| **LLM inference** | Always run in background Isolate; never block UI thread; Qualcomm Adreno GPU acceleration |
| **Database queries** | Use Drift's streaming queries for reactive UI; add indexes on hot columns |
| **Image storage** | Compress receipt images to 80% JPEG before storing |
| **List rendering** | Use `ListView.builder` for all transaction lists (lazy loading) |
| **Chart rendering** | Cache chart data; recompute only on data change |
| **Memory** | Monitor RAM usage (< 150 MB baseline, peak < 500 MB when Tier 2 LLM isolate active) |

---

## 9. Error Handling Strategy

- Use a `Result<T>` type for all repository methods
- Never throw unhandled exceptions in the UI layer
- Show user-friendly snackbars for errors
- Log errors to a local debug log (viewable in Settings for debugging)
- LLM errors: Show "I couldn't understand that. Try again?" with retry option

---

## 10. Testing Strategy

| Layer | Approach |
|---|---|
| **Domain** | Unit tests for entities, value objects, and business logic |
| **Data** | Unit tests for repository implementations with in-memory Drift DB |
| **Providers** | Unit tests with Riverpod container overrides |
| **Widgets** | Widget tests for critical components (transaction card, budget progress) |
| **Integration** | Manual testing on Samsung A36 device |
| **LLM** | Manual testing with various natural language inputs |
