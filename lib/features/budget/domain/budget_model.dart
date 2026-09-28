import 'package:flutter/material.dart';

class BudgetModel {
  final String id;
  final String categoryId;
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;
  final double limitAmount;
  final double spentAmount;
  final int daysLeft;

  const BudgetModel({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.limitAmount,
    required this.spentAmount,
    this.daysLeft = 12,
  });

  double get percentage => (spentAmount / limitAmount).clamp(0.0, 2.0);
  double get remainingAmount => (limitAmount - spentAmount).clamp(0.0, limitAmount);
  bool get isOverBudget => spentAmount > limitAmount;

  BudgetStatus get status {
    final pct = spentAmount / limitAmount;
    if (pct > 1.0) return BudgetStatus.over;
    if (pct >= 0.75) return BudgetStatus.caution;
    return BudgetStatus.safe;
  }
}

enum BudgetStatus {
  safe,
  caution,
  over,
}
