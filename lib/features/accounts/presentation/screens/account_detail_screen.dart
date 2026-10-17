import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/accounts/presentation/widgets/add_account_sheet.dart';
import 'package:hermanos_ledgr/features/accounts/presentation/widgets/delete_account_sheet.dart';
import 'package:hermanos_ledgr/features/accounts/presentation/widgets/personalized_card.dart';
import 'package:hermanos_ledgr/features/accounts/providers/accounts_provider.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';
import 'package:hermanos_ledgr/features/transactions/presentation/widgets/add_transaction_sheet.dart';
import 'package:hermanos_ledgr/features/transactions/presentation/widgets/transaction_card.dart';
import 'package:hermanos_ledgr/features/transactions/providers/mock_transactions_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';

enum AccountTxFilter { all, expense, income, transfer }

/// Detailed account screen showing personalized card, account metrics,
/// quick action triggers, and dedicated transaction ledger.
class AccountDetailScreen extends ConsumerStatefulWidget {
  final String accountId;

  const AccountDetailScreen({
    super.key,
    required this.accountId,
  });

  @override
  ConsumerState<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends ConsumerState<AccountDetailScreen> {
  AccountTxFilter _selectedFilter = AccountTxFilter.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final account = ref.watch(accountByIdProvider(widget.accountId));

    if (account == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          title: const Text('Account Details'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.credit_card_off_rounded,
                size: 56,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(height: Spacing.md),
              Text(
                'Account not found',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              FilledButton.tonal(
                onPressed: () => context.pop(),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    final allTransactions = ref.watch(transactionsProvider);
    final accountTransactions = allTransactions.where((t) {
      return t.accountId == account.id || t.destinationAccountId == account.id;
    }).toList();

    // Compute cashflow metrics
    double totalInflow = 0.0;
    double totalOutflow = 0.0;

    for (final tx in accountTransactions) {
      if (tx.type == TransactionType.income) {
        totalInflow += tx.amount;
      } else if (tx.type == TransactionType.expense) {
        totalOutflow += tx.amount;
      } else if (tx.type == TransactionType.transfer) {
        if (tx.destinationAccountId == account.id) {
          totalInflow += tx.amount;
        }
        if (tx.accountId == account.id) {
          totalOutflow += tx.amount;
        }
      }
    }

    final netCashflow = totalInflow - totalOutflow;

    // Filter transactions
    final filteredTransactions = accountTransactions.where((tx) {
      switch (_selectedFilter) {
        case AccountTxFilter.all:
          return true;
        case AccountTxFilter.expense:
          return tx.type == TransactionType.expense;
        case AccountTxFilter.income:
          return tx.type == TransactionType.income;
        case AccountTxFilter.transfer:
          return tx.type == TransactionType.transfer;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          account.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Account',
            onPressed: () => AddAccountSheet.edit(context, account),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: SemanticColors.expense(isDark),
            ),
            tooltip: 'Delete Account',
            onPressed: () => DeleteAccountSheet.show(context, account),
          ),
          const SizedBox(width: Spacing.xs),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 1. Personalized Card Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                Spacing.sm,
                Spacing.lg,
                Spacing.md,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: AspectRatio(
                    aspectRatio: 1.586, // Standard physical ISO credit card ratio
                    child: PersonalizedCard(
                      account: account,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Quick Action Buttons Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
                vertical: Spacing.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionTile(
                      context: context,
                      theme: theme,
                      icon: Icons.arrow_downward_rounded,
                      label: 'Expense',
                      color: SemanticColors.expense(isDark),
                      onTap: () => AddTransactionSheet.show(
                        context,
                        initialType: TransactionType.expense,
                        initialAccount: account,
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: _buildActionTile(
                      context: context,
                      theme: theme,
                      icon: Icons.arrow_upward_rounded,
                      label: 'Income',
                      color: SemanticColors.income(isDark),
                      onTap: () => AddTransactionSheet.show(
                        context,
                        initialType: TransactionType.income,
                        initialAccount: account,
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: _buildActionTile(
                      context: context,
                      theme: theme,
                      icon: Icons.swap_horiz_rounded,
                      label: 'Transfer',
                      color: SemanticColors.transfer(isDark),
                      onTap: () => AddTransactionSheet.show(
                        context,
                        initialType: TransactionType.transfer,
                        initialAccount: account,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Financial Metrics Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                Spacing.md,
                Spacing.lg,
                Spacing.md,
              ),
              child: M3Card(
                padding: const EdgeInsets.all(Spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cashflow Summary',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.sm,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            account.typeLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.md),
                    const Divider(height: 1, thickness: 0.5),
                    const SizedBox(height: Spacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricItem(
                            label: 'Total Inflow',
                            amount: totalInflow,
                            color: SemanticColors.income(isDark),
                            prefix: '+',
                            theme: theme,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 38,
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: Spacing.md),
                            child: _buildMetricItem(
                              label: 'Total Outflow',
                              amount: totalOutflow,
                              color: SemanticColors.expense(isDark),
                              prefix: '-',
                              theme: theme,
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 38,
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: Spacing.md),
                            child: _buildMetricItem(
                              label: 'Net Flow',
                              amount: netCashflow.abs(),
                              color: netCashflow >= 0
                                  ? SemanticColors.income(isDark)
                                  : SemanticColors.expense(isDark),
                              prefix: netCashflow >= 0 ? '+' : '-',
                              theme: theme,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Activity Header & Filter Chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                Spacing.sm,
                Spacing.lg,
                Spacing.xs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Account Activity',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${filteredTransactions.length} records',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: 'All (${accountTransactions.length})',
                          filter: AccountTxFilter.all,
                          theme: theme,
                        ),
                        const SizedBox(width: Spacing.xs),
                        _buildFilterChip(
                          label: 'Expenses',
                          filter: AccountTxFilter.expense,
                          theme: theme,
                        ),
                        const SizedBox(width: Spacing.xs),
                        _buildFilterChip(
                          label: 'Income',
                          filter: AccountTxFilter.income,
                          theme: theme,
                        ),
                        const SizedBox(width: Spacing.xs),
                        _buildFilterChip(
                          label: 'Transfers',
                          filter: AccountTxFilter.transfer,
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. Transactions List or Empty State
          if (filteredTransactions.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: Spacing.md),
                      Text(
                        'No transactions for this account',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        'Transactions recorded with ${account.name} will appear here.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: Spacing.lg),
                      FilledButton.icon(
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Transaction'),
                        onPressed: () => AddTransactionSheet.show(
                          context,
                          initialAccount: account,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
                vertical: Spacing.sm,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tx = filteredTransactions[index];
                    final showDateHeader = index == 0 ||
                        !_isSameDay(
                          filteredTransactions[index - 1].date,
                          tx.date,
                        );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showDateHeader) ...[
                          Padding(
                            padding: const EdgeInsets.only(
                              top: Spacing.sm,
                              bottom: Spacing.xs,
                            ),
                            child: Text(
                              _formatDateHeader(tx.date),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                        Padding(
                          padding: const EdgeInsets.only(bottom: Spacing.xs),
                          child: TransactionCard(
                            transaction: tx,
                            onTap: () => AddTransactionSheet.show(
                              context,
                              existingTransaction: tx,
                            ),
                            onDelete: () {
                              ref
                                  .read(transactionsProvider.notifier)
                                  .deleteTransaction(tx.id);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                  childCount: filteredTransactions.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: Spacing.xxl),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required ThemeData theme,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Spacing.sm + 2),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required double amount,
    required Color color,
    required String prefix,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$prefix${CurrencyFormatter.format(amount)}',
          style: moneyStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required AccountTxFilter filter,
    required ThemeData theme,
  }) {
    final isSelected = _selectedFilter == filter;

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface,
      ),
      selectedColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide.none,
      onSelected: (_) => setState(() => _selectedFilter = filter),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) return 'TODAY';
    final yesterday = now.subtract(const Duration(days: 1));
    if (_isSameDay(date, yesterday)) return 'YESTERDAY';
    return DateFormat('EEEE, MMM d').format(date).toUpperCase();
  }
}
