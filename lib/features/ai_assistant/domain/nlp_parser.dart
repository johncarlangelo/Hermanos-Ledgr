import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hermanos_ledgr/core/constants/category_defaults.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/parsed_transaction.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';

/// Unified NLP Parser standardizing both Tier 1 Classifier and Tier 2 LLM outputs (Task 9.6).
class NlpParser {
  /// Parses JSON output from the Tier 2 LLM into a list of validated [ParsedTransaction]s.
  /// Handles JSON arrays `[{...}, {...}]`, object wrappers `{"transactions": [...]}`, or single objects `{...}`.
  static List<ParsedTransaction> parseLlmJsonList({
    required String rawLlmOutput,
    required List<AccountModel> accounts,
    List<CategoryItem> categories = const [],
    DateTime? fallbackDate,
  }) {
    try {
      String cleanedJson = rawLlmOutput.trim();
      if (cleanedJson.contains('```json')) {
        final start = cleanedJson.indexOf('```json') + 7;
        final end = cleanedJson.indexOf('```', start);
        cleanedJson = cleanedJson.substring(start, end != -1 ? end : cleanedJson.length).trim();
      } else if (cleanedJson.contains('```')) {
        final start = cleanedJson.indexOf('```') + 3;
        final end = cleanedJson.indexOf('```', start);
        cleanedJson = cleanedJson.substring(start, end != -1 ? end : cleanedJson.length).trim();
      }

      final dynamic decoded = jsonDecode(cleanedJson);
      final results = <ParsedTransaction>[];

      if (decoded is List) {
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final tx = _parseSingleMap(item, accounts, categories, fallbackDate);
            if (tx != null) results.add(tx);
          }
        }
      } else if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('transactions') && decoded['transactions'] is List) {
          for (final item in decoded['transactions'] as List) {
            if (item is Map<String, dynamic>) {
              final tx = _parseSingleMap(item, accounts, categories, fallbackDate);
              if (tx != null) results.add(tx);
            }
          }
        } else {
          final tx = _parseSingleMap(decoded, accounts, categories, fallbackDate);
          if (tx != null) results.add(tx);
        }
      }

      return results;
    } catch (_) {
      return [];
    }
  }

  /// Parses JSON output from the Tier 2 LLM into a single validated [ParsedTransaction].
  static ParsedTransaction? parseLlmJson({
    required String rawLlmOutput,
    required List<AccountModel> accounts,
    List<CategoryItem> categories = const [],
    DateTime? fallbackDate,
  }) {
    final list = parseLlmJsonList(
      rawLlmOutput: rawLlmOutput,
      accounts: accounts,
      categories: categories,
      fallbackDate: fallbackDate,
    );
    return list.isNotEmpty ? list.first : null;
  }

  static ParsedTransaction? _parseSingleMap(
    Map<String, dynamic> decoded,
    List<AccountModel> accounts,
    List<CategoryItem> categories,
    DateTime? fallbackDate,
  ) {
    try {
      // Check for error payload from system prompt
      if (decoded.containsKey('error')) return null;

    // Extract amount
    final rawAmount = decoded['amount'];
    double? amount;
    if (rawAmount is num) {
      amount = rawAmount.toDouble();
    } else if (rawAmount is String) {
      amount = double.tryParse(rawAmount.replaceAll(',', ''));
    }
    if (amount == null || amount <= 0) return null;

      // Extract transaction type
      final rawType = (decoded['type'] as String?)?.toLowerCase() ?? 'expense';
      final type = rawType == 'income'
          ? TransactionType.income
          : rawType == 'transfer'
              ? TransactionType.transfer
              : TransactionType.expense;

      // Extract date
      DateTime txDate = fallbackDate ?? DateTime.now();
      if (decoded['date'] != null && decoded['date'] is String) {
        final parsedDate = DateTime.tryParse(decoded['date'] as String);
        if (parsedDate != null) txDate = parsedDate;
      }

      // Resolve category
      final allCats = categories.isNotEmpty ? categories : CategoryDefaults.defaultCategories;
      final rawCategory = (decoded['category'] as String?)?.toLowerCase() ?? '';
      CategoryItem? matchedCat;

      for (final cat in allCats) {
        if (rawCategory.contains(cat.name.toLowerCase()) || rawCategory.contains(cat.id.toLowerCase())) {
          matchedCat = cat;
          break;
        }
      }

      matchedCat ??= type == TransactionType.income
          ? allCats.firstWhere((c) => c.id == 'salary', orElse: () => allCats.first)
          : allCats.firstWhere((c) => c.id == 'food', orElse: () => allCats.first);

      // Resolve account
      final rawAccount = (decoded['account'] as String?)?.toLowerCase() ?? '';
      AccountModel? matchedAccount;
      for (final acc in accounts) {
        if (rawAccount.contains(acc.name.toLowerCase()) ||
            (acc.institution != null && rawAccount.contains(acc.institution!.toLowerCase()))) {
          matchedAccount = acc;
          break;
        }
      }

      final defaultAccount = matchedAccount ??
          (accounts.isNotEmpty
              ? accounts.first
              : AccountModel(
                  id: 'acc_default',
                  name: 'Main Wallet',
                  type: AccountType.cash,
                  balance: 0.0,
                  icon: Icons.account_balance_wallet_rounded,
                  color: const Color(0xFF00897B),
                ));

      // Resolve transfer to_account if applicable
      AccountModel? matchedToAccount;
      if (type == TransactionType.transfer && decoded['to_account'] != null) {
        final rawToAccount = (decoded['to_account'] as String).toLowerCase();
        for (final acc in accounts) {
          if (acc.id != defaultAccount.id &&
              (rawToAccount.contains(acc.name.toLowerCase()) ||
                  (acc.institution != null && rawToAccount.contains(acc.institution!.toLowerCase())))) {
            matchedToAccount = acc;
            break;
          }
        }
      }

      // Title & Note
      final note = decoded['note'] as String?;
      final title = (decoded['title'] as String?) ?? note ?? matchedCat.name;

      return ParsedTransaction(
        title: title.length > 28 ? title.substring(0, 28) : title,
        amount: amount,
        type: type,
        categoryId: matchedCat.id,
        categoryName: matchedCat.name,
        categoryIcon: matchedCat.icon,
        categoryColor: matchedCat.color,
        accountId: defaultAccount.id,
        accountName: defaultAccount.name,
        toAccountId: matchedToAccount?.id,
        toAccountName: matchedToAccount?.name,
        date: txDate,
        note: note,
        confidence: 0.95,
      );
    } catch (_) {
      return null;
    }
  }
}
