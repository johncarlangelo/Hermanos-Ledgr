import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/features/goals/data/goal_repository_impl.dart';
import 'package:hermanos_ledgr/features/goals/domain/goal_model.dart';

void main() {
  group('GoalModel Domain Logic & Calculations (Task 6.1 & 6.8)', () {
    test('calculates percentage and remaining amount correctly', () {
      final goal = GoalModel(
        id: 'goal_1',
        name: 'Emergency Fund',
        targetAmount: 100000.0,
        currentAmount: 25000.0,
      );

      expect(goal.percentage, closeTo(0.25, 0.001));
      expect(goal.progressPercent, 25);
      expect(goal.remainingAmount, 75000.0);
      expect(goal.isAchieved, isFalse);
    });

    test('clamps percentage to 1.0 when exceeded and marks achieved', () {
      final goal = GoalModel(
        id: 'goal_2',
        name: 'New Headset',
        targetAmount: 5000.0,
        currentAmount: 6000.0,
      );

      expect(goal.percentage, 1.0);
      expect(goal.progressPercent, 100);
      expect(goal.remainingAmount, 0.0);
      expect(goal.isAchieved, isTrue);
    });

    test('monthlyContributionNeeded returns 0 if already achieved', () {
      final goal = GoalModel(
        id: 'goal_3',
        name: 'Done Goal',
        targetAmount: 10000.0,
        currentAmount: 10000.0,
        targetDate: DateTime.now().add(const Duration(days: 90)),
      );

      expect(goal.monthlyContributionNeeded, 0.0);
    });

    test('monthlyContributionNeeded calculates pacing for future deadline (Task 6.8)', () {
      final futureDate = DateTime.now().add(const Duration(days: 85)); // ~3 months
      final goal = GoalModel(
        id: 'goal_4',
        name: 'Japan Trip',
        targetAmount: 60000.0,
        currentAmount: 0.0,
        targetDate: futureDate,
      );

      // 60,000 / 3 months = 20,000/mo
      expect(goal.monthlyContributionNeeded, 20000.0);
    });

    test('monthlyContributionNeeded returns remaining if less than 1 month left', () {
      final soonDate = DateTime.now().add(const Duration(days: 10));
      final goal = GoalModel(
        id: 'goal_5',
        name: 'Urgent Target',
        targetAmount: 15000.0,
        currentAmount: 5000.0,
        targetDate: soonDate,
      );

      expect(goal.monthlyContributionNeeded, 10000.0);
    });
  });

  group('GoalRepositoryImpl SQLite Integration (Task 6.2 & 6.7)', () {
    late AppDatabase db;
    late GoalRepositoryImpl repository;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repository = GoalRepositoryImpl(db: db, goalsDao: db.goalsDao);
    });

    tearDown(() async {
      await db.close();
    });

    test('inserts, streams, updates, and deletes goals in SQLite', () async {
      final goal = GoalModel(
        id: 'goal_test_1',
        name: 'Emergency Fund',
        targetAmount: 100000.0,
        currentAmount: 10000.0,
        targetDate: DateTime(2027, 12, 31),
        icon: Icons.shield_rounded,
        color: const Color(0xFF00897B),
      );

      // 1. Add Goal
      final addResult = await repository.addGoal(goal);
      expect(addResult.isSuccess, isTrue);

      // 2. Fetch Goal by ID
      final fetched = await repository.getGoalById('goal_test_1');
      expect(fetched, isNotNull);
      expect(fetched!.name, 'Emergency Fund');
      expect(fetched.targetAmount, 100000.0);
      expect(fetched.currentAmount, 10000.0);
      expect(fetched.isCompleted, isFalse);

      // 3. Add Contribution (Task 6.7)
      final contribResult = await repository.addContribution(
        goalId: 'goal_test_1',
        amount: 40000.0,
      );
      expect(contribResult.isSuccess, isTrue);

      final afterContrib = await repository.getGoalById('goal_test_1');
      expect(afterContrib!.currentAmount, 50000.0);
      expect(afterContrib.isCompleted, isFalse);

      // 4. Complete Goal via contribution
      await repository.addContribution(
        goalId: 'goal_test_1',
        amount: 60000.0,
      );
      final completed = await repository.getGoalById('goal_test_1');
      expect(completed!.currentAmount, 110000.0);
      expect(completed.isCompleted, isTrue);

      // 5. Delete Goal
      final delResult = await repository.deleteGoal('goal_test_1');
      expect(delResult.isSuccess, isTrue);

      final deleted = await repository.getGoalById('goal_test_1');
      expect(deleted, isNull);
    });
  });
}
