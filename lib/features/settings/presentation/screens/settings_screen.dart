import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hermanos_ledgr/app/theme/app_theme.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/constants/app_constants.dart';
import 'package:hermanos_ledgr/core/providers/onboarding_provider.dart';
import 'package:hermanos_ledgr/core/providers/theme_provider.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/accounts/presentation/widgets/add_account_sheet.dart';
import 'package:hermanos_ledgr/features/accounts/presentation/widgets/delete_account_sheet.dart';
import 'package:hermanos_ledgr/features/accounts/providers/mock_accounts_provider.dart';
import 'package:hermanos_ledgr/features/settings/presentation/widgets/export_dialog_sheet.dart';
import 'package:hermanos_ledgr/features/settings/presentation/widgets/profile_edit_sheet.dart';
import 'package:hermanos_ledgr/features/settings/presentation/widgets/reset_confirm_sheet.dart';
import 'package:hermanos_ledgr/features/settings/presentation/widgets/settings_tile.dart';
import 'package:hermanos_ledgr/features/settings/presentation/widgets/stash_switch.dart';
import 'package:hermanos_ledgr/features/settings/providers/settings_provider.dart';
import 'package:hermanos_ledgr/features/transactions/providers/mock_transactions_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';
import 'package:hermanos_ledgr/shared/widgets/theme_selection_sheet.dart';
import 'package:hermanos_ledgr/shared/widgets/version_pill.dart';

/// Full-featured Settings Screen for Hermanos Ledgr.
/// Adheres strictly to the Zero Stock Android Native UI rule,
/// utilizing custom Hermanos-Stash containers, custom sheets, and tactile toggles.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _tabNames = [
    'Dashboard',
    'Transactions',
    'Quick Log',
    'Budget',
    'Hermano',
  ];

  static const _tabIcons = [
    Icons.dashboard_outlined,
    Icons.receipt_long_outlined,
    Icons.add_circle_outline_rounded,
    Icons.pie_chart_outline_rounded,
    Icons.psychology_outlined,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userName = ref.watch(onboardingProvider).userName;
    final currentTheme = ref.watch(themeProvider);
    final userPrefs = ref.watch(userPreferencesProvider);
    final accounts = ref.watch(accountsProvider);
    final transactions = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 22),
          tooltip: 'Back',
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: Spacing.md),
            child: VersionPill(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
        children: [
          // 1. Profile & Identity Hero Card
          _buildProfileCard(
            context: context,
            theme: theme,
            isDark: isDark,
            userName: userName,
            accountsCount: accounts.length,
            transactionsCount: transactions.length,
          ),
          const SizedBox(height: Spacing.xl),

          // 2. Accounts & Wallets Management
          _buildSectionHeader(theme, 'ACCOUNTS & WALLETS'),
          const SizedBox(height: Spacing.sm),
          _buildCardGroup(
            theme: theme,
            children: [
              for (int i = 0; i < accounts.length; i++) ...[
                _buildAccountTile(
                  context: context,
                  theme: theme,
                  isDark: isDark,
                  account: accounts[i],
                  accountsCount: accounts.length,
                  showDivider: true,
                ),
              ],
              SettingsTile(
                icon: Icons.add_circle_outline_rounded,
                title: 'Add Account or Wallet',
                subtitle: 'Link another bank, e-wallet, or cash envelope',
                showDivider: false,
                onTap: () => AddAccountSheet.show(context),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xl),

          // 3. Preferences & Appearance
          _buildSectionHeader(theme, 'APPEARANCE & DISPLAY'),
          const SizedBox(height: Spacing.sm),
          _buildCardGroup(
            theme: theme,
            children: [
              SettingsTile(
                icon: Icons.palette_outlined,
                title: 'Display Theme',
                subtitle: _getThemeDescription(currentTheme),
                trailing: _buildThemeBadge(context, theme, currentTheme),
                onTap: () => ThemeSelectionSheet.show(context),
              ),
              SettingsTile(
                icon: Icons.format_list_numbered_rounded,
                title: 'Compact Numbers',
                subtitle: 'Abbreviate large figures (e.g. ₱12.5k instead of ₱12,500.00)',
                trailing: StashSwitch(
                  value: userPrefs.compactNumbers,
                  onChanged: (val) {
                    ref
                        .read(userPreferencesProvider.notifier)
                        .setCompactNumbers(val);
                  },
                ),
              ),
              SettingsTile(
                icon: Icons.tab_rounded,
                title: 'Default Landing Tab',
                subtitle: _tabNames[userPrefs.defaultLandingTab.clamp(0, 4)],
                showDivider: false,
                onTap: () => _showTabPickerSheet(
                  context,
                  ref,
                  userPrefs.defaultLandingTab,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xl),

          // 4. Tactile & Haptics
          _buildSectionHeader(theme, 'SOUND & TACTILE'),
          const SizedBox(height: Spacing.sm),
          _buildCardGroup(
            theme: theme,
            children: [
              SettingsTile(
                icon: Icons.vibration_rounded,
                title: 'Haptic Feedback',
                subtitle: 'Tactile buzz on keypad clicks, toggle switches, and quick log saves',
                trailing: StashSwitch(
                  value: userPrefs.hapticsEnabled,
                  onChanged: (val) {
                    ref
                        .read(userPreferencesProvider.notifier)
                        .setHapticsEnabled(val);
                  },
                ),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: Spacing.xl),

          // 5. Hermano AI Intelligence
          _buildSectionHeader(theme, 'HERMANO AI INTELLIGENCE'),
          const SizedBox(height: Spacing.sm),
          _buildAiCard(context, theme, isDark),
          const SizedBox(height: Spacing.xl),

          // 5. Data & Backup
          _buildSectionHeader(theme, 'DATA & STORAGE'),
          const SizedBox(height: Spacing.sm),
          _buildCardGroup(
            theme: theme,
            children: [
              SettingsTile(
                icon: Icons.file_download_outlined,
                title: 'Export Ledger',
                subtitle: 'Generate and copy CSV or structured JSON backup',
                onTap: () => ExportDialogSheet.show(context),
              ),
              SettingsTile(
                icon: Icons.auto_stories_outlined,
                title: 'Replay Onboarding Tour',
                subtitle: 'Review features and philosophy without clearing your data',
                showDivider: false,
                onTap: () => ResetConfirmSheet.show(context, isFullReset: false),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xl),

          // 6. Danger Zone
          _buildSectionHeader(
            theme,
            'DANGER ZONE',
            color: SemanticColors.expense(isDark),
          ),
          const SizedBox(height: Spacing.sm),
          _buildCardGroup(
            theme: theme,
            borderColor: SemanticColors.expense(isDark).withValues(alpha: 0.3),
            children: [
              SettingsTile(
                icon: Icons.delete_forever_rounded,
                title: 'Reset Ledger Data',
                subtitle: 'Purge all transactions and restore clean default state',
                isDestructive: true,
                showDivider: false,
                onTap: () => ResetConfirmSheet.show(context, isFullReset: true),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xl),

          // 7. About Hermanos Ledgr
          _buildAboutCard(context, theme, isDark),
          const SizedBox(height: Spacing.xxl),
        ],
      ),
    );
  }

  // --- Accounts & Wallets Management Tile ---
  Widget _buildAccountTile({
    required BuildContext context,
    required ThemeData theme,
    required bool isDark,
    required AccountModel account,
    required int accountsCount,
    required bool showDivider,
  }) {
    final dangerColor = SemanticColors.expense(isDark);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm + 2,
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: account.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  account.icon,
                  size: 20,
                  color: account.color,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${account.institution} • ${account.typeLabel}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(account.balance),
                    style: moneyStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: account.balance < 0
                          ? dangerColor
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: Spacing.xs),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: accountsCount > 1
                      ? dangerColor
                      : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                ),
                tooltip: accountsCount > 1
                    ? 'Delete ${account.name}'
                    : 'Cannot delete the only remaining account',
                onPressed: () {
                  DeleteAccountSheet.show(context, account);
                },
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            indent: Spacing.lg + 38,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
      ],
    );
  }

  // --- Profile Header Card ---
  Widget _buildProfileCard({
    required BuildContext context,
    required ThemeData theme,
    required bool isDark,
    required String userName,
    required int accountsCount,
    required int transactionsCount,
  }) {
    final initials = userName.trim().isNotEmpty
        ? userName
            .trim()
            .split(' ')
            .where((part) => part.isNotEmpty)
            .map((part) => part[0].toUpperCase())
            .take(2)
            .join()
        : 'HL';

    return M3Card(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar circle with subtle teal ring
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? StashColors.raised
                      : theme.colorScheme.primaryContainer,
                  border: Border.all(
                    color: isDark
                        ? StashColors.tealAccent
                        : theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? StashColors.tealAccent
                          : theme.colorScheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            userName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: Spacing.xs),
                        InkWell(
                          onTap: () => ProfileEditSheet.show(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.edit_rounded,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sovereign Personal Ledger',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          // Stats Row
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? StashColors.base.withValues(alpha: 0.6)
                  : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(theme, 'CURRENCY', 'PHP (₱)'),
                _buildStatDivider(theme),
                _buildStatItem(theme, 'ACCOUNTS', '$accountsCount'),
                _buildStatDivider(theme),
                _buildStatItem(theme, 'LOGS', '$transactionsCount'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(ThemeData theme) {
    return Container(
      width: 1,
      height: 24,
      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
    );
  }

  // --- Section Header ---
  Widget _buildSectionHeader(ThemeData theme, String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: color ?? theme.colorScheme.primary,
        ),
      ),
    );
  }

  // --- Card Group Wrapper ---
  Widget _buildCardGroup({
    required ThemeData theme,
    required List<Widget> children,
    Color? borderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ??
              theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }

  // --- AI Model Card ---
  Widget _buildAiCard(BuildContext context, ThemeData theme, bool isDark) {
    final teal = isDark ? StashColors.tealAccent : theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: teal.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: teal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.psychology_rounded,
                  size: 22,
                  color: teal,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: Spacing.xs,
                      runSpacing: 4,
                      children: [
                        Text(
                          'Qwen 2.5 0.5B Instruct',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: teal.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '100% Offline',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: teal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'llama.cpp FFI • GGUF Q4_K_M Quantized',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Container(
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: isDark
                  ? StashColors.base.withValues(alpha: 0.5)
                  : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    'Zero cloud telemetry. Inference runs entirely inside an isolated background thread on your phone.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- About Card ---
  Widget _buildAboutCard(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => context.push('/splash'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 22,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Hermanos Ledgr',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: Spacing.sm),
                        const VersionPill(),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Build ${AppConstants.appBuildNumber} • Hermanos-Stash Design System',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Text(
            'A sovereign, offline-first personal budget ledger tailored for Samsung Galaxy A-series. Built with Flutter, Drift SQLite, and on-device machine intelligence. Zero ads, zero tracking, zero subscriptions.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Icon(
                Icons.system_update_rounded,
                size: 15,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Text(
                  'Auto-updater via GitHub Releases coming in roadmap',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Theme Helpers ---
  String _getThemeDescription(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'Follow System (Auto light/dark)';
      case AppThemeMode.dark:
        return 'Stash Dark (Deep slate & glass)';
      case AppThemeMode.amoled:
        return 'AMOLED Black (True #000000)';
      case AppThemeMode.light:
        return 'Light Mode (Crisp daylight)';
    }
  }

  Widget _buildThemeBadge(
    BuildContext context,
    ThemeData theme,
    AppThemeMode mode,
  ) {
    String label;
    Color color;

    switch (mode) {
      case AppThemeMode.system:
        label = 'System';
        color = theme.colorScheme.secondary;
        break;
      case AppThemeMode.dark:
        label = 'Dark';
        color = theme.colorScheme.primary;
        break;
      case AppThemeMode.amoled:
        label = 'AMOLED';
        color = const Color(0xFF7FC08D);
        break;
      case AppThemeMode.light:
        label = 'Light';
        color = const Color(0xFF00796B);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  // --- Default Tab Custom Sheet ---
  void _showTabPickerSheet(
    BuildContext context,
    WidgetRef ref,
    int currentTab,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg,
              Spacing.xs,
              Spacing.lg,
              Spacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(Spacing.sm),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.tab_rounded,
                        size: 22,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Default Landing Tab',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Choose which tab opens on startup',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.lg),
                for (int i = 0; i < _tabNames.length; i++) ...[
                  // Exclude Quick Log (tab 2) from landing tab since it's an action modal
                  if (i != 2) ...[
                    _buildTabChoiceTile(
                      context: ctx,
                      theme: theme,
                      index: i,
                      name: _tabNames[i],
                      icon: _tabIcons[i],
                      isSelected: currentTab == i,
                      onTap: () {
                        ref
                            .read(userPreferencesProvider.notifier)
                            .setDefaultLandingTab(i);
                        Navigator.of(ctx).pop();
                      },
                    ),
                    const SizedBox(height: Spacing.xs),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabChoiceTile({
    required BuildContext context,
    required ThemeData theme,
    required int index,
    required String name,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
