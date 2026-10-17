import 'package:flutter/material.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';
import 'package:hermanos_ledgr/features/transactions/presentation/widgets/add_transaction_sheet.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              context: context,
              icon: Icons.arrow_downward_rounded,
              label: 'Expense',
              color: SemanticColors.expense(isDark),
              onTap: () => AddTransactionSheet.show(
                context,
                initialType: TransactionType.expense,
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: _buildActionCard(
              context: context,
              icon: Icons.arrow_upward_rounded,
              label: 'Income',
              color: SemanticColors.income(isDark),
              onTap: () => AddTransactionSheet.show(
                context,
                initialType: TransactionType.income,
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: _buildActionCard(
              context: context,
              icon: Icons.swap_horiz_rounded,
              label: 'Transfer',
              color: SemanticColors.transfer(isDark),
              onTap: () => AddTransactionSheet.show(
                context,
                initialType: TransactionType.transfer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return M3Card(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: Spacing.md),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
