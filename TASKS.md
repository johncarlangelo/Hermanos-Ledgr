# Task Breakdown
## Hermanos Ledgr

> **Last Updated:** 2026-09-28
> **Status:** Planning

---

## Task Structure

Tasks are grouped into **phases**. Each phase builds on the previous one. Within each phase, tasks are ordered by dependency (do them in order).

**Estimation Key:**
- 🟢 Small (< 1 hour)
- 🟡 Medium (1–3 hours)
- 🔴 Large (3+ hours)

---

## Phase 0: Project Scaffolding & Front-End Setup
> **Goal:** Flutter app with Material 3 Calm Finance theme, Onboarding flow, GoRouter bottom nav shell, and all 5 tabs

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| 0.1 | Delete old project files, clean workspace | 🟢 | — | ✅ DONE |
| 0.2 | Create new Flutter project (`flutter create --org com.hermanos --project-name hermanos_ledgr --platforms android ./`) | 🟢 | 0.1 | ✅ DONE |
| 0.3 | Configure `pubspec.yaml` with required UI & state dependencies | 🟡 | 0.2 | ✅ DONE |
| 0.4 | Set up directory structure (`lib/app/`, `lib/core/`, `lib/features/`, `lib/shared/`) | 🟢 | 0.2 | ✅ DONE |
| 0.5 | Configure Material 3 theme (light + dark + AMOLED) with Inter font & tabular figures | 🟡 | 0.3 | ✅ DONE |
| 0.6 | Set up GoRouter with bottom navigation shell & onboarding redirect | 🟡 | 0.4 | ✅ DONE |
| 0.7 | Build first-time Onboarding flow (welcome, live theme selector, starter accounts) | 🟡 | 0.6 | ✅ DONE |
| 0.8 | Build interactive front-end screens for all 5 tabs (Home, Transactions, Log sheet, Budget, AI) | 🔴 | 0.7 | ✅ DONE |
| 0.9 | Configure Android-specific settings (app name 'Hermanos Ledgr', package name) | 🟢 | 0.8 | ✅ DONE |

---

## Phase 1: Database Foundation
> **Goal:** Drift database with all tables, DAOs, and seed data

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| 1.1 | Define all Drift table classes in `lib/core/database/tables/` | 🔴 | 0.3 | ⬜ TODO |
| 1.2 | Define `AppDatabase` class with all tables and DAOs | 🟡 | 1.1 | ⬜ TODO |
| 1.3 | Run Drift code generation | 🟢 | 1.2 | ⬜ TODO |
| 1.4 | Create database provider (Riverpod) | 🟢 | 1.3 | ⬜ TODO |
| 1.5 | Seed default profile on first launch | 🟢 | 1.4 | ⬜ TODO |
| 1.6 | Seed default categories (Philippine-relevant) with icons and colors | 🟡 | 1.5 | ⬜ TODO |
| 1.7 | Create `Result<T>` sealed class for error handling | 🟢 | 0.4 | ⬜ TODO |
| 1.8 | Create core value objects (`Money`, `DateRange`) | 🟢 | 0.4 | ⬜ TODO |
| 1.9 | Create currency formatter and date formatter utilities | 🟢 | 1.8 | ⬜ TODO |
| 1.10 | Write unit tests for database CRUD operations | 🟡 | 1.6 | ⬜ TODO |

---

## Phase 2: Account Management
> **Goal:** Create, edit, view accounts with correct balances

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| 2.1 | Create `AccountEntity` and `AccountRepository` (abstract) | 🟢 | 1.1 | ⬜ TODO |
| 2.2 | Implement `AccountRepositoryImpl` with Drift DAO | 🟡 | 2.1, 1.4 | ⬜ TODO |
| 2.3 | Create `accountProvider` (Riverpod) | 🟢 | 2.2 | ⬜ TODO |
| 2.4 | Build account list screen | 🟡 | 2.3 | ⬜ TODO |
| 2.5 | Build account creation/edit form | 🟡 | 2.4 | ⬜ TODO |
| 2.6 | Add bank/e-wallet templates (BDO, BPI, GCash, Maya, etc.) | 🟢 | 2.5 | ⬜ TODO |
| 2.7 | Build account detail screen (transaction history for one account) | 🟡 | 2.4, 3.4 | ⬜ TODO |

---

## Phase 3: Transaction Management
> **Goal:** Full CRUD for expenses, income, and transfers

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| 3.1 | Create `TransactionEntity` and `TransactionRepository` (abstract) | 🟡 | 1.1 | ⬜ TODO |
| 3.2 | Implement `TransactionRepositoryImpl` with Drift DAO | 🔴 | 3.1, 1.4 | ⬜ TODO |
| 3.3 | Create transaction providers (list, form state) | 🟡 | 3.2 | ⬜ TODO |
| 3.4 | Build transaction list screen with date grouping | 🔴 | 3.3 | ⬜ TODO |
| 3.5 | Build `TransactionCard` widget | 🟡 | 3.4 | ⬜ TODO |
| 3.6 | Build add transaction bottom sheet | 🔴 | 3.3, 2.3 | ⬜ TODO |
| 3.7 | Build amount keypad widget | 🟡 | 3.6 | ⬜ TODO |
| 3.8 | Build category picker (grid with icons) | 🟡 | 1.6 | ⬜ TODO |
| 3.9 | Build account selector | 🟢 | 2.3 | ⬜ TODO |
| 3.10 | Implement expense creation (save + update account balance) | 🟡 | 3.6 | ⬜ TODO |
| 3.11 | Implement income creation | 🟢 | 3.10 | ⬜ TODO |
| 3.12 | Implement account transfer | 🟡 | 3.10 | ⬜ TODO |
| 3.13 | Build filter chips bar (date, category, account) | 🟡 | 3.4 | ⬜ TODO |
| 3.14 | Implement search transactions | 🟢 | 3.4 | ⬜ TODO |
| 3.15 | Implement edit transaction | 🟡 | 3.6 | ⬜ TODO |
| 3.16 | Implement delete transaction with balance rollback | 🟡 | 3.4 | ⬜ TODO |
| 3.17 | Add swipe actions (edit/delete) to transaction cards | 🟢 | 3.5 | ⬜ TODO |
| 3.18 | Add image attachment (camera + gallery) | 🟡 | 3.6 | ⬜ TODO |

---

## Phase 4: Dashboard
> **Goal:** Home screen with net worth, accounts, and recent transactions

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| 4.1 | Create `dashboardProvider` (computed from accounts + transactions) | 🟡 | 2.3, 3.3 | ⬜ TODO |
| 4.2 | Build net worth hero card | 🟡 | 4.1 | ⬜ TODO |
| 4.3 | Build account summary cards (scrollable row) | 🟡 | 4.1 | ⬜ TODO |
| 4.4 | Build recent transactions widget | 🟡 | 3.5 | ⬜ TODO |
| 4.5 | Build quick actions row (add expense, add income) | 🟢 | 3.6 | ⬜ TODO |
| 4.6 | Assemble dashboard screen | 🟡 | 4.2-4.5 | ⬜ TODO |
| 4.7 | Add count-up animation for numbers | 🟢 | 4.2 | ⬜ TODO |

---

## Phase 5: Budget System
> **Goal:** Per-category monthly budgets with progress tracking

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| 5.1 | Create `BudgetEntity` and `BudgetRepository` | 🟢 | 1.1 | ⬜ TODO |
| 5.2 | Implement `BudgetRepositoryImpl` | 🟡 | 5.1, 3.2 | ⬜ TODO |
| 5.3 | Create budget providers | 🟡 | 5.2 | ⬜ TODO |
| 5.4 | Build budget overview screen | 🔴 | 5.3 | ⬜ TODO |
| 5.5 | Build budget progress card widget | 🟡 | 5.4 | ⬜ TODO |
| 5.6 | Build budget creation/edit form | 🟡 | 5.3 | ⬜ TODO |
| 5.7 | Build monthly spending chart | 🟡 | 5.3 | ⬜ TODO |
| 5.8 | Implement overspend warnings (75%, 90%, 100%) | 🟢 | 5.5 | ⬜ TODO |

---

## Phase 6: Savings Goals
> **Goal:** Goal tracking with progress visualization

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| 6.1 | Create `GoalEntity` and `GoalRepository` | 🟢 | 1.1 | ⬜ TODO |
| 6.2 | Implement `GoalRepositoryImpl` | 🟡 | 6.1 | ⬜ TODO |
| 6.3 | Create goal providers | 🟢 | 6.2 | ⬜ TODO |
| 6.4 | Build goals screen with goal cards | 🟡 | 6.3 | ⬜ TODO |
| 6.5 | Build goal progress ring widget | 🟡 | 6.4 | ⬜ TODO |
| 6.6 | Build goal creation/edit form | 🟡 | 6.3 | ⬜ TODO |
| 6.7 | Implement contribution logging | 🟡 | 6.3 | ⬜ TODO |
| 6.8 | Calculate and display monthly contribution needed | 🟢 | 6.4 | ⬜ TODO |

---

## Phase 7: Debt & Receivables
> **Goal:** Track debts, loans, and money owed to you

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| 7.1 | Create `DebtEntity`, `ReceivableEntity`, `DebtRepository` | 🟡 | 1.1 | ⬜ TODO |
| 7.2 | Implement `DebtRepositoryImpl` | 🟡 | 7.1 | ⬜ TODO |
| 7.3 | Create debt providers | 🟢 | 7.2 | ⬜ TODO |
| 7.4 | Build debts screen with tabs (Debts / Receivables) | 🟡 | 7.3 | ⬜ TODO |
| 7.5 | Build debt card with payoff progress | 🟡 | 7.4 | ⬜ TODO |
| 7.6 | Build debt creation/edit form | 🟡 | 7.3 | ⬜ TODO |
| 7.7 | Implement payment logging against debts | 🟡 | 7.3 | ⬜ TODO |
| 7.8 | Build simple bill split calculator | 🟡 | — | ⬜ TODO |

---

## Phase 8: Recurring Transactions & Forecast
> **Goal:** Auto-logging recurring items and cashflow timeline

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| 8.1 | Create `RecurringEntity` and `RecurringRepository` | 🟢 | 1.1 | ⬜ TODO |
| 8.2 | Implement `RecurringRepositoryImpl` | 🟡 | 8.1, 3.2 | ⬜ TODO |
| 8.3 | Create recurring providers | 🟢 | 8.2 | ⬜ TODO |
| 8.4 | Build recurring rules management screen | 🟡 | 8.3 | ⬜ TODO |
| 8.5 | Build recurring rule creation/edit form | 🟡 | 8.3 | ⬜ TODO |
| 8.6 | Implement auto-log engine (check and create on app open) | 🔴 | 8.2, 3.2 | ⬜ TODO |
| 8.7 | Build cashflow forecast screen | 🔴 | 8.3, 3.3 | ⬜ TODO |
| 8.8 | Build forecast timeline widget | 🟡 | 8.7 | ⬜ TODO |
| 8.9 | Build upcoming payments list | 🟡 | 8.7 | ⬜ TODO |

---

## Phase 9: AI Assistant (Local LLM)
> **Goal:** Chat interface with on-device natural language transaction logging

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| 9.1 | Add `flutter_llama` dependency and configure Android build | 🟡 | 0.3 | ⬜ TODO |
| 9.2 | Build `ModelManager` — download, store, load GGUF models | 🔴 | 9.1 | ⬜ TODO |
| 9.3 | Build `LlmService` — inference wrapper with streaming | 🔴 | 9.2 | ⬜ TODO |
| 9.4 | Build `NlpParser` — parse LLM JSON output → `ParsedTransaction` | 🟡 | 9.3, 3.1 | ⬜ TODO |
| 9.5 | Create LLM and chat providers | 🟡 | 9.3, 9.4 | ⬜ TODO |
| 9.6 | Design and write system prompt template | 🟡 | 9.3 | ⬜ TODO |
| 9.7 | Build chat screen UI (message list, input bar) | 🔴 | 9.5 | ⬜ TODO |
| 9.8 | Build chat bubble widget | 🟡 | 9.7 | ⬜ TODO |
| 9.9 | Build transaction action card (confirm/edit/undo) | 🟡 | 9.7, 3.6 | ⬜ TODO |
| 9.10 | Implement confirm flow (action card → save transaction) | 🟡 | 9.9, 3.10 | ⬜ TODO |
| 9.11 | Add voice input button (speech-to-text → LLM) | 🟡 | 9.7 | ⬜ TODO |
| 9.12 | Build model download dialog with progress | 🟡 | 9.2 | ⬜ TODO |
| 9.13 | Implement daily summary generation | 🟡 | 9.3, 3.3 | ⬜ TODO |
| 9.14 | Implement insights/pattern analysis | 🟡 | 9.3, 3.3 | ⬜ TODO |
| 9.15 | Chat history persistence (load on screen open) | 🟢 | 9.7, 1.4 | ⬜ TODO |
| 9.16 | Test with various NL inputs on Samsung A57 | 🟡 | 9.10 | ⬜ TODO |

---

## Phase 10: Receipt Scanner
> **Goal:** OCR-based receipt scanning to pre-fill transactions

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| 10.1 | Add Google ML Kit text recognition dependency | 🟢 | 0.3 | ⬜ TODO |
| 10.2 | Build `OcrService` — image → extracted text → parsed data | 🟡 | 10.1 | ⬜ TODO |
| 10.3 | Build scanner screen (camera viewfinder) | 🟡 | 10.2 | ⬜ TODO |
| 10.4 | Build scan result card (extracted amount, merchant) | 🟡 | 10.3 | ⬜ TODO |
| 10.5 | Connect scan result → pre-filled add transaction sheet | 🟡 | 10.4, 3.6 | ⬜ TODO |
| 10.6 | Add gallery picker as alternative to camera | 🟢 | 10.3 | ⬜ TODO |

---

## Phase 11: Backup & Data Management
> **Goal:** Export, import, auto-backup

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| 11.1 | Build `BackupService` — serialize full database to JSON | 🔴 | 1.4 | ⬜ TODO |
| 11.2 | Build `CsvExportService` — transactions to CSV | 🟡 | 3.2 | ⬜ TODO |
| 11.3 | Implement auto-backup (daily, on app open) | 🟡 | 11.1 | ⬜ TODO |
| 11.4 | Implement manual JSON export (via Share sheet) | 🟡 | 11.1 | ⬜ TODO |
| 11.5 | Implement JSON import (validate + restore) | 🔴 | 11.1 | ⬜ TODO |
| 11.6 | Implement backup retention (keep last 7) | 🟢 | 11.3 | ⬜ TODO |
| 11.7 | Build backup/restore UI in Settings | 🟡 | 11.1-11.5 | ⬜ TODO |

---

## Phase 12: Settings & Profiles
> **Goal:** Theme controls, profile management, LLM settings

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| 12.1 | Build settings screen layout | 🟡 | 0.6 | ⬜ TODO |
| 12.2 | Theme toggle (light/dark/system) | 🟢 | 0.5 | ⬜ TODO |
| 12.3 | AMOLED black mode toggle | 🟢 | 0.5 | ⬜ TODO |
| 12.4 | Build profile manager screen | 🟡 | 1.5 | ⬜ TODO |
| 12.5 | Profile CRUD (create, switch, delete) | 🟡 | 12.4 | ⬜ TODO |
| 12.6 | LLM model management UI (download, delete, switch model) | 🟡 | 9.2 | ⬜ TODO |
| 12.7 | Quick notes screen | 🟡 | 1.4 | ⬜ TODO |
| 12.8 | About screen (version, build info) | 🟢 | — | ⬜ TODO |

---

## Phase 13: Polish & Optimization
> **Goal:** Final pass on animations, performance, and edge cases

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| 13.1 | Add screen transition animations (shared axis) | 🟡 | All screens | ⬜ TODO |
| 13.2 | Add micro-animations (card taps, list item add/remove) | 🟡 | All screens | ⬜ TODO |
| 13.3 | Add empty state illustrations for all lists | 🟡 | All screens | ⬜ TODO |
| 13.4 | Performance audit on Samsung A57 (profiling) | 🟡 | All features | ⬜ TODO |
| 13.5 | Fix any janky scrolling or frame drops | 🟡 | 13.4 | ⬜ TODO |
| 13.6 | Edge case testing (no accounts, no transactions, etc.) | 🟡 | All features | ⬜ TODO |
| 13.7 | Memory leak testing (especially LLM lifecycle) | 🟡 | 9.3 | ⬜ TODO |
| 13.8 | Final build: signed release APK | 🟢 | All | ⬜ TODO |

---

## Summary

| Phase | Tasks | Est. Total |
|---|---|---|
| 0. Project Scaffolding | 9 | ~5 hours |
| 1. Database Foundation | 10 | ~7 hours |
| 2. Account Management | 7 | ~6 hours |
| 3. Transaction Management | 18 | ~15 hours |
| 4. Dashboard | 7 | ~6 hours |
| 5. Budget System | 8 | ~8 hours |
| 6. Savings Goals | 8 | ~6 hours |
| 7. Debt & Receivables | 8 | ~7 hours |
| 8. Recurring & Forecast | 9 | ~10 hours |
| 9. AI Assistant | 16 | ~18 hours |
| 10. Receipt Scanner | 6 | ~5 hours |
| 11. Backup & Data | 7 | ~8 hours |
| 12. Settings & Profiles | 8 | ~6 hours |
| 13. Polish & Optimization | 8 | ~7 hours |
| **Total** | **129** | **~114 hours** |
