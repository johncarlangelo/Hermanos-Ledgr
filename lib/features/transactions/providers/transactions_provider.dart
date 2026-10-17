import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/features/accounts/providers/accounts_provider.dart';
import 'package:hermanos_ledgr/features/transactions/data/transaction_repository_impl.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_repository.dart';

/// Notifier managing reactive transaction list backed by Drift SQLite [TransactionRepository].
class TransactionsNotifier extends Notifier<List<TransactionModel>> {
  StreamSubscription? _sub;

  TransactionRepository get _repository => ref.read(transactionRepositoryProvider);

  @override
  List<TransactionModel> build() {
    final repo = ref.watch(transactionRepositoryProvider);

    _sub?.cancel();
    _sub = repo.watchAllTransactions().listen((transactions) {
      state = transactions;
    });

    ref.onDispose(() => _sub?.cancel());
    return const [];
  }

  void addTransaction(TransactionModel tx) {
    // Optimistic UI state update
    state = [tx, ...state];

    // Optimistic balance update
    final accountsNotifier = ref.read(accountsProvider.notifier);
    if (tx.type == TransactionType.expense) {
      accountsNotifier.updateBalanceInMemory(tx.accountId, -tx.amount);
    } else if (tx.type == TransactionType.income) {
      accountsNotifier.updateBalanceInMemory(tx.accountId, tx.amount);
    } else if (tx.type == TransactionType.transfer) {
      accountsNotifier.updateBalanceInMemory(tx.accountId, -tx.amount);
      if (tx.destinationAccountId != null) {
        accountsNotifier.updateBalanceInMemory(tx.destinationAccountId!, tx.amount);
      }
    }

    _repository.addTransaction(tx);
  }

  TransactionModel? deleteTransaction(String id) {
    final index = state.indexWhere((t) => t.id == id);
    if (index == -1) return null;
    final deleted = state[index];

    // Optimistic UI update
    state = state.where((t) => t.id != id).toList();

    // Rollback balance in memory
    final accountsNotifier = ref.read(accountsProvider.notifier);
    if (deleted.type == TransactionType.expense) {
      accountsNotifier.updateBalanceInMemory(deleted.accountId, deleted.amount);
    } else if (deleted.type == TransactionType.income) {
      accountsNotifier.updateBalanceInMemory(deleted.accountId, -deleted.amount);
    } else if (deleted.type == TransactionType.transfer) {
      accountsNotifier.updateBalanceInMemory(deleted.accountId, deleted.amount);
      if (deleted.destinationAccountId != null) {
        accountsNotifier.updateBalanceInMemory(
            deleted.destinationAccountId!, -deleted.amount);
      }
    }

    _repository.deleteTransaction(deleted);
    return deleted;
  }

  void restoreTransaction(TransactionModel tx) {
    final list = [...state, tx];
    list.sort((a, b) => b.date.compareTo(a.date));
    state = list;

    // Re-apply balance in memory
    final accountsNotifier = ref.read(accountsProvider.notifier);
    if (tx.type == TransactionType.expense) {
      accountsNotifier.updateBalanceInMemory(tx.accountId, -tx.amount);
    } else if (tx.type == TransactionType.income) {
      accountsNotifier.updateBalanceInMemory(tx.accountId, tx.amount);
    } else if (tx.type == TransactionType.transfer) {
      accountsNotifier.updateBalanceInMemory(tx.accountId, -tx.amount);
      if (tx.destinationAccountId != null) {
        accountsNotifier.updateBalanceInMemory(
            tx.destinationAccountId!, tx.amount);
      }
    }

    _repository.restoreTransaction(tx);
  }

  void updateTransaction(TransactionModel updatedTx) {
    final oldIndex = state.indexWhere((t) => t.id == updatedTx.id);
    if (oldIndex == -1) return;
    final oldTx = state[oldIndex];

    state = [
      for (final t in state)
        if (t.id == updatedTx.id) updatedTx else t
    ];

    // Revert old transaction and apply new transaction in memory
    final accountsNotifier = ref.read(accountsProvider.notifier);
    if (oldTx.type == TransactionType.expense) {
      accountsNotifier.updateBalanceInMemory(oldTx.accountId, oldTx.amount);
    } else if (oldTx.type == TransactionType.income) {
      accountsNotifier.updateBalanceInMemory(oldTx.accountId, -oldTx.amount);
    } else if (oldTx.type == TransactionType.transfer) {
      accountsNotifier.updateBalanceInMemory(oldTx.accountId, oldTx.amount);
      if (oldTx.destinationAccountId != null) {
        accountsNotifier.updateBalanceInMemory(
            oldTx.destinationAccountId!, -oldTx.amount);
      }
    }

    if (updatedTx.type == TransactionType.expense) {
      accountsNotifier.updateBalanceInMemory(updatedTx.accountId, -updatedTx.amount);
    } else if (updatedTx.type == TransactionType.income) {
      accountsNotifier.updateBalanceInMemory(updatedTx.accountId, updatedTx.amount);
    } else if (updatedTx.type == TransactionType.transfer) {
      accountsNotifier.updateBalanceInMemory(updatedTx.accountId, -updatedTx.amount);
      if (updatedTx.destinationAccountId != null) {
        accountsNotifier.updateBalanceInMemory(
            updatedTx.destinationAccountId!, updatedTx.amount);
      }
    }

    _repository.updateTransaction(oldTx: oldTx, newTx: updatedTx);
  }

  void clearAll() {
    state = [];
    _repository.clearAllTransactions();
  }
}

final transactionsProvider =
    NotifierProvider<TransactionsNotifier, List<TransactionModel>>(
        TransactionsNotifier.new);

// Filter Notifiers
class TransactionFilterNotifier extends Notifier<TransactionType?> {
  @override
  TransactionType? build() => null;
  void setFilter(TransactionType? filter) => state = filter;
}

final transactionFilterTypeProvider =
    NotifierProvider<TransactionFilterNotifier, TransactionType?>(
        TransactionFilterNotifier.new);

class TransactionAccountFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setFilter(String? accountId) => state = accountId;
}

final transactionAccountFilterProvider =
    NotifierProvider<TransactionAccountFilterNotifier, String?>(
        TransactionAccountFilterNotifier.new);

class TransactionSearchNotifier extends Notifier<String> {
  @override
  String build() => '';
  void setSearch(String query) => state = query;
}

final transactionSearchQueryProvider =
    NotifierProvider<TransactionSearchNotifier, String>(
        TransactionSearchNotifier.new);

/// Filtered transactions provider matching active type, account, and search criteria
final filteredTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final all = ref.watch(transactionsProvider);
  final filterType = ref.watch(transactionFilterTypeProvider);
  final accountFilter = ref.watch(transactionAccountFilterProvider);
  final query = ref.watch(transactionSearchQueryProvider).toLowerCase();

  return all.where((t) {
    if (filterType != null && t.type != filterType) return false;
    if (accountFilter != null &&
        t.accountId != accountFilter &&
        t.destinationAccountId != accountFilter) {
      return false;
    }
    if (query.isNotEmpty) {
      final matchesTitle = t.title.toLowerCase().contains(query);
      final matchesNote = t.note?.toLowerCase().contains(query) ?? false;
      final matchesCat = t.categoryName.toLowerCase().contains(query);
      final matchesAccount = t.accountName.toLowerCase().contains(query);
      if (!matchesTitle && !matchesNote && !matchesCat && !matchesAccount) {
        return false;
      }
    }
    return true;
  }).toList();
});
