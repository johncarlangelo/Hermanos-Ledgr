import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/recurring/presentation/widgets/insufficient_funds_sheet.dart';
import 'package:hermanos_ledgr/features/recurring/providers/recurring_auto_log_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';

/// Reusable banner warning user of recurring payments paused due to low account balance.
/// Displayed prominently on Dashboard and Recurring screens.
class InsufficientFundsBanner extends ConsumerWidget {
  const InsufficientFundsBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pendingItems = ref.watch(pendingInsufficientFundsProvider);

    if (pendingItems.isEmpty) return const SizedBox.shrink();

    final warningColor = SemanticColors.expense(isDark);
    final firstItem = pendingItems.first;
    final hasMultiple = pendingItems.length > 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.md),
      child: M3Card(
        color: warningColor.withValues(alpha: 0.08),
        padding: const EdgeInsets.all(Spacing.md),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: warningColor.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.pause_circle_outline_rounded,
                color: warningColor,
                size: 22,
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        hasMultiple
                            ? '${pendingItems.length} Payments Paused'
                            : 'Payment Paused: ${firstItem.rule.title}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasMultiple
                        ? 'Low balance on scheduled accounts. Tap to resolve.'
                        : '${CurrencyFormatter.format(firstItem.requiredAmount)} due on ${firstItem.rule.accountName} (Balance: ${CurrencyFormatter.format(firstItem.availableBalance)})',
                    style: moneyStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.sm),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                backgroundColor: warningColor.withValues(alpha: 0.18),
                foregroundColor: warningColor,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                InsufficientFundsSheet.show(context, firstItem);
              },
              child: const Text('Resolve', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

