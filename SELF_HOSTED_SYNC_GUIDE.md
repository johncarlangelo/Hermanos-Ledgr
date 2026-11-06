# Optional Self-Hosted Sync & Web Companion Guide
## Hermanos Ledgr (Docker-Powered Local-First Architecture)

> **Last Updated:** 2026-11-06  
> **Status:** Architecture & Implementation Blueprint (Post-v1 Roadmap)  
> **Inspiration:** [openGym](https://github.com/DuarteSantos8/openGym) (Hybrid Local-Only or Self-Hosted Docker Sync)  
> **Companion Tasks:** `TASKS.md` (Standalone / Future Capabilities: Optional Self-Hosted Sync)

---

## 1. Executive Summary & Design Philosophy

**Hermanos Ledgr** was founded on the strict principle of **Zero-Cloud Privacy**: your financial data should never live on a third party's servers, require a monthly subscription, or depend on an internet connection to work.

However, power users often encounter two limitations with phone-only software:
1. **Desktop Friction:** Entering historical bank statements, organizing 50+ monthly categories, or running complex cash flow projections on a small mobile touchscreen is tedious.
2. **Single-Device Isolation:** When sitting at a desk, having immediate access to your financial ledger on a PC with a physical keyboard and high-resolution monitor is significantly faster.

Inspired by open-source, local-first projects like [openGym](https://github.com/DuarteSantos8/openGym), Hermanos Ledgr adopts an **Optional Self-Hosted Sync & Web Companion**:

| Principle | Mobile Standalone (Default) | Self-Hosted Companion (Opt-In) |
|---|---|---|
| **Cloud Dependency** | ❌ None (100% on-device Drift SQLite) | ❌ None (Self-hosted Docker on your PC/NAS) |
| **Network Requirement** | ❌ None (Works 100% offline indefinitely) | Optional home Wi-Fi / LAN or private Tailscale mesh |
| **Authentication** | None needed | Local pre-shared Bearer token / 1-tap QR scan |
| **Data Storage** | Samsung Galaxy internal storage | PC host filesystem (`./data/hermanos_ledger.db`) |
| **Web Interface** | None | Full-screen Stash M3 Desktop Web Companion |
| **Backups** | Manual JSON/CSV export from phone | Automated nightly cold snapshots on your PC/NAS |

> [!IMPORTANT]
> **Zero Compromise on Offline First:** The mobile app will never require the server. If the server is offline, unreachable, or never deployed, the app functions with 100% of its offline capabilities untouched.

---

## 2. High-Level System Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│                   ANDROID MOBILE DEVICE (CLIENT)                       │
│                                                                        │
│  ┌───────────────────────┐         ┌─────────────────────────┐         │
│  │  UI Screens & Sheets  │ ◄─────► │   Riverpod State Layer  │         │
│  └───────────────────────┘         └────────────┬────────────┘         │
│                                                 │                      │
│                                    ┌────────────▼────────────┐         │
│                                    │  Drift SQLite Database  │         │
│                                    │  (UUIDs, Microsecond    │         │
│                                    │   Timestamps, Tombstone)│         │
│                                    └────────────┬────────────┘         │
│                                                 │                      │
│                                    ┌────────────▼────────────┐         │
│                                    │   Local Sync Service    │         │
│                                    │  (Change Queue / Push)  │         │
│                                    └────────────┬────────────┘         │
└─────────────────────────────────────────────────┼──────────────────────┘
                                                  │
                 Local Wi-Fi / LAN (mDNS)         │
                 or Private Tailscale VPN         │ HTTP/2 + JSON (or Protobuf)
                 (Zero Public Internet Exposure)  │ Bearer Token Auth
                                                  │
                                                  ▼
┌────────────────────────────────────────────────────────────────────────┐
│               PC / HOME SERVER (DOCKER CONTAINER)                      │
│                                                                        │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                    DOCKER CONTAINER: hermanos-sync               │  │
│  │                                                                  │  │
│  │  ┌──────────────────────┐             ┌───────────────────────┐  │  │
│  │  │   Sync REST API      │ ◄─────────► │   Web Companion UI    │  │  │
│  │  │   (Go / Dart Frog)   │             │   (Hermanos-Stash M3) │  │  │
│  │  └──────────┬───────────┘             └───────────────────────┘  │  │
│  │             │                                                    │  │
│  │  ┌──────────▼───────────┐                                        │  │
│  │  │ Central Sync SQLite  │                                        │  │
│  │  │ (Mounted to Host OS) │                                        │  │
│  │  └──────────────────────┘                                        │  │
│  └──────────────────────────────────┬───────────────────────────────┘  │
│                                     │ Mounted Volume: ./data           │
│                                     ▼                                  │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │ HOST FILE SYSTEM: ./data/hermanos_ledger.db & ./backups/*.sqlite │  │
│  └──────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Data Synchronization Protocol

To ensure seamless offline editing on both mobile and desktop without overwriting entries, synchronization follows a **Differential Changeset Model with Tombstones**.

### 3.1 Entity Metadata Schema Changes
Every synchronizable Drift SQLite table (`accounts`, `transactions`, `budgets`, `goals`, `debts`, `recurring_rules`, `notes`) will incorporate four metadata columns:

```dart
// Drift SQLite Table Definition Mixin
mixin SyncableTable on Table {
  // UUIDv4 primary key guarantees collision-free creation across offline devices
  TextColumn get id => text()();

  // Microsecond Unix timestamp marking last modification
  Int64Column get updatedAt => int64()();

  // Soft-delete tombstone: records are flagged rather than dropped immediately
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  // Local-only sync status flag: 'synced' | 'pending_push' | 'conflict'
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};
}
```

### 3.2 Two-Phase Sync Protocol

```
Mobile App (Client)                               Docker Server (PC/NAS)
        │                                                    │
        │ 1. POST /api/v1/sync/handshake                    │
        │    Headers: Authorization: Bearer <TOKEN>          │
        │    Body: { client_id, last_sync_time, app_version }│
        ├───────────────────────────────────────────────────►│
        │    200 OK { server_time, changes_available }      │
        │◄───────────────────────────────────────────────────┤
        │                                                    │
        │ 2. POST /api/v1/sync/pull                          │
        │    Body: { since: last_sync_time }                 │
        ├───────────────────────────────────────────────────►│
        │    200 OK { server_changes: [...], server_time }   │
        │◄───────────────────────────────────────────────────┤
        │ (Client writes incoming changes to Drift SQLite)   │
        │                                                    │
        │ 3. POST /api/v1/sync/push                          │
        │    Body: { local_changes: [...] }                  │
        ├───────────────────────────────────────────────────►│
        │ (Server applies changes atomically to Host SQLite) │
        │    200 OK { acknowledged_ids: [...], new_time }    │
        │◄───────────────────────────────────────────────────┤
        │ (Client updates local sync_status to 'synced')     │
        ▼                                                    ▼
```

### 3.3 Conflict Resolution & Math Invariants
1. **Last-Write-Wins (LWW) with Microsecond Authority:** For scalar fields (e.g., editing a transaction note or category), the record with the higher `updated_at` microsecond timestamp wins.
2. **Additive Account Balances:** Account balances are not blindly synced as static numbers; instead, the server and client recompute account net totals from all active transaction records.
3. **Tombstone Garbage Collection:** Soft-deleted records (`is_deleted = true`) are retained for **90 days** so all offline devices have ample time to receive the deletion. A background worker purges tombstones older than 90 days.

---

## 4. Docker Deployment Stack

The entire backend will run from a single, self-contained `docker-compose.yml` file designed for instant setup on Windows (Docker Desktop / WSL2), macOS, or Linux home servers.

### 4.1 Sample `docker-compose.yml`

```yaml
version: '3.8'

services:
  hermanos-ledgr:
    image: ghcr.io/johncarlangelo/hermanos-ledgr-server:latest
    container_name: hermanos-ledgr-server
    restart: unless-stopped
    ports:
      - "8080:8080"
    environment:
      - PORT=8080
      - AUTH_TOKEN=your_secure_personal_token_here
      - AUTO_BACKUP_ENABLED=true
      - AUTO_BACKUP_CRON=0 3 * * * # Nightly cold backup at 3:00 AM
      - BACKUP_RETENTION_DAYS=30
    volumes:
      - ./data:/app/data
      - ./backups:/app/backups
```

### 4.2 Server Core Features
* **Zero External Dependencies:** Built as a single lightweight binary (Go or Dart Frog) with embedded SQLite and embedded web assets. Total container image size < 40 MB.
* **Persistent Host Volume:** Database lives on your host at `./data/hermanos_ledger.db` so pulling or upgrading container versions never touches your data.
* **Automatic Cold Backups:** Built-in cron creates timestamped `.sqlite` snapshots in `./backups/` every night.
* **Zero Inbound Internet Exposure Required:** Accessible strictly on your home Wi-Fi (`http://192.168.x.x:8080` or `http://hermanos.local:8080`) or via Tailscale.

---

## 5. Desktop Web Companion Experience

The Docker container serves an optional, responsive web dashboard built with Flutter Web (or lightweight Svelte/Preact) strictly adhering to the **Hermanos-Stash Design System**:

1. **Large-Screen Ledger View:** 
   - Full-width interactive transactions ledger with ergonomic keyboard shortcuts (`N` for new entry, `/` for search, arrow keys for navigation).
   - Multi-select batch editing (change category, account, or tags for 20 transactions at once).
2. **Deep Analytics & Big Screen Charts:**
   - Expanded cashflow diagrams, sankey income/expense flow visualizations, and annual category breakdown charts.
3. **Desktop Bank Import/Export Hub:**
   - Drag-and-drop CSV import from desktop online banking (BDO, BPI, GCash statements).
   - Instant export to Excel / Google Sheets formats.
4. **Instant LAN Pairing QR Code:**
   - Navigating to `Settings -> Pair Mobile Device` displays a secure QR code containing the server's local IP address and pairing token. Scanning with the mobile app connects both devices in 3 seconds.

---

## 6. Mobile App Integration (Flutter)

In the mobile app, a new dedicated settings section **"Self-Hosted Sync"** will be added:

1. **Connection Modes:**
   - **Standalone Mode (Default):** Sync is disabled; app operates completely local.
   - **Self-Hosted Mode:** Connects to the user's Docker server.
2. **Pairing Flow:**
   - Scan QR code from Web Companion or enter custom server URL (`http://192.168.1.150:8080`) and Auth Token.
   - Instant connectivity ping test with status indicator (🟢 Connected / 🟡 Connecting / 🔴 Offline).
3. **Automatic Background Sync:**
   - Automatically attempts a sync when the phone connects to the user's home Wi-Fi SSID.
   - Manual "Sync Now" button on the Settings screen and drawer.
4. **Data Isolation:**
   - If the server is unreachable or offline, the app continues operating normally without displaying disruptive error popups; dirty changes queue until the next connection.

---

## 7. Step-by-Step Self-Hosting & Deployment Guide

### Step 1: Clone or Download Docker Files
On your PC or home server, create a directory for Hermanos Ledgr:
```bash
mkdir hermanos-server && cd hermanos-server
```

Create `docker-compose.yml` and paste the configuration from §4.1.

### Step 2: Launch Container
```bash
docker-compose up -d
```
Check logs to verify startup:
```bash
docker-compose logs -f
```

### Step 3: Open Desktop Web Companion
Open your browser to:
`http://localhost:8080`

### Step 4: Pair Your Mobile Device
1. On the Web Companion, open **Settings ➔ Pair Mobile Device**.
2. A QR Code appears containing the local network URL and your pre-shared authentication token.
3. On your phone, open **Hermanos Ledgr ➔ Settings ➔ Self-Hosted Sync ➔ Scan QR Code**.
4. Both devices are instantly paired and synchronize in real-time.

---

## 8. Implementation Roadmap & Milestones

| Milestone | Key Deliverable | Status |
|---|---|---|
| **M1: Schema Migration** | Add UUIDs, `updated_at`, `is_deleted` tombstones, and `sync_status` to Drift tables | Planned |
| **M2: Sync Engine Core** | Build client-side changeset builder (`SyncService`) & conflict resolver | Planned |
| **M3: Docker Server Binary** | Lightweight Go/Dart Frog sync backend with SQLite persistence | Planned |
| **M4: Docker Compose Setup** | Packaged container, volumes, auto-backup cron, and documentation | Planned |
| **M5: QR LAN Pairing** | Mobile camera scan of server QR code for instantaneous zero-config pairing | Planned |
| **M6: Web Companion UI** | Stash-themed desktop dashboard for large-screen ledger review and imports | Planned |
| **M7: Background Wi-Fi Sync**| Automated silent sync when connected to home network | Planned |

