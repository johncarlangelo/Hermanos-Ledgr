import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/accounts/providers/accounts_provider.dart';
import 'package:hermanos_ledgr/features/recurring/domain/forecast_engine.dart';
import 'package:hermanos_ledgr/features/recurring/presentation/widgets/forecast_timeline_widget.dart';
import 'package:hermanos_ledgr/features/recurring/presentation/widgets/upcoming_payments_list.dart';
import 'package:hermanos_ledgr/features/recurring/providers/recurring_auto_log_provider.dart';
import 'package:hermanos_ledgr/features/recurring/providers/recurring_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';

/// Cashflow Forecast screen projecting future balance and upcoming commitments (Task 8.7).
class ForecastScreen extends ConsumerStatefulWidget {
  const ForecastScreen({super.key});

  @override
  ConsumerState<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends ConsumerState<ForecastScreen> {
  int _selectedHorizon = 30; // 30, 60, or 90 days

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final accounts = ref.watch(accountsProvider);
    final rules = ref.watch(recurringProvider);

    final startingBalance = accounts.fold<double>(0.0, (sum, a) => sum + a.balance);

    final forecast = ForecastEngine.calculate(
      startingBalance: startingBalance,
      rules: rules,
      daysHorizon: _selectedHorizon,
    );

    final netColor = forecast.isPositiveNet
        ? SemanticColors.income(isDark)
        : SemanticColors.expense(isDark);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cashflow Forecast'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.sm,
          ),
          children: [
            // 1. Horizon Selector Chips (30 / 60 / 90 Days)
            Row(
              children: [
                for (final horizon in [30, 60, 90]) ...[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildHorizonChip(
                        title: '$horizon Days',
                        isSelected: _selectedHorizon == horizon,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedHorizon = horizon);
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: Spacing.md),

            // 2. Projected Balance Hero Card
            M3Card(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PROJECTED BALANCE IN $_selectedHorizon DAYS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: isDark ? StashColors.tealAccent : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      CurrencyFormatter.format(forecast.endingBalance),
                      style: moneyStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),

                  // Net change pill + Starting balance
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: netColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              forecast.isPositiveNet
                                  ? Icons.trending_up_rounded
                                  : Icons.trending_down_rounded,
                              size: 14,
                              color: netColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${forecast.isPositiveNet ? '+' : ''}${CurrencyFormatter.format(forecast.netChange)}',
                              style: moneyStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: netColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: Text(
                          'from current ${CurrencyFormatter.format(startingBalance)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 11.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: Spacing.md),
                  const Divider(height: 1, thickness: 0.5),
                  const SizedBox(height: Spacing.md),

                  // Total Expected In vs Out
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scheduled Income',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '+${CurrencyFormatter.format(forecast.totalIncome)}',
                              style: moneyStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: SemanticColors.income(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 28,
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scheduled Bills & Expenses',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '-${CurrencyFormatter.format(forecast.totalExpense)}',
                              style: moneyStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: SemanticColors.expense(isDark),
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
            const SizedBox(height: Spacing.lg),

            // 3. Interactive Cashflow Timeline Curve (Task 8.8)
            ForecastTimelineWidget(forecast: forecast),
            const SizedBox(height: Spacing.xl),

            // 4. Upcoming Scheduled Payments (Task 8.9)
            Text(
              'UPCOMING SCHEDULED PAYMENTS',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            UpcomingPaymentsList(
              occurrences: forecast.upcomingOccurrences,
              onLogEarly: (item) {
                ref.read(recurringAutoLogProvider.notifier).manuallyLogRule(context, item.rule);
              },
            ),
            const SizedBox(height: Spacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizonChip({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? StashColors.raised : Colors.white)
              : theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? StashColors.tealAccent : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
