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

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final currentMode = ref.read(themeProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Display Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Dark Mode (M3 Tonal)'),
              trailing: currentMode == AppThemeMode.dark
                  ? Icon(Icons.check_circle_rounded,
                      color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(AppThemeMode.dark);
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              title: const Text('AMOLED Black (Samsung True Black)'),
              trailing: currentMode == AppThemeMode.amoled
                  ? Icon(Icons.check_circle_rounded,
                      color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(AppThemeMode.amoled);
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              title: const Text('Light Mode'),
              trailing: currentMode == AppThemeMode.light
                  ? Icon(Icons.check_circle_rounded,
                      color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(AppThemeMode.light);
                Navigator.of(ctx).pop();
              },
            ),
          ],
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
            onPressed: () => _showThemeDialog(context, ref),
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
      bottomNavigationBar: NavigationBar(
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
            label: 'Transactions',
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
    );
  }
}
