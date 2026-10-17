import 'package:flutter/material.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';

/// Recurrence cadence for recurring transactions and subscriptions (Phase 8).
enum RecurringFrequency {
  daily,
  weekly,
  biweekly,
  monthly,
  yearly;

  String get displayName => switch (this) {
        RecurringFrequency.daily => 'Daily',
        RecurringFrequency.weekly => 'Weekly',
        RecurringFrequency.biweekly => 'Bi-weekly',
        RecurringFrequency.monthly => 'Monthly',
        RecurringFrequency.yearly => 'Yearly',
      };

  /// Monthly cost normalization factor to calculate equivalent monthly expense.
  double get monthlyFactor => switch (this) {
        RecurringFrequency.daily => 30.0,
        RecurringFrequency.weekly => 52.0 / 12.0, // ~4.333
        RecurringFrequency.biweekly => 26.0 / 12.0, // ~2.167
        RecurringFrequency.monthly => 1.0,
        RecurringFrequency.yearly => 1.0 / 12.0,
      };

  /// Calculates the next occurrence date after [fromDate].
  DateTime calculateNextDate(DateTime fromDate) {
    switch (this) {
      case RecurringFrequency.daily:
        return fromDate.add(const Duration(days: 1));
      case RecurringFrequency.weekly:
        return fromDate.add(const Duration(days: 7));
      case RecurringFrequency.biweekly:
        return fromDate.add(const Duration(days: 14));
      case RecurringFrequency.monthly:
        int nextYear = fromDate.year;
        int nextMonth = fromDate.month + 1;
        if (nextMonth > 12) {
          nextMonth = 1;
          nextYear += 1;
        }
        // Clamp day to maximum days in the target month (e.g. Jan 31 -> Feb 28/29)
        final daysInNextMonth = DateUtils.getDaysInMonth(nextYear, nextMonth);
        final targetDay = fromDate.day > daysInNextMonth ? daysInNextMonth : fromDate.day;
        return DateTime(
          nextYear,
          nextMonth,
          targetDay,
          fromDate.hour,
          fromDate.minute,
          fromDate.second,
        );
      case RecurringFrequency.yearly:
        int nextYear = fromDate.year + 1;
        final daysInMonth = DateUtils.getDaysInMonth(nextYear, fromDate.month);
        final targetDay = fromDate.day > daysInMonth ? daysInMonth : fromDate.day;
        return DateTime(
          nextYear,
          fromDate.month,
          targetDay,
          fromDate.hour,
          fromDate.minute,
          fromDate.second,
        );
    }
  }
}

/// Domain model representing a Recurring Transaction Rule or Subscription (Task 8.1).
class RecurringModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String categoryName;
  final String accountId;
  final String accountName;
  final RecurringFrequency frequency;
  final DateTime startDate;
  final DateTime nextDueDate;
  final bool isActive;

  const RecurringModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    required this.accountId,
    required this.accountName,
    required this.frequency,
    required this.startDate,
    required this.nextDueDate,
    this.isActive = true,
  });

  /// Monthly equivalent amount (Task 8.3 & 8.7)
  double get monthlyEquivalent => (amount * frequency.monthlyFactor);

  /// Number of calendar days until this recurring transaction is due.
  int get daysUntilDue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(nextDueDate.year, nextDueDate.month, nextDueDate.day);
    return target.difference(today).inDays;
  }

  /// Whether this recurring rule has reached or passed its due date.
  bool get isDue {
    final now = DateTime.now();
    return nextDueDate.isBefore(now) ||
        (nextDueDate.year == now.year &&
            nextDueDate.month == now.month &&
            nextDueDate.day == now.day);
  }

  /// Whether this recurrence represents an expense.
  bool get isExpense => type == TransactionType.expense;

  /// Whether this recurrence represents an income.
  bool get isIncome => type == TransactionType.income;

  RecurringModel copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? categoryName,
    String? accountId,
    String? accountName,
    RecurringFrequency? frequency,
    DateTime? startDate,
    DateTime? nextDueDate,
    bool? isActive,
  }) {
    return RecurringModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
