import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hermanos_ledgr/app/theme/app_theme.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/core/providers/onboarding_provider.dart';
import 'package:hermanos_ledgr/core/providers/theme_provider.dart';
import 'package:hermanos_ledgr/features/transactions/presentation/widgets/add_transaction_sheet.dart';

class ShellScaffold extends ConsumerWidget {
  final Widget child;

  const ShellScaffold({
    super.key,
    required this.child,
  });

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/transactions')) return 1;
    if (location.startsWith('/budget')) return 3;
    if (location.startsWith('/ai')) return 4;
    return 0; // default to home
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/transactions');
        break;
      case 2:
        // Center Log Tab: open bottom sheet directly without navigating away
        AddTransactionSheet.show(context);
        break;
      case 3:
        context.go('/budget');
        break;
      case 4:
        context.go('/ai');
        break;
    }
  }

  void _showThemeSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final currentMode = ref.watch(themeProvider);
            final theme = Theme.of(context);

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
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(Spacing.sm),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.palette_rounded,
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
                                'Display Theme',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Tailored visual styles for your display',
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

                    // Theme Options
                    _buildThemeOptionCard(
                      context: context,
                      theme: theme,
                      mode: AppThemeMode.dark,
                      currentMode: currentMode,
                      title: 'Dark Mode',
                      subtitle: 'Deep Stash glass surfaces with soft teal accents',
                      badge: 'Balanced Tonal',
                      badgeColor: theme.colorScheme.primary,
                      paletteBg: const Color(0xFF08090D),
                      paletteCard: const Color(0xFF12151E),
                      paletteAccent: const Color(0xFF7FB8AE),
                      icon: Icons.dark_mode_rounded,
                      onTap: () {
                        ref
                            .read(themeProvider.notifier)
                            .setTheme(AppThemeMode.dark);
                      },
                    ),
                    const SizedBox(height: Spacing.sm),

                    _buildThemeOptionCard(
                      context: context,
                      theme: theme,
                      mode: AppThemeMode.amoled,
                      currentMode: currentMode,
                      title: 'AMOLED Black',
                      subtitle: 'True black (#000000) for Samsung OLED power saving',
                      badge: '⚡ OLED Saver',
                      badgeColor: const Color(0xFF7FC08D),
                      paletteBg: const Color(0xFF000000),
                      paletteCard: const Color(0xFF0C1017),
                      paletteAccent: const Color(0xFF7FB8AE),
                      icon: Icons.brightness_2_rounded,
                      onTap: () {
                        ref
                            .read(themeProvider.notifier)
                            .setTheme(AppThemeMode.amoled);
                      },
                    ),
                    const SizedBox(height: Spacing.sm),

                    _buildThemeOptionCard(
                      context: context,
                      theme: theme,
                      mode: AppThemeMode.light,
                      currentMode: currentMode,
                      title: 'Light Mode',
                      subtitle: 'Crisp daylight slate with vibrant teal highlights',
                      badge: 'Daylight Ready',
                      badgeColor: const Color(0xFF00796B),
                      paletteBg: const Color(0xFFF4F6F8),
                      paletteCard: const Color(0xFFFFFFFF),
                      paletteAccent: const Color(0xFF00897B),
                      icon: Icons.light_mode_rounded,
                      onTap: () {
                        ref
                            .read(themeProvider.notifier)
                            .setTheme(AppThemeMode.light);
                      },
                    ),
                    const SizedBox(height: Spacing.sm),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThemeOptionCard({
    required BuildContext context,
    required ThemeData theme,
    required AppThemeMode mode,
    required AppThemeMode currentMode,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required Color paletteBg,
    required Color paletteCard,
    required Color paletteAccent,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isSelected = mode == currentMode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.08)
                : theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              // Mini Swatch Palette Preview
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: paletteBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 6,
                      left: 6,
                      right: 6,
                      bottom: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: paletteCard,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: paletteAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.md),

              // Title, Subtitle & Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: Spacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.sm),

              // Selection Indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isSelected ? theme.colorScheme.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                    width: isSelected ? 0 : 1.5,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: theme.colorScheme.onPrimary,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _calculateSelectedIndex(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(Spacing.xs),
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
            Text(
              'Hermanos Ledgr',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        actions: [
          // Theme Switcher Button
          IconButton(
            icon: const Icon(Icons.palette_outlined, size: 22),
            tooltip: 'Change Theme',
            onPressed: () => _showThemeSheet(context, ref),
          ),
          // Re-experience Onboarding Button (for testing & review)
          IconButton(
            icon: const Icon(Icons.auto_stories_outlined, size: 22),
            tooltip: 'View Onboarding',
            onPressed: () async {
              await ref.read(onboardingProvider.notifier).resetOnboarding();
              if (context.mounted) {
                context.go('/onboarding');
              }
            },
          ),
          const SizedBox(width: Spacing.xs),
        ],
      ),
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (idx) => _onItemTapped(idx, context),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Ledger',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline_rounded),
              selectedIcon: Icon(Icons.add_circle_rounded),
              label: 'Log',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Budget',
            ),
            NavigationDestination(
              icon: Icon(Icons.smart_toy_outlined),
              selectedIcon: Icon(Icons.smart_toy_rounded),
              label: 'AI',
            ),
          ],
        ),
      ),
    );
  }
}
