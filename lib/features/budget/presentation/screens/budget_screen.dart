import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/budget/presentation/widgets/budget_progress_card.dart';
import 'package:hermanos_ledgr/features/budget/providers/mock_budgets_provider.dart';
import 'package:hermanos_ledgr/features/transactions/presentation/widgets/add_transaction_sheet.dart';
import 'package:hermanos_ledgr/shared/widgets/empty_state_view.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';

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
                      'September 2026',
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
            for (final budget in budgets) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.sm),
                child: BudgetProgressCard(budget: budget),
              ),
            ],

          const SizedBox(height: Spacing.xl),

          // 4. Savings Goals Preview Card
          M3Card(
            padding: const EdgeInsets.all(Spacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.flag_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency Fund Goal',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '₱125,000 / ₱200,000 (62%)',
                        style: moneyStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
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
