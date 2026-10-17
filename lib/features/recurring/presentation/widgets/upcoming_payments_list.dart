import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/constants/category_defaults.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/recurring/domain/forecast_engine.dart';
import 'package:hermanos_ledgr/shared/widgets/empty_state_view.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';

/// List widget displaying scheduled upcoming payments and income (Task 8.9).
class UpcomingPaymentsList extends StatelessWidget {
  final List<ScheduledOccurrence> occurrences;
  final void Function(ScheduledOccurrence item)? onLogEarly;

  const UpcomingPaymentsList({
    super.key,
    required this.occurrences,
    this.onLogEarly,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (occurrences.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: Spacing.xl),
        child: EmptyStateView(
          icon: Icons.calendar_month_rounded,
          title: 'No upcoming payments',
          subtitle: 'No recurring transactions or subscriptions fall within this forecast window.',
        ),
      );
    }

    final today = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in occurrences) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: _buildOccurrenceTile(context, theme, isDark, item, today),
          ),
        ],
      ],
    );
  }

  Widget _buildOccurrenceTile(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    ScheduledOccurrence item,
    DateTime today,
  ) {
    final primaryAccent = item.isExpense
        ? SemanticColors.expense(isDark)
        : SemanticColors.income(isDark);

    final cat = CategoryDefaults.defaultCategories.firstWhere(
      (c) => c.id == item.rule.categoryId,
      orElse: () => CategoryDefaults.defaultCategories.first,
    );

    final daysUntil = DateTime(item.date.year, item.date.month, item.date.day)
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;

    final dateStr = DateFormat('MMM d, EEE').format(item.date);
    final daysStr = daysUntil == 0
        ? 'Today'
        : (daysUntil == 1 ? 'Tomorrow' : 'In $daysUntil days');

    return M3Card(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.md),
      child: Row(
        children: [
          // Date Badge Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('MMM').format(item.date).toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${item.date.day}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.md),

          // Title & Account details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.rule.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: Spacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: cat.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        daysStr,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: cat.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.rule.accountName} · $dateStr',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Amount Row & Action
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.isExpense ? '-' : '+'}${CurrencyFormatter.format(item.amount)}',
                style: moneyStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: primaryAccent,
                ),
              ),
              if (onLogEarly != null && daysUntil <= 7) ...[
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: () => onLogEarly?.call(item),
                  child: Text(
                    'Log early',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
