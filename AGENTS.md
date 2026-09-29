# Agent Instructions
## Hermanos Ledgr

> **Last Updated:** 2026-09-28
> **Companion Skill:** `.agents/skills/flutter-m3-premium-design/SKILL.md`

---

## Project Overview

**Hermanos Ledgr** is a personal-use Android budget tracking app built with Flutter. It is an offline-first finance tracker with custom-tailored Hermanos-Stash styling and local LLM integration. See `PRD.md` for full requirements and `ARCHITECTURE.md` for technical architecture.

---

## Tech Stack

- **Framework:** Flutter (Dart) — Android only
- **State Management:** Riverpod 2.x (use `@riverpod` code generation where possible)
- **Database:** Drift (SQLite) with code generation
- **LLM:** `flutter_llama` (llama.cpp via FFI, GGUF models)
- **OCR:** Google ML Kit (on-device)
- **Charts:** `fl_chart`
- **Design:** Material Design 3 with `ColorScheme.fromSeed(seedColor: Color(0xFF00897B))` (Stash Teal)

---

## Mandatory Design System & Skill Usage

> [!IMPORTANT]
> **Before creating or modifying any UI widget or screen**, agents MUST read and follow the specifications in:
> [`.agents/skills/flutter-m3-premium-design/SKILL.md`](file:///d:/Comsci%20things/Hermanos%20Ledgr%20-%20Budget%20Tracking%20app/hermanos-ledgr/.agents/skills/flutter-m3-premium-design/SKILL.md) and [`DESIGN.md`](file:///d:/Comsci%20things/Hermanos%20Ledgr%20-%20Budget%20Tracking%20app/hermanos-ledgr/DESIGN.md).

### Core UI Rules for Agents:
1. **Cards:** Corner radius must be **16dp**, elevation **0**, background `surfaceContainer`.
2. **Numbers:** All money amounts MUST use `fontFeatures: [FontFeature.tabularFigures()]` so digits do not jump or jitter.
3. **Colors:** Never use raw `Colors.green` or `Colors.red`. Always use semantic color tokens from `SemanticColors` or `colorScheme`. Primary accent is Stash Teal (`#7FB8AE`).
4. **Loading States:** Always use **shimmer skeleton cards** (not circular spinners) for data screens.
5. **Empty States:** Every empty view must have an icon (48dp, 40% opacity), descriptive message, and CTA button.
6. **Undo Toast:** Use `UndoSnackbar.show` (floating pill banner) with an `[Undo]` button after adding, editing, or deleting transactions.
7. **Hero Numbers:** Net worth and balances place the label *above* the number and use count-up animations (300ms easeOutCubic).
8. **Motion:** Use staggered card cascades (50ms delay) when lists or dashboards load.
9. **Zero Stock Android Native UI (Strict Rule):** We do NOT use generic Android native UI components anywhere in this app. Everything must be custom and tailored:
   - ❌ **No Native Alerts/Dialogs:** No `AlertDialog` or `SimpleDialog`. Use custom bottom sheets (28dp top radius, Stash dark container hierarchy) or tailored overlay modals.
   - ❌ **No Dropdowns or Native Menus:** No `DropdownButton`, `DropdownButtonFormField`, or `PopupMenuButton`. Build custom modal bottom sheets or selection tiles with custom icon badges, balances, and selection check indicators.
   - ❌ **No Stock Snackbars or Toasts:** Never invoke raw `ScaffoldMessenger.of(context).showSnackBar` or system toasts. Use `UndoSnackbar` (`UndoSnackbar.show`, `UndoSnackbar.error`, `UndoSnackbar.info`) which renders floating pill cards styled with Stash raised containers and teal accents.
   - ❌ **No Stock Checkboxes/Radios/Switches:** Never use standard `Checkbox`, `Radio`, or `Switch`. Build custom animated containers (`AnimatedContainer`) with 7dp corner radii, smooth color transitions, and check icons.
   - ❌ **No System Pickers:** No default `showDatePicker` / `showTimePicker`. Use custom interactive calendar/time sheets.

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

### Git & Commit Standards
- **Strict 1-Liner Conventional Commits:** All git commit messages MUST be a single line. NEVER write long, multi-paragraph, or bulleted commit messages.
- **Format:** `<type>(<scope>): <short description in lowercase imperative mood>`
- **Allowed Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`
- **Max Length:** ~72 characters (concise, clean, scannable on GitHub).
- **Examples:**
  - ✅ `feat(settings): add settings screen and user preferences`
  - ✅ `fix(drawer): resolve double drag handle in account picker`
  - ✅ `style(theme): update color tokens to stash teal`
  - ❌ `feat(settings): add settings screen\n\n- Detailed item 1\n- Detailed item 2` (NO paragraphs or bullet points)

---

## Command Execution & Safety Protocol (Strict Rule)

The user has Antigravity configured for automatic command execution. Because commands execute without an interactive CLI prompt, agents MUST exercise strict safety boundaries and **NEVER run dangerous, system-modifying, environment-altering, or remote-altering commands without explicit user permission**.

### Strictly Prohibited Without Explicit User Request:
1. **System & Global Git Configs:**
   - ❌ Never run `git config --global`, `gh auth setup-git`, or change system credential helpers.
   - ❌ Never change, rename, or touch git remotes (`git remote set-url`, `git remote add`, `git remote remove`) without asking.
   - ❌ Never touch user global SSH, GPG, or `.gitconfig` settings.
2. **Pushing & Remote Mutating:**
   - ❌ Never run `git push`, `git push --force`, or publish commits unless the user explicitly requests it (e.g., "you may push now", "push to main").
3. **Destructive Git & Filesystem Actions:**
   - ❌ Never run `git reset --hard`, `git clean -fd`, `git restore .`, `git rebase`, or delete branches.
   - ❌ Never delete databases, drop SQLite tables, or run destructive file deletions without asking.
4. **Safe to Run Autonomously:**
   - Read-only diagnostics: `git status`, `git diff`, `git log`.
   - Local validation & builds: `flutter pub get`, `dart run build_runner build`, `flutter analyze`, `flutter test`.

---

## Design System Tokens Summary

- **Theme:** Material Design 3 with `useMaterial3: true`
- **Seed Color:** `#00897B` (Stash Teal — Hermanos-Stash palette)
- **Primary Accent:** `#7FB8AE` (Teal)
- **Font:** Google Fonts — Inter with tabular figures
- **Dark Mode:** Default; follows system preference
- **AMOLED Mode:** True black (`#000000`) option for Samsung displays
- **Currency:** Philippine Peso (₱) — hardcoded for personal use
- **Spacing:** 4dp grid system (xs=4, sm=8, md=12, lg=16, xl=24, xxl=32, xxxl=48)
- **Corner Radius:** Cards=16dp, Sheets=28dp, Chips=8dp, Keypad buttons=12dp

See `DESIGN.md` and `.agents/skills/flutter-m3-premium-design/SKILL.md` for complete details.

---

## Semantic Versioning (SemVer) Rules

Agents MUST actively maintain and bump the semantic version according to what is implemented, fixed, or modified:
- **Pre-1.0 Development Phase (`0.Y.Z`)**:
  The current development state is strictly in early pre-release (`v0.1.0-alpha`). It is **NOT v1.0.0**. Version 1.0.0 is reserved exclusively for the complete, stable release featuring full Drift SQLite persistence, on-device LLM inference, and all core PRD requirements.
- **Patch Version Bump (`0.Y.Z` → `0.Y.(Z+1)` / build +1)**:
  - Triggered by: Bug fixes, UI/styling tweaks, text/spacing corrections, minor refactors.
  - Example: Fixing a double drag handle or padding overflow bumps `0.1.0` → `0.1.1`.
- **Minor Version Bump (`0.Y.Z` → `0.(Y+1).0` / build +1)**:
  - Triggered by: New feature screens or major capabilities.
  - Example: Implementing the Settings screen, Drift DAO layer, camera OCR scanner, or CSV data export.
- **Major Version Bump (`X.0.0`)**:
  - Reserved strictly for full production milestone readiness (`v1.0.0`) when the entire PRD feature set is completed for daily personal driver use on the Samsung Galaxy A36/A55.
- **No Bump (`docs`, `skills`, `chore`, non-app changes)**:
  - Updates to documentation, agent rules, skills, repository configurations, or toolchains that do NOT touch runtime application code do **NOT** bump the version. Version numbers remain untouched.
- **Mandatory SemVer Files to Synchronize (when code changes occur):**
  1. [`pubspec.yaml`](file:///d:/Comsci%20things/Hermanos%20Ledgr%20-%20Budget%20Tracking%20app/hermanos-ledgr/pubspec.yaml) (`version: X.Y.Z+B`)
  2. [`lib/core/constants/app_constants.dart`](file:///d:/Comsci%20things/Hermanos%20Ledgr%20-%20Budget%20Tracking%20app/hermanos-ledgr/lib/core/constants/app_constants.dart) (`appVersion`, `appBuildNumber`, `appVersionDisplay`)
- **Version Pill:** The app displays a subtle custom `VersionPill` (`v0.1.0-alpha`) on the Dashboard header and Settings screen.

---

## Future Capabilities Roadmap

### In-App OTA Auto-Updater
- An automated updater checking GitHub Releases API (`api.github.com/repos/johncarlangelo/hermanos-ledgr/releases/latest`) whenever major, minor, or patch releases are pushed to `main`.
- When an update is detected, the app displays a custom bottom sheet prompting the user, downloads the release APK silently in the background, and triggers package installation on Android without Google Play Store dependency.

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
- ❌ Do not add streaks or gamification systems
- ❌ Do not bundle the LLM model in the APK (download on first use)
- ❌ Do not use `setState` for state management (use Riverpod)
- ❌ Do not use bare circular spinners for page loading (use shimmer)
- ❌ Do not use raw colors (`Colors.red`, `Colors.green`)
- ❌ Do not use stock Android native UI components (`AlertDialog`, `DropdownButton`, `PopupMenuButton`, raw `SnackBar`, `Toast`, `Checkbox`, `Radio`, `Switch`) — everything must be custom-tailored
- ❌ Do not write multi-line, paragraphed, or bulleted commit messages (strictly 1-liner conventional commits only)
- ❌ Do not run dangerous, environment-modifying, or system configuration commands (`git config --global`, `gh auth`, changing remotes, destructive git commands) without explicit user permission
- ❌ Do not run `git push` unless the user explicitly commands to push
- ❌ Do not store sensitive data unencrypted (though this is a personal app, be sensible)
