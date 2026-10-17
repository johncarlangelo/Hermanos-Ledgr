import 'package:flutter/material.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/dashboard/providers/dashboard_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/hero_amount_display.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';

class NetWorthHeroCard extends StatelessWidget {
  final DashboardData data;

  const NetWorthHeroCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return M3Card(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Net Worth with Count-up animation
          HeroAmountDisplay(
            label: 'Net Worth',
            amount: data.netWorth,
            changeAmount: data.monthlyNetChange,
            changeLabel: 'this month',
          ),
          const SizedBox(height: Spacing.lg),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: Spacing.md),

          // Total Assets vs Total Liabilities breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Assets',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(data.totalAssets),
                      style: moneyStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: SemanticColors.income(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Liabilities',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(data.totalLiabilities),
                      style: moneyStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: SemanticColors.expense(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Monthly Cashflow summary pill if there is activity this month
          if (data.monthlyIncome > 0 || data.monthlyExpenses > 0) ...[
            const SizedBox(height: Spacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.xs + 2,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? StashColors.raised
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.savings_outlined,
                          size: 14,
                          color: isDark ? StashColors.tealAccent : theme.colorScheme.primary,
                        ),
                        const SizedBox(width: Spacing.xs),
                        Flexible(
                          child: Text(
                            'Savings Rate: ${data.savingsRate.toStringAsFixed(0)}%',
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark ? StashColors.tealAccent : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    'Net: ${data.monthlyNetChange >= 0 ? "+" : ""}${CurrencyFormatter.formatCompact(data.monthlyNetChange)}',
                    style: moneyStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: data.monthlyNetChange >= 0
                          ? SemanticColors.income(isDark)
                          : SemanticColors.expense(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
