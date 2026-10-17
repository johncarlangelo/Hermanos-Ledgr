import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/core/database/daos/goals_dao.dart';
import 'package:hermanos_ledgr/core/database/database_mappers.dart';
import 'package:hermanos_ledgr/core/models/result.dart';
import 'package:hermanos_ledgr/features/goals/domain/goal_model.dart';
import 'package:hermanos_ledgr/features/goals/domain/goal_repository.dart';

/// Concrete implementation of [GoalRepository] utilizing Drift SQLite [GoalsDao].
class GoalRepositoryImpl implements GoalRepository {
  final AppDatabase db;
  final GoalsDao goalsDao;

  GoalRepositoryImpl({
    required this.db,
    required this.goalsDao,
  });

  @override
  Stream<List<GoalModel>> watchAllGoals() {
    return goalsDao.watchAllGoals().map(
          (rows) => rows.map(DatabaseMappers.goalFromDrift).toList(),
        );
  }

  @override
  Future<List<GoalModel>> getAllGoals() async {
    final rows = await goalsDao.getAllGoals();
    return rows.map(DatabaseMappers.goalFromDrift).toList();
  }

  @override
  Future<GoalModel?> getGoalById(String id) async {
    final row = await goalsDao.getGoalById(id);
    return row != null ? DatabaseMappers.goalFromDrift(row) : null;
  }

  @override
  Future<Result<void>> addGoal(GoalModel goal) async {
    try {
      await goalsDao.insertOrUpdateGoal(DatabaseMappers.goalToCompanion(goal));
      return const Success(null);
    } catch (e) {
      return Failure('Failed to add goal: $e', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateGoal(GoalModel goal) async {
    try {
      await goalsDao.insertOrUpdateGoal(DatabaseMappers.goalToCompanion(goal));
      return const Success(null);
    } catch (e) {
      return Failure('Failed to update goal: $e', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> addContribution({
    required String goalId,
    required double amount,
  }) async {
    try {
      final rowsUpdated = await goalsDao.addContribution(goalId, amount);
      if (rowsUpdated > 0) {
        return const Success(null);
      }
      return Failure('Goal with id $goalId not found');
    } catch (e) {
      return Failure('Failed to add contribution: $e', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteGoal(String id) async {
    try {
      await goalsDao.deleteGoal(id);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete goal: $e', e is Exception ? e : Exception(e.toString()));
    }
  }
}
