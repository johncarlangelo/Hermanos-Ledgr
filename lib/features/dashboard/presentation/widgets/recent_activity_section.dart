import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';
import 'package:hermanos_ledgr/features/transactions/presentation/widgets/add_transaction_sheet.dart';
import 'package:hermanos_ledgr/features/transactions/presentation/widgets/transaction_card.dart';
import 'package:hermanos_ledgr/shared/widgets/empty_state_view.dart';
import 'package:hermanos_ledgr/shared/widgets/motion_wrapper.dart';

class RecentActivitySection extends StatelessWidget {
  final List<TransactionModel> transactions;

  const RecentActivitySection({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Recent Activity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/transactions'),
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.xs),

        // List Content
        if (transactions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: EmptyStateView(
              icon: Icons.receipt_long_outlined,
              title: 'No recent transactions',
              subtitle: 'Start tracking your spending by adding an expense.',
              actionLabel: 'Log Expense',
              onAction: () => AddTransactionSheet.show(context),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Column(
              children: [
                for (var i = 0; i < transactions.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.sm),
                    child: StaggeredEntrance(
                      index: i,
                      child: TransactionCard(
                        transaction: transactions[i],
                        onTap: () => AddTransactionSheet.show(
                          context,
                          existingTransaction: transactions[i],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
