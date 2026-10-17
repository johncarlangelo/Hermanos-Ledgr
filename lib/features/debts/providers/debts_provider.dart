import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/core/providers/database_provider.dart';
import 'package:hermanos_ledgr/features/debts/data/debt_repository_impl.dart';
import 'package:hermanos_ledgr/features/debts/domain/debt_model.dart';
import 'package:hermanos_ledgr/features/debts/domain/debt_repository.dart';

/// Provider exposing the [DebtRepository] backed by Drift SQLite.
final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DebtRepositoryImpl(db: db, debtsDao: db.debtsDao);
});

/// Riverpod Notifier managing reactive debts and receivables backed by Drift SQLite.
class DebtsNotifier extends Notifier<List<DebtModel>> {
  StreamSubscription? _sub;

  DebtRepository get _repository => ref.read(debtRepositoryProvider);

  @override
  List<DebtModel> build() {
    final repo = ref.watch(debtRepositoryProvider);

    _sub?.cancel();
    _sub = repo.watchAllDebts().listen((debts) {
      state = debts;
    });

    ref.onDispose(() => _sub?.cancel());
    return const [];
  }

  /// Add a new debt or receivable with optimistic UI update.
  Future<void> addDebt(DebtModel debt) async {
    state = [debt, ...state];
    await _repository.addDebt(debt);
  }

  /// Update an existing debt or receivable with optimistic UI update.
  Future<void> updateDebt(DebtModel debt) async {
    state = [
      for (final d in state)
        if (d.id == debt.id) debt else d,
    ];
    await _repository.updateDebt(debt);
  }

  /// Record a payment towards a debt or receivable.
  Future<void> recordPayment(String id, double paymentAmount) async {
    final index = state.indexWhere((d) => d.id == id);
    if (index != -1) {
      final old = state[index];
      final newRemaining = (old.remainingAmount - paymentAmount).clamp(0.0, old.originalAmount);
      final isDone = newRemaining <= 0;
      final updated = old.copyWith(
        remainingAmount: newRemaining,
        isSettled: isDone,
      );
      state = [
        for (final d in state)
          if (d.id == id) updated else d,
      ];
    }
    await _repository.recordPayment(id, paymentAmount);
  }

  /// Mark a debt or receivable as completely settled.
  Future<void> settleDebt(String id) async {
    final index = state.indexWhere((d) => d.id == id);
    if (index != -1) {
      final old = state[index];
      final updated = old.copyWith(
        remainingAmount: 0.0,
        isSettled: true,
      );
      state = [
        for (final d in state)
          if (d.id == id) updated else d,
      ];
      await _repository.updateDebt(updated);
    }
  }

  /// Delete a debt record with optimistic UI update.
  Future<DebtModel?> deleteDebt(String id) async {
    final index = state.indexWhere((d) => d.id == id);
    if (index == -1) return null;
    final deleted = state[index];
    state = state.where((d) => d.id != id).toList();
    await _repository.deleteDebt(id);
    return deleted;
  }
}

/// Global provider for all debts and receivables.
final debtsProvider = NotifierProvider<DebtsNotifier, List<DebtModel>>(
  DebtsNotifier.new,
);

/// Provider for active debts you owe (Utang - Payables).
final payableDebtsProvider = Provider<List<DebtModel>>((ref) {
  final all = ref.watch(debtsProvider);
  return all.where((d) => d.type == DebtType.debt && !d.isSettled).toList();
});

/// Provider for active receivables owed to you (Pautang - Collectibles).
final receivablesProvider = Provider<List<DebtModel>>((ref) {
  final all = ref.watch(debtsProvider);
  return all.where((d) => d.type == DebtType.receivable && !d.isSettled).toList();
});

/// Provider for settled/archived debts and receivables.
final settledDebtsProvider = Provider<List<DebtModel>>((ref) {
  final all = ref.watch(debtsProvider);
  return all.where((d) => d.isSettled).toList();
});

/// Total amount you currently owe to others.
final totalPayableAmountProvider = Provider<double>((ref) {
  final payables = ref.watch(payableDebtsProvider);
  return payables.fold(0.0, (sum, d) => sum + d.remainingAmount);
});

/// Total amount others currently owe to you.
final totalReceivableAmountProvider = Provider<double>((ref) {
  final receivables = ref.watch(receivablesProvider);
  return receivables.fold(0.0, (sum, d) => sum + d.remainingAmount);
});

/// Net debt position: Receivables (assets) minus Payables (liabilities).
final netDebtBalanceProvider = Provider<double>((ref) {
  final receivables = ref.watch(totalReceivableAmountProvider);
  final payables = ref.watch(totalPayableAmountProvider);
  return receivables - payables;
});

/// Total count of overdue records across active debts and receivables.
final overdueDebtCountProvider = Provider<int>((ref) {
  final all = ref.watch(debtsProvider);
  return all.where((d) => !d.isSettled && d.isOverdue).length;
});
