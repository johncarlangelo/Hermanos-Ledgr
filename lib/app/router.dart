import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hermanos_ledgr/app/page_transitions.dart';
import 'package:hermanos_ledgr/app/shell_scaffold.dart';
import 'package:hermanos_ledgr/core/providers/onboarding_provider.dart';
import 'package:hermanos_ledgr/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:hermanos_ledgr/features/accounts/presentation/screens/account_detail_screen.dart';
import 'package:hermanos_ledgr/features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import 'package:hermanos_ledgr/features/budget/presentation/screens/budget_screen.dart';
import 'package:hermanos_ledgr/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:hermanos_ledgr/features/debts/presentation/screens/debts_screen.dart';
import 'package:hermanos_ledgr/features/goals/presentation/screens/goals_screen.dart';
import 'package:hermanos_ledgr/features/notes/presentation/screens/quick_notes_screen.dart';
import 'package:hermanos_ledgr/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:hermanos_ledgr/features/receipt_scanner/presentation/screens/receipt_scanner_screen.dart';
import 'package:hermanos_ledgr/features/recurring/presentation/screens/forecast_screen.dart';
import 'package:hermanos_ledgr/features/recurring/presentation/screens/recurring_screen.dart';
import 'package:hermanos_ledgr/features/settings/presentation/screens/settings_screen.dart';
import 'package:hermanos_ledgr/features/splash/providers/splash_provider.dart';
import 'package:hermanos_ledgr/features/transactions/presentation/screens/transactions_screen.dart';

class _OnboardingRefreshNotifier extends ChangeNotifier {
  _OnboardingRefreshNotifier(Ref ref) {
    ref.listen<bool>(
      onboardingProvider.select((s) => s.isCompleted),
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
        pageBuilder: (context, state) => buildCrossFadeTransition(
          child: const OnboardingScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => buildSharedAxisXTransition(
          child: const SettingsScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/accounts',
        pageBuilder: (context, state) => buildSharedAxisXTransition(
          child: const AccountsScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/accounts/:id',
        pageBuilder: (context, state) => buildSharedAxisXTransition(
          child: AccountDetailScreen(
            accountId: state.pathParameters['id']!,
          ),
          state: state,
        ),
      ),
      GoRoute(
        path: '/goals',
        pageBuilder: (context, state) => buildSharedAxisXTransition(
          child: const GoalsScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/debts',
        pageBuilder: (context, state) => buildSharedAxisXTransition(
          child: const DebtsScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/recurring',
        pageBuilder: (context, state) => buildSharedAxisXTransition(
          child: const RecurringScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/forecast',
        pageBuilder: (context, state) => buildSharedAxisXTransition(
          child: const ForecastScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/scanner',
        pageBuilder: (context, state) => buildSharedAxisXTransition(
          child: const ReceiptScannerScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/receipt-scanner',
        pageBuilder: (context, state) => buildSharedAxisXTransition(
          child: const ReceiptScannerScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/notes',
        pageBuilder: (context, state) => buildSharedAxisXTransition(
          child: const QuickNotesScreen(),
          state: state,
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => buildCrossFadeTransition(
              child: const DashboardScreen(),
              state: state,
            ),
          ),
          GoRoute(
            path: '/transactions',
            pageBuilder: (context, state) => buildCrossFadeTransition(
              child: const TransactionsScreen(),
              state: state,
            ),
          ),
          GoRoute(
            path: '/budget',
            pageBuilder: (context, state) => buildCrossFadeTransition(
              child: const BudgetScreen(),
              state: state,
            ),
          ),
          GoRoute(
            path: '/ai',
            pageBuilder: (context, state) => buildCrossFadeTransition(
              child: const AiAssistantScreen(),
              state: state,
            ),
          ),
        ],
      ),
    ],
  );
});
