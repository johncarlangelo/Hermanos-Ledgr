import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/app/theme/app_theme.dart';
import 'package:hermanos_ledgr/core/constants/category_defaults.dart';
import 'package:hermanos_ledgr/features/budget/domain/budget_model.dart';
import 'package:hermanos_ledgr/features/budget/presentation/screens/budget_screen.dart';
import 'package:hermanos_ledgr/features/budget/presentation/widgets/budget_progress_card.dart';
import 'package:hermanos_ledgr/features/budget/presentation/widgets/edit_budget_sheet.dart';
import 'package:hermanos_ledgr/features/budget/providers/budgets_provider.dart';

class _MockBudgetsNotifier extends BudgetsNotifier {
  final List<BudgetModel> _initial;
  _MockBudgetsNotifier(this._initial);

  @override
  List<BudgetModel> build() => _initial;

  @override
  Future<void> setCategoryLimit({
    required String categoryId,
    required String categoryName,
    required double limitAmount,
  }) async {
    final cat = CategoryDefaults.findById(categoryId);
    final existingIndex = state.indexWhere((b) => b.categoryId == categoryId);
    final model = BudgetModel(
      id: 'budget_$categoryId',
      categoryId: categoryId,
      categoryName: categoryName,
      categoryIcon: cat.icon,
      categoryColor: cat.color,
      limitAmount: limitAmount,
      spentAmount: existingIndex != -1 ? state[existingIndex].spentAmount : 0.0,
      daysLeft: 15,
    );

    if (existingIndex != -1) {
      final updated = List<BudgetModel>.from(state);
      updated[existingIndex] = model;
      state = updated;
    } else {
      state = [...state, model];
    }
  }

  @override
  Future<void> updateLimit(String budgetId, double newLimit) async {
    state = state
        .map((b) => b.id == budgetId ? b.copyWith(limitAmount: newLimit) : b)
        .toList();
  }

  @override
  Future<void> deleteBudget(String budgetId) async {
    state = state.where((b) => b.id != budgetId).toList();
  }
}

void main() {
  final sampleBudgets = [
    BudgetModel(
      id: 'budget_food',
      categoryId: 'food',
      categoryName: 'Food & Dining',
      categoryIcon: Icons.restaurant_rounded,
      categoryColor: const Color(0xFFFF8A65),
      limitAmount: 8000.0,
      spentAmount: 2400.0,
      daysLeft: 12,
    ),
    BudgetModel(
      id: 'budget_groceries',
      categoryId: 'groceries',
      categoryName: 'Groceries',
      categoryIcon: Icons.shopping_basket_rounded,
      categoryColor: const Color(0xFF4DB6AC),
      limitAmount: 6000.0,
      spentAmount: 1800.0,
      daysLeft: 12,
    ),
  ];

  Widget createWidgetUnderTest({List<BudgetModel>? budgets}) {
    return ProviderScope(
      overrides: [
        budgetsProvider.overrideWith(
          () => _MockBudgetsNotifier(budgets ?? sampleBudgets),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(body: BudgetScreen()),
      ),
    );
  }

  testWidgets('renders Category Budgets list with cards when budgets exist',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Category Budgets'), findsOneWidget);
    expect(find.text('Set Limit'), findsOneWidget);
    expect(find.byType(BudgetProgressCard), findsNWidgets(2));
    expect(find.text('Food & Dining'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
  });

  testWidgets('renders empty state when no budgets exist', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest(budgets: []));
    await tester.pumpAndSettle();

    expect(find.text('No category budgets active'), findsOneWidget);
    expect(find.text('Set Budget Limit'), findsOneWidget);
  });

  testWidgets('tapping "Set Limit" button opens EditBudgetSheet',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Set Limit'));
    await tester.pumpAndSettle();

    expect(find.byType(EditBudgetSheet), findsOneWidget);
    expect(find.text('Set Category Budget'), findsOneWidget);
    expect(find.text('Save Budget Limit'), findsOneWidget);
  });

  testWidgets('tapping BudgetProgressCard opens EditBudgetSheet in edit mode',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BudgetProgressCard).first);
    await tester.pumpAndSettle();

    expect(find.byType(EditBudgetSheet), findsOneWidget);
    expect(find.text('Edit Category Budget'), findsOneWidget);
    expect(find.byTooltip('Remove Budget'), findsOneWidget);
  });
}
