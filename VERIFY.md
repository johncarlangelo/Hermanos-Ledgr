# Verification Checklist
## Hermanos Ledgr

> **Last Updated:** 2026-09-28
> **Status:** Pre-build (to be updated as features are implemented)

---

## How to Use This File

After completing each task or feature, run through the relevant verification section. Mark items as:
- `[x]` — Verified and passing
- `[ ]` — Not yet verified
- `[~]` — Partially working / known issues (add note)

---

## 1. Project Setup Verification

- [ ] Flutter project created with `flutter create` (Android only)
- [ ] `pubspec.yaml` has all required dependencies
- [ ] Drift code generation runs without errors
- [ ] Riverpod code generation runs without errors
- [ ] App builds and runs on Android emulator
- [ ] App builds and runs on Samsung A57 device
- [ ] Material Design 3 theme applied (light + dark)
- [ ] Inter font loads correctly from Google Fonts
- [ ] Bottom navigation bar renders with all 5 tabs
- [ ] Navigation between tabs works

---

## 2. Core Database Verification

- [ ] All tables created successfully on first launch
- [ ] Default profile created on first launch
- [ ] Default categories seeded (Philippine-relevant)
- [ ] CRUD operations work for each table:
  - [ ] Profiles
  - [ ] Accounts
  - [ ] Categories
  - [ ] Transactions
  - [ ] Budgets
  - [ ] Goals
  - [ ] Debts / Receivables
  - [ ] Debt Payments
  - [ ] Recurring Rules
  - [ ] Notes
  - [ ] Chat Messages
- [ ] Indexes created for hot columns
- [ ] Database migration strategy works (version bumps)

---

## 3. Feature Verification

### 3.1 Dashboard
- [ ] Net worth displays correctly (assets - liabilities)
- [ ] Account cards show correct balances
- [ ] Recent transactions list shows latest 5-10 items
- [ ] Quick actions (add expense, add income) work
- [ ] Numbers animate on change
- [ ] Pull-to-refresh updates data

### 3.2 Transaction Management
- [ ] Add expense via bottom sheet
- [ ] Add income via bottom sheet
- [ ] Add transfer between accounts
- [ ] Amount keypad works correctly
- [ ] Category picker shows all categories with icons
- [ ] Account selector shows all accounts
- [ ] Date picker defaults to today
- [ ] Note field accepts text
- [ ] Image attachment from camera works
- [ ] Image attachment from gallery works
- [ ] Transaction saves to database
- [ ] Account balance updates after transaction
- [ ] Transaction list shows all transactions
- [ ] Transaction list grouped by date
- [ ] Filter by date range works
- [ ] Filter by category works
- [ ] Filter by account works
- [ ] Search transactions by note works
- [ ] Edit transaction works
- [ ] Delete transaction works (with confirmation)
- [ ] Swipe-to-edit works
- [ ] Swipe-to-delete works

### 3.3 Account Management
- [ ] Create account (cash, bank, ewallet, credit card)
- [ ] Edit account
- [ ] Archive account (soft delete)
- [ ] Account detail shows transaction history
- [ ] Account balance matches sum of initial + all transactions
- [ ] Bank templates pre-fill account info (BDO, BPI, GCash, Maya, etc.)
- [ ] Transfer between accounts updates both balances

### 3.4 Budgets
- [ ] Create per-category budget with monthly amount
- [ ] Progress bar shows spent vs. budget
- [ ] Overspend warning at 75%, 90%, 100%
- [ ] Color coding: green < 75%, orange 75-100%, red > 100%
- [ ] Remaining amount and days left displayed
- [ ] Monthly budget chart shows spending trends
- [ ] Budget resets correctly at month boundary

### 3.5 Savings Goals
- [ ] Create goal with name, target amount, target date
- [ ] Progress ring/bar shows current vs. target
- [ ] Monthly contribution needed is calculated
- [ ] Add contribution updates progress
- [ ] Goal completion state works
- [ ] Multiple goals displayed correctly

### 3.6 Cashflow Forecast
- [ ] Timeline shows upcoming recurring payments
- [ ] Timeline shows expected income
- [ ] Net cashflow calculated for upcoming period
- [ ] Past-due recurring items highlighted
- [ ] Forecast accounts for manual one-off entries

### 3.7 Recurring Transactions
- [ ] Create recurring rule (daily, weekly, biweekly, monthly, yearly)
- [ ] Auto-log triggers on schedule
- [ ] Next due date updates after auto-log
- [ ] Edit recurring rule
- [ ] Pause/resume recurring rule
- [ ] Delete recurring rule

### 3.8 Debt Tracking
- [ ] Create debt (loan, credit card balance)
- [ ] Create receivable (money lent out)
- [ ] Log payment against debt
- [ ] Remaining balance updates correctly
- [ ] Payoff progress bar works
- [ ] Mark as settled
- [ ] Bill split calculator works

### 3.9 AI Assistant
- [ ] Chat interface renders correctly
- [ ] LLM model downloads on first use (with progress)
- [ ] Model loads into memory when AI tab opened
- [ ] Natural language input parses correctly:
  - [ ] "Starbucks 250" → expense, ₱250, Food category
  - [ ] "Salary 30k" → income, ₱30,000
  - [ ] "Paid electric 2500 from BDO" → expense, ₱2,500, Utilities, BDO account
  - [ ] "Transfer 5k from GCash to cash" → transfer
  - [ ] "Lunch 150 yesterday" → correct date
- [ ] Transaction action card shows parsed result
- [ ] Confirm button saves transaction
- [ ] Edit button opens edit form pre-filled
- [ ] Undo button cancels
- [ ] Voice input works (speech-to-text → LLM)
- [ ] Daily summary generates correctly
- [ ] Inference runs in background (UI stays responsive)
- [ ] LLM responds in < 5 seconds on Samsung A57
- [ ] Chat history persists across sessions

### 3.10 Receipt Scanner
- [ ] Camera opens for scanning
- [ ] Gallery picker works
- [ ] OCR extracts amount from receipt
- [ ] OCR extracts merchant name
- [ ] Pre-fills transaction form with OCR results
- [ ] User can correct OCR mistakes before saving

### 3.11 Data & Backup
- [ ] Auto-backup runs daily (on app open)
- [ ] Auto-backup saves to device storage
- [ ] Last 7 backups retained, older deleted
- [ ] Manual JSON export works
- [ ] CSV export works (transactions only)
- [ ] JSON import works (full restore)
- [ ] Import on fresh install works (phone migration)
- [ ] Import validates schema version
- [ ] Share sheet works for exporting files

### 3.12 Settings & Profiles
- [ ] Theme toggle (light/dark/system)
- [ ] AMOLED black mode toggle
- [ ] Create profile
- [ ] Switch between profiles
- [ ] Delete profile (with confirmation)
- [ ] LLM model management (download, delete, switch)
- [ ] About / version info

---

## 4. UI/UX Verification

- [ ] Dark mode renders correctly across all screens
- [ ] Light mode renders correctly across all screens
- [ ] AMOLED black mode renders correctly
- [ ] All text is readable (contrast ≥ 4.5:1)
- [ ] Touch targets ≥ 48×48dp
- [ ] Screen transitions are smooth (no janky frames)
- [ ] Bottom sheet animations work smoothly
- [ ] Card tap feedback (ripple) works
- [ ] Empty states shown when no data exists
- [ ] Loading indicators shown during async operations
- [ ] Error messages are user-friendly (no stack traces)
- [ ] Currency formatting consistent across all screens (₱)
- [ ] Numbers are comma-separated for readability
- [ ] Date formatting consistent (localized)
- [ ] Category icons and colors display correctly

---

## 5. Performance Verification

- [ ] App cold start < 2 seconds on Samsung A57
- [ ] Tab switching < 200ms
- [ ] Transaction list scrolling smooth at 60fps with 1000+ items
- [ ] LLM model load time < 10 seconds
- [ ] LLM inference time < 5 seconds for simple input
- [ ] No memory leaks during extended use
- [ ] LLM memory unloaded when leaving AI tab
- [ ] Receipt image compression reduces file size
- [ ] Database queries for transaction list < 100ms
- [ ] Auto-backup completes in < 5 seconds for typical dataset

---

## 6. Data Integrity Verification

- [ ] Account balances always consistent with transaction history
- [ ] Deleting a transaction correctly adjusts account balance
- [ ] Editing a transaction correctly adjusts account balance
- [ ] Transfer always updates both accounts
- [ ] Budget spent amounts match actual transactions
- [ ] Goal progress matches contribution history
- [ ] Debt remaining matches payment history
- [ ] Backup file can be re-imported to produce identical state
- [ ] No data loss after app force-close during transaction save
