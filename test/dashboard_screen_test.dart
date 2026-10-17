import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/app/theme/app_theme.dart';
import 'package:hermanos_ledgr/core/providers/onboarding_provider.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/accounts/providers/accounts_provider.dart';
import 'package:hermanos_ledgr/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:hermanos_ledgr/features/dashboard/presentation/widgets/dashboard_quick_actions.dart';
import 'package:hermanos_ledgr/features/dashboard/presentation/widgets/net_worth_hero_card.dart';
import 'package:hermanos_ledgr/features/dashboard/presentation/widgets/recent_activity_section.dart';
import 'package:hermanos_ledgr/features/dashboard/providers/dashboard_provider.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';
import 'package:hermanos_ledgr/features/transactions/presentation/widgets/add_transaction_sheet.dart';
import 'package:hermanos_ledgr/features/transactions/presentation/widgets/transaction_card.dart';
import 'package:hermanos_ledgr/features/transactions/providers/transactions_provider.dart';

final _testGcash = const AccountModel(
  id: 'acc_gcash',
  name: 'GCash',
  type: AccountType.eWallet,
  balance: 5000.0,
  icon: Icons.account_balance_wallet_rounded,
  color: Color(0xFF005CEE),
  institution: 'Mynt',
  monthlyChange: 0.0,
);

final _testBdo = const AccountModel(
  id: 'acc_bdo',
  name: 'BDO Savings',
  type: AccountType.bank,
  balance: 10000.0,
  icon: Icons.account_balance_rounded,
  color: Color(0xFF0038A8),
  institution: 'BDO Unibank',
  monthlyChange: 0.0,
);

final _testTxExpense = TransactionModel(
  id: 'tx_coffee',
  title: 'Starbucks Coffee',
  amount: 250.0,
  type: TransactionType.expense,
  categoryId: 'cat_food',
  categoryName: 'Food & Dining',
  categoryIcon: Icons.restaurant_rounded,
  categoryColor: const Color(0xFFE53935),
  accountId: 'acc_gcash',
  accountName: 'GCash',
  date: DateTime.now(),
);

final _testTxIncome = TransactionModel(
  id: 'tx_salary',
  title: 'Freelance Design',
  amount: 8000.0,
  type: TransactionType.income,
  categoryId: 'cat_income',
  categoryName: 'Salary',
  categoryIcon: Icons.payments_rounded,
  categoryColor: const Color(0xFF43A047),
  accountId: 'acc_bdo',
  accountName: 'BDO Savings',
  date: DateTime.now(),
);

class _TestAccountsNotifier extends AccountsNotifier {
  @override
  List<AccountModel> build() => [_testGcash, _testBdo];
}

class _TestTransactionsNotifier extends TransactionsNotifier {
  @override
  List<TransactionModel> build() => [_testTxIncome, _testTxExpense];
}

class _TestEmptyTransactionsNotifier extends TransactionsNotifier {
  @override
  List<TransactionModel> build() => [];
}

class _TestOnboardingNotifier extends OnboardingNotifier {
  @override
  OnboardingState build() => const OnboardingState(
        isCompleted: true,
        userName: 'John C.',
      );
}

void main() {
  test('dashboardProvider computes correct metrics from accounts and transactions', () {
    final container = ProviderContainer(
      overrides: [
        accountsProvider.overrideWith(_TestAccountsNotifier.new),
        transactionsProvider.overrideWith(_TestTransactionsNotifier.new),
      ],
    );
    addTearDown(container.dispose);

    final data = container.read(dashboardProvider);

    // Total Net Worth = 5000 + 10000 = 15000
    expect(data.netWorth, 15000.0);
    expect(data.totalAssets, 15000.0);
    expect(data.totalLiabilities, 0.0);

    // Monthly Income = 8000, Expense = 250, Net = 7750
    expect(data.monthlyIncome, 8000.0);
    expect(data.monthlyExpenses, 250.0);
    expect(data.monthlyNetChange, 7750.0);

    // Savings rate = (7750 / 8000) * 100 = 96.875%
    expect(data.savingsRate, closeTo(96.875, 0.01));

    expect(data.accounts.length, 2);
    expect(data.recentTransactions.length, 2);
    expect(data.hasAccounts, isTrue);
    expect(data.hasTransactions, isTrue);
  });

  testWidgets('DashboardScreen renders all hero, carousel, and quick action components', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingProvider.overrideWith(_TestOnboardingNotifier.new),
          accountsProvider.overrideWith(_TestAccountsNotifier.new),
          transactionsProvider.overrideWith(_TestTransactionsNotifier.new),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const DashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Greeting & User Header
    expect(find.textContaining('John C.'), findsOneWidget);
    expect(find.text('Personal Ledger'), findsOneWidget);

    // 2. Verify Net Worth Hero Card & Metrics
    expect(find.byType(NetWorthHeroCard), findsOneWidget);
    expect(find.text('Net Worth'), findsOneWidget);
    expect(find.text('Total Assets'), findsOneWidget);
    expect(find.text('Total Liabilities'), findsOneWidget);
    expect(find.textContaining('Savings Rate'), findsOneWidget);

    // 3. Verify Quick Actions
    expect(find.byType(DashboardQuickActions), findsOneWidget);
    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Transfer'), findsOneWidget);

    // 4. Verify Accounts Carousel & Add Button
    expect(find.text('Accounts & Wallets'), findsOneWidget);
    expect(find.text('2 active'), findsOneWidget);
    expect(find.text('Add Account'), findsOneWidget);

    // 5. Verify Recent Activity
    expect(find.byType(RecentActivitySection), findsOneWidget);
    expect(find.text('Recent Activity'), findsOneWidget);
    expect(find.text('See All'), findsOneWidget);
    expect(find.byType(TransactionCard), findsNWidgets(2));
    expect(find.text('Starbucks Coffee'), findsOneWidget);
    expect(find.text('Freelance Design'), findsOneWidget);
  });

  testWidgets('Tapping Expense quick action opens AddTransactionSheet pre-filled', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingProvider.overrideWith(_TestOnboardingNotifier.new),
          accountsProvider.overrideWith(_TestAccountsNotifier.new),
          transactionsProvider.overrideWith(_TestTransactionsNotifier.new),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const DashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Quick Action "Expense"
    await tester.tap(find.text('Expense'));
    await tester.pumpAndSettle();

    // Verify AddTransactionSheet opened
    expect(find.byType(AddTransactionSheet), findsOneWidget);
    expect(find.text('Quick Log'), findsOneWidget);
    expect(find.text('Save Expense'), findsOneWidget);
  });

  testWidgets('DashboardScreen renders empty state when no transactions exist', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingProvider.overrideWith(_TestOnboardingNotifier.new),
          accountsProvider.overrideWith(_TestAccountsNotifier.new),
          transactionsProvider.overrideWith(_TestEmptyTransactionsNotifier.new),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const DashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No recent transactions'), findsOneWidget);
    expect(find.text('Log Expense'), findsOneWidget);
  });
}
