import 'package:flutter/material.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';

/// Standardized parsed transaction entity produced by Tier 1 Classifier or Tier 2 LLM (Task 9.6).
class ParsedTransaction {
  final String title;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;
  final String accountId;
  final String accountName;
  final String? toAccountId;
  final String? toAccountName;
  final DateTime date;
  final String? note;
  final double confidence;
  final List<String> missingFields;

  const ParsedTransaction({
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.accountId,
    required this.accountName,
    this.toAccountId,
    this.toAccountName,
    required this.date,
    this.note,
    this.confidence = 1.0,
    this.missingFields = const [],
  });

  /// Converts this parsed transaction into a concrete TransactionModel for saving.
  TransactionModel toTransactionModel({String? customId}) {
    return TransactionModel(
      id: customId ?? 'tx_ai_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      amount: amount,
      type: type,
      categoryId: categoryId,
      categoryName: categoryName,
      categoryIcon: categoryIcon,
      categoryColor: categoryColor,
      accountId: accountId,
      accountName: accountName,
      destinationAccountId: toAccountId,
      destinationAccountName: toAccountName,
      date: date,
      note: note,
    );
  }

  ParsedTransaction copyWith({
    String? title,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? categoryName,
    IconData? categoryIcon,
    Color? categoryColor,
    String? accountId,
    String? accountName,
    String? toAccountId,
    String? toAccountName,
    DateTime? date,
    String? note,
    double? confidence,
    List<String>? missingFields,
  }) {
    return ParsedTransaction(
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
      toAccountId: toAccountId ?? this.toAccountId,
      toAccountName: toAccountName ?? this.toAccountName,
      date: date ?? this.date,
      note: note ?? this.note,
      confidence: confidence ?? this.confidence,
      missingFields: missingFields ?? this.missingFields,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'type': type.name,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryIconCode': categoryIcon.codePoint,
      'categoryColorValue': categoryColor.toARGB32(),
      'accountId': accountId,
      'accountName': accountName,
      'toAccountId': toAccountId,
      'toAccountName': toAccountName,
      'date': date.toIso8601String(),
      'note': note,
      'confidence': confidence,
      'missingFields': missingFields,
    };
  }

  factory ParsedTransaction.fromJson(Map<String, dynamic> json) {
    return ParsedTransaction(
      title: json['title'] as String? ?? 'Expense',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: TransactionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      categoryId: json['categoryId'] as String? ?? 'food',
      categoryName: json['categoryName'] as String? ?? 'Food & Dining',
      // ignore: non_const_argument_for_const_parameter
      categoryIcon: json['categoryIconCode'] != null
          // ignore: non_const_argument_for_const_parameter
          ? IconData(json['categoryIconCode'] as int, fontFamily: 'MaterialIcons')
          : Icons.category_rounded,
      categoryColor: json['categoryColorValue'] != null
          ? Color(json['categoryColorValue'] as int)
          : const Color(0xFF00897B),
      accountId: json['accountId'] as String? ?? 'acc_default',
      accountName: json['accountName'] as String? ?? 'Main Account',
      toAccountId: json['toAccountId'] as String?,
      toAccountName: json['toAccountName'] as String?,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
          : DateTime.now(),
      note: json['note'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      missingFields: (json['missingFields'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}

