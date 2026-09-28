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
**Context:** Need to run LLM inference locally on Samsung A57 (Exynos 1680, 8-12GB RAM) for natural language transaction parsing.
**Decision:** Use `flutter_llama` (llama.cpp wrapper) with GGUF models.
**Alternatives Considered:**
- `llamadart` — good but less mature
- LiteRT-LM (Google) — better hardware optimization but more complex setup
- Cloud API (Gemini/GPT) — requires internet, defeats offline-first principle
**Rationale:** `flutter_llama` is the most popular, production-ready Flutter wrapper for llama.cpp. Supports Vulkan GPU acceleration on Android, GGUF format, and token streaming. The Samsung A57's Exynos 1680 with Xclipse 550 GPU should handle inference well.

---

### D-005: Qwen 3 1.7B Q4_K_M as Default LLM Model
**Date:** 2026-09-28
**Status:** Accepted
**Context:** Need a model small enough for mobile but capable enough to parse "Starbucks 250 from GCash" into structured JSON.
**Decision:** Default to Qwen 3 1.7B Q4_K_M. Offer SmolLM 2 1.7B as alternative. Gemma 3 1B as lightweight fallback.
**Alternatives Considered:**
- Larger models (3B+) — too much RAM, too slow
- Smaller models (<1B) — insufficient for reliable JSON output
- Phi-3 mini — good but less tested on mobile
**Rationale:** Samsung A57 has 8-12GB RAM; Android + background apps use ~3-4GB, leaving 4-8GB for the app. A 1.7B Q4_K_M model uses ~1.2GB RAM during inference, well within budget. Qwen 3 is currently among the most capable small models for structured output.

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

---

*Add new decisions below this line.*
