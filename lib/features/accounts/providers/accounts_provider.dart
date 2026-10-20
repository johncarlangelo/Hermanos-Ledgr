import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/core/constants/account_defaults.dart';
import 'package:hermanos_ledgr/features/accounts/data/account_repository_impl.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_repository.dart';

/// Clean starter accounts with zero balances for initial setup.
const List<AccountModel> starterCleanAccounts = AccountDefaults.starterCleanAccounts;

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
