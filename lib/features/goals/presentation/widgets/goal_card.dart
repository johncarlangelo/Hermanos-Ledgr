import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/goals/domain/goal_model.dart';
import 'package:hermanos_ledgr/features/goals/presentation/widgets/goal_progress_ring.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';

/// Card displaying a single savings goal with radial progress,
/// monthly contribution pacing (Task 6.8), and quick contribution action.
class GoalCard extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback? onContribute;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const GoalCard({
    super.key,
    required this.goal,
    this.onContribute,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAchieved = goal.isAchieved;

    final targetDateStr = goal.targetDate != null
        ? DateFormat('MMM yyyy').format(goal.targetDate!)
        : null;

    final daysLeft = goal.remainingDays;

    return M3Card(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Title + Progress Ring
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: goal.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  goal.icon,
                  size: 22,
                  color: goal.color,
                ),
              ),
              const SizedBox(width: Spacing.md),

              // Title and Deadline Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            goal.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isAchieved) ...[
                          const SizedBox(width: Spacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: SemanticColors.income(isDark)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Goal Met 🎉',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: SemanticColors.income(isDark),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    if (targetDateStr != null)
                      Text(
                        daysLeft != null && daysLeft > 0
                            ? 'Target: $targetDateStr · $daysLeft days left'
                            : 'Target: $targetDateStr',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11.5,
                        ),
                      )
                    else
                      Text(
                        'Open-ended goal',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11.5,
                        ),
                      ),
                  ],
                ),
              ),

              // Radial Progress Ring
              GoalProgressRing(
                percentage: goal.percentage,
                color: isAchieved ? SemanticColors.income(isDark) : goal.color,
                size: 50,
                strokeWidth: 4.5,
              ),
            ],
          ),

          const SizedBox(height: Spacing.md),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: goal.percentage,
              minHeight: 6,
              backgroundColor: isDark
                  ? StashColors.raised
                  : theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                isAchieved ? SemanticColors.income(isDark) : goal.color,
              ),
            ),
          ),

          const SizedBox(height: Spacing.sm),

          // Saved vs Target Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: CurrencyFormatter.format(goal.currentAmount),
                          style: moneyStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        TextSpan(
                          text: ' of ${CurrencyFormatter.format(goal.targetAmount)}',
                          style: moneyStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.xs),
              if (!isAchieved)
                Text(
                  '${CurrencyFormatter.format(goal.remainingAmount)} left',
                  style: moneyStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? StashColors.dim : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),

          // Smart Monthly Run-Rate Pill (Task 6.8)
          if (!isAchieved && goal.monthlyContributionNeeded > 0) ...[
            const SizedBox(height: Spacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.xs + 2,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? StashColors.base.withValues(alpha: 0.6)
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    size: 15,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: Spacing.xs + 2),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Pace: ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: '${CurrencyFormatter.format(goal.monthlyContributionNeeded)}/mo',
                            style: moneyStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          TextSpan(
                            text: ' needed to finish on time',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: Spacing.md),

          // Actions Row: Add Contribution Button & Options
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: isAchieved
                        ? SemanticColors.income(isDark)
                        : (isDark ? StashColors.raised : theme.colorScheme.surfaceContainerHigh),
                    foregroundColor: isAchieved
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                    minimumSize: const Size.fromHeight(38),
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isAchieved
                            ? Colors.transparent
                            : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  icon: Icon(
                    isAchieved ? Icons.check_circle_outline_rounded : Icons.add_rounded,
                    size: 17,
                  ),
                  label: Text(
                    isAchieved ? 'Goal Completed' : 'Add Contribution',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                  onPressed: onContribute,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 19),
                tooltip: 'Edit Goal',
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onEdit?.call();
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 19,
                  color: SemanticColors.expense(isDark),
                ),
                tooltip: 'Delete Goal',
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onDelete?.call();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
