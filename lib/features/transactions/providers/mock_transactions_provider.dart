import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/core/database/database_mappers.dart';
import 'package:hermanos_ledgr/core/providers/database_provider.dart';
import 'package:hermanos_ledgr/features/accounts/providers/mock_accounts_provider.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';

class TransactionsNotifier extends Notifier<List<TransactionModel>> {
  StreamSubscription? _sub;

  @override
  List<TransactionModel> build() {
    final db = ref.watch(databaseProvider);
    _sub?.cancel();
    _sub = (db.select(db.transactionsTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .watch()
        .listen((rows) {
      state = rows.map(DatabaseMappers.transactionFromDrift).toList();
    });
    ref.onDispose(() => _sub?.cancel());

    return const [];
  }

  void addTransaction(TransactionModel tx) {
    state = [tx, ...state];

    // Update account balance
    final accountsNotifier = ref.read(accountsProvider.notifier);
    if (tx.type == TransactionType.expense) {
      accountsNotifier.updateBalance(tx.accountId, -tx.amount);
    } else if (tx.type == TransactionType.income) {
      accountsNotifier.updateBalance(tx.accountId, tx.amount);
    } else if (tx.type == TransactionType.transfer) {
      accountsNotifier.updateBalance(tx.accountId, -tx.amount);
      if (tx.destinationAccountId != null) {
        accountsNotifier.updateBalance(tx.destinationAccountId!, tx.amount);
      }
    }

    // Persist to Drift SQLite
    final db = ref.read(databaseProvider);
    db.into(db.transactionsTable).insert(
      DatabaseMappers.transactionToCompanion(tx),
      mode: InsertMode.insertOrReplace,
    );
  }

  TransactionModel? deleteTransaction(String id) {
    final index = state.indexWhere((t) => t.id == id);
    if (index == -1) return null;
    final deleted = state[index];
    state = state.where((t) => t.id != id).toList();

    // Rollback balance
    final accountsNotifier = ref.read(accountsProvider.notifier);
    if (deleted.type == TransactionType.expense) {
      accountsNotifier.updateBalance(deleted.accountId, deleted.amount);
    } else if (deleted.type == TransactionType.income) {
      accountsNotifier.updateBalance(deleted.accountId, -deleted.amount);
    } else if (deleted.type == TransactionType.transfer) {
      accountsNotifier.updateBalance(deleted.accountId, deleted.amount);
      if (deleted.destinationAccountId != null) {
        accountsNotifier.updateBalance(
            deleted.destinationAccountId!, -deleted.amount);
      }
    }

    // Persist delete to Drift SQLite
    final db = ref.read(databaseProvider);
    (db.delete(db.transactionsTable)..where((t) => t.id.equals(id))).go();

    return deleted;
  }

  void restoreTransaction(TransactionModel tx) {
    final list = [...state, tx];
    list.sort((a, b) => b.date.compareTo(a.date));
    state = list;

    // Re-apply balance
    final accountsNotifier = ref.read(accountsProvider.notifier);
    if (tx.type == TransactionType.expense) {
      accountsNotifier.updateBalance(tx.accountId, -tx.amount);
    } else if (tx.type == TransactionType.income) {
      accountsNotifier.updateBalance(tx.accountId, tx.amount);
    } else if (tx.type == TransactionType.transfer) {
      accountsNotifier.updateBalance(tx.accountId, -tx.amount);
      if (tx.destinationAccountId != null) {
        accountsNotifier.updateBalance(tx.destinationAccountId!, tx.amount);
      }
    }

    // Re-insert into Drift SQLite
    final db = ref.read(databaseProvider);
    db.into(db.transactionsTable).insert(
      DatabaseMappers.transactionToCompanion(tx),
      mode: InsertMode.insertOrReplace,
    );
  }

  void clearAll() {
    state = [];
    final db = ref.read(databaseProvider);
    db.delete(db.transactionsTable).go();
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

class TransactionSearchNotifier extends Notifier<String> {
  @override
  String build() => '';
  void setSearch(String query) => state = query;
}

final transactionSearchQueryProvider =
    NotifierProvider<TransactionSearchNotifier, String>(
        TransactionSearchNotifier.new);

final filteredTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final all = ref.watch(transactionsProvider);
  final filterType = ref.watch(transactionFilterTypeProvider);
  final query = ref.watch(transactionSearchQueryProvider).toLowerCase();

  return all.where((t) {
    if (filterType != null && t.type != filterType) return false;
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
