import 'package:flutter/material.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';

class AccountCard extends StatelessWidget {
  final AccountModel account;
  final VoidCallback? onTap;

  const AccountCard({
    super.key,
    required this.account,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final balanceColor = account.balance < 0
        ? SemanticColors.expense(isDark)
        : theme.colorScheme.onSurface;

    return SizedBox(
      width: 210,
      child: M3Card(
        onTap: onTap,
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Icon + Type
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: account.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    account.icon,
                    size: 20,
                    color: account.color,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.xs + 2,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    account.typeLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),

            // Middle: Name
            Text(
              account.name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),

            // Bottom: Balance with Tabular figures + monthly change
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  CurrencyFormatter.format(account.balance),
                  style: moneyStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: balanceColor,
                  ),
                ),
                if (account.monthlyChange != 0)
                  Text(
                    account.monthlyChange >= 0
                        ? '+₱${account.monthlyChange.toInt()}'
                        : '-₱${account.monthlyChange.abs().toInt()}',
                    style: moneyStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: account.monthlyChange >= 0
                          ? SemanticColors.income(isDark)
                          : SemanticColors.expense(isDark),
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
