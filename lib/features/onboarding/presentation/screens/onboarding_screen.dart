import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hermanos_ledgr/app/theme/app_theme.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/core/providers/onboarding_provider.dart';
import 'package:hermanos_ledgr/core/providers/theme_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
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
    await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onboardingState = ref.watch(onboardingProvider);
    final currentThemeMode = ref.watch(themeProvider);

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
                            Container(
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
          ],
        ],
      ),
    );
  }

  Widget _buildReadyPage(ThemeData theme, OnboardingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: Spacing.xxl),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 48,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: Spacing.xl),
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
          const SizedBox(height: Spacing.xxl),

          // Privacy Guarantee Card
          M3Card(
            padding: const EdgeInsets.all(Spacing.lg),
            color: theme.colorScheme.surfaceContainerHigh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: Spacing.sm),
                    Text(
                      'Zero-Cloud Guarantee',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  'Your financial records never leave this Samsung Galaxy device. No telemetry, no background network calls, and no monthly fees. You are in total control.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),

          // Quick Start Tips
          Row(
            children: [
              Expanded(
                child: M3Card(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: Column(
                    children: [
                      Icon(Icons.flash_on_rounded,
                          color: theme.colorScheme.secondary),
                      const SizedBox(height: Spacing.xs),
                      Text('Sub-3s Logging',
                          style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600)),
                      Text('Custom Keypad',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 10)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: M3Card(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: Column(
                    children: [
                      Icon(Icons.undo_rounded,
                          color: theme.colorScheme.secondary),
                      const SizedBox(height: Spacing.xs),
                      Text('5s Undo Toast',
                          style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600)),
                      Text('Safety Net',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
