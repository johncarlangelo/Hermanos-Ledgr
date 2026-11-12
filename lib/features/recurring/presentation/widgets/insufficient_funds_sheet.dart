import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/accounts/providers/accounts_provider.dart';
import 'package:hermanos_ledgr/features/recurring/domain/recurring_auto_log_engine.dart';
import 'package:hermanos_ledgr/features/recurring/providers/recurring_auto_log_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';

/// Modal bottom sheet for resolving recurring transactions paused due to insufficient funds.
/// Offers 3 actions: Change Account, Log Anyway (manual override), or Skip this Cycle.
class InsufficientFundsSheet extends ConsumerStatefulWidget {
  final InsufficientFundsItem item;

  const InsufficientFundsSheet({
    super.key,
    required this.item,
  });

  static Future<void> show(BuildContext context, InsufficientFundsItem item) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => InsufficientFundsSheet(item: item),
    );
  }

  @override
  ConsumerState<InsufficientFundsSheet> createState() => _InsufficientFundsSheetState();
}

class _InsufficientFundsSheetState extends ConsumerState<InsufficientFundsSheet> {
  AccountModel? _selectedAlternativeAccount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final item = widget.item;
    final accounts = ref.watch(accountsProvider);

    final warningColor = SemanticColors.expense(isDark);
    final eligibleAccounts = accounts.where((a) => a.id != item.rule.accountId).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(bottom: Spacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header with Alert Badge
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: warningColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: warningColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Insufficient Balance',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Scheduled payment paused to prevent negative balance',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),

            // Payment & Balance Details Card
            M3Card(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.rule.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(item.requiredAmount),
                        style: moneyStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  const Divider(height: 1),
                  const SizedBox(height: Spacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Account (${item.rule.accountName})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(item.availableBalance),
                        style: moneyStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: item.availableBalance < 0
                              ? warningColor
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Shortfall Needed',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: warningColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '-${CurrencyFormatter.format(item.shortfall)}',
                        style: moneyStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: warningColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.md),

            // Alternative Account Picker Section
            if (eligibleAccounts.isNotEmpty) ...[
              Text(
                'PAY FROM ANOTHER ACCOUNT',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              SizedBox(
                height: 54,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: eligibleAccounts.length,
                  separatorBuilder: (context, index) => const SizedBox(width: Spacing.sm),
                  itemBuilder: (context, index) {
                    final acc = eligibleAccounts[index];
                    final isSelected = _selectedAlternativeAccount?.id == acc.id;
                    final hasSufficient = acc.balance >= item.requiredAmount;

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedAlternativeAccount = isSelected ? null : acc;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(acc.icon, size: 18, color: acc.color),
                            const SizedBox(width: Spacing.xs),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  acc.name,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(acc.balance),
                                  style: moneyStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                    color: hasSufficient
                                        ? SemanticColors.income(isDark)
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: Spacing.md),
            ],

            // Action Buttons
            if (_selectedAlternativeAccount != null) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.of(context).pop();
                    ref.read(pendingInsufficientFundsProvider.notifier).resolveWithAnotherAccount(
                          context,
                          item,
                          _selectedAlternativeAccount!.id,
                          _selectedAlternativeAccount!.name,
                        );
                  },
                  icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                  label: Text('Pay via ${_selectedAlternativeAccount!.name}'),
                ),
              ),
              const SizedBox(height: Spacing.xs),
            ],

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                      ref.read(pendingInsufficientFundsProvider.notifier).resolveSkipCycle(
                            context,
                            item,
                          );
                    },
                    child: const Text('Skip Cycle'),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).pop();
                      ref.read(pendingInsufficientFundsProvider.notifier).resolveLogAnyway(
                            context,
                            item,
                          );
                    },
                    child: const Text('Log Anyway'),
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

