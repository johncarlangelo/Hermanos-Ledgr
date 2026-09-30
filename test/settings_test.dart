import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/app/theme/app_theme.dart';
import 'package:hermanos_ledgr/core/constants/app_constants.dart';
import 'package:hermanos_ledgr/core/providers/shared_preferences_provider.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/accounts/presentation/widgets/delete_account_sheet.dart';
import 'package:hermanos_ledgr/features/settings/presentation/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('SettingsScreen mounts with profile, sections, and version pill', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify AppBar title and version
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text(AppConstants.appVersionDisplay), findsWidgets);

    // Verify Section Headers
    expect(find.text('ACCOUNTS & WALLETS'), findsOneWidget);
    expect(find.text('APPEARANCE & DISPLAY'), findsOneWidget);
    expect(find.text('SOUND & TACTILE'), findsOneWidget);
    expect(find.text('HERMANO AI INTELLIGENCE'), findsOneWidget);
    // Scroll down to reveal bottom sections
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('DANGER ZONE'), findsOneWidget);

    // Verify key action tiles
    expect(find.text('Export Ledger'), findsOneWidget);
    expect(find.text('Reset Ledger Data'), findsOneWidget);
  });

  testWidgets('DeleteAccountSheet mounts with account name, balance, and action buttons', (tester) async {
    const testAccount = AccountModel(
      id: 'acc_test_delete',
      name: 'Maya Test',
      type: AccountType.eWallet,
      balance: 1500.0,
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF005CEE),
      institution: 'Maya Philippines',
      monthlyChange: 0.0,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const Scaffold(
            body: DeleteAccountSheet(account: testAccount),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Delete Account'), findsWidgets);
    expect(find.text('Maya Test'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Maya Philippines • E-Wallet'), findsOneWidget);
  });
}
