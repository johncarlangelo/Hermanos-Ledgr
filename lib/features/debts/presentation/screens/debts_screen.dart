import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/debts/domain/debt_model.dart';
import 'package:hermanos_ledgr/features/debts/presentation/widgets/add_debt_sheet.dart';
import 'package:hermanos_ledgr/features/debts/presentation/widgets/bill_split_sheet.dart';
import 'package:hermanos_ledgr/features/debts/presentation/widgets/debt_card.dart';
import 'package:hermanos_ledgr/features/debts/presentation/widgets/record_payment_sheet.dart';
import 'package:hermanos_ledgr/features/debts/providers/debts_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/empty_state_view.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Full-featured Debts & Receivables screen for Hermanos Ledgr (Phase 7).
/// Manages debts you owe (Utang), money owed to you (Pautang), and bill splits.
class DebtsScreen extends ConsumerStatefulWidget {
  const DebtsScreen({super.key});

  @override
  ConsumerState<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends ConsumerState<DebtsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final payables = ref.watch(payableDebtsProvider);
    final receivables = ref.watch(receivablesProvider);
    final settled = ref.watch(settledDebtsProvider);

    final totalPayable = ref.watch(totalPayableAmountProvider);
    final totalReceivable = ref.watch(totalReceivableAmountProvider);
    final netBalance = ref.watch(netDebtBalanceProvider);
    final overdueCount = ref.watch(overdueDebtCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debts & Receivables'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.call_split_rounded),
            tooltip: 'Bill Split Calculator',
            onPressed: () => BillSplitSheet.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Record',
            onPressed: () => AddDebtSheet.show(
              context,
              defaultType: _tabController.index == 1
                  ? DebtType.receivable
                  : DebtType.debt,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Hero Summary Position Card
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
                vertical: Spacing.xs,
              ),
              child: M3Card(
                padding: const EdgeInsets.all(Spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'NET DEBT POSITION',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: theme.colorScheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (overdueCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: SemanticColors.expense(isDark).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$overdueCount Overdue',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: SemanticColors.expense(isDark),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: Spacing.xs),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${netBalance >= 0 ? "+" : ""}${CurrencyFormatter.format(netBalance)}',
                        style: moneyStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: netBalance >= 0
                              ? SemanticColors.income(isDark)
                              : SemanticColors.expense(isDark),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      netBalance >= 0
                          ? 'Others owe you more than what you owe overall'
                          : 'Your outstanding debts exceed what others owe you',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    const Divider(height: 1, thickness: 0.5),
                    const SizedBox(height: Spacing.sm),

                    // Breakdown Row: Owed to you vs You owe
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Owed to You',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 11.5,
                                ),
                              ),
                              const SizedBox(height: 1),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  CurrencyFormatter.format(totalReceivable),
                                  style: moneyStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: SemanticColors.income(isDark),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: Spacing.md),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'You Owe',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 11.5,
                                ),
                              ),
                              const SizedBox(height: 1),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  CurrencyFormatter.format(totalPayable),
                                  style: moneyStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: SemanticColors.expense(isDark),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Spacing.xs),

            // 2. Custom Stash Segmented Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? StashColors.raised : theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: isDark ? StashColors.base : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  labelColor: theme.colorScheme.onSurface,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                  tabs: [
                    Tab(text: 'I Owe (${payables.length})'),
                    Tab(text: 'Owed to Me (${receivables.length})'),
                    Tab(text: 'Settled (${settled.length})'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Spacing.sm),

            // 3. Tab Views with animated list cascades
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 0: Payables (Debts you owe)
                  _buildDebtList(
                    context,
                    debts: payables,
                    emptyTitle: 'No active debts',
                    emptySubtitle: 'Great news! You currently do not have any pending debts or loans.',
                    actionLabel: 'Log Debt (Utang)',
                    onAction: () => AddDebtSheet.show(
                      context,
                      defaultType: DebtType.debt,
                    ),
                  ),

                  // Tab 1: Receivables (Money owed to you)
                  _buildDebtList(
                    context,
                    debts: receivables,
                    emptyTitle: 'No pending receivables',
                    emptySubtitle: 'Track money you lend to friends or split group bills here.',
                    actionLabel: 'Log Receivable (Pautang)',
                    onAction: () => AddDebtSheet.show(
                      context,
                      defaultType: DebtType.receivable,
                    ),
                  ),

                  // Tab 2: Settled History
                  _buildDebtList(
                    context,
                    debts: settled,
                    emptyTitle: 'No settled records',
                    emptySubtitle: 'Fully paid debts and collected loans will appear here.',
                    actionLabel: 'Split a Bill',
                    onAction: () => BillSplitSheet.show(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtList(
    BuildContext context, {
    required List<DebtModel> debts,
    required String emptyTitle,
    required String emptySubtitle,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    if (debts.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: EmptyStateView(
            icon: Icons.handshake_outlined,
            title: emptyTitle,
            subtitle: emptySubtitle,
            actionLabel: actionLabel,
            onAction: onAction,
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.sm,
      ),
      itemCount: debts.length,
      separatorBuilder: (_, _) => const SizedBox(height: Spacing.sm),
      itemBuilder: (ctx, i) {
        final d = debts[i];
        return DebtCard(
          debt: d,
          onRecordPayment: () => RecordPaymentSheet.show(ctx, d),
          onEdit: () => AddDebtSheet.edit(ctx, d),
          onSettle: () {
            HapticFeedback.mediumImpact();
            ref.read(debtsProvider.notifier).settleDebt(d.id);
            UndoSnackbar.show(
              ctx,
              message: 'Marked ${d.personName} as fully settled',
              onUndo: () {
                ref.read(debtsProvider.notifier).updateDebt(d);
              },
            );
          },
          onDelete: () async {
            HapticFeedback.heavyImpact();
            final deleted = await ref.read(debtsProvider.notifier).deleteDebt(d.id);
            if (deleted != null && context.mounted) {
              UndoSnackbar.show(
                ctx,
                message: 'Deleted record for ${deleted.personName}',
                onUndo: () {
                  ref.read(debtsProvider.notifier).addDebt(deleted);
                },
              );
            }
          },
        );
      },
    );
  }
}
