import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/core/constants/category_defaults.dart';
import 'package:hermanos_ledgr/core/services/notification_service.dart';
import 'package:hermanos_ledgr/features/accounts/providers/accounts_provider.dart';
import 'package:hermanos_ledgr/features/recurring/domain/recurring_auto_log_engine.dart';
import 'package:hermanos_ledgr/features/recurring/domain/recurring_model.dart';
import 'package:hermanos_ledgr/features/recurring/providers/recurring_provider.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';
import 'package:hermanos_ledgr/features/transactions/providers/transactions_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Provider holding any recurring payments that are currently paused due to insufficient account balance.
class PendingInsufficientFundsNotifier extends Notifier<List<InsufficientFundsItem>> {
  @override
  List<InsufficientFundsItem> build() => const [];

  void setItems(List<InsufficientFundsItem> items) {
    state = items;
  }

  void removeItem(String ruleId) {
    state = state.where((item) => item.rule.id != ruleId).toList();
  }

  /// 1. Log anyway: allows the transaction to deduct from the original account (allowing negative balance safety net).
  Future<void> resolveLogAnyway(BuildContext context, InsufficientFundsItem item) async {
    final txNotifier = ref.read(transactionsProvider.notifier);
    final recNotifier = ref.read(recurringProvider.notifier);

    final cat = CategoryDefaults.defaultCategories.firstWhere(
      (c) => c.id == item.rule.categoryId,
      orElse: () => CategoryDefaults.defaultCategories.first,
    );

    final tx = TransactionModel(
      id: 'tx_rec_${item.rule.id}_${item.dueDate.millisecondsSinceEpoch}_manual',
      title: item.rule.title,
      amount: item.rule.amount,
      type: item.rule.type,
      categoryId: item.rule.categoryId,
      categoryName: item.rule.categoryName,
      categoryIcon: cat.icon,
      categoryColor: cat.color,
      accountId: item.rule.accountId,
      accountName: item.rule.accountName,
      date: item.dueDate,
      note: 'Scheduled: ${item.rule.frequency.displayName} (Manual override)',
    );

    txNotifier.addTransaction(tx);
    await recNotifier.advanceDueDate(
      item.rule.id,
      item.rule.frequency.calculateNextDate(item.dueDate),
    );
    removeItem(item.rule.id);

    if (context.mounted) {
      UndoSnackbar.show(
        context,
        message: 'Logged "${item.rule.title}" via ${item.rule.accountName}',
        onUndo: () => txNotifier.deleteTransaction(tx.id),
      );
    }
  }

  /// 2. Pay with another account: redirects payment to an account that has funds.
  Future<void> resolveWithAnotherAccount(
    BuildContext context,
    InsufficientFundsItem item,
    String targetAccountId,
    String targetAccountName,
  ) async {
    final txNotifier = ref.read(transactionsProvider.notifier);
    final recNotifier = ref.read(recurringProvider.notifier);

    final cat = CategoryDefaults.defaultCategories.firstWhere(
      (c) => c.id == item.rule.categoryId,
      orElse: () => CategoryDefaults.defaultCategories.first,
    );

    final tx = TransactionModel(
      id: 'tx_rec_${item.rule.id}_${item.dueDate.millisecondsSinceEpoch}_rerouted',
      title: item.rule.title,
      amount: item.rule.amount,
      type: item.rule.type,
      categoryId: item.rule.categoryId,
      categoryName: item.rule.categoryName,
      categoryIcon: cat.icon,
      categoryColor: cat.color,
      accountId: targetAccountId,
      accountName: targetAccountName,
      date: item.dueDate,
      note: 'Scheduled: ${item.rule.frequency.displayName} (Paid via $targetAccountName)',
    );

    txNotifier.addTransaction(tx);
    await recNotifier.advanceDueDate(
      item.rule.id,
      item.rule.frequency.calculateNextDate(item.dueDate),
    );
    removeItem(item.rule.id);

    if (context.mounted) {
      UndoSnackbar.show(
        context,
        message: 'Paid "${item.rule.title}" via $targetAccountName',
        onUndo: () => txNotifier.deleteTransaction(tx.id),
      );
    }
  }

  /// 3. Skip this cycle: advances due date to next period without creating an expense.
  Future<void> resolveSkipCycle(BuildContext context, InsufficientFundsItem item) async {
    final recNotifier = ref.read(recurringProvider.notifier);
    final nextDate = item.rule.frequency.calculateNextDate(item.dueDate);

    await recNotifier.advanceDueDate(item.rule.id, nextDate);
    removeItem(item.rule.id);

    if (context.mounted) {
      UndoSnackbar.info(
        context,
        message: 'Skipped payment for "${item.rule.title}" this cycle.',
      );
    }
  }
}

final pendingInsufficientFundsProvider =
    NotifierProvider<PendingInsufficientFundsNotifier, List<InsufficientFundsItem>>(
  PendingInsufficientFundsNotifier.new,
);

class RecurringAutoLogNotifier extends Notifier<bool> {
  bool _hasRunThisSession = false;

  @override
  bool build() => _hasRunThisSession;

  /// Runs the auto-log engine once on app launch or when called explicitly (Task 8.6).
  /// Verifies account balances to prevent driving accounts negative automatically.
  AutoLogResult runAutoLog({BuildContext? context, bool force = false}) {
    if (_hasRunThisSession && !force) {
      return const AutoLogResult(loggedCount: 0, createdTransactions: [], ruleTitles: []);
    }

    _hasRunThisSession = true;
    state = true;

    final rules = ref.read(recurringProvider);
    final txNotifier = ref.read(transactionsProvider.notifier);
    final recNotifier = ref.read(recurringProvider.notifier);
    final accounts = ref.read(accountsProvider);
    final notifService = ref.read(notificationServiceProvider);

    final accountBalances = {for (final a in accounts) a.id: a.balance};

    final result = RecurringAutoLogEngine.checkAndProcess(
      rules: rules,
      accountBalances: accountBalances,
      onLogTransaction: (tx) => txNotifier.addTransaction(tx),
      onAdvanceDueDate: (id, newDueDate) => recNotifier.advanceDueDate(id, newDueDate),
    );

    // If any payments were paused due to insufficient funds, save to pending list & notify
    if (result.hasInsufficientFunds) {
      ref.read(pendingInsufficientFundsProvider.notifier).setItems(result.insufficientFunds);
      for (final item in result.insufficientFunds) {
        notifService.showInsufficientFundsNotification(item);
      }
    }

    if (result.hasLogged && context != null && context.mounted) {
      UndoSnackbar.show(
        context,
        message: result.summaryMessage,
        onUndo: () {
          for (final tx in result.createdTransactions) {
            txNotifier.deleteTransaction(tx.id);
          }
        },
      );
    }

    return result;
  }

  /// Manually trigger a single recurring rule to log immediately (e.g. from rule card menu).
  void manuallyLogRule(BuildContext context, RecurringModel rule) {
    final txNotifier = ref.read(transactionsProvider.notifier);
    final recNotifier = ref.read(recurringProvider.notifier);

    final result = RecurringAutoLogEngine.checkAndProcess(
      rules: [rule],
      referenceDate: DateTime.now().add(const Duration(days: 365)), // Forces current cycle to log
      onLogTransaction: (tx) => txNotifier.addTransaction(tx),
      onAdvanceDueDate: (id, newDueDate) => recNotifier.advanceDueDate(id, newDueDate),
    );

    if (result.hasLogged && context.mounted) {
      UndoSnackbar.show(
        context,
        message: 'Logged "${rule.title}" successfully!',
        onUndo: () {
          for (final tx in result.createdTransactions) {
            txNotifier.deleteTransaction(tx.id);
          }
        },
      );
    }
  }
}

final recurringAutoLogProvider = NotifierProvider<RecurringAutoLogNotifier, bool>(
  RecurringAutoLogNotifier.new,
);
