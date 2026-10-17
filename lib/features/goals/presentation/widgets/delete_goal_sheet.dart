import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/goals/domain/goal_model.dart';
import 'package:hermanos_ledgr/features/goals/providers/goals_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Custom bottom sheet confirming deletion of a savings goal.
/// Strictly follows Zero Stock Android Native UI (no AlertDialog).
class DeleteGoalSheet extends ConsumerWidget {
  final GoalModel goal;

  const DeleteGoalSheet({
    super.key,
    required this.goal,
  });

  static Future<void> show(BuildContext context, GoalModel goal) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => DeleteGoalSheet(goal: goal),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dangerColor = SemanticColors.expense(isDark);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: Spacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: dangerColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: dangerColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delete Savings Goal?',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        goal.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Text(
              'Are you sure you want to delete "${goal.name}"? Current saved progress of ${CurrencyFormatter.format(goal.currentAmount)} will be removed from your goal tracker.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: Spacing.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: dangerColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      final deleted = await ref
                          .read(goalsProvider.notifier)
                          .deleteGoal(goal.id);
                      if (!context.mounted) return;
                      Navigator.of(context).pop();

                      if (deleted != null) {
                        UndoSnackbar.show(
                          context,
                          message: 'Deleted goal: ${deleted.name}',
                          onUndo: () {
                            ref.read(goalsProvider.notifier).addGoal(deleted);
                          },
                        );
                      }
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
          ],
        ),
      ),
    );
  }
}
