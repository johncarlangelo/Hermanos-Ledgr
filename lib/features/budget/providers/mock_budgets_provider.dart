import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/core/constants/category_defaults.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/core/providers/database_provider.dart';
import 'package:hermanos_ledgr/features/budget/domain/budget_model.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';
import 'package:hermanos_ledgr/features/transactions/providers/mock_transactions_provider.dart';

const List<BudgetModel> _defaultBudgets = [
  BudgetModel(
    id: 'bg_food',
    categoryId: 'food',
    categoryName: 'Food & Dining',
    categoryIcon: Icons.restaurant_rounded,
    categoryColor: Color(0xFFF57C00),
    limitAmount: 5000.0,
    spentAmount: 285.0,
    daysLeft: 12,
  ),
  BudgetModel(
    id: 'bg_groceries',
    categoryId: 'groceries',
    categoryName: 'Groceries',
    categoryIcon: Icons.shopping_cart_rounded,
    categoryColor: Color(0xFF43A047),
    limitAmount: 10000.0,
    spentAmount: 2450.0,
    daysLeft: 12,
  ),
  BudgetModel(
    id: 'bg_utilities',
    categoryId: 'utilities',
    categoryName: 'Utilities & Bills',
    categoryIcon: Icons.bolt_rounded,
    categoryColor: Color(0xFFFBC02D),
    limitAmount: 6000.0,
    spentAmount: 3820.0,
    daysLeft: 12,
  ),
  BudgetModel(
    id: 'bg_transport',
    categoryId: 'transport',
    categoryName: 'Transportation',
    categoryIcon: Icons.directions_bus_rounded,
    categoryColor: Color(0xFF1E88E5),
    limitAmount: 3500.0,
    spentAmount: 145.0,
    daysLeft: 12,
  ),
  BudgetModel(
    id: 'bg_entertainment',
    categoryId: 'entertainment',
    categoryName: 'Entertainment',
    categoryIcon: Icons.movie_filter_rounded,
    categoryColor: Color(0xFF00ACC1),
    limitAmount: 2500.0,
    spentAmount: 549.0,
    daysLeft: 12,
  ),
];

class BudgetsNotifier extends Notifier<List<BudgetModel>> {
  StreamSubscription? _sub;
  List<BudgetsTableData> _budgetRows = [];

  @override
  List<BudgetModel> build() {
    final db = ref.watch(databaseProvider);
    final transactions = ref.watch(transactionsProvider);

    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = (lastDayOfMonth - now.day).clamp(0, 31);

    _sub?.cancel();
    _sub = db.select(db.budgetsTable).watch().listen((rows) {
      _budgetRows = rows;
      if (rows.isNotEmpty) {
        state = _buildModelsFromRows(rows, transactions, daysLeft);
      }
    });
    ref.onDispose(() => _sub?.cancel());

    if (_budgetRows.isNotEmpty) {
      return _buildModelsFromRows(_budgetRows, transactions, daysLeft);
    }
    return _defaultBudgets;
  }

  static List<BudgetModel> _buildModelsFromRows(
    List<BudgetsTableData> rows,
    List<TransactionModel> transactions,
    int daysLeft,
  ) {
    final now = DateTime.now();
    return rows.map((row) {
      final category = CategoryDefaults.findById(row.categoryId);
      final spent = transactions
          .where((t) =>
              t.type == TransactionType.expense &&
              t.categoryId == row.categoryId &&
              t.date.year == now.year &&
              t.date.month == now.month)
          .fold(0.0, (sum, t) => sum + t.amount);

      return BudgetModel(
        id: row.id,
        categoryId: row.categoryId,
        categoryName: row.categoryName,
        categoryIcon: category.icon,
        categoryColor: category.color,
        limitAmount: row.monthlyLimit,
        spentAmount: spent,
        daysLeft: daysLeft,
      );
    }).toList();
  }

  Future<void> updateLimit(String budgetId, double newLimit) async {
    final db = ref.read(databaseProvider);
    await (db.update(db.budgetsTable)..where((t) => t.id.equals(budgetId))).write(
      BudgetsTableCompanion(monthlyLimit: Value(newLimit)),
    );
  }
}

final budgetsProvider =
    NotifierProvider<BudgetsNotifier, List<BudgetModel>>(BudgetsNotifier.new);

final totalBudgetSpentProvider = Provider<double>((ref) {
  final budgets = ref.watch(budgetsProvider);
  return budgets.fold(0.0, (sum, b) => sum + b.spentAmount);
});

final totalBudgetLimitProvider = Provider<double>((ref) {
  final budgets = ref.watch(budgetsProvider);
  return budgets.fold(0.0, (sum, b) => sum + b.limitAmount);
});
