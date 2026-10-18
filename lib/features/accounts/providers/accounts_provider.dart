import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/features/accounts/data/account_repository_impl.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_repository.dart';

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

  AccountRepository get _repository => ref.read(accountRepositoryProvider);

  @override
  List<AccountModel> build() {
    final repo = ref.watch(accountRepositoryProvider);

    _sub?.cancel();
    _sub = repo.watchAccounts().listen((accounts) {
      state = accounts;
    });
    ref.onDispose(() => _sub?.cancel());

    return const [];
  }

  Future<void> addAccount(AccountModel newAccount) async {
    state = [...state, newAccount];
    await _repository.addAccount(newAccount);
  }

  Future<void> updateAccount(AccountModel updatedAccount) async {
    state = [
      for (final account in state)
        if (account.id == updatedAccount.id) updatedAccount else account,
    ];
    await _repository.updateAccount(updatedAccount);
  }

  void updateBalanceInMemory(String accountId, double delta) {
    state = [
      for (final account in state)
        if (account.id == accountId)
          account.copyWith(balance: account.balance + delta)
        else
          account,
    ];
  }

  Future<void> updateBalance(String accountId, double delta) async {
    updateBalanceInMemory(accountId, delta);
    await _repository.updateBalance(accountId, delta);
  }

  Future<void> deleteAccount(String accountId) async {
    state = state.where((a) => a.id != accountId).toList();
    await _repository.deleteAccount(accountId);
  }
}

final accountsProvider =
    NotifierProvider<AccountsNotifier, List<AccountModel>>(AccountsNotifier.new);

final accountByIdProvider = Provider.family<AccountModel?, String>((ref, id) {
  final accounts = ref.watch(accountsProvider);
  try {
    return accounts.firstWhere((a) => a.id == id);
  } catch (_) {
    return null;
  }
});

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
