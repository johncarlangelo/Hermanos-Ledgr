import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/features/accounts/data/account_repository_impl.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/accounts/providers/accounts_provider.dart';

void main() {
  late AppDatabase db;
  late AccountRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = AccountRepositoryImpl(
      accountsDao: db.accountsDao,
      db: db,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('AccountRepositoryImpl inserts and retrieves accounts', () async {
    const account = AccountModel(
      id: 'acc_maribank',
      name: 'MariBank Savings',
      type: AccountType.bank,
      balance: 15000.0,
      icon: Icons.account_balance_rounded,
      color: Color(0xFFFF5722),
      institution: 'MariBank',
    );

    final addResult = await repository.addAccount(account);
    expect(addResult.isSuccess, isTrue);

    final retrieved = await repository.getAccountById('acc_maribank');
    expect(retrieved, isNotNull);
    expect(retrieved!.name, 'MariBank Savings');
    expect(retrieved.balance, 15000.0);
    expect(retrieved.type, AccountType.bank);
  });

  test('AccountRepositoryImpl updates account details', () async {
    const account = AccountModel(
      id: 'acc_gcash_test',
      name: 'GCash Personal',
      type: AccountType.eWallet,
      balance: 2500.0,
      icon: Icons.wallet_rounded,
      color: Color(0xFF005CEE),
    );

    await repository.addAccount(account);

    final updated = account.copyWith(
      name: 'GCash Main',
      balance: 3200.0,
    );

    final updateResult = await repository.updateAccount(updated);
    expect(updateResult.isSuccess, isTrue);

    final result = await repository.getAccountById('acc_gcash_test');
    expect(result!.name, 'GCash Main');
    expect(result.balance, 3200.0);
  });

  test('AccountRepositoryImpl updates balance delta', () async {
    const account = AccountModel(
      id: 'acc_cash_test',
      name: 'Cash In Pocket',
      type: AccountType.cash,
      balance: 1000.0,
      icon: Icons.payments_rounded,
      color: Color(0xFF00897B),
    );

    await repository.addAccount(account);
    await repository.updateBalance('acc_cash_test', -350.0);

    final result = await repository.getAccountById('acc_cash_test');
    expect(result!.balance, 650.0);
  });

  test('AccountRepositoryImpl deletes account and cascades transactions', () async {
    const account = AccountModel(
      id: 'acc_to_delete',
      name: 'Temporary Account',
      type: AccountType.bank,
      balance: 500.0,
      icon: Icons.account_balance_rounded,
      color: Color(0xFF1E88E5),
    );

    await repository.addAccount(account);

    // Insert associated transaction
    await db.into(db.transactionsTable).insert(
      TransactionsTableCompanion.insert(
        id: 'tx_delete_test',
        title: 'Snack',
        amount: 50.0,
        type: 'expense',
        categoryId: 'food',
        categoryName: 'Food',
        categoryIconCode: 0,
        categoryColorValue: 0xFFF57C00,
        accountId: 'acc_to_delete',
        accountName: 'Temporary Account',
        date: DateTime.now(),
      ),
    );

    final deleteResult = await repository.deleteAccount('acc_to_delete');
    expect(deleteResult.isSuccess, isTrue);

    final checkAccount = await repository.getAccountById('acc_to_delete');
    expect(checkAccount, isNull);

    final remainingTxs = await (db.select(db.transactionsTable)
          ..where((t) => t.accountId.equals('acc_to_delete')))
        .get();
    expect(remainingTxs, isEmpty);
  });

  test('AccountsNotifier handles ref.invalidate (pull-to-refresh) without throwing LateInitializationError', () async {
    final container = ProviderContainer(
      overrides: [
        accountRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    // Initial read
    container.read(accountsProvider);
    await pumpEventQueue();

    // Invalidate (simulates pull-to-refresh on dashboard)
    container.invalidate(accountsProvider);
    await pumpEventQueue();

    // Re-read without error
    final accounts = container.read(accountsProvider);
    expect(accounts, isA<List<AccountModel>>());
  });
}
