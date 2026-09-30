import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hermanos_ledgr/app/shell_scaffold.dart';
import 'package:hermanos_ledgr/core/providers/onboarding_provider.dart';
import 'package:hermanos_ledgr/features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import 'package:hermanos_ledgr/features/budget/presentation/screens/budget_screen.dart';
import 'package:hermanos_ledgr/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:hermanos_ledgr/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:hermanos_ledgr/features/settings/presentation/screens/settings_screen.dart';
import 'package:hermanos_ledgr/features/splash/providers/splash_provider.dart';
import 'package:hermanos_ledgr/features/transactions/presentation/screens/transactions_screen.dart';

class _OnboardingRefreshNotifier extends ChangeNotifier {
  _OnboardingRefreshNotifier(Ref ref) {
    ref.listen<bool>(
      onboardingProvider.select((s) => s.isCompleted),
      (previous, current) => notifyListeners(),
    );
    ref.listen<bool>(
      onboardingProvider.select((s) => s.isLoading),
      (previous, current) => notifyListeners(),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _OnboardingRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final onboardingState = ref.read(onboardingProvider);
      if (onboardingState.isLoading) return null;

      final isGoingToOnboarding = state.matchedLocation == '/onboarding';

      if (!onboardingState.isCompleted && !isGoingToOnboarding) {
        return '/onboarding';
      }

      if (onboardingState.isCompleted && isGoingToOnboarding) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        redirect: (context, state) {
          ref.read(splashProvider.notifier).replay();
          return '/';
        },
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/transactions',
            builder: (context, state) => const TransactionsScreen(),
          ),
          GoRoute(
            path: '/budget',
            builder: (context, state) => const BudgetScreen(),
          ),
          GoRoute(
            path: '/ai',
            builder: (context, state) => const AiAssistantScreen(),
          ),
        ],
      ),
    ],
  );
});
