import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/core/providers/database_provider.dart';
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

  test('Database seeds default accounts, transactions, and categories on creation', () async {
    final accounts = await db.select(db.accountsTable).get();
    expect(accounts.length, 5);

    final transactions = await db.select(db.transactionsTable).get();
    expect(transactions.length, 7);

    final categories = await db.select(db.categoriesTable).get();
    expect(categories.isNotEmpty, isTrue);

    final budgets = await db.select(db.budgetsTable).get();
    expect(budgets.length, 5);
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

  test('clearAndReseed resets tables back to defaults', () async {
    await (db.delete(db.transactionsTable)).go();
    var txs = await db.select(db.transactionsTable).get();
    expect(txs, isEmpty);

    await db.clearAndReseed();
    txs = await db.select(db.transactionsTable).get();
    expect(txs.length, 7);
  });

  test('TransactionsNotifier persists to SQLite and reactively updates Accounts & Budgets', () async {
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
    );
    addTearDown(container.dispose);

    // Initial check: 7 transactions
    final initialTxs = container.read(transactionsProvider);
    expect(initialTxs.length, 7);

    // Initial GCash balance: 14,850.50
    final initialAccounts = container.read(accountsProvider);
    final gcash = initialAccounts.firstWhere((a) => a.id == 'acc_gcash');
    expect(gcash.balance, 14850.50);

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
    expect(updatedGcash.balance, 14850.50 - 190.0);

    // Verify persisted directly into SQLite table
    final dbRows = await (db.select(db.transactionsTable)
          ..where((t) => t.id.equals('tx_coffee')))
        .get();
    expect(dbRows.length, 1);
    expect(dbRows.first.title, 'Iced Spanish Latte');
    expect(dbRows.first.amount, 190.0);

    // Verify account balance persisted in SQLite
    final dbAccount = await (db.select(db.accountsTable)
          ..where((t) => t.id.equals('acc_gcash')))
        .getSingle();
    expect(dbAccount.balance, 14850.50 - 190.0);

    // Delete transaction and verify rollback in SQLite
    container.read(transactionsProvider.notifier).deleteTransaction('tx_coffee');
    final dbRowsAfterDelete = await (db.select(db.transactionsTable)
          ..where((t) => t.id.equals('tx_coffee')))
        .get();
    expect(dbRowsAfterDelete, isEmpty);

    final dbAccountAfterRollback = await (db.select(db.accountsTable)
          ..where((t) => t.id.equals('acc_gcash')))
        .getSingle();
    expect(dbAccountAfterRollback.balance, 14850.50);
  });
}
