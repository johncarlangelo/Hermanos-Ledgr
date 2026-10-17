# In-App OTA Auto-Updater & CI/CD Guide
## Hermanos Ledgr (Non-Play Store Sideloaded APK)

> **Last Updated:** 2026-10-17  
> **Status:** Architecture & Implementation Reference  
> **Companion Tasks:** `TASKS.md` (Standalone / Future Capabilities: In-App OTA Auto-Updater)

---

## 1. Overview & Architecture

Because **Hermanos Ledgr** is a personal-use Android budget tracker and will **not** be published on the Google Play Store, it uses an **Over-The-Air (OTA) self-updating mechanism** powered by **GitHub Actions** and the **GitHub Releases API**.

Whenever you merge or push new features to the `main` branch:
1. **GitHub Actions** triggers in the cloud, runs tests, and compiles a release APK signed with your private keystore.
2. It publishes a **GitHub Release** tagged with your app version (e.g. `v0.8.0`) and attaches `app-release.apk`.
3. Your phone's Hermanos Ledgr app checks the release API (automatically once a day or manually via Settings).
4. The app downloads the update in the background with a progress bar and opens Android's native package installer to update seamlessly in-place **without losing any of your local database data**.

```
┌─────────────────────────────────────────────────────────────────┐
│                      DEVELOPER WORKFLOW                         │
│                                                                 │
│  [feature/xyz] ──(test & verify)──> [main] ──(git push origin)─┐│
└────────────────────────────────────────────────────────────────┼┘
                                                                 │
┌────────────────────────────────────────────────────────────────┼┐
│                   GITHUB ACTIONS (CI / CD)                     │
│                                                                │
│  1. Check out code & verify tests (`flutter test`)             │
│  2. Build signed release APK (`flutter build apk --release`)   │
│  3. Publish GitHub Release tagged `vX.Y.Z` + attach APK <──────┘
└────────────────────────────────┬────────────────────────────────┘
                                 │
┌────────────────────────────────┼────────────────────────────────┐
│               YOUR ANDROID DEVICE (HERMANOS LEDGR)              │
│                                                                 │
│  1. App queries `api.github.com/.../releases/latest` <─────────┘
│  2. Compares remote version with `AppConstants.appVersion`      │
│  3. Displays Stash M3 `UpdateAvailableSheet` (Changelog + CTA)  │
│  4. Downloads APK & prompts Android Package Installer           │
│  5. 1-Tap in-place update (SQLite & preferences 100% preserved) │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Git Branching Strategy

To prevent unfinished experiments from triggering releases to your phone, use a simple 2-tier branching model:

```
feature/phase-4-dashboard ──┐
                            ├──(PR / Merge)──> main ──(Triggers Release)
feature/ota-updater ────────┘
```

### Branches
- **`main`**: The single source of truth for stable, release-ready code. Every push or merge to `main` automatically triggers the release workflow and builds a new update.
- **`feature/<name>`**: Where all daily coding, bug fixes, and feature development happen (e.g., `feature/phase-4-dashboard`, `feature/budget-system`). Pushes to feature branches run tests for validation, but **never** publish APKs.

---

## 3. GitHub Actions CI/CD Configuration

Create `.github/workflows/release.yml`:

```yaml
name: Build & Release Sideloaded APK

on:
  push:
    branches:
      - main
    paths:
      - 'lib/**'
      - 'pubspec.yaml'
      - 'assets/**'
      - 'android/**'

permissions:
  contents: write

jobs:
  build-and-release:
    name: Test, Build & Publish APK
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Java 17
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.29.0' # Matches local SDK
          channel: 'stable'
          cache: true

      - name: Install Dependencies
        run: flutter pub get

      - name: Run Static Analysis
        run: flutter analyze

      - name: Run Unit & Widget Tests
        run: flutter test

      - name: Extract Version from pubspec.yaml
        id: get_version
        run: |
          VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //')
          VERSION_TAG="v$(echo $VERSION | cut -d'+' -f1)"
          echo "version=$VERSION" >> $GITHUB_OUTPUT
          echo "tag=$VERSION_TAG" >> $GITHUB_OUTPUT

      - name: Decode Android Release Keystore
        env:
          KEYSTORE_BASE64: ${{ secrets.ANDROID_KEYSTORE_BASE64 }}
        run: |
          echo "$KEYSTORE_BASE64" | base64 --decode > android/app/release.jks

      - name: Build Signed Release APK
        env:
          KEYSTORE_PASSWORD: ${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
          KEY_ALIAS: ${{ secrets.ANDROID_KEY_ALIAS }}
          KEY_PASSWORD: ${{ secrets.ANDROID_KEY_PASSWORD }}
        run: |
          flutter build apk --release \
            --split-per-abi=false

      - name: Rename Release APK
        run: |
          cp build/app/outputs/flutter-apk/app-release.apk \
             build/app/outputs/flutter-apk/hermanos-ledgr-${{ steps.get_version.outputs.tag }}.apk

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: ${{ steps.get_version.outputs.tag }}
          name: Hermanos Ledgr ${{ steps.get_version.outputs.tag }}
          generate_release_notes: true
          draft: false
          prerelease: false
          files: |
            build/app/outputs/flutter-apk/hermanos-ledgr-${{ steps.get_version.outputs.tag }}.apk
            build/app/outputs/flutter-apk/app-release.apk
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## 4. Keystore & GitHub Secrets Setup

Android will **refuse** to update an app if the new APK is signed with a different key than the installed APK. Therefore, your release key must be consistent.

### Step 1: Generate Release Keystore (Local Machine, One-Time)
Run in PowerShell:
```bash
keytool -genkey -v -keystore release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias hermanos_release
```
Save your keystore file safely and remember the passwords!

### Step 2: Convert to Base64 for GitHub Secrets
In PowerShell:
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("release.jks")) | Set-Clipboard
```

### Step 3: Add to GitHub Repository Secrets
Go to your repository on GitHub: **Settings ➔ Secrets and variables ➔ Actions ➔ New repository secret**:
1. `ANDROID_KEYSTORE_BASE64`: Paste the Base64 string from your clipboard.
2. `ANDROID_KEYSTORE_PASSWORD`: The keystore password you chose.
3. `ANDROID_KEY_ALIAS`: `hermanos_release` (or your chosen alias).
4. `ANDROID_KEY_PASSWORD`: The key password.

---

## 5. Android Manifest Configuration

### 1. Permissions (`android/app/src/main/AndroidManifest.xml`)
Add inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
```

### 2. FileProvider Configuration
Add inside `<application>` in `AndroidManifest.xml`:
```xml
<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/file_paths" />
</provider>
```

Create `android/app/src/main/res/xml/file_paths.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-cache-path name="apk_cache" path="." />
    <cache-path name="internal_cache" path="." />
</paths>
```

---

## 6. Flutter In-App Architecture

### 1. API Release Model (`update_release_model.dart`)
Parses `api.github.com/repos/johncarlangelo/Hermanos-Ledgr/releases/latest`:
- `tag`: Remote version string (e.g. `0.9.0`)
- `changelog`: Markdown body
- `apkDownloadUrl`: Direct HTTPS link to `app-release.apk`
- `fileSizeBytes`: Size in bytes (for progress calculation)
- `publishedAt`: DateTime

### 2. SemVer Comparison Utility (`semver_comparator.dart`)
Compares `remoteTag` with `AppConstants.appVersion`:
- `isNewer('0.9.0', '0.8.0')` ➔ `true`
- `isNewer('0.8.0', '0.8.0')` ➔ `false`

### 3. State Notifier (`updater_provider.dart`)
State machine:
- `idle`: Not checking
- `checking`: Querying GitHub API
- `updateAvailable(release)`: Update found
- `upToDate`: Current version is latest
- `downloading(progress, receivedBytes, totalBytes)`: Active streaming download
- `readyToInstall(apkFile)`: Ready for package installer
- `error(message)`: Network or parsing failure

### 4. Custom UI: `UpdateAvailableSheet`
- M3 bottom sheet, 28dp top radius, `surfaceContainer` background.
- Version transition pills: `v0.8.0` ➔ `v0.9.0` (Stash Teal accent).
- Markdown changelog view.
- Dual button state: transitions from "Download & Install" into an active linear progress bar, then prompts the Android installer.

### 5. Settings Screen Tile
Under Settings ➔ "About & System":
- **Tile:** "Check for Updates"
- **Subtitle:** `Current: v0.8.0-alpha · Tap to check`
- Shows inline spinner while checking.
- If up-to-date, triggers `UndoSnackbar.info(context, message: 'Hermanos Ledgr is up to date!')`.
- If an update is available, pops `UpdateAvailableSheet`.

---

## 7. When Should You Implement This?

### Recommended Timing: Right after Phase 4 (Dashboard) 🎯

| Milestone | Recommended Status | Rationale |
|---|---|---|
| **Now (Phase 3 Complete)** | 🟢 Great Option | Early setup means everything from Phase 4 onward can be tested directly on your phone via OTA. |
| **After Phase 4 (Dashboard)** | 🌟 **The Sweet Spot** | Once the Dashboard is built, the app has a complete daily-driver flow (Accounts, Transactions, Net Worth). Sideloading it to your phone here allows real-world daily testing while building Budgets and Goals. |
| **At the Very End (Phase 13)** | ⚠️ Not Recommended | Waiting until all 13 phases are done means you miss out on real-device testing (AMOLED dark mode, touch responsiveness) during active development. |
