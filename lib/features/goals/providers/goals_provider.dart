import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/core/providers/database_provider.dart';
import 'package:hermanos_ledgr/features/goals/data/goal_repository_impl.dart';
import 'package:hermanos_ledgr/features/goals/domain/goal_model.dart';
import 'package:hermanos_ledgr/features/goals/domain/goal_repository.dart';

/// Provider exposing the [GoalRepository] backed by Drift SQLite.
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return GoalRepositoryImpl(db: db, goalsDao: db.goalsDao);
});

/// Riverpod Notifier managing reactive savings goals backed by Drift SQLite.
class GoalsNotifier extends Notifier<List<GoalModel>> {
  StreamSubscription? _sub;

  GoalRepository get _repository => ref.read(goalRepositoryProvider);

  @override
  List<GoalModel> build() {
    final repo = ref.watch(goalRepositoryProvider);

    _sub?.cancel();
    _sub = repo.watchAllGoals().listen((goals) {
      state = goals;
    });

    ref.onDispose(() => _sub?.cancel());
    return const [];
  }

  /// Add a new savings goal with optimistic UI update.
  Future<void> addGoal(GoalModel goal) async {
    state = [...state, goal];
    await _repository.addGoal(goal);
  }

  /// Update an existing goal with optimistic UI update.
  Future<void> updateGoal(GoalModel goal) async {
    state = [
      for (final g in state)
        if (g.id == goal.id) goal else g,
    ];
    await _repository.updateGoal(goal);
  }

  /// Log a financial contribution towards a goal (Task 6.7).
  Future<void> addContribution({
    required String goalId,
    required double amount,
  }) async {
    final index = state.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final old = state[index];
      final newCurrent = old.currentAmount + amount;
      final isDone = newCurrent >= old.targetAmount;
      final updated = old.copyWith(
        currentAmount: newCurrent,
        isCompleted: isDone,
      );
      state = [
        for (final g in state)
          if (g.id == goalId) updated else g,
      ];
    }
    await _repository.addContribution(goalId: goalId, amount: amount);
  }

  /// Delete a goal with optimistic UI update.
  Future<GoalModel?> deleteGoal(String id) async {
    final index = state.indexWhere((g) => g.id == id);
    if (index == -1) return null;
    final deleted = state[index];
    state = state.where((g) => g.id != id).toList();
    await _repository.deleteGoal(id);
    return deleted;
  }
}

/// Global provider for all savings goals.
final goalsProvider = NotifierProvider<GoalsNotifier, List<GoalModel>>(
  GoalsNotifier.new,
);

/// Provider for active (uncompleted) savings goals.
final activeGoalsProvider = Provider<List<GoalModel>>((ref) {
  final goals = ref.watch(goalsProvider);
  return goals.where((g) => !g.isAchieved).toList();
});

/// Provider for achieved/completed savings goals.
final completedGoalsProvider = Provider<List<GoalModel>>((ref) {
  final goals = ref.watch(goalsProvider);
  return goals.where((g) => g.isAchieved).toList();
});

/// Total amount currently saved across all goals.
final totalGoalsSavedProvider = Provider<double>((ref) {
  final goals = ref.watch(goalsProvider);
  return goals.fold<double>(0.0, (sum, g) => sum + g.currentAmount);
});

/// Total target amount across all goals.
final totalGoalsTargetProvider = Provider<double>((ref) {
  final goals = ref.watch(goalsProvider);
  return goals.fold<double>(0.0, (sum, g) => sum + g.targetAmount);
});

/// Total required monthly contribution needed across all active goals (Task 6.8).
final totalMonthlyContributionNeededProvider = Provider<double>((ref) {
  final activeGoals = ref.watch(activeGoalsProvider);
  return activeGoals.fold<double>(0.0, (sum, g) => sum + g.monthlyContributionNeeded);
});
