import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/app/theme/app_theme.dart';
import 'package:hermanos_ledgr/features/goals/domain/goal_model.dart';
import 'package:hermanos_ledgr/features/goals/presentation/screens/goals_screen.dart';
import 'package:hermanos_ledgr/features/goals/presentation/widgets/add_goal_sheet.dart';
import 'package:hermanos_ledgr/features/goals/presentation/widgets/goal_card.dart';
import 'package:hermanos_ledgr/features/goals/presentation/widgets/goal_progress_ring.dart';
import 'package:hermanos_ledgr/features/goals/providers/goals_provider.dart';

Widget _buildTestApp({required Widget child, List<dynamic> overrides = const []}) {
  return ProviderScope(
    overrides: [for (final o in overrides) o],
    child: MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('GoalProgressRing renders percentage text and CustomPaint', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        child: const Center(
          child: GoalProgressRing(
            percentage: 0.65,
            color: Color(0xFF00897B),
            size: 60,
          ),
        ),
      ),
    );

    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.text('65%'), findsOneWidget);
  });

  testWidgets('GoalCard renders title, amounts, pacing, and triggers callbacks', (tester) async {
    bool contributeClicked = false;
    bool editClicked = false;
    bool deleteClicked = false;

    final goal = GoalModel(
      id: 'g_japan',
      name: 'Japan Vacation',
      targetAmount: 80000.0,
      currentAmount: 20000.0,
      targetDate: DateTime.now().add(const Duration(days: 120)),
      icon: Icons.flight_takeoff_rounded,
      color: const Color(0xFF00897B),
    );

    await tester.pumpWidget(
      _buildTestApp(
        child: GoalCard(
          goal: goal,
          onContribute: () => contributeClicked = true,
          onEdit: () => editClicked = true,
          onDelete: () => deleteClicked = true,
        ),
      ),
    );

    expect(find.text('Japan Vacation'), findsOneWidget);
    expect(find.text('25%'), findsOneWidget); // 20k / 80k
    expect(find.text('Add Contribution'), findsOneWidget);
    expect(find.textContaining('Pace:'), findsOneWidget); // Smart pacing calculation (Task 6.8)

    // Tap Add Contribution
    await tester.tap(find.text('Add Contribution'));
    await tester.pump();
    expect(contributeClicked, isTrue);

    // Tap Edit
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pump();
    expect(editClicked, isTrue);

    // Tap Delete
    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pump();
    expect(deleteClicked, isTrue);
  });

  testWidgets('GoalsScreen renders empty state when no goals exist', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        overrides: [
          goalsProvider.overrideWith(() => _MockEmptyGoalsNotifier()),
        ],
        child: const GoalsScreen(),
      ),
    );

    expect(find.text('Savings Goals'), findsOneWidget);
    expect(find.text('No savings goals set'), findsOneWidget);
    expect(find.text('Create First Goal'), findsOneWidget);
  });

  testWidgets('GoalsScreen renders hero card and goal list when goals exist', (tester) async {
    final testGoals = [
      GoalModel(
        id: 'g_emergency',
        name: 'Emergency Fund',
        targetAmount: 100000.0,
        currentAmount: 50000.0,
        icon: Icons.shield_rounded,
      ),
      GoalModel(
        id: 'g_tech',
        name: 'New Monitor',
        targetAmount: 15000.0,
        currentAmount: 15000.0,
        isCompleted: true,
        icon: Icons.laptop_mac_rounded,
      ),
    ];

    await tester.pumpWidget(
      _buildTestApp(
        overrides: [
          goalsProvider.overrideWith(() => _MockGoalsNotifier(testGoals)),
        ],
        child: const GoalsScreen(),
      ),
    );

    expect(find.text('Savings Goals'), findsOneWidget);
    expect(find.text('Total Goals Progress'), findsOneWidget);
    expect(find.text('Emergency Fund'), findsOneWidget);
    expect(find.text('New Monitor'), findsOneWidget);
    expect(find.text('ACTIVE GOALS (1)'), findsOneWidget);
    expect(find.text('COMPLETED GOALS (1)'), findsOneWidget);
  });

  testWidgets('AddGoalSheet renders expanded icon grid and updates selected icon label', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        child: const AddGoalSheet(),
      ),
    );

    expect(find.text('CHOOSE ICON'), findsOneWidget);
    expect(find.text('Piggy Bank'), findsOneWidget); // Default selected icon label
    expect(find.byType(GridView), findsOneWidget);

    // Verify presence of travel icon in the grid
    expect(find.byIcon(Icons.flight_takeoff_rounded), findsOneWidget);

    // Tap travel icon
    await tester.tap(find.byIcon(Icons.flight_takeoff_rounded));
    await tester.pump();

    // Verify selected label updated to 'Travel & Flights'
    expect(find.text('Travel & Flights'), findsOneWidget);
  });
}

class _MockEmptyGoalsNotifier extends GoalsNotifier {
  @override
  List<GoalModel> build() => const [];
}

class _MockGoalsNotifier extends GoalsNotifier {
  final List<GoalModel> initial;
  _MockGoalsNotifier(this.initial);

  @override
  List<GoalModel> build() => initial;
}
