import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/accounts/providers/accounts_provider.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';
import 'package:hermanos_ledgr/features/transactions/providers/transactions_provider.dart';

/// Aggregated, memoized dashboard metrics computed reactively from [accountsProvider] and [transactionsProvider].
class DashboardData {
  final double netWorth;
  final double totalAssets;
  final double totalLiabilities;
  final double monthlyNetChange;
  final double monthlyIncome;
  final double monthlyExpenses;
  final double savingsRate;
  final List<AccountModel> accounts;
  final List<TransactionModel> recentTransactions;

  const DashboardData({
    required this.netWorth,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.monthlyNetChange,
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.savingsRate,
    required this.accounts,
    required this.recentTransactions,
  });

  bool get hasAccounts => accounts.isNotEmpty;
  bool get hasTransactions => recentTransactions.isNotEmpty;
}

final dashboardProvider = Provider<DashboardData>((ref) {
  final accounts = ref.watch(accountsProvider);
  final transactions = ref.watch(transactionsProvider);

  final netWorth = accounts.fold(0.0, (sum, acc) => sum + acc.balance);
  final totalAssets = accounts
      .where((acc) => acc.balance > 0)
      .fold(0.0, (sum, acc) => sum + acc.balance);
  final totalLiabilities = accounts
      .where((acc) => acc.balance < 0)
      .fold(0.0, (sum, acc) => sum + acc.balance.abs());

  final now = DateTime.now();
  final currentMonthTxs = transactions.where(
    (t) => t.date.year == now.year && t.date.month == now.month,
  );

  double monthlyIncome = 0.0;
  double monthlyExpenses = 0.0;

  for (final t in currentMonthTxs) {
    if (t.type == TransactionType.income) {
      monthlyIncome += t.amount;
    } else if (t.type == TransactionType.expense) {
      monthlyExpenses += t.amount;
    }
  }

  final monthlyNetChange = monthlyIncome - monthlyExpenses;
  final savingsRate = monthlyIncome > 0
      ? ((monthlyNetChange / monthlyIncome) * 100).clamp(0.0, 100.0)
      : 0.0;

  return DashboardData(
    netWorth: netWorth,
    totalAssets: totalAssets,
    totalLiabilities: totalLiabilities,
    monthlyNetChange: monthlyNetChange,
    monthlyIncome: monthlyIncome,
    monthlyExpenses: monthlyExpenses,
    savingsRate: savingsRate,
    accounts: accounts,
    recentTransactions: transactions.take(5).toList(),
  );
});
