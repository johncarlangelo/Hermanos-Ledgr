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

  test('clearAndReseed clears user data and preserves categories', () async {
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
    var txs = await db.select(db.transactionsTable).get();
    expect(txs.length, 1);

    await db.clearAndReseed();
    txs = await db.select(db.transactionsTable).get();
    expect(txs, isEmpty);

    final cats = await db.select(db.categoriesTable).get();
    expect(cats.isNotEmpty, isTrue);
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
}
