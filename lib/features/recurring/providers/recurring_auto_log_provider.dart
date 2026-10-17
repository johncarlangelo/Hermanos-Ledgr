import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/features/recurring/domain/recurring_auto_log_engine.dart';
import 'package:hermanos_ledgr/features/recurring/domain/recurring_model.dart';
import 'package:hermanos_ledgr/features/recurring/providers/recurring_provider.dart';
import 'package:hermanos_ledgr/features/transactions/providers/transactions_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

class RecurringAutoLogNotifier extends Notifier<bool> {
  bool _hasRunThisSession = false;

  @override
  bool build() => _hasRunThisSession;

  /// Runs the auto-log engine once on app launch or when called explicitly (Task 8.6).
  AutoLogResult runAutoLog({BuildContext? context, bool force = false}) {
    if (_hasRunThisSession && !force) {
      return const AutoLogResult(loggedCount: 0, createdTransactions: [], ruleTitles: []);
    }

    _hasRunThisSession = true;
    state = true;

    final rules = ref.read(recurringProvider);
    final txNotifier = ref.read(transactionsProvider.notifier);
    final recNotifier = ref.read(recurringProvider.notifier);

    final result = RecurringAutoLogEngine.checkAndProcess(
      rules: rules,
      onLogTransaction: (tx) => txNotifier.addTransaction(tx),
      onAdvanceDueDate: (id, newDueDate) => recNotifier.advanceDueDate(id, newDueDate),
    );

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
