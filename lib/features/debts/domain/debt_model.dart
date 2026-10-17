import 'package:flutter/material.dart';

/// Type of debt record:
/// - `debt`: Money you owe to someone else (payable / Utang)
/// - `receivable`: Money someone owes to you (collectible / Pautang)
enum DebtType {
  debt,
  receivable;

  String get displayName => switch (this) {
        DebtType.debt => 'I Owe',
        DebtType.receivable => 'Owed to Me',
      };

  String get actionLabel => switch (this) {
        DebtType.debt => 'Pay Debt',
        DebtType.receivable => 'Collect Payment',
      };

  IconData get icon => switch (this) {
        DebtType.debt => Icons.call_made_rounded,
        DebtType.receivable => Icons.call_received_rounded,
      };
}

/// Domain model representing a Debt or Receivable (Phase 7).
class DebtModel {
  final String id;
  final DebtType type;
  final String personName;
  final double originalAmount;
  final double remainingAmount;
  final String? note;
  final DateTime? dueDate;
  final bool isSettled;
  final DateTime createdAt;

  const DebtModel({
    required this.id,
    required this.type,
    required this.personName,
    required this.originalAmount,
    required this.remainingAmount,
    this.note,
    this.dueDate,
    this.isSettled = false,
    required this.createdAt,
  });

  /// Amount paid so far
  double get paidAmount =>
      (originalAmount - remainingAmount).clamp(0.0, originalAmount);

  /// Payoff progress from 0.0 to 1.0
  double get paidPercentage {
    if (originalAmount <= 0) return 0.0;
    return (paidAmount / originalAmount).clamp(0.0, 1.0);
  }

  /// Percentage as an integer (0 - 100)
  int get progressPercent => (paidPercentage * 100).round();

  /// Whether the payment deadline has passed
  bool get isOverdue {
    if (isSettled || dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.isBefore(today);
  }

  /// Remaining days until due date, or negative if overdue
  int? get remainingDays {
    if (dueDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.difference(today).inDays;
  }

  DebtModel copyWith({
    String? id,
    DebtType? type,
    String? personName,
    double? originalAmount,
    double? remainingAmount,
    String? note,
    DateTime? dueDate,
    bool? isSettled,
    DateTime? createdAt,
  }) {
    return DebtModel(
      id: id ?? this.id,
      type: type ?? this.type,
      personName: personName ?? this.personName,
      originalAmount: originalAmount ?? this.originalAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      note: note ?? this.note,
      dueDate: dueDate ?? this.dueDate,
      isSettled: isSettled ?? this.isSettled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          personName == other.personName &&
          originalAmount == other.originalAmount &&
          remainingAmount == other.remainingAmount &&
          note == other.note &&
          dueDate == other.dueDate &&
          isSettled == other.isSettled;

  @override
  int get hashCode =>
      id.hashCode ^
      type.hashCode ^
      personName.hashCode ^
      originalAmount.hashCode ^
      remainingAmount.hashCode ^
      note.hashCode ^
      dueDate.hashCode ^
      isSettled.hashCode;
}
