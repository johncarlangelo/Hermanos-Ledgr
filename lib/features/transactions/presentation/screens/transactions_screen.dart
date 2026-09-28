import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';
import 'package:hermanos_ledgr/features/transactions/presentation/widgets/add_transaction_sheet.dart';
import 'package:hermanos_ledgr/features/transactions/presentation/widgets/transaction_card.dart';
import 'package:hermanos_ledgr/features/transactions/providers/mock_transactions_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/empty_state_view.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDate = DateTime(date.year, date.month, date.day);

    if (txDate == today) {
      return 'Today';
    } else if (txDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, MMM d').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactions = ref.watch(filteredTransactionsProvider);
    final currentFilter = ref.watch(transactionFilterTypeProvider);

    // Group transactions by date string
    final Map<String, List<TransactionModel>> grouped = {};
    for (final tx in transactions) {
      final header = _getDateHeader(tx.date);
      grouped.putIfAbsent(header, () => []).add(tx);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Transaction',
            onPressed: () => AddTransactionSheet.show(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.xs,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search transactions, notes, categories...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(transactionSearchQueryProvider.notifier)
                              .setSearch('');
                        },
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onChanged: (val) {
                ref.read(transactionSearchQueryProvider.notifier).setSearch(val);
                setState(() {});
              },
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.sm,
            ),
            child: Row(
              children: [
                _buildFilterChip('All', null, currentFilter),
                const SizedBox(width: Spacing.sm),
                _buildFilterChip('Expense', TransactionType.expense, currentFilter),
                const SizedBox(width: Spacing.sm),
                _buildFilterChip('Income', TransactionType.income, currentFilter),
                const SizedBox(width: Spacing.sm),
                _buildFilterChip('Transfer', TransactionType.transfer, currentFilter),
              ],
            ),
          ),

          // Transactions List or Empty State
          Expanded(
            child: transactions.isEmpty
                ? EmptyStateView(
                    icon: Icons.search_off_rounded,
                    title: 'No transactions found',
                    subtitle: 'Try changing your search query or filter chips.',
                    actionLabel: 'Add Transaction',
                    onAction: () => AddTransactionSheet.show(context),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                    itemCount: grouped.keys.length,
                    itemBuilder: (context, index) {
                      final header = grouped.keys.elementAt(index);
                      final items = grouped[header]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sticky-style Date Header
                          Padding(
                            padding: const EdgeInsets.only(
                              top: Spacing.md,
                              bottom: Spacing.sm,
                              left: Spacing.xs,
                            ),
                            child: Text(
                              header.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          for (final tx in items) ...[
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: Spacing.sm),
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    TransactionType? type,
    TransactionType? activeFilter,
  ) {
    final isSelected = activeFilter == type;
    final theme = Theme.of(context);

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface,
      ),
      selectedColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide.none,
      onSelected: (_) {
        ref.read(transactionFilterTypeProvider.notifier).setFilter(type);
      },
    );
  }
}
