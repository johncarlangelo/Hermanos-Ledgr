import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/core/providers/database_provider.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/accounts/providers/mock_accounts_provider.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';
import 'package:hermanos_ledgr/features/transactions/providers/mock_transactions_provider.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('Database seeds default categories on creation with zero mock data', () async {
    final categories = await db.select(db.categoriesTable).get();
    expect(categories.isNotEmpty, isTrue);

    final transactions = await db.select(db.transactionsTable).get();
    expect(transactions, isEmpty);

    final budgets = await db.select(db.budgetsTable).get();
    expect(budgets, isEmpty);
  });

  test('Can insert, query, and delete transactions in SQLite', () async {
    final now = DateTime.now();
    await db.into(db.transactionsTable).insert(
      TransactionsTableCompanion.insert(
        id: 'test_tx_1',
        title: 'Coffee at Dunkin',
        amount: 120.0,
        type: 'expense',
        categoryId: 'food',
        categoryName: 'Food & Dining',
        categoryIconCode: 0,
        categoryColorValue: 0xFFF57C00,
        accountId: 'acc_gcash',
        accountName: 'GCash',
        date: now,
      ),
    );

    final txs = await (db.select(db.transactionsTable)..where((t) => t.id.equals('test_tx_1'))).get();
    expect(txs.length, 1);
    expect(txs.first.title, 'Coffee at Dunkin');
    expect(txs.first.amount, 120.0);

    // Delete
    await (db.delete(db.transactionsTable)..where((t) => t.id.equals('test_tx_1'))).go();
    final remaining = await (db.select(db.transactionsTable)..where((t) => t.id.equals('test_tx_1'))).get();
    expect(remaining, isEmpty);
  });

  test('clearAndReseed clears user data, preserves categories, and reseeds starter accounts', () async {
    final now = DateTime.now();
    await db.into(db.transactionsTable).insert(
      TransactionsTableCompanion.insert(
        id: 'temp_tx',
        title: 'Snack',
        amount: 50.0,
        type: 'expense',
        categoryId: 'food',
        categoryName: 'Food & Dining',
        categoryIconCode: 0,
        categoryColorValue: 0xFFF57C00,
        accountId: 'acc_cash',
        accountName: 'Cash',
        date: now,
      ),
    );
    await db.into(db.notesTable).insert(
      NotesTableCompanion.insert(
        content: 'Apples, Milk',
        createdAt: now,
        updatedAt: now,
      ),
    );

    var txs = await db.select(db.transactionsTable).get();
    expect(txs.length, 1);
    var notes = await db.select(db.notesTable).get();
    expect(notes.length, 1);

    await db.clearAndReseed();
    txs = await db.select(db.transactionsTable).get();
    expect(txs, isEmpty);
    notes = await db.select(db.notesTable).get();
    expect(notes, isEmpty);

    final cats = await db.select(db.categoriesTable).get();
    expect(cats.isNotEmpty, isTrue);

    final accounts = await db.select(db.accountsTable).get();
    expect(accounts.length, 3);
  });

  test('TransactionsNotifier persists to SQLite and reactively updates Accounts', () async {
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
    );
    addTearDown(container.dispose);

    // Initial check: 0 transactions (zero mock data)
    final initialTxs = container.read(transactionsProvider);
    expect(initialTxs, isEmpty);

    // Setup an account with balance 1000.0
    container.read(accountsProvider.notifier).addAccount(
      const AccountModel(
        id: 'acc_gcash',
        name: 'GCash',
        type: AccountType.eWallet,
        balance: 1000.0,
        icon: Icons.account_balance_wallet_rounded,
        color: Color(0xFF005CEE),
        institution: 'Mynt',
        monthlyChange: 0.0,
      ),
    );

    // Add a new transaction via notifier
    final newTx = TransactionModel(
      id: 'tx_coffee',
      title: 'Iced Spanish Latte',
      amount: 190.0,
      type: TransactionType.expense,
      categoryId: 'food',
      categoryName: 'Food & Dining',
      categoryIcon: Icons.local_cafe_rounded,
      categoryColor: const Color(0xFFF57C00),
      accountId: 'acc_gcash',
      accountName: 'GCash',
      date: DateTime.now(),
      note: 'Afternoon pick-me-up',
    );

    container.read(transactionsProvider.notifier).addTransaction(newTx);

    // Verify in-memory state updated
    expect(container.read(transactionsProvider).first.id, 'tx_coffee');
    final updatedGcash = container
        .read(accountsProvider)
        .firstWhere((a) => a.id == 'acc_gcash');
    expect(updatedGcash.balance, 1000.0 - 190.0);

    // Verify persisted directly into SQLite table
    final dbRows = await (db.select(db.transactionsTable)
          ..where((t) => t.id.equals('tx_coffee')))
        .get();
    expect(dbRows.length, 1);
    expect(dbRows.first.title, 'Iced Spanish Latte');
    expect(dbRows.first.amount, 190.0);
  });

  test('DAOs perform queries and operations correctly', () async {
    // AccountsDao
    await db.accountsDao.insertOrUpdateAccount(
      const AccountsTableCompanion(
        id: Value('acc_test_bpi'),
        name: Value('BPI Express'),
        type: Value('bank'),
        balance: Value(5000.0),
        iconCode: Value(0),
        colorValue: Value(0xFFB71C1C),
        institution: Value('BPI'),
      ),
    );
    final acc = await db.accountsDao.getAccountById('acc_test_bpi');
    expect(acc, isNotNull);
    expect(acc!.balance, 5000.0);

    await db.accountsDao.updateBalance('acc_test_bpi', -500.0);
    final updatedAcc = await db.accountsDao.getAccountById('acc_test_bpi');
    expect(updatedAcc!.balance, 4500.0);

    // GoalsDao
    await db.goalsDao.insertOrUpdateGoal(
      const GoalsTableCompanion(
        id: Value('goal_emergency'),
        name: Value('Emergency Fund'),
        targetAmount: Value(100000.0),
        currentAmount: Value(20000.0),
      ),
    );
    final goal = await db.goalsDao.getGoalById('goal_emergency');
    expect(goal, isNotNull);
    expect(goal!.currentAmount, 20000.0);

    await db.goalsDao.addContribution('goal_emergency', 10000.0);
    final updatedGoal = await db.goalsDao.getGoalById('goal_emergency');
    expect(updatedGoal!.currentAmount, 30000.0);
    expect(updatedGoal.isCompleted, isFalse);
  });

  test('Account initial balance is strictly preserved across beforeOpen lifecycle', () async {
    // Insert an account with an initial balance and ZERO transactions
    await db.accountsDao.insertOrUpdateAccount(
      const AccountsTableCompanion(
        id: Value('acc_persisted'),
        name: Value('MariBank Savings'),
        type: Value('bank'),
        balance: Value(7500.0),
        iconCode: Value(0),
        colorValue: Value(0xFFE91E63),
        institution: Value('MariBank'),
      ),
    );

    // Run beforeOpen (simulating app restart)
    await db.migration.beforeOpen?.call(const OpeningDetails(null, 1));

    // Verify balance is STILL 7500.0 (NOT reset to 0.0)
    final acc = await db.accountsDao.getAccountById('acc_persisted');
    expect(acc, isNotNull);
    expect(acc!.balance, equals(7500.0));
  });

  test('ChatDao persists messages and safely prunes history beyond 50 messages to avoid bloat', () async {
    final now = DateTime.now();

    // Insert 55 messages sequentially
    for (int i = 1; i <= 55; i++) {
      await db.chatDao.insertMessage(
        ChatMessagesTableCompanion.insert(
          id: 'msg_$i',
          content: 'Message #$i',
          isUser: i % 2 == 1,
          timestamp: now.add(Duration(seconds: i)),
        ),
      );
    }

    // Should only keep the most recent 50 messages (55 - 50 = messages 1..5 pruned)
    final allInDb = await (db.select(db.chatMessagesTable)..orderBy([(t) => OrderingTerm.asc(t.timestamp)])).get();
    expect(allInDb.length, 50);

    // Oldest surviving message should be msg_6
    expect(allInDb.first.id, 'msg_6');
    // Newest message should be msg_55
    expect(allInDb.last.id, 'msg_55');

    // getAllMessages returns chronological order (oldest to newest among surviving)
    final retrieved = await db.chatDao.getAllMessages(limit: 50);
    expect(retrieved.length, 50);
    expect(retrieved.first.id, 'msg_6');
    expect(retrieved.last.id, 'msg_55');
  });
}
