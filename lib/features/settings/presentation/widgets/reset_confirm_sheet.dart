import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/core/providers/database_provider.dart';
import 'package:hermanos_ledgr/core/providers/onboarding_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Custom bottom sheet for confirming data reset operations.
/// Replaces native AlertDialog with tailored Stash container styling.
class ResetConfirmSheet extends ConsumerWidget {
  final bool isFullReset;

  const ResetConfirmSheet({
    super.key,
    this.isFullReset = false,
  });

  static Future<void> show(BuildContext context, {bool isFullReset = false}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      builder: (_) => ResetConfirmSheet(isFullReset: isFullReset),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dangerColor = SemanticColors.expense(isDark);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.lg,
          Spacing.xs,
          Spacing.lg,
          Spacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: dangerColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 24,
                    color: dangerColor,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFullReset ? 'Reset All Ledger Data?' : 'Replay Onboarding Setup?',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: dangerColor,
                        ),
                      ),
                      Text(
                        isFullReset
                            ? 'This will wipe all transactions and restore starter accounts.'
                            : 'You will be guided through initial setup again.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            Container(
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                color: isDark ? StashColors.raised : theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: dangerColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: dangerColor),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      isFullReset
                          ? 'This action cannot be undone. Make sure you have exported your data if needed.'
                          : 'Your recorded transactions will not be deleted, but onboarding flags will reset.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
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
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      if (isFullReset) {
                        await ref.read(databaseProvider).clearAndReseed();
                        if (context.mounted) {
                          UndoSnackbar.info(
                            context,
                            message: 'All ledger data has been reset to defaults',
                          );
                        }
                      } else {
                        await ref.read(onboardingProvider.notifier).resetOnboarding();
                        if (context.mounted) {
                          context.go('/onboarding');
                        }
                      }
                    },
                    child: Text(isFullReset ? 'Reset Data' : 'Restart Setup'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
