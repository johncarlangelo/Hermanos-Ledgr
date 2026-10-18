import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/budget/presentation/widgets/budget_progress_card.dart';
import 'package:hermanos_ledgr/features/budget/providers/mock_budgets_provider.dart';
import 'package:hermanos_ledgr/features/debts/providers/debts_provider.dart';
import 'package:hermanos_ledgr/features/recurring/providers/recurring_provider.dart';
import 'package:hermanos_ledgr/features/goals/presentation/widgets/add_contribution_sheet.dart';
import 'package:hermanos_ledgr/features/goals/presentation/widgets/add_goal_sheet.dart';
import 'package:hermanos_ledgr/features/goals/presentation/widgets/delete_goal_sheet.dart';
import 'package:hermanos_ledgr/features/goals/presentation/widgets/goal_card.dart';
import 'package:hermanos_ledgr/features/goals/providers/goals_provider.dart';
import 'package:hermanos_ledgr/features/transactions/presentation/widgets/add_transaction_sheet.dart';
import 'package:hermanos_ledgr/shared/widgets/empty_state_view.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';
import 'package:hermanos_ledgr/shared/widgets/motion_wrapper.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  int _touchedSectionIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final budgets = ref.watch(budgetsProvider);
    final totalSpent = ref.watch(totalBudgetSpentProvider);
    final totalLimit = ref.watch(totalBudgetLimitProvider);

    final overallPercent = totalLimit > 0
        ? ((totalSpent / totalLimit) * 100).toInt()
        : 0;

    final goals = ref.watch(goalsProvider);
    final totalPayable = ref.watch(totalPayableAmountProvider);
    final totalReceivable = ref.watch(totalReceivableAmountProvider);
    final monthlyRecurring = ref.watch(monthlyRecurringExpenseProvider);
    final activeRecurring = ref.watch(activeRecurringProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget & Planning'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
        children: [
          // 1. Monthly Budget Summary Hero Card
          M3Card(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Monthly Budget',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(DateTime.now()),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      CurrencyFormatter.format(totalSpent),
                      style: moneyStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'of ${CurrencyFormatter.format(totalLimit)}',
                      style: moneyStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),

                // Overall progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: totalLimit > 0
                        ? (totalSpent / totalLimit).clamp(0.0, 1.0)
                        : 0.0,
                    minHeight: 6,
                    backgroundColor: theme.colorScheme.surfaceContainerHigh,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      overallPercent > 100
                          ? SemanticColors.budgetOver(isDark)
                          : overallPercent >= 75
                              ? SemanticColors.budgetCaution(isDark)
                              : SemanticColors.budgetSafe(isDark),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.sm),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$overallPercent% of total budget used',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      totalLimit >= totalSpent
                          ? '${CurrencyFormatter.format(totalLimit - totalSpent)} left'
                          : '${CurrencyFormatter.format(totalSpent - totalLimit)} over',
                      style: moneyStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: totalLimit >= totalSpent
                            ? SemanticColors.income(isDark)
                            : SemanticColors.expense(isDark),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),

          // 2. Spending Breakdown Donut Chart
          M3Card(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Spending by Category',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                if (budgets.isEmpty || totalSpent == 0)
                  SizedBox(
                    height: 120,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.pie_chart_outline_rounded,
                            size: 32,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: Spacing.xs),
                          Text(
                            'No category expenses logged yet',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 180,
                    child: RepaintBoundary(
                      child: PieChart(
                        PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                _touchedSectionIndex = -1;
                                return;
                              }
                              _touchedSectionIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 3,
                        centerSpaceRadius: 46,
                        sections: budgets.asMap().entries.map((entry) {
                          final i = entry.key;
                          final b = entry.value;
                          final isTouched = i == _touchedSectionIndex;
                          final radius = isTouched ? 42.0 : 36.0;

                          return PieChartSectionData(
                            color: b.categoryColor,
                            value: b.spentAmount,
                            title: isTouched
                                ? CurrencyFormatter.formatCompact(b.spentAmount)
                                : '',
                            radius: radius,
                            titleStyle: moneyStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),

          // 3. Category Budgets Header & List
          Text(
            'Category Budgets',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Spacing.sm),

          if (budgets.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.md),
              child: EmptyStateView(
                icon: Icons.track_changes_rounded,
                title: 'No category budgets active',
                subtitle:
                    'Budgets and category spending will appear as you log transactions.',
                actionLabel: 'Log Expense',
                onAction: () => AddTransactionSheet.show(context),
              ),
            )
          else
            for (var i = 0; i < budgets.length; i++) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.sm),
                child: StaggeredEntrance(
                  index: i.clamp(0, 10),
                  child: BudgetProgressCard(budget: budgets[i]),
                ),
              ),
            ],

          const SizedBox(height: Spacing.xl),

          // 4. Savings Goals Section (Phase 6)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  goals.isNotEmpty
                      ? 'SAVINGS GOALS (${goals.length})'
                      : 'SAVINGS GOALS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: theme.colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              if (goals.isNotEmpty)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                  label: const Text('View All'),
                  onPressed: () => context.push('/goals'),
                )
              else
                TextButton.icon(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add Goal'),
                  onPressed: () => AddGoalSheet.show(context),
                ),
            ],
          ),
          const SizedBox(height: Spacing.xs),

          if (goals.isEmpty)
            M3Card(
              padding: const EdgeInsets.all(Spacing.md),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.savings_rounded,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Track Savings Milestones',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Set targets for emergency funds, travel, or gear with monthly pacing.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                    ),
                    onPressed: () => AddGoalSheet.show(context),
                    child: const Text('New Goal'),
                  ),
                ],
              ),
            )
          else ...[
            for (final goal in goals.take(2)) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.sm),
                child: GoalCard(
                  goal: goal,
                  onContribute: () => AddContributionSheet.show(context, goal),
                  onEdit: () => AddGoalSheet.edit(context, goal),
                  onDelete: () => DeleteGoalSheet.show(context, goal),
                ),
              ),
            ],
            if (goals.length > 2) ...[
              Center(
                child: TextButton(
                  onPressed: () => context.push('/goals'),
                  child: Text('View ${goals.length - 2} more goals...'),
                ),
              ),
            ],
          ],
          const SizedBox(height: Spacing.lg),

          // 4. Debts & Receivables Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'DEBTS & RECEIVABLES',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: theme.colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              TextButton.icon(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                label: const Text('View All'),
                onPressed: () => context.push('/debts'),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          M3Card(
            onTap: () => context.push('/debts'),
            padding: const EdgeInsets.all(Spacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'I Owe',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.format(totalPayable),
                        style: moneyStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: totalPayable > 0
                              ? SemanticColors.expense(isDark)
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Owed to Me',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.format(totalReceivable),
                        style: moneyStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: totalReceivable > 0
                              ? SemanticColors.income(isDark)
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 20),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),

          // 5. Recurring & Forecast Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'RECURRING & FORECAST',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: theme.colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              TextButton.icon(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                label: const Text('View All'),
                onPressed: () => context.push('/recurring'),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          M3Card(
            onTap: () => context.push('/recurring'),
            padding: const EdgeInsets.all(Spacing.md),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: StashColors.tealAccent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.event_repeat_rounded,
                    size: 22,
                    color: StashColors.tealAccent,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Subscriptions',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${CurrencyFormatter.format(monthlyRecurring)}/mo (${activeRecurring.length} active rules)',
                        style: moneyStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.auto_graph_rounded, size: 20),
                  tooltip: 'Cashflow Forecast',
                  onPressed: () => context.push('/forecast'),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xxl),
        ],
      ),
    );
  }
}
