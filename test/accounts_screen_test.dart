import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/app/theme/app_theme.dart';
import 'package:hermanos_ledgr/core/providers/shared_preferences_provider.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:hermanos_ledgr/features/accounts/providers/accounts_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('AccountsScreen mounts and displays net worth, filter chips, and account cards', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final testAccounts = [
      const AccountModel(
        id: 'acc_bdo',
        name: 'BDO Savings',
        type: AccountType.bank,
        balance: 10000.0,
        icon: Icons.account_balance_rounded,
        color: Color(0xFF0038A8),
        institution: 'BDO Unibank',
      ),
      const AccountModel(
        id: 'acc_gcash',
        name: 'GCash',
        type: AccountType.eWallet,
        balance: 5000.0,
        icon: Icons.wallet_rounded,
        color: Color(0xFF005CEE),
        institution: 'Mynt',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          accountsProvider.overrideWith(() => _FakeAccountsNotifier(testAccounts)),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const AccountsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify AppBar title and FAB
    expect(find.text('Accounts & Wallets'), findsOneWidget);
    expect(find.text('New Account'), findsOneWidget);

    // Verify Summary Card
    expect(find.text('Total Net Worth'), findsOneWidget);
    expect(find.text('Total Assets'), findsOneWidget);
    expect(find.text('Total Liabilities'), findsOneWidget);

    // Verify Account Items (appears on mini card and on tile title)
    expect(find.text('BDO Savings'), findsWidgets);
    expect(find.text('GCash'), findsWidgets);

    // Verify Filter Chips
    expect(find.text('All (2)'), findsOneWidget);
    expect(find.text('Banks (1)'), findsOneWidget);
    expect(find.text('E-Wallets (1)'), findsOneWidget);

    // Tap Banks filter chip
    await tester.tap(find.text('Banks (1)'));
    await tester.pumpAndSettle();

    expect(find.text('BDO Savings'), findsWidgets);
    expect(find.text('GCash'), findsNothing);
  });
}

class _FakeAccountsNotifier extends AccountsNotifier {
  final List<AccountModel> initial;
  _FakeAccountsNotifier(this.initial);

  @override
  List<AccountModel> build() => initial;
}
