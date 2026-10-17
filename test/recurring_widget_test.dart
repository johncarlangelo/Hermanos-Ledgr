import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/app/theme/app_theme.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/accounts/providers/accounts_provider.dart';
import 'package:hermanos_ledgr/features/recurring/domain/recurring_model.dart';
import 'package:hermanos_ledgr/features/recurring/presentation/screens/forecast_screen.dart';
import 'package:hermanos_ledgr/features/recurring/presentation/screens/recurring_screen.dart';
import 'package:hermanos_ledgr/features/recurring/presentation/widgets/add_recurring_sheet.dart';
import 'package:hermanos_ledgr/features/recurring/presentation/widgets/recurring_rule_card.dart';
import 'package:hermanos_ledgr/features/recurring/providers/recurring_provider.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';

class _MockRecurringNotifier extends RecurringNotifier {
  final List<RecurringModel> _initial;
  _MockRecurringNotifier(this._initial);

  @override
  List<RecurringModel> build() => _initial;

  @override
  Future<void> addRule(RecurringModel rule) async {
    state = [...state, rule];
  }

  @override
  Future<void> updateRule(RecurringModel rule) async {
    state = [for (final r in state) if (r.id == rule.id) rule else r];
  }

  @override
  Future<void> toggleActive(String id) async {
    state = [
      for (final r in state)
        if (r.id == id) r.copyWith(isActive: !r.isActive) else r,
    ];
  }

  @override
  Future<RecurringModel?> deleteRule(String id) async {
    final match = state.cast<RecurringModel?>().firstWhere((r) => r?.id == id, orElse: () => null);
    state = state.where((r) => r.id != id).toList();
    return match;
  }
}

class _FakeAccountsNotifier extends AccountsNotifier {
  final List<AccountModel> initial;
  _FakeAccountsNotifier(this.initial);

  @override
  List<AccountModel> build() => initial;
}

Widget _buildTestApp({required Widget child, List<dynamic> overrides = const []}) {
  return ProviderScope(
    overrides: [for (final o in overrides) o],
    child: MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  final now = DateTime.now();

  final sampleActiveRule = RecurringModel(
    id: 'r_netflix',
    title: 'Netflix Premium',
    amount: 549.0,
    type: TransactionType.expense,
    categoryId: 'utilities',
    categoryName: 'Utilities & Bills',
    accountId: 'acc_1',
    accountName: 'GCash Wallet',
    frequency: RecurringFrequency.monthly,
    startDate: now,
    nextDueDate: now.add(const Duration(days: 5)),
    isActive: true,
  );

  final samplePausedRule = RecurringModel(
    id: 'r_gym',
    title: 'Anytime Fitness',
    amount: 2500.0,
    type: TransactionType.expense,
    categoryId: 'health',
    categoryName: 'Health & Fitness',
    accountId: 'acc_1',
    accountName: 'GCash Wallet',
    frequency: RecurringFrequency.monthly,
    startDate: now,
    nextDueDate: now.add(const Duration(days: 12)),
    isActive: false,
  );

  final sampleAccount = AccountModel(
    id: 'acc_1',
    name: 'GCash Wallet',
    type: AccountType.eWallet,
    balance: 15000.0,
    icon: Icons.account_balance_wallet_rounded,
    color: const Color(0xFF007DFE),
  );

  testWidgets('RecurringRuleCard renders details, switch, and options sheet', (tester) async {
    bool toggleClicked = false;
    bool logNowClicked = false;

    await tester.pumpWidget(
      _buildTestApp(
        child: RecurringRuleCard(
          rule: sampleActiveRule,
          onToggleActive: () => toggleClicked = true,
          onLogNow: () => logNowClicked = true,
        ),
      ),
    );

    expect(find.text('Netflix Premium'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.textContaining('549.00'), findsOneWidget);
    expect(find.textContaining('In 5 days'), findsOneWidget);

    // Tap animated switch container
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pump();
    expect(toggleClicked, isTrue);

    // Open options sheet via more_vert_rounded
    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Log Instance Now'), findsOneWidget);
    expect(find.text('Edit Rule'), findsOneWidget);
    expect(find.text('Pause Rule'), findsOneWidget);

    // Tap Log Instance Now
    await tester.tap(find.text('Log Instance Now'));
    await tester.pumpAndSettle();
    expect(logNowClicked, isTrue);
  });

  testWidgets('RecurringScreen displays commitment hero, segmented tabs, and filters', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        overrides: [
          recurringProvider.overrideWith(
            () => _MockRecurringNotifier([sampleActiveRule, samplePausedRule]),
          ),
          accountsProvider.overrideWith(
            () => _FakeAccountsNotifier([sampleAccount]),
          ),
        ],
        child: const RecurringScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recurring & Subscriptions'), findsOneWidget);
    expect(find.text('MONTHLY RECURRING COMMITMENT'), findsOneWidget);

    // Tab counts
    expect(find.text('All (2)'), findsOneWidget);
    expect(find.text('Active (1)'), findsOneWidget);
    expect(find.text('Paused (1)'), findsOneWidget);

    // Default 'All' tab shows both
    expect(find.text('Netflix Premium'), findsOneWidget);
    expect(find.text('Anytime Fitness'), findsOneWidget);

    // Switch to 'Active' tab
    await tester.tap(find.text('Active (1)'));
    await tester.pumpAndSettle();

    expect(find.text('Netflix Premium'), findsOneWidget);
    expect(find.text('Anytime Fitness'), findsNothing);

    // Switch to 'Paused' tab
    await tester.tap(find.text('Paused (1)'));
    await tester.pumpAndSettle();

    expect(find.text('Anytime Fitness'), findsOneWidget);
    expect(find.text('Netflix Premium'), findsNothing);
  });

  testWidgets('ForecastScreen renders projected balance, horizon selector, and timeline', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      _buildTestApp(
        overrides: [
          recurringProvider.overrideWith(
            () => _MockRecurringNotifier([sampleActiveRule]),
          ),
          accountsProvider.overrideWith(
            () => _FakeAccountsNotifier([sampleAccount]),
          ),
        ],
        child: const ForecastScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cashflow Forecast'), findsOneWidget);
    expect(find.text('PROJECTED BALANCE IN 30 DAYS'), findsOneWidget);
    expect(find.text('PROJECTED CASHFLOW CURVE'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('UPCOMING SCHEDULED PAYMENTS'), 100);
    expect(find.text('UPCOMING SCHEDULED PAYMENTS'), findsOneWidget);

    // Switch horizon to 60 Days
    await tester.ensureVisible(find.text('60 Days'));
    await tester.tap(find.text('60 Days'));
    await tester.pumpAndSettle();

    expect(find.text('PROJECTED BALANCE IN 60 DAYS'), findsOneWidget);
  });

  testWidgets('AddRecurringSheet validates fields and allows frequency selection', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      _buildTestApp(
        overrides: [
          accountsProvider.overrideWith(
            () => _FakeAccountsNotifier([sampleAccount]),
          ),
        ],
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => AddRecurringSheet.show(context),
            child: const Text('Open Add Recurring'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Add Recurring'));
    await tester.pumpAndSettle();

    expect(find.text('New Recurring Rule'), findsOneWidget);
    expect(find.text('RECURRENCE FREQUENCY'), findsOneWidget);

    // Select Weekly chip
    await tester.ensureVisible(find.text('Weekly'));
    await tester.tap(find.text('Weekly'));
    await tester.pumpAndSettle();

    // Tap save without filling title
    await tester.ensureVisible(find.text('Create Recurring Rule'));
    await tester.tap(find.text('Create Recurring Rule'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a title'), findsOneWidget);
  });
}
