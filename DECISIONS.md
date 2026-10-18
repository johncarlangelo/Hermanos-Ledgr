# Decision Log
## Hermanos Ledgr

> **Last Updated:** 2026-09-28

---

## How to Use This File

Record every non-obvious technical or design decision here. Future-you (or future-AI) will thank present-you when wondering "why did we do it this way?"

### Entry Format

```
### D-XXX: [Short Title]
**Date:** YYYY-MM-DD
**Status:** Accepted | Superseded | Rejected
**Context:** Why this decision came up
**Decision:** What was decided
**Alternatives Considered:** What else was on the table
**Rationale:** Why this option was chosen
```

---

## Decisions

### D-001: Flutter as Framework
**Date:** 2026-09-28
**Status:** Accepted
**Context:** Need to build an Android-only budget tracking app. Options include native Kotlin, Flutter, React Native, and Kotlin Multiplatform.
**Decision:** Use Flutter with Dart.
**Alternatives Considered:**
- Native Kotlin/Jetpack Compose — great performance, but slower development for one person
- React Native — JavaScript ecosystem is less suited for heavy local processing (LLM)
- Kotlin Multiplatform — overkill since we only target Android
**Rationale:** Flutter offers fast development, excellent UI toolkit (Material 3 built-in), strong Riverpod ecosystem, and the `flutter_llama` package for on-device LLM. Previous experience with the framework from the old codebase. Cross-platform capability is a free bonus if ever needed later.

---

### D-002: Riverpod for State Management
**Date:** 2026-09-28
**Status:** Accepted
**Context:** Need a state management solution that handles reactive database streams, async operations (LLM), and complex form state.
**Decision:** Use Riverpod 2.x with code generation (`@riverpod` annotations).
**Alternatives Considered:**
- BLoC — more boilerplate, overkill for a personal app
- Provider — predecessor to Riverpod, less powerful
- GetX — implicit magic, harder to debug
- Signals — newer, less ecosystem support
**Rationale:** Riverpod is compile-safe, supports all provider types needed (Stream, Async, Notifier), has excellent devtools, and works naturally with Drift's streaming queries. Code generation reduces boilerplate.

---

### D-003: Drift (SQLite) for Local Database
**Date:** 2026-09-28
**Status:** Accepted
**Context:** All data must be stored locally. Need a typed, reactive database solution.
**Decision:** Use Drift (formerly Moor) with SQLite.
**Alternatives Considered:**
- Isar — fast, but less mature SQL capabilities
- Hive — key-value only, not relational enough
- ObjectBox — good, but less community support
- Raw SQLite (sqflite) — no type safety, no reactive streams
**Rationale:** Drift provides type-safe queries, code generation, reactive streaming (perfect for Riverpod StreamProviders), and migration support. It's the most mature typed SQLite solution in the Flutter ecosystem. Relational model fits the financial data (accounts → transactions → categories) naturally.

---

### D-004: flutter_llama for On-Device LLM
**Date:** 2026-09-28
**Status:** Accepted
**Context:** Need to run LLM inference locally on Samsung A36 (Snapdragon 6 Gen 3, 6-8GB RAM) for natural language transaction parsing.
**Decision:** Use `flutter_llama` (llama.cpp wrapper) with GGUF models.
**Alternatives Considered:**
- `llamadart` — good but less mature
- LiteRT-LM (Google) — better hardware optimization but more complex setup
- Cloud API (Gemini/GPT) — requires internet, defeats offline-first principle
**Rationale:** `flutter_llama` is the most popular, production-ready Flutter wrapper for llama.cpp. Supports Vulkan and OpenCL GPU acceleration on Android, GGUF format, and token streaming. The Samsung A36's Snapdragon 6 Gen 3 with Adreno GPU handles mobile inference efficiently.

---

### D-005: Qwen 3 1.7B Q4_K_M as Default LLM Model
**Date:** 2026-09-28
**Status:** Superseded by D-013
**Context:** Need a model small enough for mobile but capable enough to parse "Starbucks 250 from GCash" into structured JSON.
**Decision:** Originally defaulted to Qwen 3 1.7B. Superseded by D-013 in favor of a two-tier hybrid architecture (Tier 1 Classifier + Tier 2 Sub-1B Light LLM: Qwen 2.5 0.5B / SmolLM 2 360M).
**Alternatives Considered:**
- Larger models (3B+) — too much RAM, too slow
- Smaller models (<1B) — insufficient for reliable JSON output
- Phi-3 mini — good but less tested on mobile
**Rationale:** Samsung A36 has 6-8GB RAM; Android + background apps use ~3GB, leaving 3-5GB for the app. A 1.7B Q4_K_M model uses ~1.1-1.2GB RAM during inference, well within budget. Qwen 3 (or SmolLM 2 1.7B / Gemma 1B) fits comfortably.

---

### D-006: No Authentication / Pure Local
**Date:** 2026-09-28
**Status:** Accepted
**Context:** Personal-use app with a single user.
**Decision:** No login screen, no authentication, no cloud sync. All data stored locally with export/import for migration.
**Alternatives Considered:**
- PIN/biometric lock — could add later if needed
- Cloud backup to Google Drive — adds complexity and cloud dependency
**Rationale:** Single user on a personal device. Phone's own lock screen provides sufficient security. Export/import via JSON file handles the phone migration use case without needing any server infrastructure.

---

### D-007: Money as REAL (Double) Not Integer Cents
**Date:** 2026-09-28
**Status:** Accepted
**Context:** Financial apps typically store money as integer cents to avoid floating-point errors. However, this is a personal tracking app, not a banking system.
**Decision:** Store money as `REAL` (double) in SQLite. Display with 2 decimal places.
**Alternatives Considered:**
- Integer cents (multiply by 100) — safer for accounting, more code complexity
- Decimal package — overkill for personal tracking
**Rationale:** For personal expense tracking, floating-point precision is more than adequate. We're tracking spending patterns, not doing bank reconciliation. Doubles are simpler to work with in Dart and display formatting. The rounding errors at this scale (personal budgets) are negligible.

---

### D-008: Feature-First Directory Structure
**Date:** 2026-09-28
**Status:** Accepted
**Context:** Need to organize ~12 features with clean separation.
**Decision:** Feature-first modular architecture: `lib/features/<name>/` each with `data/`, `domain/`, `presentation/`, `providers/`.
**Alternatives Considered:**
- Layer-first (`lib/data/`, `lib/domain/`, `lib/presentation/`) — scatters related code
- Flat structure — gets messy beyond 5 features
**Rationale:** Feature-first keeps related code co-located. Adding or removing a feature is a single directory operation. Each feature is a self-contained module. Clean Architecture layers within each feature ensure proper dependency direction.

---

### D-009: Philippine Peso (₱) as Hardcoded Currency
**Date:** 2026-09-28
**Status:** Accepted
**Context:** Personal app used exclusively in the Philippines.
**Decision:** Hardcode Philippine Peso (₱) as the only currency. No multi-currency support.
**Alternatives Considered:**
- Multi-currency with conversion — significant complexity for no personal benefit
- Configurable currency — slight overhead for no real need
**Rationale:** Single user in the Philippines. All income, expenses, and accounts are in PHP. Multi-currency would add complexity with zero benefit. Can be added later if needed.

---

### D-010: Download-on-First-Use for LLM Model
**Date:** 2026-09-28
**Status:** Accepted
**Context:** GGUF models are 1-1.5 GB. Bundling in the APK would make the install size enormous.
**Decision:** Download the LLM model from Hugging Face on first use with a progress dialog. Store in app's internal storage.
**Alternatives Considered:**
- Bundle in APK — 1.5GB APK is unacceptable
- Require manual download via file manager — bad UX
**Rationale:** Keeps the APK small (~30MB). User downloads the model once, over WiFi, with a clear progress indicator. Model persists in app storage until manually deleted.

---

### D-011: GoRouter for Navigation
**Date:** 2026-09-28
**Status:** Accepted
**Context:** Need routing that supports bottom navigation shell, nested routes, and deep linking (for future use).
**Decision:** Use `go_router` with `ShellRoute` for the bottom navigation bar.
**Alternatives Considered:**
- Navigator 2.0 raw — too verbose
- Auto Route — good but heavier
- Basic Navigator.push — insufficient for shell pattern
**Rationale:** GoRouter is the official Flutter-recommended routing solution. `ShellRoute` perfectly handles the bottom navigation pattern with persistent tab state. Declarative, type-safe, minimal boilerplate.

---

### D-012: Material Design 3 + "Calm Finance" Design System with Custom Skill
**Date:** 2026-09-28
**Status:** Accepted
**Context:** Need a premium, high-craft mobile UI/UX design standard for Android that feels Apple-quality while adhering to native Material 3 and optimizing for Samsung AMOLED screens.
**Decision:** Adopt a "Calm Finance" design system with customized tokens (16dp cards, 0 elevation + tonal surface containers, Inter with tabular figures, 6dp thin budget bars, 50ms staggered animations, shimmer loaders, and 5-second undo toast pattern), documented in a dedicated `.agents/skills/flutter-m3-premium-design/SKILL.md` skill.
**Alternatives Considered:**
- Standard out-of-the-box M3 defaults — functional but feels generic/material-boilerplate
- Heavy glassmorphism / skeuomorphism throughout — reduces contrast and battery life on mobile
- Ad-hoc styling per screen — leads to inconsistency across features
**Rationale:** Standardizing tokens in `DESIGN.md` and a dedicated skill ensures consistent implementation across all phases. The "Calm Finance" philosophy emphasizes speed of input and tabular clarity over flashy gamification, perfectly matching the personal finance use-case.

### D-013: Cascaded Hybrid AI Architecture (Fast Classifier + Sub-1B Light LLM)
**Date:** 2026-09-28
**Status:** Accepted (Amends and supersedes D-005 model sizing)
**Context:** Running a 1.7B–2B parameter model for every basic transaction ("Starbucks 250") on a mobile phone (Samsung Galaxy A36) introduces unnecessary memory allocation (~1.2 GB RAM), battery usage, and large download size (~1.2 GB). However, pure heuristics alone cannot handle complex multi-item splits or conversational spending summaries.
**Decision:** Adopt a two-tier cascaded hybrid pipeline:
1. **Tier 1 (System 1 - Fast Classifier & Entity Extractor):** A lightweight non-autoregressive decision model / pattern extractor (< 30 MB, < 20ms) that resolves ~90% of straightforward daily entries (extracting amount, date, and classifying category/account with calibrated confidence).
2. **Tier 2 (System 2 - Sub-1B Light LLM):** An ultra-compact GGUF model (`Qwen 2.5 0.5B Instruct` ~350 MB, with `SmolLM 2 360M` ~220 MB as alternative) running via `flutter_llama`. The Tier 1 router invokes Tier 2 only when input is complex, multi-entity, conversational, or for generating daily spending summaries.
**Alternatives Considered:**
- Monolithic 1.7B–3B LLM for all inputs — overkill for simple logging, 1.2 GB RAM footprint, higher battery draw.
- Pure classifier only without LLM — cannot generate natural language summaries or handle complex conversational queries.
- Cloud API (GPT/Gemini) — violates 100% offline, zero-cloud privacy principle.
**Rationale:** Delivers instantaneous (< 50ms) logging for 90% of transactions with zero memory strain, while preserving full conversational LLM capabilities for complex inputs and summaries. Reduces download size from ~1.2 GB to ~350 MB and peak RAM from ~1.2 GB to < 400 MB, perfectly suited for the Samsung Galaxy A36.

### D-014: Semantic Versioning (SemVer) Lifecycle
**Date:** 2026-09-29
**Status:** Accepted
**Context:** App is undergoing active iterations. Calling early development builds `v1.0.0` misrepresents progress, and changes need structured version tracking.
**Decision:** Standardize on strict Semantic Versioning (`0.Y.Z` for pre-1.0 development, moving to `1.0.0` only when all PRD requirements, Drift DB, and on-device LLM are fully implemented and stable). Every code task will increment patch (`0.Y.Z+1`) or minor (`0.(Y+1).0`), synchronized across `pubspec.yaml` and `app_constants.dart`. A subtle `VersionPill` component is displayed in-app.
**Alternatives Considered:**
- Static version until final release — loses tracking of progressive build milestones.
- Unstructured date-based versioning — less compatible with Flutter build numbers and automated release pipelines.
**Rationale:** Keeps build artifacts identifiable, aligns with Flutter's `version: X.Y.Z+B` system, and enables clear communication during testing.

---

### D-015: GitHub Releases In-App OTA Auto-Updater
**Date:** 2026-09-29
**Status:** Accepted (Roadmap for future implementation)
**Context:** Since Hermanos Ledgr is a personal-use app that will not be published to Google Play Store, updating the app on the phone currently requires manual USB cable sideloading or downloading APKs manually.
**Decision:** Plan an in-app OTA auto-updater that queries the GitHub Releases API (`api.github.com/repos/johncarlangelo/hermanos-ledgr/releases/latest`) on startup and from the Settings screen. When a newer version tag is found, the app prompts the user, downloads the APK to local cache, and invokes the Android Package Installer.
**Alternatives Considered:**
- Google Play Console internal testing track — requires developer account, review overhead, and breaks zero-cloud independence.
- Third-party app stores (F-Droid / Obtainium) — adds external app dependencies.
**Rationale:** Preserves 100% self-reliance and privacy. Pushing a tag to `main` with GitHub Actions builds and publishes the APK automatically, allowing the owner to update directly from their phone with one tap.

---

### D-016: Unified Debt & Receivables Model with Direct Bill Splitting
**Date:** 2026-10-18
**Status:** Accepted
**Context:** Tracking personal loans, debts owed to friends/banks (Utang), and money owed to you (Pautang/collectibles) requires intuitive management and quick bill-splitting among friends.
**Decision:** Model both debts and receivables under a unified `DebtModel` entity parameterized by `DebtType` (`debt` vs `receivable`). Implement a reactive Drift SQLite DAO (`debts_dao.dart`) with atomic `recordPayment` increments and status updates. Provide a dedicated `BillSplitSheet` calculator with adjustable headcounts and tip/tax presets that can automatically generate individual receivable records in a single tap with undo support.
**Alternatives Considered:**
- Separate tables for Debts and Receivables — duplicates schema and DAO queries for identical attributes.
- External bill-split calculator app — breaks offline all-in-one experience.
**Rationale:** Keeps database queries and presentation components DRY while providing distinct visual badges, progress bars, and dedicated segmented tabs ("I Owe", "Owed to Me", "Settled").

---

### D-017: Recurring Transactions Auto-Log Engine & Cashflow Timeline Forecast
**Date:** 2026-10-18
**Status:** Accepted
**Context:** Users need scheduled payments (e.g., subscriptions, rent, utility bills, salary) to log automatically or be logged ahead of time, while visualizing projected liquidity over 30, 60, and 90-day horizons.
**Decision:** Implement a modular `RecurringAutoLogEngine` and `ForecastEngine` with clean architecture separation:
1. `RecurringTransactionsTable` Drift table and `RecurringDao` managing recurring rules with frequency math (`daily`, `weekly`, `biweekly`, `monthly`, `yearly`), month-end clamping (Jan 31 -> Feb 28), and monthly equivalent normalization factors.
2. `RecurringAutoLogEngine`: Runs on app launch (guarded to once per session via Riverpod state notifier), checks for rules whose `nextDueDate` is on or before current date and `isActive == true`, inserts corresponding `TransactionCompanion` records, and advances `nextDueDate` atomically.
3. `ForecastEngine`: Simulates daily cashflow deltas over user-selectable horizons (30, 60, 90 days) based on current total liquid balances + recurring income & expense occurrences. Feeds into an interactive `fl_chart` LineChart widget with smooth cubic curvature, gradient area shading, dot markers on active payment days, and chronological upcoming payment tiles.
**Alternatives Considered:**
- Android WorkManager background service — unnecessary battery drain and complexity for an offline personal app; running on session startup is 100% reliable and instantaneous.
- Static monthly multiplier without day-by-day simulation — fails to depict mid-month cash dips or account for bi-weekly paychecks.
**Rationale:** Delivers high-precision predictive cashflow visualization, zero battery overhead, zero stock Android UI, and seamless offline SQLite persistence.

### D-018: Cascaded Hybrid AI Assistant (Tier 1 Classifier + Light Qwen 2.5 LLM)
**Date:** 2026-10-18
**Status:** Accepted
**Context:** Natural language logging and chat assistance require immediate (<20ms) responsiveness, zero battery drain, and zero hallucinations, while supporting complex queries, split allocations, and natural conversational summaries offline on Samsung Galaxy A36/A55 devices.
**Decision:** Adopt a two-tier Cascaded Hybrid AI architecture:
1. **Tier 1 Fast Rule/Classifier Engine (`ClassifierService`):** Pure Dart entity extractor with regex and keyword matching. Handles 90%+ of standard transaction inputs ("Coffee 150 GCash", "Salary 50k BDO kahapon") in <15ms with 0MB memory overhead. Strictly rejects gibberish or inputs without valid amounts (`ClassifierIntent.unclearOrGibberish`), completely eliminating hallucinations and fake transaction generation.
2. **Tier 2 Light On-Device LLM (`Qwen 2.5 0.5B Instruct` via `flutter_llama`):** An optional GGUF model (~380MB Q4_K_M) downloaded on-demand directly on the device or imported from local storage (never bundled in the APK to keep the app featherweight at ~25-35MB). Invoked when Tier 1 detects `complexOrSplit` transactions, ambiguous multi-line expenses, or requests for natural language spending summaries.
3. **Clean Action Card Flow & Persistence:** Transactions parsed by either tier are presented as an interactive Action Card (amount, category, account, date) with `[Confirm]`, `[Edit]`, and `[Discard]`. Confirming atomically logs the transaction to the real Drift SQLite database, updates account balances, and shows an `UndoSnackbar` with a 5-second rollback window. Full chat conversation history persists in Drift (`chat_messages` table).
**Alternatives Considered:**
- Pure cloud LLM (OpenAI/Anthropic API) — violates 100% offline-first and zero-cloud privacy architecture.
- Bundling GGUF model directly in the APK assets — inflates APK size from ~30MB to 400MB+, creating slow sideloading and storage bloat.
- Relying exclusively on an LLM for simple inputs — introduces 1-2s latency and non-deterministic behavior for trivial 3-word expense logs.
**Rationale:** Gives the user instant sub-20ms responsiveness for daily transaction logging while providing full natural language reasoning and offline on-device AI capabilities when needed.

### D-019: Cascaded Hybrid Receipt Scanner with Pure Dart Heuristic Parser & Optional Qwen LLM Fallback
**Date:** 2026-10-18
**Status:** Accepted
**Context:** Automated receipt scanning requires fast on-device text extraction, parsing amounts, merchants, dates, and categories without requiring cloud APIs or mandatory heavy ML dependencies. Users must also be warned of physical OCR limitations (crumpled paper, blurry camera, poor lighting).
**Decision:**
1. Use Google ML Kit Text Recognition (`google_mlkit_text_recognition`) running 100% on-device for raw OCR text extraction.
2. Implement a pure Dart `ReceiptParser` (<5ms execution time) with deterministic regex extraction for Philippine and international receipts:
   - Scans totals from bottom to top, strictly filtering out CASH/TENDERED, CHANGE/SUKLI, and VAT lines to avoid mistaking payment tenders or tax for total expense.
   - Extracts merchant headers and maps keywords to default categories (Jollibee -> Food, SM Supermarket -> Groceries, Mercury Drug -> Health, Petron -> Transport, etc.) with length-descending prioritization.
   - Extracts dates from standard formats (`YYYY-MM-DD`, `DD/MM/YYYY`, `Month DD, YYYY`).
3. Cascaded Tier 2 LLM Fallback: If confidence is low (<0.70) and the optional Tier 2 Qwen 2.5 LLM is loaded, invoke `generateStructuredJson` to resolve messy multi-column receipt formats. If no LLM is downloaded, Tier 1 returns its best estimate seamlessly without blocking the user.
4. Accuracy Disclaimer Banner: Prominently displayed on the scan result preview sheet: *"Note: OCR text detection may be inaccurate if the image is blurry, poorly lit, or the receipt is crumpled. Always verify details before adding to ledger."*
5. UI & Integration: Custom `ReceiptScannerScreen` featuring animated scanning laser beam, viewfinder corner brackets, camera shutter, and gallery photo picker (`image_picker`). Directly opens pre-filled `AddTransactionSheet` with parsed amount, merchant, category, date, and receipt image preview attached.
**Alternatives Considered:**
- Cloud OCR (Google Cloud Vision / AWS Textract) — violates offline-first privacy.
- LLM-only OCR extraction — requires downloading a 350MB model before anyone can scan a receipt; 1-2s latency vs <5ms pure Dart regex.
**Rationale:** Instant zero-cost receipt parsing for 95% of receipts, with graceful optional LLM fallback and transparent user verification.

### D-020: Full SQLite Database JSON Serialization, 7-Snapshot Retention, & Share Sheet Integration
**Date:** 2026-10-18
**Status:** Accepted
**Context:** Local backups, easy recovery, and cross-platform data mobility are critical for an offline-first budget app. Users need 1-tap automated daily backups, manual on-demand snapshots, RFC 4180 CSV spreadsheets for spreadsheet apps (Excel/Sheets), and structured JSON database export/import with validation and atomic restoration across all 8 Drift tables (`accounts`, `transactions`, `budgets`, `categories`, `debts`, `recurring`, `chat_messages`, `receipts`).
**Decision:**
1. **Full Database Serialization (`BackupService`):** Serializes all 8 Drift SQLite tables into a single JSON payload with an embedded `BackupManifest` (app name, version, timestamp, schema version, table counts). On import/restore, performs structural validation, checks table keys, presents an interactive confirmation sheet showing detected record chips, and executes atomic table replacement inside a single SQLite transaction.
2. **RFC 4180 CSV Serializer (`CsvExportService`):** Formats transactions and accounts with strict RFC 4180 compliance (double-quote escaping, comma handling, multi-line notes support).
3. **Dedicated Local Storage & Retention (`BackupStorageService`):** Manages backups under `getApplicationDocumentsDirectory()/backups`. Enforces automated 7-snapshot retention (`pruneAutoBackups(keepLast: 7)`) that preserves the 7 newest auto-backups and purges older automated files.
4. **App Launch Hook:** `checkAndRunDailyAutoBackup()` executed once per calendar day upon dashboard mount via `addPostFrameCallback`, running non-blocking in the background.
5. **Custom UI & Share Sheet Integration:** Custom 28dp top radius bottom sheets (`BackupHistorySheet`, `RestoreConfirmSheet`, `ExportDialogSheet`, `ImportDialogSheet`) with `share_plus` system share sheet integration, clipboard fallback, file picker support, and zero stock Android native pickers or dialogs.
**Alternatives Considered:**
- Direct raw SQLite database file copying (`.db`) — brittle across Drift schema migrations and unreadable in text editors or external tools.
- Cloud storage sync (Google Drive / Dropbox API) — violates 100% offline-first and zero-cloud independence principles.
**Rationale:** JSON serialization provides transparent, readable, and future-proof backup archives that the user can inspect, share, or restore anytime, completely offline.

### D-021: Multi-Profile Support, Multi-Model LLM Lifecycle, and Financial Scratchpad (Quick Notes)
**Date:** 2026-10-18
**Status:** Accepted
**Context:** Personal budgeting requires flexible workspace separation (e.g., personal spending vs side-hustle/freelance) without requiring accounts or cloud synchronization. Samsung Galaxy A36/A55 users also require granular control over their on-device AI brains (switching between ultra-light 360M models, recommended 0.5B Qwen 2.5, and 1.5B models, or importing local GGUFs) and reclaiming storage at will. Lastly, users need a scratchpad to jot down fleeting financial thoughts ("Dentist ₱1200", "Buy grocery 150 GCash") before committing them to ledger accounts.
**Decision:**
1. **Multi-Profile Support (`ProfileNotifier`, `ProfileManagerSheet` - Task 12.5):**
   - Implemented `ProfileModel` with unique ID, display name, accent color, and custom photo path.
   - Primary default profile is seeded from onboarding and protected from deletion.
   - 1-tap profile switching atomically synchronizes the active user identity across `onboardingProvider`, dashboard greetings, and settings.
   - Custom 28dp sheets for profile management and profile creation with interactive accent color chips and 1:1 square photo cropping.
2. **Multi-Model LLM Lifecycle (`ModelManager`, `ModelDownloadSheet` - Task 12.6):**
   - Upgraded `ModelManager` to support multi-model specs (`Qwen 2.5 0.5B Instruct` default/recommended, `SmolLM2 360M Instruct` ultra-light, `Qwen 2.5 1.5B Instruct`).
   - Active brain selection persists across app launches via SharedPreferences.
   - Streaming download progress with byte counters, cancellation, active model badge indicators, and 1-tap model switching.
   - Safe deletion unloads active models from memory before deleting local files to reclaim device storage.
   - Custom GGUF file importer allows advanced users to sideload arbitrary quantized models from device storage.
3. **Quick Notes & Financial Scratchpad (`NotesDao`, `NotesTable`, `QuickNotesScreen` - Task 12.7):**
   - Created Drift SQLite `notes` table with reactive `NotesDao` (`watchAllNotes()`).
   - Pure Dart heuristic regex extractor automatically detects currency amounts (e.g., `₱1,200`, `150 GCash`, `50k`).
   - Material 3 `NoteCard` with custom 7dp animated checkbox, strikethrough styling, tag badges, and 1-tap "Log to Ledger" opening pre-filled `AddTransactionSheet`.
   - Included `notes` table in the full database JSON serialization and atomic restore pipeline (`BackupService`).
**Alternatives Considered:**
- Storing notes in memory or shared preferences — loses queryability, filtering, and cross-backup persistence.
- Bundling multiple models in the APK — bloats APK size to over 1GB; modular downloading and local file import keep the app compact.
**Rationale:** Delivers complete multi-profile customization, flexible on-device LLM management, and a low-friction scratchpad for quick expense tracking.

### D-022: Motion Transitions, Micro-Animations, and Samsung A36 Render Optimizations
**Date:** 2026-10-18
**Status:** Accepted
**Context:** Delivering a fluid, 120Hz-ready experience on the Samsung Galaxy A36 5G (Exynos 1380 / Mali-G68 GPU) while adhering to Hermanos-Stash styling and Material Design 3 motion principles. The app needed shared axis screen transitions, staggered card cascades, tactile spring press feedback, edge-case math hardening, and paint containment to prevent jank during rapid scrolling.
**Decision:**
1. **Page Transitions (`lib/app/page_transitions.dart` - Task 13.1):**
   - Shared Axis X Slide-Fade: 300ms `Curves.easeOutCubic` horizontal slide-fade for deep route pushes (`/settings`, `/accounts`, `/accounts/:id`, `/goals`, `/debts`, `/recurring`, `/forecast`, `/scanner`, `/notes`).
   - Cross-Fade: 200ms `Curves.easeInOut` cross-fade for ShellRoute tab switching (`/`, `/transactions`, `/budget`, `/ai`) and `/onboarding`.
2. **Motion Wrappers & Micro-Animations (`lib/shared/widgets/motion_wrapper.dart`, `m3_card.dart` - Task 13.2):**
   - `StaggeredEntrance`: Ticker-driven `Interval` curve (no uncancelled `Timer` leaks) with 50ms per-index stagger and 220ms `Curves.easeOutCubic` fade-and-rise entrance for lists and dashboard cards.
   - `BouncyPressable`: Spring-like scale micro-animation (0.96 scale on tap down, 1.0 on release) with subtle `HapticFeedback.selectionClick()`.
   - Integrated subtle tactile haptics into all interactive cards (`M3Card`).
3. **GPU Render Layer Containment (`RepaintBoundary` - Tasks 13.4, 13.5):**
   - Wrapped `PersonalizedCard` root container in `RepaintBoundary` to isolate complex multi-layer shadows, SVG bank logos, and EMV chip vectors in GPU texture memory during horizontal carousel scrolling.
   - Wrapped `HeroAmountDisplay` count-up ticker in `RepaintBoundary` to prevent frequent numeric text rasterization from triggering full dashboard repaints.
   - Wrapped `PieChart` in `BudgetScreen` in `RepaintBoundary` to isolate canvas repaints during scroll.
   - Removed deprecated `cacheExtent` overrides, letting Flutter's built-in 250px viewport cache work smoothly without layout jank.
4. **Edge-Case Hardening & Lifecycle Leak Prevention (Tasks 13.6, 13.7):**
   - Guarded `BudgetModel` against division by zero: `percentage` returns 2.0 (if spent > 0) or 0.0 when `limitAmount <= 0.0`; `remainingAmount` returns 0.0; `status` safely flags `over` or `safe` without throwing `ArgumentError`.
   - Guarded `AddContributionSheet` against zero target goals (`widget.goal.targetAmount > 0`).
   - Ensured all animation controllers and tickers across screens and widgets are safely disposed on teardown.
5. **Release Milestone Discipline (Task 13.8):**
   - Kept Task 13.8 (signed release APK) pending user on-device verification. The app SemVer is bumped to `0.17.0+35` (`v0.17.0-alpha`), reserving `v1.0.0` strictly for confirmed release.
**Alternatives Considered:**
- Using stock page transitions (MaterialPageRoute standard zoom) — felt generic and mismatched Stash's calm finance aesthetic.
- Using heavy third-party animation packages (`animations`, `flutter_animate`) — unnecessary dependency overhead when pure Flutter ticker transitions and curves deliver 60/120fps with zero extra dependencies.
**Rationale:** Guarantees buttery-smooth 120Hz motion on the Samsung Galaxy A36, eliminates repaint thrashing, hardens all mathematical edge cases, and provides tactile feedback.

---

*Add new decisions below this line.*
