import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final amountColor = switch (transaction.type) {
      TransactionType.expense => SemanticColors.expense(isDark),
      TransactionType.income => SemanticColors.income(isDark),
      TransactionType.transfer => SemanticColors.transfer(isDark),
    };

    final amountPrefix = switch (transaction.type) {
      TransactionType.expense => '-',
      TransactionType.income => '+',
      TransactionType.transfer => '',
    };

    final timeFormat = DateFormat('h:mm a');
    final formattedTime = timeFormat.format(transaction.date);

    Widget cardContent = M3Card(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.md,
      ),
      child: Row(
        children: [
          // 40dp circle with category color at 12% opacity
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: transaction.categoryColor.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.categoryIcon,
              size: 20,
              color: transaction.categoryColor,
            ),
          ),
          const SizedBox(width: Spacing.md),

          // Title & Note/Timestamp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      formattedTime,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    if (transaction.note != null &&
                        transaction.note!.isNotEmpty) ...[
                      Text(
                        ' · ',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          transaction.note!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                // Micro tag for account
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
                    transaction.type == TransactionType.transfer
                        ? '${transaction.accountName} ➔ ${transaction.destinationAccountName ?? "Account"}'
                        : transaction.accountName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: Spacing.sm),

          // Amount right-aligned with Tabular Figures
          Text(
            '$amountPrefix${CurrencyFormatter.format(transaction.amount)}',
            style: moneyStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: amountColor,
            ),
          ),
        ],
      ),
    );

    if (onDelete != null || onTap != null) {
      final accentColor = isDark ? StashColors.tealAccent : theme.colorScheme.primary;

      return Dismissible(
        key: ValueKey(transaction.id),
        direction: (onDelete != null && onTap != null)
            ? DismissDirection.horizontal
            : (onDelete != null
                ? DismissDirection.endToStart
                : DismissDirection.startToEnd),
        // Swipe Right Background (Edit)
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: Spacing.xl),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_rounded, color: Colors.white, size: 22),
              SizedBox(width: Spacing.sm),
              Text(
                'Edit',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        // Swipe Left Secondary Background (Delete)
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: Spacing.xl),
          decoration: BoxDecoration(
            color: SemanticColors.expense(isDark).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              SizedBox(width: Spacing.sm),
              Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            onTap?.call();
            return false; // Do not dismiss card from tree
          }
          return true; // Dismiss card on delete
        },
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            onDelete?.call();
          }
        },
        child: cardContent,
      );
    }

    return cardContent;
  }
}
