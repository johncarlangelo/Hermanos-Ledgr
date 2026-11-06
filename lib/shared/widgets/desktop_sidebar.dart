import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/features/transactions/presentation/widgets/add_transaction_sheet.dart';

class DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const DesktopSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentPath = GoRouterState.of(context).uri.path;

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: isDark ? StashColors.shell : theme.colorScheme.surfaceContainerLow,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Brand Header
          Padding(
            padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.xl, Spacing.lg, Spacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(Spacing.xs + 2),
                  decoration: BoxDecoration(
                    color: isDark ? StashColors.tealSoft : theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: StashColors.tealAccent.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 20,
                    color: StashColors.tealAccent,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hermanos Ledgr',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: StashColors.tealAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Desktop Companion',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: StashColors.tealAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Primary Quick Log Action Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
            child: FilledButton.icon(
              onPressed: () => AddTransactionSheet.show(context),
              style: FilledButton.styleFrom(
                backgroundColor: StashColors.tealAccent,
                foregroundColor: const Color(0xFF08090D),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                'New Transaction',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ),

          const SizedBox(height: Spacing.sm),

          // 3. Navigation List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
              children: [
                _buildSectionHeader('Core Platform', theme),
                _buildNavItem(
                  icon: Icons.home_rounded,
                  label: 'Home Dashboard',
                  isSelected: currentPath == '/',
                  onTap: () => context.go('/'),
                  theme: theme,
                  isDark: isDark,
                ),
                _buildNavItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Ledger',
                  isSelected: currentPath.startsWith('/transactions'),
                  onTap: () => context.go('/transactions'),
                  theme: theme,
                  isDark: isDark,
                ),
                _buildNavItem(
                  icon: Icons.pie_chart_rounded,
                  label: 'Budget & Planning',
                  isSelected: currentPath.startsWith('/budget'),
                  onTap: () => context.go('/budget'),
                  theme: theme,
                  isDark: isDark,
                ),
                _buildNavItem(
                  icon: Icons.smart_toy_rounded,
                  label: 'Hermano AI',
                  isSelected: currentPath.startsWith('/ai'),
                  onTap: () => context.go('/ai'),
                  theme: theme,
                  isDark: isDark,
                ),

                const SizedBox(height: Spacing.sm),
                _buildSectionHeader('Management', theme),

                _buildNavItem(
                  icon: Icons.credit_card_rounded,
                  label: 'Accounts & Cards',
                  isSelected: currentPath.startsWith('/accounts'),
                  onTap: () => context.push('/accounts'),
                  theme: theme,
                  isDark: isDark,
                ),
                _buildNavItem(
                  icon: Icons.event_repeat_rounded,
                  label: 'Recurring & Bills',
                  isSelected: currentPath.startsWith('/recurring'),
                  onTap: () => context.push('/recurring'),
                  theme: theme,
                  isDark: isDark,
                ),
                _buildNavItem(
                  icon: Icons.handshake_rounded,
                  label: 'Debts & Splits',
                  isSelected: currentPath.startsWith('/debts'),
                  onTap: () => context.push('/debts'),
                  theme: theme,
                  isDark: isDark,
                ),
                _buildNavItem(
                  icon: Icons.flag_rounded,
                  label: 'Savings Goals',
                  isSelected: currentPath.startsWith('/goals'),
                  onTap: () => context.push('/goals'),
                  theme: theme,
                  isDark: isDark,
                ),
              ],
            ),
          ),

          // 4. Bottom Footer (Settings & Sync Indicator)
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              color: isDark ? StashColors.base : theme.colorScheme.surface,
            ),
            child: Column(
              children: [
                _buildNavItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  isSelected: currentPath.startsWith('/settings'),
                  onTap: () => context.push('/settings'),
                  theme: theme,
                  isDark: isDark,
                ),
                const SizedBox(height: Spacing.xs),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: StashColors.ok,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      'Localhost Drift Ready',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.sm, Spacing.xs, Spacing.sm, Spacing.xs),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
    required bool isDark,
  }) {
    final bgColor = isSelected
        ? (isDark ? StashColors.surface : theme.colorScheme.primaryContainer.withValues(alpha: 0.5))
        : Colors.transparent;
    final fgColor = isSelected
        ? (isDark ? StashColors.tealAccent : theme.colorScheme.primary)
        : theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.sm + 2, vertical: 9),
            child: Row(
              children: [
                Icon(icon, size: 18, color: fgColor),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected ? theme.colorScheme.onSurface : fgColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

