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
| 1.1 | Define all Drift table classes in `lib/core/database/tables/` | 🔴 | 0.3 | ✅ DONE |
| 1.2 | Define `AppDatabase` class with all tables and DAOs | 🟡 | 1.1 | ✅ DONE |
| 1.3 | Run Drift code generation | 🟢 | 1.2 | ✅ DONE |
| 1.4 | Create database provider (Riverpod) | 🟢 | 1.3 | ✅ DONE |
| 1.5 | Seed default profile on first launch | 🟢 | 1.4 | ✅ DONE |
| 1.6 | Seed default categories (Philippine-relevant) with icons and colors | 🟡 | 1.5 | ✅ DONE |
| 1.7 | Create `Result<T>` sealed class for error handling | 🟢 | 0.4 | ✅ DONE |
| 1.8 | Create core value objects (`Money`, `DateRange`) | 🟢 | 0.4 | ✅ DONE |
| 1.9 | Create currency formatter and date formatter utilities | 🟢 | 1.8 | ✅ DONE |
| 1.10 | Write unit tests for database CRUD operations | 🟡 | 1.6 | ✅ DONE |

---

## Phase 2: Account Management
> **Goal:** Create, edit, view accounts with correct balances

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| 2.1 | Create `AccountEntity` and `AccountRepository` (abstract) | 🟢 | 1.1 | ✅ DONE |
| 2.2 | Implement `AccountRepositoryImpl` with Drift DAO | 🟡 | 2.1, 1.4 | ✅ DONE |
| 2.3 | Create `accountProvider` (Riverpod) | 🟢 | 2.2 | ✅ DONE |
| 2.4 | Build account list screen | 🟡 | 2.3 | ✅ DONE |
| 2.5 | Build account creation/edit form | 🟡 | 2.4 | ✅ DONE |
| 2.6 | Add bank/e-wallet templates (BDO, BPI, GCash, Maya, etc.) | 🟢 | 2.5 | ✅ DONE |
| 2.7 | Build account detail screen (transaction history for one account) | 🟡 | 2.4, 3.4 | ✅ DONE |

---

## Phase 3: Transaction Management
> **Goal:** Full CRUD for expenses, income, and transfers

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| 3.1 | Create `TransactionEntity` and `TransactionRepository` (abstract) | 🟡 | 1.1 | ✅ DONE |
| 3.2 | Implement `TransactionRepositoryImpl` with Drift DAO | 🔴 | 3.1, 1.4 | ✅ DONE |
| 3.3 | Create transaction providers (list, form state) | 🟡 | 3.2 | ✅ DONE |
| 3.4 | Build transaction list screen with date grouping | 🔴 | 3.3 | ✅ DONE |
| 3.5 | Build `TransactionCard` widget | 🟡 | 3.4 | ✅ DONE |
| 3.6 | Build add transaction bottom sheet | 🔴 | 3.3, 2.3 | ✅ DONE |
| 3.7 | Build amount keypad widget | 🟡 | 3.6 | ✅ DONE |
| 3.8 | Build category picker (grid with icons) | 🟡 | 1.6 | ✅ DONE |
| 3.9 | Build account selector | 🟢 | 2.3 | ✅ DONE |
| 3.10 | Implement expense creation (save + update account balance) | 🟡 | 3.6 | ✅ DONE |
| 3.11 | Implement income creation | 🟢 | 3.10 | ✅ DONE |
| 3.12 | Implement account transfer | 🟡 | 3.10 | ✅ DONE |
| 3.13 | Build filter chips bar (date, category, account) | 🟡 | 3.4 | ✅ DONE |
| 3.14 | Implement search transactions | 🟢 | 3.4 | ✅ DONE |
| 3.15 | Implement edit transaction | 🟡 | 3.6 | ✅ DONE |
| 3.16 | Implement delete transaction with balance rollback | 🟡 | 3.4 | ✅ DONE |
| 3.17 | Add swipe actions (edit/delete) to transaction cards | 🟢 | 3.5 | ✅ DONE |
| 3.18 | Add image attachment (camera + gallery) | 🟡 | 3.6 | ✅ DONE |

---

## Phase 4: Dashboard
> **Goal:** Home screen with net worth, accounts, and recent transactions

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| 4.1 | Create `dashboardProvider` (computed from accounts + transactions) | 🟡 | 2.3, 3.3 | ✅ DONE |
| 4.2 | Build net worth hero card | 🟡 | 4.1 | ✅ DONE |
| 4.3 | Build account summary cards (scrollable row) | 🟡 | 4.1 | ✅ DONE |
| 4.4 | Build recent transactions widget | 🟡 | 3.5 | ✅ DONE |
| 4.5 | Build quick actions row (add expense, add income) | 🟢 | 3.6 | ✅ DONE |
| 4.6 | Assemble dashboard screen | 🟡 | 4.2-4.5 | ✅ DONE |
| 4.7 | Add count-up animation for numbers | 🟢 | 4.2 | ✅ DONE |

---

## Phase 5: Budget System
> **Goal:** Per-category monthly budgets with progress tracking

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| 5.1 | Create `BudgetEntity` and `BudgetRepository` | 🟢 | 1.1 | ⬜ TODO |
| 5.2 | Implement `BudgetRepositoryImpl` | 🟡 | 5.1, 3.2 | ⬜ TODO |
| 5.3 | Create budget providers | 🟡 | 5.2 | ⬜ TODO |
| 5.4 | Build budget overview screen | 🔴 | 5.3 | ✅ DONE |
| 5.5 | Build budget progress card widget | 🟡 | 5.4 | ✅ DONE |
| 5.6 | Build budget creation/edit form | 🟡 | 5.3 | ⬜ TODO |
| 5.7 | Build monthly spending chart | 🟡 | 5.3 | ✅ DONE |
| 5.8 | Implement overspend warnings (75%, 90%, 100%) | 🟢 | 5.5 | ✅ DONE |

---

## Phase 6: Savings Goals
> **Goal:** Goal tracking with progress visualization

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| 6.1 | Create `GoalEntity` and `GoalRepository` | 🟢 | 1.1 | ✅ DONE |
| 6.2 | Implement `GoalRepositoryImpl` | 🟡 | 6.1 | ✅ DONE |
| 6.3 | Create goal providers | 🟢 | 6.2 | ✅ DONE |
| 6.4 | Build goals screen with goal cards | 🟡 | 6.3 | ✅ DONE |
| 6.5 | Build goal progress ring widget | 🟡 | 6.4 | ✅ DONE |
| 6.6 | Build goal creation/edit form | 🟡 | 6.3 | ✅ DONE |
| 6.7 | Implement contribution logging | 🟡 | 6.3 | ✅ DONE |
| 6.8 | Calculate and display monthly contribution needed | 🟢 | 6.4 | ✅ DONE |

---

## Phase 7: Debt & Receivables
> **Goal:** Track debts, loans, and money owed to you

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| 7.1 | Create `DebtEntity`, `ReceivableEntity`, `DebtRepository` | 🟡 | 1.1 | ✅ DONE |
| 7.2 | Implement `DebtRepositoryImpl` | 🟡 | 7.1 | ✅ DONE |
| 7.3 | Create debt providers | 🟢 | 7.2 | ✅ DONE |
| 7.4 | Build debts screen with tabs (Debts / Receivables) | 🟡 | 7.3 | ✅ DONE |
| 7.5 | Build debt card with payoff progress | 🟡 | 7.4 | ✅ DONE |
| 7.6 | Build debt creation/edit form | 🟡 | 7.3 | ✅ DONE |
| 7.7 | Implement payment logging against debts | 🟡 | 7.3 | ✅ DONE |
| 7.8 | Build simple bill split calculator | 🟡 | — | ✅ DONE |

---

## Phase 8: Recurring Transactions & Forecast
> **Goal:** Auto-logging recurring items and cashflow timeline

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| 8.1 | Create `RecurringEntity` and `RecurringRepository` | 🟢 | 1.1 | ✅ DONE |
| 8.2 | Implement `RecurringRepositoryImpl` | 🟡 | 8.1, 3.2 | ✅ DONE |
| 8.3 | Create recurring providers | 🟢 | 8.2 | ✅ DONE |
| 8.4 | Build recurring rules management screen | 🟡 | 8.3 | ✅ DONE |
| 8.5 | Build recurring rule creation/edit form | 🟡 | 8.3 | ✅ DONE |
| 8.6 | Implement auto-log engine (check and create on app open) | 🔴 | 8.2, 3.2 | ✅ DONE |
| 8.7 | Build cashflow forecast screen | 🔴 | 8.3, 3.3 | ✅ DONE |
| 8.8 | Build forecast timeline widget | 🟡 | 8.7 | ✅ DONE |
| 8.9 | Build upcoming payments list | 🟡 | 8.7 | ✅ DONE |

---

## Phase 9: AI Assistant (Cascaded Hybrid AI: Classifier + Light LLM)
> **Goal:** Two-tier chat interface & natural language logging (Tier 1 Fast Classifier <30MB, <20ms + Tier 2 Sub-1B Light LLM `Qwen 2.5 0.5B` ~350MB)

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| 9.1 | Build `ClassifierService` — Tier 1 fast decision model & entity extractor (<30MB) | 🟡 | 3.1 | ✅ DONE |
| 9.2 | Build hybrid router logic — direct map high-confidence inputs vs delegate complex/summaries to Tier 2 | 🟡 | 9.1 | ✅ DONE |
| 9.3 | Add `flutter_llama` dependency and configure Android Vulkan/OpenCL build | 🟡 | 0.3 | ✅ DONE |
| 9.4 | Build `ModelManager` — download, store, and manage Sub-1B light GGUF model (`Qwen 2.5 0.5B` / `SmolLM 2 360M`) | 🔴 | 9.4 | ✅ DONE |
| 9.5 | Build `LlmService` — background isolate inference wrapper with token streaming for complex queries | 🔴 | 9.4 | ✅ DONE |
| 9.6 | Build `NlpParser` — unified parser standardizing Tier 1 & Tier 2 outputs → `ParsedTransaction` | 🟡 | 9.1, 9.5 | ✅ DONE |
| 9.7 | Create hybrid AI providers (`ClassifierProvider`, `LlmProvider`, `ChatProvider`) | 🟡 | 9.2, 9.6 | ✅ DONE |
| 9.8 | Design and benchmark optimized system prompt for sub-1B model | 🟡 | 9.5 | ✅ DONE |
| 9.9 | Build chat screen UI (offline badge, message list, prompt chips, input bar) | 🔴 | 9.7 | ✅ DONE |
| 9.10 | Build chat bubble widget (user messages + assistant responses) | 🟡 | 9.9 | ✅ DONE |
| 9.11 | Build transaction action card (amount, category, account preview with confirm/edit/discard) | 🟡 | 9.9, 3.6 | ✅ DONE |
| 9.12 | Implement confirm flow (action card → save transaction to Drift DB with 5s undo toast) | 🟡 | 9.11, 3.10 | ✅ DONE |
| 9.13 | Add voice input button (Android speech-to-text → hybrid pipeline) | 🟡 | 9.9 | ✅ DONE |
| 9.14 | Build model download dialog with progress indicator (for optional Tier 2 Sub-1B model) | 🟡 | 9.4 | ✅ DONE |
| 9.15 | Implement daily spending summary generation (via Tier 2 LLM) | 🟡 | 9.5, 3.3 | ✅ DONE |
| 9.16 | Chat history persistence in Drift database (`chat_messages` table) | 🟢 | 9.9, 1.4 | ✅ DONE |
| 9.17 | Benchmark & test on Samsung Galaxy A36 (Tier 1 <20ms, Tier 2 <1.5s, edge case splits) | 🟡 | 9.12 | ✅ DONE |

---

## Phase 10: Receipt Scanner
> **Goal:** OCR-based receipt scanning to pre-fill transactions

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| 10.1 | Add Google ML Kit text recognition dependency | 🟢 | 0.3 | ✅ DONE |
| 10.2 | Build `OcrService` — image → extracted text → parsed data | 🟡 | 10.1 | ✅ DONE |
| 10.3 | Build scanner screen (camera viewfinder) | 🟡 | 10.2 | ✅ DONE |
| 10.4 | Build scan result card (extracted amount, merchant) | 🟡 | 10.3 | ✅ DONE |
| 10.5 | Connect scan result → pre-filled add transaction sheet | 🟡 | 10.4, 3.6 | ✅ DONE |
| 10.6 | Add gallery picker as alternative to camera | 🟢 | 10.3 | ✅ DONE |

---

## Phase 11: Backup & Data Management
> **Goal:** Export, import, auto-backup

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| 11.1 | Build `BackupService` — serialize full database to JSON | 🔴 | 1.4 | ✅ DONE |
| 11.2 | Build `CsvExportService` — transactions to CSV | 🟡 | 3.2 | ✅ DONE |
| 11.3 | Implement auto-backup (daily, on app open) | 🟡 | 11.1 | ✅ DONE |
| 11.4 | Implement manual JSON export (via Share sheet) | 🟡 | 11.1 | ✅ DONE |
| 11.5 | Implement JSON import (validate + restore) | 🔴 | 11.1 | ✅ DONE |
| 11.6 | Implement backup retention (keep last 7) | 🟢 | 11.3 | ✅ DONE |
| 11.7 | Build backup/restore UI in Settings | 🟡 | 11.1-11.5 | ✅ DONE |

---

## Phase 12: Settings & Profiles
> **Goal:** Theme controls, profile management, LLM settings

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| 12.1 | Build settings screen layout | 🟡 | 0.6 | ✅ DONE |
| 12.2 | Theme toggle (light/dark/system) | 🟢 | 0.5 | ✅ DONE |
| 12.3 | AMOLED black mode toggle | 🟢 | 0.5 | ✅ DONE |
| 12.4 | Build profile manager screen | 🟡 | 1.5 | ✅ DONE |
| 12.5 | Profile CRUD (create, switch, delete) | 🟡 | 12.4 | ⬜ TODO |
| 12.6 | LLM model management UI (download, delete, switch model) | 🟡 | 9.2 | ⬜ TODO |
| 12.7 | Quick notes screen | 🟡 | 1.4 | ⬜ TODO |
| 12.8 | About screen (version, build info) | 🟢 | — | ✅ DONE |

---

## Phase 13: Polish & Optimization
> **Goal:** Final pass on animations, performance, and edge cases

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| 13.1 | Add screen transition animations (shared axis) | 🟡 | All screens | ⬜ TODO |
| 13.2 | Add micro-animations (card taps, list item add/remove) | 🟡 | All screens | ⬜ TODO |
| 13.3 | Add empty state illustrations for all lists | 🟡 | All screens | ✅ DONE |
| 13.4 | Performance audit on Samsung A36 (profiling) | 🟡 | All features | ⬜ TODO |
| 13.5 | Fix any janky scrolling or frame drops | 🟡 | 13.4 | ⬜ TODO |
| 13.6 | Edge case testing (no accounts, no transactions, etc.) | 🟡 | All features | ⬜ TODO |
| 13.7 | Memory leak testing (especially LLM lifecycle) | 🟡 | 9.3 | ⬜ TODO |
| 13.8 | Final build: signed release APK | 🟢 | All | ⬜ TODO |

---

## Standalone / Future Capabilities: In-App OTA Auto-Updater (Non-Play Store)
> **Goal:** Sideloaded APK over-the-air updater fetching GitHub Releases without Google Play Store

| # | Task | Size | Dependencies | Status |
|---|---|---|---|---|
| OTA.1 | Configure Android Manifest permissions (`REQUEST_INSTALL_PACKAGES`) & FileProvider | 🟢 | — | ⬜ TODO |
| OTA.2 | Create `UpdateReleaseModel` and `GitHubUpdateService` (fetch latest release metadata from GitHub API) | 🟡 | — | ⬜ TODO |
| OTA.3 | Implement SemVer version comparator (`remoteVersion > localVersion`) | 🟢 | OTA.2 | ⬜ TODO |
| OTA.4 | Create `updateProvider` (Riverpod notifier managing check status, download progress, release info) | 🟡 | OTA.2, OTA.3 | ⬜ TODO |
| OTA.5 | Build custom Stash-styled `UpdateAvailableSheet` (version badge, changelog markdown viewer, download progress) | 🟡 | OTA.4 | ⬜ TODO |
| OTA.6 | Implement APK downloader with stream progress tracking to local temporary cache | 🟡 | OTA.4 | ⬜ TODO |
| OTA.7 | Implement Android Package Installer trigger via intent (`application/vnd.android.package-archive`) | 🟡 | OTA.1, OTA.6 | ⬜ TODO |
| OTA.8 | Add "Check for Updates" tile with instant status indicator to Settings screen | 🟢 | OTA.4 | ⬜ TODO |
| OTA.9 | Implement optional startup background update check with 24-hour throttling | 🟢 | OTA.4 | ⬜ TODO |

---

## Summary

| Phase | Tasks | Completed | Est. Total | Status |
|---|---|---|---|---|
| 0. Project Scaffolding | 9 | 9 / 9 | ~5 hours | ✅ Complete (100%) |
| 1. Database Foundation | 10 | 10 / 10 | ~7 hours | ✅ Complete (100%) |
| 2. Account Management | 7 | 7 / 7 | ~6 hours | ✅ Complete (100%) |
| 3. Transaction Management | 18 | 18 / 18 | ~15 hours | ✅ Complete (100%) |
| 4. Dashboard | 7 | 7 / 7 | ~6 hours | ✅ Complete (100%) |
| 5. Budget System | 8 | 4 / 8 | ~8 hours | 🟡 In Progress (50%) |
| 6. Savings Goals | 8 | 8 / 8 | ~6 hours | ✅ Complete (100%) |
| 7. Debt & Receivables | 8 | 0 / 8 | ~7 hours | ⬜ Pending (0%) |
| 8. Recurring & Forecast | 9 | 0 / 9 | ~10 hours | ⬜ Pending (0%) |
| 9. AI Assistant | 17 | 3 / 17 | ~18 hours | 🟡 UI Mockup Built (18%) |
| 10. Receipt Scanner | 6 | 0 / 6 | ~5 hours | ⬜ Pending (0%) |
| 11. Backup & Data | 7 | 4 / 7 | ~8 hours | 🟡 In Progress (57%) |
| 12. Settings & Profiles | 8 | 5 / 8 | ~6 hours | 🟡 Mostly Built (63%) |
| 13. Polish & Optimization | 8 | 1 / 8 | ~7 hours | 🟡 Ongoing (13%) |
| **Total** | **130** | **76 / 130** | **~114 hours** | **58.5% Completed** |
| *Standalone: OTA Auto-Updater* | *9* | *0 / 9* | *~8 hours* | *⬜ Planned* |
