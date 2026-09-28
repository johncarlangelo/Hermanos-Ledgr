import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/features/accounts/providers/mock_accounts_provider.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';

class TransactionsNotifier extends Notifier<List<TransactionModel>> {
  @override
  List<TransactionModel> build() {
    return [
      TransactionModel(
        id: 'tx_1',
        title: 'Jollibee Chickenjoy Meal',
        amount: 285.00,
        type: TransactionType.expense,
        categoryId: 'food',
        categoryName: 'Food & Dining',
        categoryIcon: Icons.restaurant_rounded,
        categoryColor: const Color(0xFFF57C00),
        accountId: 'acc_gcash',
        accountName: 'GCash',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        note: 'Lunch with colleagues',
      ),
      TransactionModel(
        id: 'tx_2',
        title: 'Puregold Supermarket',
        amount: 2450.00,
        type: TransactionType.expense,
        categoryId: 'groceries',
        categoryName: 'Groceries',
        categoryIcon: Icons.shopping_cart_rounded,
        categoryColor: const Color(0xFF43A047),
        accountId: 'acc_bdo',
        accountName: 'BDO Savings',
        date: DateTime.now().subtract(const Duration(hours: 5)),
        note: 'Weekly essentials & snacks',
      ),
      TransactionModel(
        id: 'tx_3',
        title: 'Angkas Ride to Ortigas',
        amount: 145.00,
        type: TransactionType.expense,
        categoryId: 'transport',
        categoryName: 'Transportation',
        categoryIcon: Icons.directions_bus_rounded,
        categoryColor: const Color(0xFF1E88E5),
        accountId: 'acc_gcash',
        accountName: 'GCash',
        date: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        note: 'Morning commute',
      ),
      TransactionModel(
        id: 'tx_4',
        title: 'Client Project Milestone',
        amount: 28000.00,
        type: TransactionType.income,
        categoryId: 'freelance',
        categoryName: 'Side Hustle',
        categoryIcon: Icons.laptop_chromebook_rounded,
        categoryColor: const Color(0xFF00897B),
        accountId: 'acc_bdo',
        accountName: 'BDO Savings',
        date: DateTime.now().subtract(const Duration(days: 2)),
        note: 'Mobile app consulting phase 1',
      ),
      TransactionModel(
        id: 'tx_5',
        title: 'Meralco Electric Bill',
        amount: 3820.00,
        type: TransactionType.expense,
        categoryId: 'utilities',
        categoryName: 'Utilities & Bills',
        categoryIcon: Icons.bolt_rounded,
        categoryColor: const Color(0xFFFBC02D),
        accountId: 'acc_maya',
        accountName: 'Maya',
        date: DateTime.now().subtract(const Duration(days: 3)),
        note: 'September statement',
      ),
      TransactionModel(
        id: 'tx_6',
        title: 'Netflix Subscription',
        amount: 549.00,
        type: TransactionType.expense,
        categoryId: 'entertainment',
        categoryName: 'Entertainment',
        categoryIcon: Icons.movie_filter_rounded,
        categoryColor: const Color(0xFF00ACC1),
        accountId: 'acc_bpi_cc',
        accountName: 'BPI Platinum Card',
        date: DateTime.now().subtract(const Duration(days: 4)),
        note: 'Monthly premium',
      ),
      TransactionModel(
        id: 'tx_7',
        title: 'Transfer to GCash',
        amount: 5000.00,
        type: TransactionType.transfer,
        categoryId: 'other_expense',
        categoryName: 'Transfer',
        categoryIcon: Icons.swap_horiz_rounded,
        categoryColor: const Color(0xFF1565C0),
        accountId: 'acc_bdo',
        accountName: 'BDO Savings',
        destinationAccountId: 'acc_gcash',
        destinationAccountName: 'GCash',
        date: DateTime.now().subtract(const Duration(days: 5)),
        note: 'E-wallet reload',
      ),
    ];
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
    return deleted;
  }

  void restoreTransaction(TransactionModel tx) {
    addTransaction(tx);
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
