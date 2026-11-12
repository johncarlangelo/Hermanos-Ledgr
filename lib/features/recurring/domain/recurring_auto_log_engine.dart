import 'package:hermanos_ledgr/core/constants/category_defaults.dart';
import 'package:hermanos_ledgr/features/recurring/domain/recurring_model.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';

/// Represents a recurring expense rule that could not be auto-logged due to insufficient account balance.
class InsufficientFundsItem {
  final RecurringModel rule;
  final double requiredAmount;
  final double availableBalance;
  final DateTime dueDate;

  const InsufficientFundsItem({
    required this.rule,
    required this.requiredAmount,
    required this.availableBalance,
    required this.dueDate,
  });

  /// Amount required beyond the available balance to complete the transaction.
  double get shortfall => (requiredAmount - availableBalance).clamp(0.0, double.infinity);
}

/// Output result summarizing transactions created and payments paused by the auto-log engine.
class AutoLogResult {
  final int loggedCount;
  final List<TransactionModel> createdTransactions;
  final List<String> ruleTitles;
  final List<InsufficientFundsItem> insufficientFunds;

  const AutoLogResult({
    required this.loggedCount,
    required this.createdTransactions,
    required this.ruleTitles,
    this.insufficientFunds = const [],
  });

  bool get hasLogged => loggedCount > 0;
  bool get hasInsufficientFunds => insufficientFunds.isNotEmpty;

  String get summaryMessage {
    if (loggedCount == 0 && insufficientFunds.isEmpty) {
      return 'No scheduled payments due.';
    }
    if (insufficientFunds.isNotEmpty && loggedCount == 0) {
      if (insufficientFunds.length == 1) {
        return 'Payment paused: ${insufficientFunds.first.rule.title} (insufficient balance).';
      }
      return '${insufficientFunds.length} scheduled payments paused (insufficient balance).';
    }
    if (loggedCount == 1) {
      final base = 'Auto-logged scheduled payment: ${ruleTitles.first}';
      return insufficientFunds.isNotEmpty
          ? '$base (${insufficientFunds.length} paused: low funds)'
          : base;
    }
    final base = 'Auto-logged $loggedCount scheduled transactions';
    return insufficientFunds.isNotEmpty
        ? '$base (${insufficientFunds.length} paused: low funds)'
        : base;
  }
}

/// Engine that checks active recurring rules and auto-logs due transactions (Task 8.6).
/// Guards against negative balances by pausing expense auto-logging when funds are insufficient.
class RecurringAutoLogEngine {
  RecurringAutoLogEngine._();

  /// Evaluates active recurring rules against [referenceDate] (default: now).
  /// For each due rule with sufficient funds, creates real [TransactionModel] entries
  /// and advances the rule's next due date.
  /// If an expense rule exceeds the available balance in [accountBalances], it is paused
  /// and reported in [AutoLogResult.insufficientFunds] without advancing or deducting.
  static AutoLogResult checkAndProcess({
    required List<RecurringModel> rules,
    required void Function(TransactionModel tx) onLogTransaction,
    required void Function(String ruleId, DateTime newDueDate) onAdvanceDueDate,
    Map<String, double>? accountBalances,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final List<TransactionModel> created = [];
    final List<String> titles = [];
    final List<InsufficientFundsItem> insufficientList = [];

    // Track simulated running balances to account for multiple sequential deductions
    final Map<String, double> runningBalances = accountBalances != null
        ? Map<String, double>.from(accountBalances)
        : {};

    for (final rule in rules) {
      if (!rule.isActive) continue;

      var currentDue = rule.nextDueDate;
      bool advanced = false;

      // Handle overdue occurrences (including multiple cycles missed while app was closed)
      int cycles = 0;
      while (currentDue.isBefore(now) || _isSameDay(currentDue, now)) {
        if (cycles >= 50) break; // Safety cap
        cycles++;

        // If an expense and balance tracking is enabled, check available funds
        if (rule.isExpense && accountBalances != null) {
          final currentBalance = runningBalances[rule.accountId] ?? 0.0;
          if (currentBalance < rule.amount) {
            // Insufficient balance! Do NOT deduct, do NOT auto-log, do NOT advance due date.
            insufficientList.add(
              InsufficientFundsItem(
                rule: rule,
                requiredAmount: rule.amount,
                availableBalance: currentBalance,
                dueDate: currentDue,
              ),
            );
            // Stop processing further overdue cycles for this rule
            break;
          }

          // Deduct from simulated running balance for any subsequent rules
          runningBalances[rule.accountId] = currentBalance - rule.amount;
        } else if (rule.isIncome && accountBalances != null) {
          final currentBalance = runningBalances[rule.accountId] ?? 0.0;
          runningBalances[rule.accountId] = currentBalance + rule.amount;
        }

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
      insufficientFunds: insufficientList,
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
