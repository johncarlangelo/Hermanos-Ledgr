# Optional Self-Hosted Sync & Web Companion Architecture Plan
## Hermanos Ledgr (Docker-Powered Local-First Synchronization)

> **Status:** Planned / Architecture Blueprint (Post-v1 Roadmap)  
> **Inspiration:** [openGym](https://github.com/DuarteSantos8/openGym) (Hybrid Local-Only or Self-Hosted Docker Sync)  
> **Target Deployment:** Local PC / Home Server / NAS / Raspberry Pi via `docker-compose`  
> **Companion Tasks:** `TASKS.md` (Standalone / Future Capabilities: Optional Self-Hosted Sync)

---

## 1. Executive Summary & Philosophy

Hermanos Ledgr was founded on the strict principle of **Zero-Cloud Privacy**: your financial data should never live on a third party's servers, require a monthly subscription, or depend on an internet connection to work.

However, many power users (as seen in apps like [openGym](https://github.com/DuarteSantos8/openGym)) appreciate having an **optional, self-hosted companion** that allows them to:
1. **View and manage transactions on their desktop PC** with a large monitor and physical keyboard.
2. **Seamlessly synchronize data between their mobile phone and PC** without exposing anything to third-party cloud vendors.
3. **Keep automated cold backups** of their ledger on their home server/NAS.

### Guiding Principles:
* **Mobile-First & 100% Standalone by Default:** The mobile app will never require the server. If the server is turned off, unreachable, or never deployed, the app functions with 100% of its offline capabilities untouched.
* **Opt-In Self-Hosting:** Running the Docker container is completely optional.
* **Zero Third-Party Cloud:** Sync occurs directly over Local Area Network (LAN / Wi-Fi) or private mesh VPNs (Tailscale / WireGuard).
* **Conflict-Free Differential Sync:** Offline mutations queue locally and synchronize deterministically when the device reconnects to the home network.

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
│                                    │  (UUIDs, UpdatedAt,     │         │
│                                    │   Tombstone Deletes)    │         │
│                                    └────────────┬────────────┘         │
│                                                 │                      │
│                                    ┌────────────▼────────────┐         │
│                                    │   Local Sync Service    │         │
│                                    │   (Outbox / Push / Pull)│         │
│                                    └────────────┬────────────┘         │
└─────────────────────────────────────────────────┼──────────────────────┘
                                                  │
                 Local Wi-Fi / LAN (mDNS)         │
                 or Private Tailscale VPN         │ HTTP/2 + JSON (or Protobuf)
                                                  │ Bearer Token Auth
                                                  ▼
┌────────────────────────────────────────────────────────────────────────┐
│               PC / HOME SERVER (DOCKER CONTAINER)                      │
│                                                                        │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                    DOCKER CONTAINER: hermanos-sync               │  │
│  │                                                                  │  │
│  │  ┌──────────────────────┐             ┌───────────────────────┐  │  │
│  │  │   Lightweight API    │ ◄─────────► │   Web Companion UI    │  │  │
│  │  │   (Go / Dart Frog)   │             │   (Stash M3 Dark)     │  │  │
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
│  │ HOST FILE SYSTEM: ./data/hermanos_ledger.db & daily auto-backups │  │
│  └──────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Data Synchronization Protocol

To ensure seamless offline editing on mobile and desktop without overwriting entries, synchronization follows a **Differential Changeset Model with Tombstones**.

### 3.1 Entity Metadata Schema Changes
Every synchronizable Drift SQLite table (`accounts`, `transactions`, `budgets`, `goals`, `debts`, `recurring_rules`, `notes`) will incorporate three metadata columns:
1. `id` (`TEXT PRIMARY KEY`): Migrated to UUIDv4 to ensure conflict-free ID generation across independent devices.
2. `updated_at` (`INTEGER NOT NULL`): Microsecond timestamp marking when the record was created or modified.
3. `is_deleted` (`BOOLEAN NOT NULL DEFAULT 0`): Soft-delete tombstone. Records are never deleted immediately from SQLite; deleting an item sets `is_deleted = 1` so the deletion propagates to peer devices. A garbage collection worker purges tombstones older than 90 days.
4. `sync_status` (`TEXT NOT NULL DEFAULT 'synced'`): Local-only flag (`synced`, `pending_push`, `conflict`) to rapidly filter dirty records that must be pushed to the server.

### 3.2 Two-Phase Sync Protocol

```
Mobile App                                       Docker Server
    │                                                  │
    │ 1. POST /api/v1/sync/handshake                  │
    │    { client_id, last_sync_time, app_version }    │
    ├─────────────────────────────────────────────────►│
    │    200 OK { server_time, changes_available }    │
    │◄─────────────────────────────────────────────────┤
    │                                                  │
    │ 2. POST /api/v1/sync/pull                        │
    │    { since: last_sync_time }                     │
    ├─────────────────────────────────────────────────►│
    │    200 OK { server_changes: [...], server_time } │
    │◄─────────────────────────────────────────────────┤
    │ (App applies incoming server changes into Drift) │
    │                                                  │
    │ 3. POST /api/v1/sync/push                        │
    │    { local_changes: [...] }                      │
    ├─────────────────────────────────────────────────►│
    │ (Server commits client changes & updates time)   │
    │    200 OK { acknowledged_ids: [...], new_time }  │
    │◄─────────────────────────────────────────────────┤
    │ (App updates local sync_status to 'synced')      │
    ▼                                                  ▼
```

### 3.3 Conflict Resolution Strategy
* **Last-Write-Wins (LWW) with Timestamp Authority:** For scalar fields (e.g., editing a transaction note or category), the record with the higher `updated_at` microsecond timestamp wins.
* **Additive Balance Recomputation:** Account balances are not blindly overwritten as static numbers; instead, the server and client recompute account net totals from all active transaction records to avoid race conditions.

---

## 4. Docker Deployment Stack

The entire backend will run from a single, self-contained `docker-compose.yml` file designed for instant setup on Windows, macOS, or Linux.

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
      - AUTO_BACKUP_CRON=0 3 * * * # Daily at 3 AM
    volumes:
      - ./data:/app/data
      - ./backups:/app/backups
```

### 4.2 Server Core Features
* **Zero External Dependencies:** Built as a single lightweight binary (Go or Dart Frog) with embedded SQLite and embedded web assets. Total container size < 40 MB.
* **Persistent Host Volume:** Database lives on your host at `./data/hermanos_ledger.db` so upgrading the container never touches your data.
* **Automatic Cold Backups:** Built-in cron creates timestamped `.sqlite` and `.json` dumps in `./backups/` every night.
* **No Inbound Internet Exposure Required:** Accessible strictly on your home Wi-Fi (`http://192.168.x.x:8080` or `http://[hostname].local:8080`) or via Tailscale.

---

## 5. Web Companion Experience (Desktop PC)

The Docker container will serve an optional, responsive web dashboard built with Flutter Web (or lightweight Svelte/Preact) strictly adhering to the **Hermanos-Stash Design System**:

1. **Large-Screen Ledger View:** 
   - Full-width interactive transactions ledger with keyboard shortcuts (`N` for new entry, `/` for search, arrow keys for navigation).
   - Multi-select batch editing (change category, account, or tags for 20 transactions at once).
2. **Deep Analytics & Big Screen Charts:**
   - Expanded cashflow diagrams, sankey income/expense flow visualizations, and annual category breakdown charts.
3. **Data Import/Export Hub:**
   - Drag-and-drop CSV import from desktop banks (BDO, BPI, GCash statements).
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

## 7. Implementation Roadmap & Milestones

| Milestone | Key Deliverable | Status |
|---|---|---|
| **M1: Schema Migration** | Add UUIDs, `updated_at`, `is_deleted` tombstones, and `sync_status` to Drift tables | Planned |
| **M2: Sync Engine Core** | Build client-side changeset builder (`SyncService`) & conflict resolver | Planned |
| **M3: Docker Server Binary** | Lightweight Go/Dart Frog sync backend with SQLite persistence | Planned |
| **M4: Docker Compose Setup** | Packaged container, volumes, auto-backup cron, and documentation | Planned |
| **M5: QR LAN Pairing** | Mobile camera scan of server QR code for instantaneous zero-config pairing | Planned |
| **M6: Web Companion UI** | Stash-themed desktop dashboard for large-screen ledger review and imports | Planned |
| **M7: Background Wi-Fi Sync**| Automated silent sync when connected to home network | Planned |
