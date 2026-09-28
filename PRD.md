# Product Requirements Document (PRD)
## Hermanos Ledgr — Personal Budget Tracker

> **Version:** 1.0 · **Last Updated:** 2026-09-28
> **Author:** John C. · **Status:** Planning

---

## 1. Overview

**Hermanos Ledgr** is a personal-use Android budget tracking app inspired by [Tarsi Budget Tracker](https://www.tarsi.cloud/features). It recreates Tarsi's core financial tracking capabilities without the paywall, cloud dependency, or social features. The app runs entirely offline on a **Samsung Galaxy A36 5G** (Snapdragon 6 Gen 3, 6–8 GB RAM, Android 15/16).

### 1.1 Why Rebuild?

Tarsi locks its best features (AI chat logging, forecasting, advanced budgets) behind a monthly subscription. Since this app is for **personal use only** and will never be published on any app store, it can replicate that feature set freely, tailored exactly to the owner's workflow.

### 1.2 Key Principles

| Principle | Detail |
|---|---|
| **No Paywall** | Every feature is unlocked from day one |
| **Android Only** | Target: Samsung Galaxy A36 5G (Snapdragon 6 Gen 3) |
| **Offline First** | All data lives on-device; no account/login required |
| **Local AI** | Cascaded hybrid: Tier 1 Fast Classifier (<30MB) + Tier 2 Sub-1B Light LLM (Qwen 2.5 0.5B ~350MB via `flutter_llama`) |
| **Data Portability** | Export/import JSON/CSV for backup and phone migration |
| **Privacy** | Zero analytics, zero telemetry, zero cloud |

---

## 2. Target User

**Single user:** John C. — the developer and sole user. No multi-user, no shared access, no onboarding flow needed.

---

## 3. Features — In Scope

### 3.1 Core Financial Tracking

| Feature | Description |
|---|---|
| **Expense Logging** | Add expense with amount, category, subcategory, note, date, account, and optional image attachment |
| **Income Logging** | Same fields as expense, tagged as income |
| **Account Management** | Track multiple accounts: cash, bank accounts, e-wallets (GCash, Maya, etc.), credit cards |
| **Account Transfers** | Move money between accounts with automatic balance sync |
| **Net Worth Dashboard** | Single screen showing total assets, total liabilities, and net worth |
| **Transaction History** | Filterable/searchable list of all transactions with date range, category, and account filters |
| **Categories & Subcategories** | Pre-built Philippine-relevant categories with ability to add custom ones |

### 3.2 Budget & Planning

| Feature | Description |
|---|---|
| **Monthly Budgets** | Set per-category budgets with visual progress bars and overspend warnings |
| **Cashflow Forecast** | Timeline view of upcoming recurring payments vs. expected income |
| **Recurring Transactions** | Auto-log bills, subscriptions, installments on schedule (daily/weekly/biweekly/monthly/yearly) |
| **Savings Goals** | Set target amount, track progress, see monthly contribution needed |

### 3.3 Debt Management

| Feature | Description |
|---|---|
| **Debt Tracking** | Track loans, credit card debt — balance, payments, payoff progress |
| **Receivables** | Track money lent to others — who owes you, how much, when |
| **Bill Splitting** | Simple split calculator for shared expenses (personal records only, no multi-user sync) |

### 3.4 AI Assistant (Local LLM)

| Feature | Description |
|---|---|
| **Cascaded Hybrid Pipeline** | Tier 1: Fast Classifier/Extractor (<50ms) handles 90% of simple entries without waking LLM. Tier 2: Sub-1B Light LLM handles multi-item & complex inputs. |
| **Natural Language Logging** | Type or speak: "Starbucks 250", "Salary 30k last Friday", "Dinner 1500 split with 2 friends" → auto-parsed into structured transaction |
| **Voice Input** | Speech-to-text → Hybrid parsing → transaction creation |
| **Offline AI** | Models run entirely on-device (zero internet, zero API keys, 100% private) |
| **Smart Categorization** | Decision model auto-classifies category & account based on description |
| **Daily Summary** | Sub-1B LLM generates brief summaries of the day's spending on-demand |
| **Insights** | Pattern recognition — spending trends, unusual expenses, budget drift warnings |

### 3.5 Data & Privacy

| Feature | Description |
|---|---|
| **Local Storage** | SQLite (via `drift`) for all data |
| **Auto-Backup** | Daily automatic backup to device storage |
| **Manual Backup** | Export full database as JSON for manual safekeeping |
| **CSV Export** | Export transactions as CSV for spreadsheet analysis |
| **Import** | Import from JSON backup to restore or migrate to new phone |
| **Receipt Scanning** | Camera/gallery → OCR extracts amount and merchant → pre-fill transaction |

### 3.6 UX & Polish

| Feature | Description |
|---|---|
| **Light & Dark Mode** | Follows system theme or manual toggle |
| **Quick Notes** | Jot future expenses/reminders without creating a transaction |
| **Bank Templates** | Pre-built templates for Philippine banks and e-wallets (BDO, BPI, GCash, Maya, etc.) |
| **Multiple Profiles** | Separate profiles (personal, family, side business) each with own accounts/budgets |

---

## 4. Features — Out of Scope (v1)

| Feature | Reason |
|---|---|
| Stocks & Crypto tracking | Not needed for now |
| Streaks & Achievement badges | Not needed |
| Mascot customization | Not needed |
| Cloud sync / web app | Personal device only |
| User authentication / login | Single user, no need |
| App Store publishing | Personal use only |
| Multi-device sync | Import/export covers phone migration |
| Shared/collaborative accounts | Single user |

---

## 5. Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter (Dart) — Android only build |
| **State Management** | Riverpod 2.x |
| **Local Database** | Drift (SQLite wrapper) |
| **On-Device AI Engine** | Tier 1: Local Classifier/Pattern Extractor + Tier 2: `flutter_llama` (llama.cpp FFI) |
| **Language Model** | Qwen 2.5 0.5B Instruct Q4_K_M (~350 MB) or SmolLM 2 360M (~220 MB) — download on first use |
| **OCR** | Google ML Kit (on-device text recognition) |
| **Speech-to-Text** | Android native STT (via `speech_to_text` package) |
| **Charts** | `fl_chart` |
| **Notifications** | `flutter_local_notifications` |
| **File Handling** | `file_picker`, `share_plus`, `path_provider` |
| **Design System** | Material Design 3 with custom color scheme |
| **Architecture** | Feature-first modular architecture |

---

## 6. Target Device

| Spec | Value |
|---|---|
| **Phone** | Samsung Galaxy A36 5G |
| **Processor** | Snapdragon 6 Gen 3 (4nm, octa-core, Adreno GPU) |
| **RAM** | 6–8 GB |
| **Storage** | 128–256 GB (microSD expandable) |
| **OS** | Android 15 / 16, One UI |
| **Display** | 6.6" Super AMOLED, 120Hz |
| **Min Android SDK** | API 31 (Android 12) for future-proofing |

---

## 7. Success Criteria

Since this is personal-use software, success is measured by:

1. **Daily usability** — Logging an expense takes < 5 seconds
2. **AI accuracy** — Natural language parsing correctly identifies amount, category, and account ≥ 80% of the time
3. **Reliability** — No data loss; daily backups work silently
4. **Performance** — App launches in < 2 seconds; LLM responds in < 5 seconds
5. **Completeness** — All in-scope features functional and stable

---

## 8. Risks & Mitigations

| Risk | Mitigation |
|---|---|
| AI too slow or memory-heavy | Use Cascaded Hybrid architecture: Tier 1 Classifier resolves 90% in <50ms; Tier 2 Sub-1B model (Qwen 0.5B) uses only ~350MB RAM |
| Model too large to download | Sub-1B model is only ~350MB (vs 1.5GB 2B+ models); download on first use with clear progress |
| Database corruption | Daily auto-backup + manual export |
| OCR inaccuracy | Allow manual correction after scan; OCR is a convenience, not a requirement |
| Scope creep | Strict adherence to out-of-scope list; features added only after v1 is stable |
