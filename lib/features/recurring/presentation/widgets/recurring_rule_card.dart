import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/constants/category_defaults.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/recurring/domain/recurring_model.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';

/// Card widget displaying a recurring rule or subscription (Task 8.4).
/// Complies with Zero Stock Android Native UI: custom animated switch, tailored actions sheet.
class RecurringRuleCard extends StatelessWidget {
  final RecurringModel rule;
  final VoidCallback? onToggleActive;
  final VoidCallback? onEdit;
  final VoidCallback? onLogNow;
  final VoidCallback? onDelete;

  const RecurringRuleCard({
    super.key,
    required this.rule,
    this.onToggleActive,
    this.onEdit,
    this.onLogNow,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryAccent = rule.isIncome
        ? SemanticColors.income(isDark)
        : SemanticColors.expense(isDark);

    final cat = CategoryDefaults.defaultCategories.firstWhere(
      (c) => c.id == rule.categoryId,
      orElse: () => CategoryDefaults.defaultCategories.first,
    );

    final dueDateStr = DateFormat('MMM d, yyyy').format(rule.nextDueDate);
    final daysUntil = rule.daysUntilDue;

    return M3Card(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top row: Icon + Title + Frequency Badge + Custom Animated Switch
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Category Icon Badge
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(cat.icon, size: 20, color: cat.color),
              ),
              const SizedBox(width: Spacing.md),

              // Title & Category / Account
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            rule.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              decoration: rule.isActive
                                  ? TextDecoration.none
                                  : TextDecoration.lineThrough,
                              color: rule.isActive
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: Spacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            rule.frequency.displayName,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${rule.accountName} · ${rule.categoryName}',
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

              // Custom Animated Toggle Switch (Zero stock Switch rule)
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onToggleActive?.call();
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 46,
                  height: 26,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: rule.isActive
                        ? StashColors.tealAccent
                        : (isDark ? StashColors.dim : theme.colorScheme.outlineVariant),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    alignment: rule.isActive
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: Spacing.xs),
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

          // 2. Amount & Monthly Normalization Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${rule.isExpense ? '-' : '+'}${CurrencyFormatter.format(rule.amount)}',
                style: moneyStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: rule.isActive ? primaryAccent : theme.colorScheme.outline,
                ),
              ),
              if (rule.frequency != RecurringFrequency.monthly)
                Text(
                  '≈ ${CurrencyFormatter.format(rule.monthlyEquivalent)}/mo',
                  style: moneyStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? StashColors.dim : theme.colorScheme.outline,
                  ),
                ),
            ],
          ),

          const SizedBox(height: Spacing.sm),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: Spacing.sm),

          // 3. Due Date Pill & Next Occurrence
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_repeat_rounded,
                    size: 14,
                    color: rule.isDue
                        ? SemanticColors.expense(isDark)
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    'Next: $dueDateStr',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              _buildDueBadge(theme, isDark, daysUntil),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDueBadge(ThemeData theme, bool isDark, int daysUntil) {
    if (!rule.isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Paused',
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    if (daysUntil < 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: SemanticColors.expense(isDark).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '${daysUntil.abs()}d overdue',
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: SemanticColors.expense(isDark),
          ),
        ),
      );
    } else if (daysUntil == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: SemanticColors.expense(isDark).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Due Today',
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: SemanticColors.expense(isDark),
          ),
        ),
      );
    } else if (daysUntil <= 3) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'In $daysUntil days',
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF59E0B),
          ),
        ),
      );
    } else {
      return Text(
        'In $daysUntil days',
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 11,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
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
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.md),
              Text(
                rule.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              ListTile(
                leading: const Icon(Icons.flash_on_rounded, color: StashColors.tealAccent),
                title: const Text('Log Instance Now'),
                subtitle: const Text('Creates a transaction and advances next due date'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onLogNow?.call();
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit Rule'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onEdit?.call();
                },
              ),
              ListTile(
                leading: Icon(
                  rule.isActive ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                ),
                title: Text(rule.isActive ? 'Pause Rule' : 'Resume Rule'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onToggleActive?.call();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline_rounded, color: SemanticColors.expense(isDark)),
                title: Text(
                  'Delete Rule',
                  style: TextStyle(color: SemanticColors.expense(isDark)),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onDelete?.call();
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
