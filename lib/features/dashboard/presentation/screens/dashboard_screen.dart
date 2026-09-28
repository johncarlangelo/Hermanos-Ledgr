import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/providers/onboarding_provider.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/accounts/providers/mock_accounts_provider.dart';
import 'package:hermanos_ledgr/features/dashboard/presentation/widgets/account_card.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';
import 'package:hermanos_ledgr/features/transactions/presentation/widgets/add_transaction_sheet.dart';
import 'package:hermanos_ledgr/features/transactions/presentation/widgets/transaction_card.dart';
import 'package:hermanos_ledgr/features/transactions/providers/mock_transactions_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/empty_state_view.dart';
import 'package:hermanos_ledgr/shared/widgets/hero_amount_display.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userName = ref.watch(onboardingProvider).userName;
    final netWorth = ref.watch(netWorthProvider);
    final totalAssets = ref.watch(totalAssetsProvider);
    final totalLiabilities = ref.watch(totalLiabilitiesProvider);
    final accounts = ref.watch(accountsProvider);
    final transactions = ref.watch(transactionsProvider);
    final recentTransactions = transactions.take(5).toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 400));
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: Spacing.md),
            children: [
              // Header Greeting & Date
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mabuhay, $userName',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Personal Ledger',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.flash_on_rounded, size: 20),
                      tooltip: 'Quick Log',
                      onPressed: () => AddTransactionSheet.show(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.lg),

              // 1. Net Worth Hero Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: M3Card(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeroAmountDisplay(
                        label: 'Net Worth',
                        amount: netWorth,
                        changeAmount: 14450.00,
                        changeLabel: 'this month',
                      ),
                      const SizedBox(height: Spacing.lg),
                      const Divider(height: 1, thickness: 0.5),
                      const SizedBox(height: Spacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
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
                                CurrencyFormatter.format(totalAssets),
                                style: moneyStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: SemanticColors.income(isDark),
                                ),
                              ),
                            ],
                          ),
                          Column(
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
                                CurrencyFormatter.format(totalLiabilities),
                                style: moneyStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: SemanticColors.expense(isDark),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.xl),

              // 2. Quick Actions Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        context,
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
                      child: _buildQuickActionButton(
                        context,
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
                      child: _buildQuickActionButton(
                        context,
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
              ),
              const SizedBox(height: Spacing.xl),

              // 3. Accounts Carousel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Accounts & Wallets',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${accounts.length} active',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.sm),
              SizedBox(
                height: 124,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                  itemCount: accounts.length,
                  separatorBuilder: (_, _) => const SizedBox(width: Spacing.sm),
                  itemBuilder: (context, index) {
                    return AccountCard(account: accounts[index]);
                  },
                ),
              ),
              const SizedBox(height: Spacing.xl),

              // 4. Recent Transactions Header & List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Activity',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
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

              if (recentTransactions.isEmpty)
                EmptyStateView(
                  icon: Icons.receipt_long_outlined,
                  title: 'No recent transactions',
                  subtitle: 'Start tracking your spending by adding an expense.',
                  actionLabel: 'Log Expense',
                  onAction: () => AddTransactionSheet.show(context),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                  child: Column(
                    children: [
                      for (final tx in recentTransactions) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: Spacing.sm),
                          child: TransactionCard(
                            transaction: tx,
                            onDelete: () {
                              final deleted = ref
                                  .read(transactionsProvider.notifier)
                                  .deleteTransaction(tx.id);
                              if (deleted != null) {
                                UndoSnackbar.show(
                                  context,
                                  message: 'Deleted "${deleted.title}"',
                                  onUndo: () => ref
                                      .read(transactionsProvider.notifier)
                                      .restoreTransaction(deleted),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: Spacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
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
