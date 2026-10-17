import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/goals/presentation/widgets/add_contribution_sheet.dart';
import 'package:hermanos_ledgr/features/goals/presentation/widgets/add_goal_sheet.dart';
import 'package:hermanos_ledgr/features/goals/presentation/widgets/delete_goal_sheet.dart';
import 'package:hermanos_ledgr/features/goals/presentation/widgets/goal_card.dart';
import 'package:hermanos_ledgr/features/goals/providers/goals_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/empty_state_view.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';

/// Full-featured Goals Screen for Hermanos Ledgr (Phase 6).
/// Displays overall savings goal summary, active goals, completed goals,
/// and smart monthly pacing calculators.
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final allGoals = ref.watch(goalsProvider);
    final activeGoals = ref.watch(activeGoalsProvider);
    final completedGoals = ref.watch(completedGoalsProvider);
    final totalSaved = ref.watch(totalGoalsSavedProvider);
    final totalTarget = ref.watch(totalGoalsTargetProvider);
    final monthlyNeeded = ref.watch(totalMonthlyContributionNeededProvider);

    final overallPercent = totalTarget > 0
        ? ((totalSaved / totalTarget) * 100).clamp(0, 100).toInt()
        : 0;

    return Scaffold(
      appBar: AppBar(
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Text('Savings Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Add Goal',
            onPressed: () => AddGoalSheet.show(context),
          ),
        ],
      ),
      body: allGoals.isEmpty
          ? Center(
              child: EmptyStateView(
                icon: Icons.savings_outlined,
                title: 'No savings goals set',
                subtitle:
                    'Create milestones for emergency funds, travel, or big purchases to track your progress and monthly run-rate.',
                actionLabel: 'Create First Goal',
                onAction: () => AddGoalSheet.show(context),
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
                vertical: Spacing.md,
              ),
              children: [
                // 1. Overall Savings Summary Hero Card
                M3Card(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Goals Progress',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$overallPercent% Saved',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.md),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            CurrencyFormatter.format(totalSaved),
                            style: moneyStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: Spacing.xs),
                          Text(
                            'of ${CurrencyFormatter.format(totalTarget)}',
                            style: moneyStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.sm),

                      // Linear overall bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0,
                          minHeight: 8,
                          backgroundColor: isDark
                              ? StashColors.raised
                              : theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ),

                      if (monthlyNeeded > 0) ...[
                        const SizedBox(height: Spacing.md),
                        Container(
                          padding: const EdgeInsets.all(Spacing.sm + 2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? StashColors.base.withValues(alpha: 0.6)
                                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: Spacing.sm),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(text: 'Monthly Pace: '),
                                      TextSpan(
                                        text: CurrencyFormatter.format(monthlyNeeded),
                                        style: moneyStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: '/mo needed across active goals',
                                      ),
                                    ],
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.xl),

                // 2. Active Goals Section
                if (activeGoals.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ACTIVE GOALS (${activeGoals.length})',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: theme.colorScheme.primary,
                        ),
                      ),
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
                  for (final goal in activeGoals) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.md),
                      child: GoalCard(
                        goal: goal,
                        onContribute: () =>
                            AddContributionSheet.show(context, goal),
                        onEdit: () => AddGoalSheet.edit(context, goal),
                        onDelete: () => DeleteGoalSheet.show(context, goal),
                      ),
                    ),
                  ],
                ],

                // 3. Completed Goals Section
                if (completedGoals.isNotEmpty) ...[
                  const SizedBox(height: Spacing.md),
                  Text(
                    'COMPLETED GOALS (${completedGoals.length})',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: SemanticColors.income(isDark),
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  for (final goal in completedGoals) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.md),
                      child: GoalCard(
                        goal: goal,
                        onContribute: () =>
                            AddContributionSheet.show(context, goal),
                        onEdit: () => AddGoalSheet.edit(context, goal),
                        onDelete: () => DeleteGoalSheet.show(context, goal),
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: Spacing.xxl),
              ],
            ),
    );
  }
}
