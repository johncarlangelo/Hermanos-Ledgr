import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hermanos_ledgr/app/theme/app_theme.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/core/providers/onboarding_provider.dart';
import 'package:hermanos_ledgr/core/providers/theme_provider.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/accounts/providers/mock_accounts_provider.dart';
import 'package:hermanos_ledgr/features/splash/providers/splash_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _customAccountController = TextEditingController();
  int _currentPage = 0;
  static const int _totalPages = 4;

  @override
  void initState() {
    super.initState();
    _nameController.text = ref.read(onboardingProvider).userName;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _customAccountController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _finish() async {
    ref.read(onboardingProvider.notifier).setUserName(_nameController.text);

    final onboardingState = ref.read(onboardingProvider);
    final accountsNotifier = ref.read(accountsProvider.notifier);

    const templates = {
      'GCash': AccountModel(
        id: 'acc_gcash',
        name: 'GCash',
        type: AccountType.eWallet,
        balance: 0.0,
        icon: Icons.account_balance_wallet_rounded,
        color: Color(0xFF005CEE),
        institution: 'Mynt',
        monthlyChange: 0.0,
      ),
      'Cash Wallet': AccountModel(
        id: 'acc_cash',
        name: 'Cash Wallet',
        type: AccountType.cash,
        balance: 0.0,
        icon: Icons.payments_rounded,
        color: Color(0xFF00897B),
        institution: 'Cash',
        monthlyChange: 0.0,
      ),
      'BDO Savings': AccountModel(
        id: 'acc_bdo',
        name: 'BDO Savings',
        type: AccountType.bank,
        balance: 0.0,
        icon: Icons.account_balance_rounded,
        color: Color(0xFF0038A8),
        institution: 'BDO Unibank',
        monthlyChange: 0.0,
      ),
      'Maya': AccountModel(
        id: 'acc_maya',
        name: 'Maya',
        type: AccountType.eWallet,
        balance: 0.0,
        icon: Icons.wallet_rounded,
        color: Color(0xFF00D166),
        institution: 'Maya Philippines',
        monthlyChange: 0.0,
      ),
      'BPI Platinum Card': AccountModel(
        id: 'acc_bpi_cc',
        name: 'BPI Platinum Card',
        type: AccountType.creditCard,
        balance: 0.0,
        icon: Icons.credit_card_rounded,
        color: Color(0xFFB71C1C),
        institution: 'Bank of the Philippine Islands',
        monthlyChange: 0.0,
      ),
    };

    for (final selected in onboardingState.selectedStarterAccounts) {
      if (templates.containsKey(selected)) {
        accountsNotifier.addAccount(templates[selected]!);
      }
    }

    if (onboardingState.selectedStarterAccounts.contains('Other / Custom')) {
      final customName = _customAccountController.text.trim().isEmpty
          ? (onboardingState.customAccountName.trim().isEmpty
              ? 'Custom Account'
              : onboardingState.customAccountName.trim())
          : _customAccountController.text.trim();
      final isEWallet = onboardingState.customAccountType == 'eWallet';
      final isCash = onboardingState.customAccountType == 'cash';
      final accType = isEWallet
          ? AccountType.eWallet
          : (isCash ? AccountType.cash : AccountType.bank);
      final icon = isEWallet
          ? Icons.account_balance_wallet_rounded
          : (isCash ? Icons.payments_rounded : Icons.account_balance_rounded);

      final newAcc = AccountModel(
        id: 'acc_${DateTime.now().millisecondsSinceEpoch}',
        name: customName,
        type: accType,
        balance: 0.0,
        icon: icon,
        color: const Color(0xFF00897B),
        institution: customName,
        monthlyChange: 0.0,
      );
      accountsNotifier.addAccount(newAcc);
    }

    await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    if (media.width <= 10 || media.height <= 10) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final onboardingState = ref.watch(onboardingProvider);
    final currentThemeMode = ref.watch(themeProvider);
    final splashState = ref.watch(splashProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxHeight < 200 || constraints.maxWidth < 150) {
              return const SizedBox.shrink();
            }

            return Column(
              children: [
                // Top Bar with Skip Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.lg,
                    vertical: Spacing.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Brand micro tag
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 160),
                              curve: Curves.easeOut,
                              opacity: splashState.isEmblemRevealed ||
                                      !splashState.isVisible
                                  ? 1.0
                                  : 0.0,
                              child: Container(
                                key: onboardingBrandEmblemKey,
                                padding: const EdgeInsets.all(Spacing.xs + 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.account_balance_wallet_rounded,
                                  size: 18,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: Spacing.sm),
                            Flexible(
                              child: Text(
                                'HERMANOS LEDGR',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: theme.colorScheme.primary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_currentPage < _totalPages - 1)
                        TextButton(
                          onPressed: _finish,
                          child: Text(
                            'Skip',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildWelcomePage(theme),
                  _buildThemePage(theme, currentThemeMode),
                  _buildAccountsPage(theme, onboardingState),
                  _buildReadyPage(theme, onboardingState),
                ],
              ),
            ),

            // Bottom Navigation & Page Indicator
            Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Row(
                children: [
                  // Animated Dots Indicator
                  Row(
                    children: List.generate(_totalPages, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.only(right: 6),
                        height: 8,
                        width: isActive ? 24 : 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),

                  // Next / Get Started Button
                  FilledButton(
                    onPressed: _nextPage,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(130, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentPage == _totalPages - 1
                              ? 'Get Started'
                              : 'Continue',
                        ),
                        const SizedBox(width: Spacing.xs),
                        Icon(
                          _currentPage == _totalPages - 1
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcomePage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Spacing.xl),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.savings_rounded,
              size: 36,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: Spacing.xl),
          Text(
            'Calm, Offline-First\nPersonal Finance',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: Spacing.md),
          Text(
            'Inspired by elite trackers, built purely for personal privacy and lightning-fast logging on your Galaxy device.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: Spacing.xxl),

          // Feature Highlights
          _buildFeatureTile(
            theme,
            icon: Icons.lock_outline_rounded,
            title: '100% Offline & Private',
            subtitle: 'No cloud sync, no tracking, no external accounts.',
          ),
          const SizedBox(height: Spacing.md),
          _buildFeatureTile(
            theme,
            icon: Icons.psychology_rounded,
            title: 'On-Device Local AI',
            subtitle: 'Log "Starbucks 250 GCash" and let local LLM do the rest.',
          ),
          const SizedBox(height: Spacing.md),
          _buildFeatureTile(
            theme,
            icon: Icons.currency_ruble_rounded,
            title: 'Philippine Presets',
            subtitle: 'Built for GCash, Maya, BDO, BPI, and Philippine Peso (₱).',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return M3Card(
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemePage(ThemeData theme, AppThemeMode currentMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Spacing.xl),
          Text(
            'Tailored Aesthetic',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Select how Hermanos Ledgr looks on your display. You can change this anytime in Settings.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.xl),

          _buildThemeCard(
            theme,
            mode: AppThemeMode.dark,
            title: 'Dark Mode (Recommended)',
            description: 'Deep Stash glass surfaces with soft teal accents and balanced contrast.',
            icon: Icons.dark_mode_rounded,
            isSelected: currentMode == AppThemeMode.dark,
          ),
          const SizedBox(height: Spacing.md),
          _buildThemeCard(
            theme,
            mode: AppThemeMode.amoled,
            title: 'AMOLED Black',
            description: 'True black (#000000) optimized for Samsung Super AMOLED power saving.',
            icon: Icons.brightness_2_rounded,
            isSelected: currentMode == AppThemeMode.amoled,
          ),
          const SizedBox(height: Spacing.md),
          _buildThemeCard(
            theme,
            mode: AppThemeMode.light,
            title: 'Light Mode',
            description: 'Crisp, high-contrast slate with vibrant teal accents for bright daylight.',
            icon: Icons.light_mode_rounded,
            isSelected: currentMode == AppThemeMode.light,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(
    ThemeData theme, {
    required AppThemeMode mode,
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
  }) {
    return M3Card(
      onTap: () => ref.read(themeProvider.notifier).setTheme(mode),
      border: isSelected
          ? Border.all(color: theme.colorScheme.primary, width: 2)
          : null,
      color: isSelected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check_circle_rounded,
              color: theme.colorScheme.primary,
            ),
        ],
      ),
    );
  }

  Widget _buildAccountsPage(ThemeData theme, OnboardingState state) {
    const availableAccounts = [
      {'name': 'GCash', 'icon': Icons.account_balance_wallet_rounded, 'subtitle': 'E-Wallet'},
      {'name': 'Cash Wallet', 'icon': Icons.payments_rounded, 'subtitle': 'Cash in hand'},
      {'name': 'BDO Savings', 'icon': Icons.account_balance_rounded, 'subtitle': 'Bank Account'},
      {'name': 'Maya', 'icon': Icons.wallet_rounded, 'subtitle': 'E-Wallet'},
      {'name': 'BPI Platinum Card', 'icon': Icons.credit_card_rounded, 'subtitle': 'Credit Card'},
      {'name': 'Other / Custom', 'icon': Icons.add_circle_outline_rounded, 'subtitle': 'Custom bank, e-wallet, or cash'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Spacing.xl),
          Text(
            'Personalize Setup',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Your ledger belongs solely to you. Enter your name and pick your starting accounts.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.xl),

          // Name Input
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Owner / Profile Name',
              hintText: 'e.g. John C.',
              prefixIcon: Icon(Icons.person_rounded),
            ),
            onChanged: (val) =>
                ref.read(onboardingProvider.notifier).setUserName(val),
          ),
          const SizedBox(height: Spacing.xl),

          Text(
            'Starting Accounts',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Tap to select the accounts you want to track initially:',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.md),

          for (final acc in availableAccounts) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: M3Card(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
                onTap: () => ref
                    .read(onboardingProvider.notifier)
                    .toggleStarterAccount(acc['name'] as String),
                border: state.selectedStarterAccounts.contains(acc['name'])
                    ? Border.all(color: theme.colorScheme.primary, width: 1.5)
                    : null,
                child: Row(
                  children: [
                    Icon(
                      acc['icon'] as IconData,
                      size: 22,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            acc['name'] as String,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            acc['subtitle'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        final isSelected = state.selectedStarterAccounts
                            .contains(acc['name']);
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline
                                      .withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: theme.colorScheme.onPrimary,
                                )
                              : null,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (acc['name'] == 'Other / Custom' &&
                state.selectedStarterAccounts.contains('Other / Custom')) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.md),
                child: M3Card(
                  padding: const EdgeInsets.all(Spacing.md),
                  color: theme.colorScheme.surfaceContainerHigh,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: Spacing.xs),
                          Text(
                            'Custom Account Details',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.sm),
                      TextField(
                        controller: _customAccountController,
                        decoration: const InputDecoration(
                          labelText: 'Account / Provider Name',
                          hintText: 'e.g. GoTyme, SeaBank, UnionBank, PayPal',
                          prefixIcon: Icon(Icons.account_balance_outlined, size: 20),
                          isDense: true,
                        ),
                        onChanged: (val) => ref
                            .read(onboardingProvider.notifier)
                            .setCustomAccountName(val),
                      ),
                      const SizedBox(height: Spacing.md),
                      Text(
                        'Account Type',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Row(
                        children: [
                          _buildAccountTypeChip(
                            theme,
                            label: 'Bank',
                            icon: Icons.account_balance_rounded,
                            isSelected: state.customAccountType == 'bank',
                            onTap: () => ref
                                .read(onboardingProvider.notifier)
                                .setCustomAccountType('bank'),
                          ),
                          const SizedBox(width: Spacing.xs),
                          _buildAccountTypeChip(
                            theme,
                            label: 'E-Wallet',
                            icon: Icons.wallet_rounded,
                            isSelected: state.customAccountType == 'eWallet',
                            onTap: () => ref
                                .read(onboardingProvider.notifier)
                                .setCustomAccountType('eWallet'),
                          ),
                          const SizedBox(width: Spacing.xs),
                          _buildAccountTypeChip(
                            theme,
                            label: 'Cash / Other',
                            icon: Icons.payments_rounded,
                            isSelected: state.customAccountType == 'cash',
                            onTap: () => ref
                                .read(onboardingProvider.notifier)
                                .setCustomAccountType('cash'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildAccountTypeChip(
    ThemeData theme, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            vertical: Spacing.sm,
            horizontal: Spacing.xs,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadyPage(ThemeData theme, OnboardingState state) {
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: Spacing.xl),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Text(
            'Ready to Begin',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Welcome, ${state.userName}! Hermanos Ledgr is fully configured and ready for your first entry.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: Spacing.xl),

          // Setup Summary Card
          M3Card(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: Spacing.sm),
                    Text(
                      'Configuration Summary',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                Divider(
                  height: 1,
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
                const SizedBox(height: Spacing.md),

                // Profile row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ledger Owner',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      state.userName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),

                // Starting accounts row
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Starting Accounts',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Wrap(
                      spacing: Spacing.xs,
                      runSpacing: Spacing.xs,
                      children: state.selectedStarterAccounts.map((accName) {
                        final typeLabel = state.customAccountType == 'eWallet'
                            ? 'E-Wallet'
                            : (state.customAccountType == 'cash'
                                ? 'Cash'
                                : 'Bank');
                        final displayName = accName == 'Other / Custom'
                            ? (state.customAccountName.trim().isEmpty
                                ? 'Custom ($typeLabel)'
                                : '${state.customAccountName.trim()} ($typeLabel)')
                            : accName;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? StashColors.raised
                                : theme.colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            displayName,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),

                // Storage mode row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Storage Engine',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'On-Device SQLite',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),

          // Privacy Assurance Banner
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: isDark
                  ? StashColors.raised.withValues(alpha: 0.5)
                  : theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    'Your data stays completely private and never leaves this device.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
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
}
