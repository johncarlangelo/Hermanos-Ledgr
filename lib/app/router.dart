import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hermanos_ledgr/app/shell_scaffold.dart';
import 'package:hermanos_ledgr/core/providers/onboarding_provider.dart';
import 'package:hermanos_ledgr/features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import 'package:hermanos_ledgr/features/budget/presentation/screens/budget_screen.dart';
import 'package:hermanos_ledgr/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:hermanos_ledgr/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:hermanos_ledgr/features/settings/presentation/screens/settings_screen.dart';
import 'package:hermanos_ledgr/features/splash/presentation/screens/splash_screen.dart';
import 'package:hermanos_ledgr/features/transactions/presentation/screens/transactions_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final onboardingState = ref.watch(onboardingProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      if (onboardingState.isLoading) return null;

      final isSplash = state.matchedLocation == '/splash';
      if (isSplash) return null;

      final isGoingToOnboarding = state.matchedLocation == '/onboarding';

      if (!onboardingState.isCompleted && !isGoingToOnboarding) {
        return '/onboarding';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
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
