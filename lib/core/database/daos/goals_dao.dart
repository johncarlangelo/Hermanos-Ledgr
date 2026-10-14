import 'package:drift/drift.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/core/database/tables/goals_table.dart';

part 'goals_dao.g.dart';

@DriftAccessor(tables: [GoalsTable])
class GoalsDao extends DatabaseAccessor<AppDatabase> with _$GoalsDaoMixin {
  GoalsDao(super.db);

  Stream<List<GoalsTableData>> watchAllGoals() => select(goalsTable).watch();

  Future<List<GoalsTableData>> getAllGoals() => select(goalsTable).get();

  Future<GoalsTableData?> getGoalById(String id) =>
      (select(goalsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertOrUpdateGoal(GoalsTableCompanion goal) =>
      into(goalsTable).insert(goal, mode: InsertMode.insertOrReplace);

  Future<int> addContribution(String id, double amount) async {
    final goal = await getGoalById(id);
    if (goal == null) return 0;
    final newCurrent = goal.currentAmount + amount;
    final isDone = newCurrent >= goal.targetAmount;
    return (update(goalsTable)..where((t) => t.id.equals(id))).write(
      GoalsTableCompanion(
        currentAmount: Value(newCurrent),
        isCompleted: Value(isDone),
      ),
    );
  }

  Future<int> deleteGoal(String id) =>
      (delete(goalsTable)..where((t) => t.id.equals(id))).go();
}
