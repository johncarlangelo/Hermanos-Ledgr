import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/core/providers/database_provider.dart';
import 'package:hermanos_ledgr/core/services/notification_service.dart';
import 'package:hermanos_ledgr/features/recurring/data/recurring_repository_impl.dart';
import 'package:hermanos_ledgr/features/recurring/domain/recurring_model.dart';
import 'package:hermanos_ledgr/features/recurring/domain/recurring_repository.dart';

/// Provider exposing [RecurringRepository] backed by Drift SQLite (Task 8.3).
final recurringRepositoryProvider = Provider<RecurringRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return RecurringRepositoryImpl(db: db, recurringDao: db.recurringDao);
});

/// Riverpod Notifier managing reactive recurring transaction rules.
class RecurringNotifier extends Notifier<List<RecurringModel>> {
  StreamSubscription? _sub;

  RecurringRepository get _repository => ref.read(recurringRepositoryProvider);
  NotificationService get _notifications => ref.read(notificationServiceProvider);

  @override
  List<RecurringModel> build() {
    final repo = ref.watch(recurringRepositoryProvider);

    _sub?.cancel();
    _sub = repo.watchAllRecurring().listen((rules) {
      state = rules;
      _notifications.syncAllReminders(rules);
    });

    ref.onDispose(() => _sub?.cancel());
    return const [];
  }

  /// Add a new recurring rule with optimistic UI update.
  Future<void> addRule(RecurringModel rule) async {
    state = [...state, rule];
    await _repository.addRecurring(rule);
    _notifications.scheduleSubscriptionReminders(rule);
  }

  /// Update an existing recurring rule with optimistic UI update.
  Future<void> updateRule(RecurringModel rule) async {
    state = [
      for (final r in state)
        if (r.id == rule.id) rule else r,
    ];
    await _repository.updateRecurring(rule);
    _notifications.scheduleSubscriptionReminders(rule);
  }

  /// Toggle active state of a recurring rule with optimistic UI update.
  Future<void> toggleActive(String id) async {
    final index = state.indexWhere((r) => r.id == id);
    if (index != -1) {
      final old = state[index];
      final newActive = !old.isActive;
      final updated = old.copyWith(isActive: newActive);
      state = [
        for (final r in state)
          if (r.id == id) updated else r,
      ];
      await _repository.toggleActive(id, newActive);
      _notifications.scheduleSubscriptionReminders(updated);
    }
  }

  /// Toggle notification reminder triggers for a specific recurring rule.
  Future<void> toggleNotifications(String id) async {
    final index = state.indexWhere((r) => r.id == id);
    if (index != -1) {
      final old = state[index];
      final newNotif = !old.enableNotifications;
      final updated = old.copyWith(enableNotifications: newNotif);
      state = [
        for (final r in state)
          if (r.id == id) updated else r,
      ];
      await _repository.updateRecurring(updated);
      _notifications.scheduleSubscriptionReminders(updated);
    }
  }

  /// Advance next due date of a recurring rule (after logging an instance).
  Future<void> advanceDueDate(String id, DateTime newDueDate) async {
    final index = state.indexWhere((r) => r.id == id);
    if (index != -1) {
      final updated = state[index].copyWith(nextDueDate: newDueDate);
      state = [
        for (final r in state)
          if (r.id == id) updated else r,
      ];
      await _repository.advanceNextDueDate(id, newDueDate);
      _notifications.scheduleSubscriptionReminders(updated);
    }
  }

  /// Delete a recurring rule with optimistic UI update.
  Future<RecurringModel?> deleteRule(String id) async {
    final index = state.indexWhere((r) => r.id == id);
    if (index == -1) return null;

    final ruleToDelete = state[index];
    state = state.where((r) => r.id != id).toList();
    await _repository.deleteRecurring(id);
    _notifications.cancelSubscriptionReminders(id);
    return ruleToDelete;
  }
}

/// Main provider for recurring transactions list.
final recurringProvider = NotifierProvider<RecurringNotifier, List<RecurringModel>>(
  RecurringNotifier.new,
);

/// Provider returning only active recurring transaction rules.
final activeRecurringProvider = Provider<List<RecurringModel>>((ref) {
  final all = ref.watch(recurringProvider);
  return all.where((r) => r.isActive).toList();
});

/// Provider returning paused/inactive recurring rules.
final pausedRecurringProvider = Provider<List<RecurringModel>>((ref) {
  final all = ref.watch(recurringProvider);
  return all.where((r) => !r.isActive).toList();
});

/// Provider returning active recurring rules sorted by next due date ascending.
final upcomingRecurringProvider = Provider<List<RecurringModel>>((ref) {
  final active = ref.watch(activeRecurringProvider);
  final sorted = [...active];
  sorted.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
  return sorted;
});

/// Provider returning active recurring rules that are currently due or past due.
final dueRecurringProvider = Provider<List<RecurringModel>>((ref) {
  final active = ref.watch(activeRecurringProvider);
  return active.where((r) => r.isDue).toList();
});

/// Monthly total cost of active recurring expenses normalized (Task 8.3).
final monthlyRecurringExpenseProvider = Provider<double>((ref) {
  final active = ref.watch(activeRecurringProvider);
  return active
      .where((r) => r.isExpense)
      .fold<double>(0.0, (sum, r) => sum + r.monthlyEquivalent);
});

/// Monthly total income from active recurring income rules (Task 8.3).
final monthlyRecurringIncomeProvider = Provider<double>((ref) {
  final active = ref.watch(activeRecurringProvider);
  return active
      .where((r) => r.isIncome)
      .fold<double>(0.0, (sum, r) => sum + r.monthlyEquivalent);
});

/// Net monthly recurring cashflow impact (Income - Expenses).
final netMonthlyRecurringCashflowProvider = Provider<double>((ref) {
  final income = ref.watch(monthlyRecurringIncomeProvider);
  final expense = ref.watch(monthlyRecurringExpenseProvider);
  return income - expense;
});
