# Agent Instructions
## Hermanos Ledgr

> **Last Updated:** 2026-09-28

---

## Project Overview

**Hermanos Ledgr** is a personal-use Android budget tracking app built with Flutter. It is a Tarsi-inspired offline-first finance tracker with local LLM integration. See `PRD.md` for full requirements and `ARCHITECTURE.md` for technical architecture.

---

## Tech Stack

- **Framework:** Flutter (Dart) — Android only
- **State Management:** Riverpod 2.x (use `@riverpod` code generation where possible)
- **Database:** Drift (SQLite) with code generation
- **LLM:** `flutter_llama` (llama.cpp via FFI, GGUF models)
- **OCR:** Google ML Kit (on-device)
- **Charts:** `fl_chart`
- **Design:** Material Design 3 with `ColorScheme.fromSeed(seedColor: Color(0xFF2E7D32))`

---

## Architecture Rules

### Directory Structure
Follow **feature-first modular architecture**. Every feature lives under `lib/features/<feature_name>/` with:
```
feature_name/
├── data/            # Repository implementations, services
├── domain/          # Entities, abstract repositories, value objects
├── presentation/
│   ├── screens/     # Full-page widgets
│   └── widgets/     # Reusable feature-specific widgets
└── providers/       # Riverpod providers
```

Shared code goes in `lib/core/` (database, models, utils) or `lib/shared/` (reusable widgets).

### Layer Dependencies
- **Presentation** → Application/Providers → Domain ← Infrastructure/Data
- **NEVER** import `data/` from `presentation/`
- **NEVER** import Flutter/UI code from `domain/`
- **Domain** layer has zero dependencies on any other layer

### File Naming
- Use `snake_case` for all file names
- Screens: `*_screen.dart`
- Widgets: descriptive name (e.g., `transaction_card.dart`)
- Providers: `*_provider.dart`
- Repositories: `*_repository.dart` (abstract), `*_repository_impl.dart` (concrete)
- Entities: `*_entity.dart`

---

## Coding Standards

### Dart Style
- Follow official Dart style guide
- Use `final` by default; `var` only when mutation is needed
- Prefer `const` constructors
- Use named parameters for constructors with > 2 params
- Use `freezed` for complex immutable data classes
- Use `sealed class` for union types (e.g., Result<T>)

### Riverpod Patterns
- Prefer `@riverpod` annotation (code generation) over manual provider declarations
- Use `AsyncNotifier` for complex async state
- Use `StreamProvider` for reactive Drift queries
- Always specify `ref.keepAlive()` for providers that should persist (e.g., database)
- Use `ref.invalidate()` for manual refresh, not `ref.refresh()` where possible

### Database (Drift)
- Define tables in `lib/core/database/tables/`
- Define the single `AppDatabase` in `lib/core/database/app_database.dart`
- Use DAOs for each feature's queries
- Always use parameterized queries (never string interpolation)
- Store dates as Unix timestamps (INTEGER)
- Store money as REAL (double) — avoid integer cents for simplicity in a personal app

### Error Handling
- Use `Result<T>` type (sealed class with `Success` and `Failure`)
- Never let exceptions propagate to the UI unhandled
- Show errors via `SnackBar` with clear messages
- Log errors locally for debugging

### LLM Integration
- Always run inference in a background Isolate
- Never block the UI thread during model loading or inference
- System prompts must include current categories and accounts for context
- Parse LLM output as JSON; fallback to showing raw text if parsing fails
- Always require user confirmation before committing an AI-parsed transaction

---

## Design System

- **Theme:** Material Design 3 with `useMaterial3: true`
- **Seed Color:** `#2E7D32` (Forest Green)
- **Font:** Google Fonts — Inter (fallback: Roboto)
- **Dark Mode:** Default; follows system preference
- **AMOLED Mode:** True black option for Samsung displays
- **Currency:** Philippine Peso (₱) — hardcoded for personal use
- **Spacing:** 4dp grid system (xs=4, sm=8, md=12, lg=16, xl=24, xxl=32)
- **Corner Radius:** Cards=12dp, Sheets=28dp, Chips=8dp, Buttons=full rounded

See `DESIGN.md` for full design specification.

---

## Key Decisions

All architectural and design decisions are logged in `DECISIONS.md`. When making a non-obvious choice, add an entry there with the rationale.

---

## Build & Run

```bash
# Get dependencies
flutter pub get

# Run code generation (Drift, Riverpod, Freezed)
dart run build_runner build --delete-conflicting-outputs

# Run on connected Android device
flutter run --flavor dev

# Build release APK (for sideloading)
flutter build apk --release
```

---

## What NOT to Do

- ❌ Do not add any cloud/server dependencies
- ❌ Do not add authentication/login flows
- ❌ Do not add analytics or telemetry
- ❌ Do not target iOS, web, or desktop
- ❌ Do not add stocks/crypto features (out of scope for v1)
- ❌ Do not add streaks or achievement systems
- ❌ Do not bundle the LLM model in the APK (download on first use)
- ❌ Do not use `setState` for state management (use Riverpod)
- ❌ Do not store sensitive data unencrypted (though this is a personal app, be sensible)
