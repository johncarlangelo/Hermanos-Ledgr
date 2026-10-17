import 'package:flutter/material.dart';

/// Immutable domain model representing a savings goal milestone.
class GoalModel {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final IconData icon;
  final Color color;
  final bool isCompleted;

  const GoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.targetDate,
    this.icon = Icons.savings_rounded,
    this.color = const Color(0xFF00897B),
    this.isCompleted = false,
  });

  /// Ratio between 0.0 and 1.0 representing percentage completed.
  double get percentage {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  /// Integer percentage (0 - 100).
  int get progressPercent => (percentage * 100).toInt();

  /// Total money left to reach target.
  double get remainingAmount {
    final remaining = targetAmount - currentAmount;
    return remaining > 0 ? remaining : 0.0;
  }

  /// Whether the goal has reached or exceeded its target.
  bool get isAchieved => currentAmount >= targetAmount || isCompleted;

  /// Remaining days until target date, or null if no deadline.
  int? get remainingDays {
    if (targetDate == null) return null;
    final now = DateTime.now();
    final diff = targetDate!.difference(DateTime(now.year, now.month, now.day)).inDays;
    return diff > 0 ? diff : 0;
  }

  /// Required monthly savings contribution to hit target date on time (Task 6.8).
  /// If no target date or already achieved, returns 0.0.
  double get monthlyContributionNeeded {
    if (isAchieved || remainingAmount <= 0) return 0.0;
    if (targetDate == null) return remainingAmount;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = targetDate!.difference(today).inDays;

    if (days <= 0) {
      return remainingAmount;
    }

    // Average days in month: ~30.44 days
    final months = (days / 30.4375).ceil();
    if (months <= 1) {
      return remainingAmount;
    }
    return remainingAmount / months;
  }

  GoalModel copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    IconData? icon,
    Color? color,
    bool? isCompleted,
  }) {
    return GoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          targetAmount == other.targetAmount &&
          currentAmount == other.currentAmount &&
          targetDate == other.targetDate &&
          icon == other.icon &&
          color == other.color &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        targetAmount,
        currentAmount,
        targetDate,
        icon,
        color,
        isCompleted,
      );
}
