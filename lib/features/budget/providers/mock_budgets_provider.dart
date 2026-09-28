import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/features/budget/domain/budget_model.dart';

class BudgetsNotifier extends Notifier<List<BudgetModel>> {
  @override
  List<BudgetModel> build() {
    return const [
      BudgetModel(
        id: 'b_food',
        categoryId: 'food',
        categoryName: 'Food & Dining',
        categoryIcon: Icons.restaurant_rounded,
        categoryColor: Color(0xFFF57C00),
        limitAmount: 5000.0,
        spentAmount: 3200.0,
        daysLeft: 12,
      ),
      BudgetModel(
        id: 'b_groceries',
        categoryId: 'groceries',
        categoryName: 'Groceries',
        categoryIcon: Icons.shopping_cart_rounded,
        categoryColor: Color(0xFF43A047),
        limitAmount: 10000.0,
        spentAmount: 7850.0,
        daysLeft: 12,
      ),
      BudgetModel(
        id: 'b_utilities',
        categoryId: 'utilities',
        categoryName: 'Utilities & Bills',
        categoryIcon: Icons.bolt_rounded,
        categoryColor: Color(0xFFFBC02D),
        limitAmount: 6000.0,
        spentAmount: 6420.0, // Over budget demonstration
        daysLeft: 12,
      ),
      BudgetModel(
        id: 'b_transport',
        categoryId: 'transport',
        categoryName: 'Transportation',
        categoryIcon: Icons.directions_bus_rounded,
        categoryColor: Color(0xFF1E88E5),
        limitAmount: 3500.0,
        spentAmount: 1850.0,
        daysLeft: 12,
      ),
      BudgetModel(
        id: 'b_entertainment',
        categoryId: 'entertainment',
        categoryName: 'Entertainment',
        categoryIcon: Icons.movie_filter_rounded,
        categoryColor: Color(0xFF00ACC1),
        limitAmount: 2500.0,
        spentAmount: 1200.0,
        daysLeft: 12,
      ),
    ];
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
