import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/core/constants/app_constants.dart';
import 'package:hermanos_ledgr/core/providers/onboarding_provider.dart';
import 'package:hermanos_ledgr/features/accounts/providers/accounts_provider.dart';
import 'package:hermanos_ledgr/features/backup/providers/backup_provider.dart';
import 'package:hermanos_ledgr/features/dashboard/presentation/widgets/account_summary_carousel.dart';
import 'package:hermanos_ledgr/features/dashboard/presentation/widgets/dashboard_quick_actions.dart';
import 'package:hermanos_ledgr/features/dashboard/presentation/widgets/net_worth_hero_card.dart';
import 'package:hermanos_ledgr/features/dashboard/providers/dashboard_provider.dart';
import 'package:hermanos_ledgr/features/dashboard/presentation/widgets/recent_activity_section.dart';
import 'package:hermanos_ledgr/features/transactions/providers/transactions_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/profile_avatar.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userName = ref.watch(onboardingProvider).userName;
    final dashboardData = ref.watch(dashboardProvider);

    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good morning'
        : (hour < 17 ? 'Good afternoon' : 'Good evening');

    // Trigger daily auto-backup check on launch (Task 11.3)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(backupProvider.notifier).checkAndRunDailyAutoBackup();
    });

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(accountsProvider);
            ref.invalidate(transactionsProvider);
            ref.invalidate(dashboardProvider);
            await Future.delayed(const Duration(milliseconds: 300));
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: Spacing.md),
            children: [
              // 1. Header Greeting & Profile Avatar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName.isEmpty ? greeting : '$greeting, $userName',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: Spacing.xs,
                            runSpacing: 2,
                            children: [
                              Text(
                                'Personal Ledger',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  AppConstants.appVersionDisplay,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontSize: 10,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    IconButton(
                      icon: const Icon(Icons.note_alt_outlined, size: 22),
                      tooltip: 'Quick Notes & Scratchpad',
                      onPressed: () => context.push('/notes'),
                    ),
                    const SizedBox(width: Spacing.xs),
                    ProfileAvatar(
                      size: 44,
                      userName: userName,
                      profilePicBase64: ref.watch(onboardingProvider).profilePicBase64,
                      onTap: () => context.push('/settings'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.lg),

              // 2. Net Worth Hero Card (Count-up animation + tabular figures)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: NetWorthHeroCard(data: dashboardData),
              ),
              const SizedBox(height: Spacing.xl),

              // 3. Quick Actions Row (Expense, Income, Transfer)
              const DashboardQuickActions(),
              const SizedBox(height: Spacing.xl),

              // 4. Accounts & Wallets Carousel
              AccountSummaryCarousel(accounts: dashboardData.accounts),
              const SizedBox(height: Spacing.xl),

              // 5. Recent Activity Section
              RecentActivitySection(transactions: dashboardData.recentTransactions),
              const SizedBox(height: Spacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
