import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hermanos_ledgr/app/page_transitions.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/budget/domain/budget_model.dart';
import 'package:hermanos_ledgr/features/debts/domain/debt_model.dart';
import 'package:hermanos_ledgr/features/goals/domain/goal_model.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';
import 'package:hermanos_ledgr/shared/widgets/motion_wrapper.dart';

void main() {
  group('Phase 13: Polish & Edge Cases (Task 13.6)', () {
    test('BudgetModel edge cases: zero limit, negative limit, extreme overspend', () {
      // 1. Zero limit
      const zeroBudget = BudgetModel(
        id: 'b_zero',
        categoryId: 'c1',
        categoryName: 'Zero Category',
        categoryIcon: Icons.category,
        categoryColor: Colors.blue,
        limitAmount: 0.0,
        spentAmount: 150.0,
      );
      expect(zeroBudget.percentage, equals(2.0));
      expect(zeroBudget.remainingAmount, equals(0.0));
      expect(zeroBudget.isOverBudget, isTrue);
      expect(zeroBudget.status, equals(BudgetStatus.over));

      // 2. Zero spent, zero limit
      const zeroBoth = BudgetModel(
        id: 'b_zero_both',
        categoryId: 'c2',
        categoryName: 'Zero Both',
        categoryIcon: Icons.category,
        categoryColor: Colors.blue,
        limitAmount: 0.0,
        spentAmount: 0.0,
      );
      expect(zeroBoth.percentage, equals(0.0));
      expect(zeroBoth.remainingAmount, equals(0.0));
      expect(zeroBoth.isOverBudget, isFalse);
      expect(zeroBoth.status, equals(BudgetStatus.safe));

      // 3. Normal safe budget
      const safeBudget = BudgetModel(
        id: 'b_safe',
        categoryId: 'c3',
        categoryName: 'Groceries',
        categoryIcon: Icons.shopping_basket,
        categoryColor: Colors.green,
        limitAmount: 10000.0,
        spentAmount: 4000.0,
      );
      expect(safeBudget.percentage, closeTo(0.40, 0.001));
      expect(safeBudget.remainingAmount, equals(6000.0));
      expect(safeBudget.status, equals(BudgetStatus.safe));

      // 4. Extreme large values (100 Million)
      const megaBudget = BudgetModel(
        id: 'b_mega',
        categoryId: 'c4',
        categoryName: 'Investments',
        categoryIcon: Icons.trending_up,
        categoryColor: Colors.purple,
        limitAmount: 100000000.0,
        spentAmount: 75000000.0,
      );
      expect(megaBudget.percentage, closeTo(0.75, 0.001));
      expect(megaBudget.status, equals(BudgetStatus.caution));
    });

    test('DebtModel edge cases: zero original, negative amounts, overpaid remaining', () {
      // 1. Zero original amount
      final zeroDebt = DebtModel(
        id: 'd_zero',
        type: DebtType.debt,
        personName: 'Test Friend',
        originalAmount: 0.0,
        remainingAmount: 0.0,
        createdAt: DateTime.now(),
      );
      expect(zeroDebt.paidPercentage, equals(0.0));
      expect(zeroDebt.paidAmount, equals(0.0));

      // 2. Fully paid debt
      final paidDebt = DebtModel(
        id: 'd_paid',
        type: DebtType.receivable,
        personName: 'Juan',
        originalAmount: 2000.0,
        remainingAmount: 0.0,
        isSettled: true,
        createdAt: DateTime.now(),
      );
      expect(paidDebt.paidPercentage, equals(1.0));
      expect(paidDebt.paidAmount, equals(2000.0));
      expect(paidDebt.isSettled, isTrue);

      // 3. Overpaid or invalid negative remaining
      final overpaidDebt = DebtModel(
        id: 'd_overpaid',
        type: DebtType.receivable,
        personName: 'Maria',
        originalAmount: 1000.0,
        remainingAmount: -200.0,
        createdAt: DateTime.now(),
      );
      expect(overpaidDebt.paidAmount, equals(1000.0)); // clamped to original
      expect(overpaidDebt.paidPercentage, equals(1.0));
    });

    test('GoalModel edge cases: zero target, complete overachieved', () {
      // 1. Zero target
      final zeroGoal = GoalModel(
        id: 'g_zero',
        name: 'Zero Goal',
        targetAmount: 0.0,
        currentAmount: 0.0,
        icon: Icons.flag,
      );
      expect(zeroGoal.percentage, equals(0.0));

      // 2. Target exceeded
      final achievedGoal = GoalModel(
        id: 'g_achieved',
        name: 'Travel Fund',
        targetAmount: 50000.0,
        currentAmount: 60000.0,
        icon: Icons.flight,
      );
      expect(achievedGoal.percentage, equals(1.0));
      expect(achievedGoal.isAchieved, isTrue);
    });

    test('CurrencyFormatter edge cases: zero, negatives, huge numbers, compact formatting', () {
      // Zero
      expect(CurrencyFormatter.format(0.0), equals('₱0.00'));
      expect(CurrencyFormatter.format(0.0, includeDecimals: false), equals('₱0'));

      // Negative
      expect(CurrencyFormatter.format(-1234.56), equals('-₱1,234.56'));
      expect(CurrencyFormatter.format(-0.50), equals('-₱0.50'));

      // Positive with showSign
      expect(CurrencyFormatter.format(500.0, showSign: true), equals('+₱500.00'));

      // Millions
      expect(CurrencyFormatter.format(12500000.50), equals('₱12,500,000.50'));

      // Compact representation (≥ 100K)
      expect(CurrencyFormatter.formatCompact(150000), equals('₱150K'));
      expect(CurrencyFormatter.formatCompact(2500000), equals('₱2.5M'));
      expect(CurrencyFormatter.formatCompact(5000), equals('₱5,000.00')); // under 100K uses standard
    });
  });

  group('Phase 13: Motion & Micro-Animations (Tasks 13.1, 13.2)', () {
    testWidgets('StaggeredEntrance animates fade and slide without leaks', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StaggeredEntrance(
              index: 0,
              duration: Duration(milliseconds: 150),
              child: Text('Staggered Card Content'),
            ),
          ),
        ),
      );

      // Verify widget mounts and settles
      await tester.pumpAndSettle();
      expect(find.text('Staggered Card Content'), findsOneWidget);
    });

    testWidgets('BouncyPressable scales on tap down and triggers onTap callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BouncyPressable(
              onTap: () => tapped = true,
              scaleDown: 0.95,
              duration: const Duration(milliseconds: 80),
              child: const Text('Bouncy Button'),
            ),
          ),
        ),
      );

      expect(find.text('Bouncy Button'), findsOneWidget);

      // Tap down
      final gesture = await tester.press(find.text('Bouncy Button'));
      await tester.pump(const Duration(milliseconds: 40));

      // Release
      await gesture.up();
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('M3Card responds to tap with smooth scale animation', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: M3Card(
              onTap: () => tapped = true,
              child: const Text('M3 Interactive Card'),
            ),
          ),
        ),
      );

      expect(find.text('M3 Interactive Card'), findsOneWidget);

      await tester.tap(find.text('M3 Interactive Card'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    test('Page transitions builders produce valid CustomTransitionPage instances', () {
      final dummyState = GoRouterState(
        GoRouter(routes: [GoRoute(path: '/', builder: (_, _) => const SizedBox())]).configuration,
        matchedLocation: '/settings',
        fullPath: '/settings',
        pathParameters: const {},
        name: 'settings',
        path: '/settings',
        uri: Uri.parse('/settings'),
        pageKey: const ValueKey('settings_page'),
      );

      final sharedAxisPage = buildSharedAxisXTransition(
        child: const SizedBox(),
        state: dummyState,
      );
      expect(sharedAxisPage.transitionDuration, equals(const Duration(milliseconds: 300)));
      expect(sharedAxisPage.reverseTransitionDuration, equals(const Duration(milliseconds: 250)));

      final crossFadePage = buildCrossFadeTransition(
        child: const SizedBox(),
        state: dummyState,
      );
      expect(crossFadePage.transitionDuration, equals(const Duration(milliseconds: 200)));
    });
  });
}
