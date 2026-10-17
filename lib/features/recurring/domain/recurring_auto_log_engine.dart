import 'package:hermanos_ledgr/core/constants/category_defaults.dart';
import 'package:hermanos_ledgr/features/recurring/domain/recurring_model.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';

/// Output result summarizing transactions created by the auto-log engine.
class AutoLogResult {
  final int loggedCount;
  final List<TransactionModel> createdTransactions;
  final List<String> ruleTitles;

  const AutoLogResult({
    required this.loggedCount,
    required this.createdTransactions,
    required this.ruleTitles,
  });

  bool get hasLogged => loggedCount > 0;

  String get summaryMessage {
    if (loggedCount == 0) return 'No scheduled payments due.';
    if (loggedCount == 1) {
      return 'Auto-logged scheduled payment: ${ruleTitles.first}';
    }
    return 'Auto-logged $loggedCount scheduled transactions (${ruleTitles.take(2).join(', ')}${ruleTitles.length > 2 ? '...' : ''})';
  }
}

/// Engine that checks active recurring rules and auto-logs due transactions (Task 8.6).
class RecurringAutoLogEngine {
  RecurringAutoLogEngine._();

  /// Evaluates active recurring rules against [referenceDate] (default: now).
  /// For each due rule, creates real [TransactionModel] entries and advances
  /// the rule's next due date.
  static AutoLogResult checkAndProcess({
    required List<RecurringModel> rules,
    required void Function(TransactionModel tx) onLogTransaction,
    required void Function(String ruleId, DateTime newDueDate) onAdvanceDueDate,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final List<TransactionModel> created = [];
    final List<String> titles = [];

    for (final rule in rules) {
      if (!rule.isActive) continue;

      var currentDue = rule.nextDueDate;
      bool advanced = false;

      // Handle overdue occurrences (including multiple cycles missed while app was closed)
      int cycles = 0;
      while (currentDue.isBefore(now) || _isSameDay(currentDue, now)) {
        if (cycles >= 50) break; // Safety cap
        cycles++;

        final cat = CategoryDefaults.defaultCategories.firstWhere(
          (c) => c.id == rule.categoryId,
          orElse: () => CategoryDefaults.defaultCategories.first,
        );

        final txId = 'tx_rec_${rule.id}_${currentDue.millisecondsSinceEpoch}_$cycles';
        final tx = TransactionModel(
          id: txId,
          title: rule.title,
          amount: rule.amount,
          type: rule.type,
          categoryId: rule.categoryId,
          categoryName: rule.categoryName,
          categoryIcon: cat.icon,
          categoryColor: cat.color,
          accountId: rule.accountId,
          accountName: rule.accountName,
          date: currentDue,
          note: 'Scheduled: ${rule.frequency.displayName}',
        );

        created.add(tx);
        titles.add(rule.title);
        onLogTransaction(tx);

        currentDue = rule.frequency.calculateNextDate(currentDue);
        advanced = true;
      }

      if (advanced) {
        onAdvanceDueDate(rule.id, currentDue);
      }
    }

    return AutoLogResult(
      loggedCount: created.length,
      createdTransactions: created,
      ruleTitles: titles.toSet().toList(),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
