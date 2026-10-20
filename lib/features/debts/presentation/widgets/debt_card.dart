import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/debts/domain/debt_model.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';

/// Card widget displaying a debt or receivable with payoff progress,
/// due date indicator, and payment action triggers (Task 7.5).
class DebtCard extends StatelessWidget {
  final DebtModel debt;
  final VoidCallback? onRecordPayment;
  final VoidCallback? onEdit;
  final VoidCallback? onSettle;
  final VoidCallback? onDelete;

  const DebtCard({
    super.key,
    required this.debt,
    this.onRecordPayment,
    this.onEdit,
    this.onSettle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isReceivable = debt.type == DebtType.receivable;
    final isSettled = debt.isSettled;

    final primaryAccent = isReceivable
        ? SemanticColors.income(isDark)
        : SemanticColors.expense(isDark);

    final dueDateStr = debt.dueDate != null
        ? DateFormat('MMM d, yyyy').format(debt.dueDate!)
        : null;

    final initials = _getInitials(debt.personName);

    return M3Card(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Avatar + Person Name + Status Pill + More Menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Person Avatar Badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primaryAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: primaryAccent,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),

              // Person Name & Note
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            debt.personName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: Spacing.xs),
                        _buildStatusBadge(theme, isDark),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      debt.note != null && debt.note!.isNotEmpty
                          ? debt.note!
                          : (isReceivable ? 'Money lent' : 'Personal debt'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Action Popup / Quick Menu
              if (onEdit != null || onDelete != null || onSettle != null)
                IconButton(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: () => _showActionsSheet(context),
                  tooltip: 'Options',
                ),
            ],
          ),

          const SizedBox(height: Spacing.md),

          // 2. Payoff Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: debt.paidPercentage,
              minHeight: 6,
              backgroundColor: isDark
                  ? StashColors.raised
                  : theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                isSettled ? SemanticColors.income(isDark) : primaryAccent,
              ),
            ),
          ),

          const SizedBox(height: Spacing.sm),

          // 3. Amount Numbers Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSettled
                          ? 'Settled'
                          : (isReceivable ? 'Remaining to collect' : 'Remaining to pay'),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10.5,
                      ),
                    ),
                    const SizedBox(height: 1),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        isSettled
                            ? CurrencyFormatter.format(debt.originalAmount)
                            : CurrencyFormatter.format(debt.remainingAmount),
                        style: moneyStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isSettled
                              ? theme.colorScheme.onSurfaceVariant
                              : primaryAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Original: ${CurrencyFormatter.format(debt.originalAmount)}',
                    style: moneyStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${debt.progressPercent}% paid (${CurrencyFormatter.format(debt.paidAmount)})',
                    style: moneyStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? StashColors.dim : theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 4. Due Date Banner & Action Button Row
          if (!isSettled) ...[
            const SizedBox(height: Spacing.md),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: Spacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: debt.isOverdue
                            ? SemanticColors.expense(isDark)
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Flexible(
                        child: Text(
                          dueDateStr != null
                              ? 'Due: $dueDateStr'
                              : 'No deadline set',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: debt.isOverdue
                                ? SemanticColors.expense(isDark)
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight:
                                debt.isOverdue ? FontWeight.w700 : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                if (onRecordPayment != null)
                  FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                        vertical: 0,
                      ),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: onRecordPayment,
                    child: Text(
                      isReceivable ? 'Record Payment' : 'Pay Debt',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, bool isDark) {
    if (debt.isSettled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: SemanticColors.income(isDark).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Settled 🎉',
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: SemanticColors.income(isDark),
          ),
        ),
      );
    }

    if (debt.isOverdue) {
      final days = debt.remainingDays != null ? debt.remainingDays!.abs() : 0;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: SemanticColors.expense(isDark).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          days > 0 ? '$days d overdue' : 'Overdue',
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: SemanticColors.expense(isDark),
          ),
        ),
      );
    }

    if (debt.remainingDays != null && debt.remainingDays! <= 7) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Due in ${debt.remainingDays} d',
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF59E0B),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showActionsSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  debt.personName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.md),
                if (!debt.isSettled && onRecordPayment != null)
                  ListTile(
                    leading: const Icon(Icons.payments_outlined),
                    title: const Text('Record Partial Payment'),
                    onTap: () {
                      Navigator.pop(ctx);
                      onRecordPayment?.call();
                    },
                  ),
                if (!debt.isSettled && onSettle != null)
                  ListTile(
                    leading: Icon(
                      Icons.check_circle_outline_rounded,
                      color: SemanticColors.income(isDark),
                    ),
                    title: const Text('Mark as Fully Settled'),
                    onTap: () {
                      Navigator.pop(ctx);
                      onSettle?.call();
                    },
                  ),
                if (onEdit != null)
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text('Edit Details'),
                    onTap: () {
                      Navigator.pop(ctx);
                      onEdit?.call();
                    },
                  ),
                if (onDelete != null)
                  ListTile(
                    leading: Icon(
                      Icons.delete_outline_rounded,
                      color: SemanticColors.expense(isDark),
                    ),
                    title: Text(
                      'Delete Record',
                      style: TextStyle(color: SemanticColors.expense(isDark)),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      onDelete?.call();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
