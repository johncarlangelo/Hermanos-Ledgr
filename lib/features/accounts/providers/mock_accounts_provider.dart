import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/core/database/database_mappers.dart';
import 'package:hermanos_ledgr/core/providers/database_provider.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';

/// Clean starter accounts with zero balances for initial setup.
const List<AccountModel> starterCleanAccounts = [
  AccountModel(
    id: 'acc_gcash',
    name: 'GCash',
    type: AccountType.eWallet,
    balance: 0.0,
    icon: Icons.account_balance_wallet_rounded,
    color: Color(0xFF005CEE),
    institution: 'Mynt',
    monthlyChange: 0.0,
  ),
  AccountModel(
    id: 'acc_cash',
    name: 'Cash Wallet',
    type: AccountType.cash,
    balance: 0.0,
    icon: Icons.payments_rounded,
    color: Color(0xFF00897B),
    institution: 'Cash',
    monthlyChange: 0.0,
  ),
  AccountModel(
    id: 'acc_bdo',
    name: 'BDO Savings',
    type: AccountType.bank,
    balance: 0.0,
    icon: Icons.account_balance_rounded,
    color: Color(0xFF0038A8),
    institution: 'BDO Unibank',
    monthlyChange: 0.0,
  ),
];

class AccountsNotifier extends Notifier<List<AccountModel>> {
  StreamSubscription? _sub;

  @override
  List<AccountModel> build() {
    final db = ref.watch(databaseProvider);

    _sub?.cancel();
    _sub = db.select(db.accountsTable).watch().listen((rows) async {
      if (rows.isEmpty) {
        // Auto-seed clean starter accounts with 0.0 balance if table is completely empty
        await _seedInitialAccounts(db);
      } else {
        final accounts = rows.map(DatabaseMappers.accountFromDrift).toList();
        final anyTx = await (db.select(db.transactionsTable)..limit(1)).get();
        if (anyTx.isEmpty) {
          for (final acc in accounts) {
            if (acc.balance != 0.0 && starterCleanAccounts.any((s) => s.id == acc.id)) {
              await (db.update(db.accountsTable)..where((t) => t.id.equals(acc.id))).write(
                const AccountsTableCompanion(balance: Value(0.0), monthlyChange: Value(0.0)),
              );
            }
          }
        }
        state = accounts;
      }
    });
    ref.onDispose(() => _sub?.cancel());

    return const [];
  }

  Future<void> _seedInitialAccounts(AppDatabase db) async {
    for (final acc in starterCleanAccounts) {
      await db.into(db.accountsTable).insert(
        DatabaseMappers.accountToCompanion(acc),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }

  void updateBalance(String accountId, double delta) {
    state = [
      for (final account in state)
        if (account.id == accountId)
          account.copyWith(balance: account.balance + delta)
        else
          account,
    ];

    final db = ref.read(databaseProvider);
    final match = state.where((a) => a.id == accountId);
    if (match.isNotEmpty) {
      (db.update(db.accountsTable)..where((t) => t.id.equals(accountId))).write(
        AccountsTableCompanion(balance: Value(match.first.balance)),
      );
    }
  }

  void addAccount(AccountModel newAccount) {
    state = [...state, newAccount];
    final db = ref.read(databaseProvider);
    db.into(db.accountsTable).insert(
      DatabaseMappers.accountToCompanion(newAccount),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> deleteAccount(String accountId) async {
    state = state.where((a) => a.id != accountId).toList();
    final db = ref.read(databaseProvider);
    // Purge associated transactions first to maintain database integrity
    await (db.delete(db.transactionsTable)
          ..where((t) =>
              t.accountId.equals(accountId) |
              t.destinationAccountId.equals(accountId)))
        .go();
    // Delete account record
    await (db.delete(db.accountsTable)..where((t) => t.id.equals(accountId))).go();
  }
}

final accountsProvider =
    NotifierProvider<AccountsNotifier, List<AccountModel>>(AccountsNotifier.new);

final netWorthProvider = Provider<double>((ref) {
  final accounts = ref.watch(accountsProvider);
  return accounts.fold(0.0, (sum, acc) => sum + acc.balance);
});

final totalAssetsProvider = Provider<double>((ref) {
  final accounts = ref.watch(accountsProvider);
  return accounts
      .where((acc) => acc.balance > 0)
      .fold(0.0, (sum, acc) => sum + acc.balance);
});

final totalLiabilitiesProvider = Provider<double>((ref) {
  final accounts = ref.watch(accountsProvider);
  return accounts
      .where((acc) => acc.balance < 0)
      .fold(0.0, (sum, acc) => sum + acc.balance.abs());
});
