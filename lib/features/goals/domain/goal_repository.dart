import 'package:hermanos_ledgr/core/models/result.dart';
import 'package:hermanos_ledgr/features/goals/domain/goal_model.dart';

/// Abstract contract defining persistence and querying operations for savings goals.
abstract class GoalRepository {
  /// Stream of all savings goals.
  Stream<List<GoalModel>> watchAllGoals();

  /// Retrieve all savings goals once.
  Future<List<GoalModel>> getAllGoals();

  /// Retrieve a specific goal by ID.
  Future<GoalModel?> getGoalById(String id);

  /// Create a new savings goal.
  Future<Result<void>> addGoal(GoalModel goal);

  /// Update an existing savings goal.
  Future<Result<void>> updateGoal(GoalModel goal);

  /// Log a financial contribution towards a savings goal (Task 6.7).
  Future<Result<void>> addContribution({
    required String goalId,
    required double amount,
  });

  /// Delete a savings goal.
  Future<Result<void>> deleteGoal(String id);
}
