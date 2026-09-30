import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/core/database/database_mappers.dart';
import 'package:hermanos_ledgr/core/providers/database_provider.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';

const List<AccountModel> _defaultAccounts = [
  AccountModel(
    id: 'acc_gcash',
    name: 'GCash',
    type: AccountType.eWallet,
    balance: 14850.50,
    icon: Icons.account_balance_wallet_rounded,
    color: Color(0xFF005CEE), // GCash Blue
    institution: 'Mynt',
    monthlyChange: 1200.0,
  ),
  AccountModel(
    id: 'acc_bdo',
    name: 'BDO Savings',
    type: AccountType.bank,
    balance: 85420.00,
    icon: Icons.account_balance_rounded,
    color: Color(0xFF0038A8), // BDO Blue
    institution: 'BDO Unibank',
    monthlyChange: 15000.0,
  ),
  AccountModel(
    id: 'acc_cash',
    name: 'Cash Wallet',
    type: AccountType.cash,
    balance: 4350.00,
    icon: Icons.payments_rounded,
    color: Color(0xFF00897B),
    institution: 'Cash',
    monthlyChange: -450.0,
  ),
  AccountModel(
    id: 'acc_maya',
    name: 'Maya',
    type: AccountType.eWallet,
    balance: 12600.25,
    icon: Icons.wallet_rounded,
    color: Color(0xFF00D166), // Maya Green
    institution: 'Maya Philippines',
    monthlyChange: 800.0,
  ),
  AccountModel(
    id: 'acc_bpi_cc',
    name: 'BPI Platinum Card',
    type: AccountType.creditCard,
    balance: -8450.00,
    icon: Icons.credit_card_rounded,
    color: Color(0xFFB71C1C), // BPI Red
    institution: 'Bank of the Philippine Islands',
    monthlyChange: -2100.0,
  ),
];

class AccountsNotifier extends Notifier<List<AccountModel>> {
  StreamSubscription? _sub;

  @override
  List<AccountModel> build() {
    final db = ref.watch(databaseProvider);
    _sub?.cancel();
    _sub = db.select(db.accountsTable).watch().listen((rows) {
      if (rows.isNotEmpty) {
        state = rows.map(DatabaseMappers.accountFromDrift).toList();
      }
    });
    ref.onDispose(() => _sub?.cancel());

    return _defaultAccounts;
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
