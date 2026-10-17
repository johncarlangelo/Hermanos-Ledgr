import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/recurring/domain/recurring_model.dart';
import 'package:hermanos_ledgr/features/recurring/presentation/widgets/add_recurring_sheet.dart';
import 'package:hermanos_ledgr/features/recurring/presentation/widgets/recurring_rule_card.dart';
import 'package:hermanos_ledgr/features/recurring/providers/recurring_auto_log_provider.dart';
import 'package:hermanos_ledgr/features/recurring/providers/recurring_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/empty_state_view.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Main screen for managing recurring transactions, subscriptions, and scheduled bills (Task 8.4).
class RecurringScreen extends ConsumerStatefulWidget {
  const RecurringScreen({super.key});

  @override
  ConsumerState<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends ConsumerState<RecurringScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Check auto-logging on screen entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recurringAutoLogProvider.notifier).runAutoLog(context: context);
    });
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

    final allRules = ref.watch(recurringProvider);
    final activeRules = ref.watch(activeRecurringProvider);
    final pausedRules = ref.watch(pausedRecurringProvider);

    final monthlyExpense = ref.watch(monthlyRecurringExpenseProvider);
    final monthlyIncome = ref.watch(monthlyRecurringIncomeProvider);
    final netCashflow = ref.watch(netMonthlyRecurringCashflowProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring & Subscriptions'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_graph_rounded),
            tooltip: 'Cashflow Forecast',
            onPressed: () => context.push('/forecast'),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Rule',
            onPressed: () => AddRecurringSheet.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Monthly Recurring Commitment Hero Card
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
                            'MONTHLY RECURRING COMMITMENT',
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
                        InkWell(
                          onTap: () => context.push('/forecast'),
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Forecast',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 13,
                                  color: theme.colorScheme.primary,
                                ),
                              ],
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
                        CurrencyFormatter.format(monthlyExpense),
                        style: moneyStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: monthlyExpense > 0
                              ? SemanticColors.expense(isDark)
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      monthlyIncome > 0
                          ? 'Net cashflow: ${netCashflow >= 0 ? '+' : ''}${CurrencyFormatter.format(netCashflow)}/mo (${CurrencyFormatter.format(monthlyIncome)} income)'
                          : '${activeRules.length} active recurring rules tracking bills and subscriptions',
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
            ),
            const SizedBox(height: Spacing.sm),

            // 2. Segmented Tab Selector (All / Active / Paused)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: Container(
                height: 38,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: isDark ? StashColors.base : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
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
                    Tab(text: 'All (${allRules.length})'),
                    Tab(text: 'Active (${activeRules.length})'),
                    Tab(text: 'Paused (${pausedRules.length})'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Spacing.sm),

            // 3. Tab Views with recurring cards
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRuleList(allRules, 'No recurring rules yet', 'Set up monthly bills, streaming services, and scheduled income.'),
                  _buildRuleList(activeRules, 'No active rules', 'All your recurring rules are currently paused.'),
                  _buildRuleList(pausedRules, 'No paused rules', 'Active rules you pause will appear here.'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: StashColors.tealAccent,
        foregroundColor: Colors.black,
        onPressed: () => AddRecurringSheet.show(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildRuleList(List<RecurringModel> rules, String emptyTitle, String emptySubtitle) {
    if (rules.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: EmptyStateView(
            icon: Icons.repeat_rounded,
            title: emptyTitle,
            subtitle: emptySubtitle,
            actionLabel: 'New Recurring Rule',
            onAction: () => AddRecurringSheet.show(context),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.sm,
      ),
      itemCount: rules.length,
      itemBuilder: (_, index) {
        final rule = rules[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: Spacing.md),
          child: RecurringRuleCard(
            rule: rule,
            onToggleActive: () => ref.read(recurringProvider.notifier).toggleActive(rule.id),
            onEdit: () => AddRecurringSheet.show(context, rule: rule),
            onLogNow: () => ref.read(recurringAutoLogProvider.notifier).manuallyLogRule(context, rule),
            onDelete: () async {
              final deleted = await ref.read(recurringProvider.notifier).deleteRule(rule.id);
              if (deleted != null && mounted) {
                UndoSnackbar.show(
                  context,
                  message: 'Deleted "${rule.title}"',
                  onUndo: () => ref.read(recurringProvider.notifier).addRule(deleted),
                );
              }
            },
          ),
        );
      },
    );
  }
}
