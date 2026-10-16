import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/app/theme/app_theme.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/accounts/domain/card_brand.dart';
import 'package:hermanos_ledgr/features/accounts/presentation/widgets/personalized_card.dart';

void main() {
  group('CardBrand detection tests', () {
    test('detects MariBank correctly from various names', () {
      expect(CardBrand.detect('MariBank'), CardBrand.mariBank);
      expect(CardBrand.detect('SeaBank Savings'), CardBrand.mariBank);
      expect(CardBrand.detect('My Mari Account'), CardBrand.mariBank);
    });

    test('detects GCash, Maya, and BDO correctly', () {
      expect(CardBrand.detect('GCash'), CardBrand.gcash);
      expect(CardBrand.detect('Maya Wallet'), CardBrand.maya);
      expect(CardBrand.detect('BDO Savings'), CardBrand.bdo);
    });

    test('detects international accounts (Wise, PayPal, Venmo)', () {
      expect(CardBrand.detect('Wise USD'), CardBrand.wise);
      expect(CardBrand.detect('PayPal Balance'), CardBrand.paypal);
      expect(CardBrand.detect('Venmo Card'), CardBrand.venmo);
    });

    test('detects digital e-wallets correctly', () {
      expect(CardBrand.detect('GrabPay Wallet'), CardBrand.grabPay);
      expect(CardBrand.detect('ShopeePay Balance'), CardBrand.shopeePay);
      expect(CardBrand.detect('Tonik Stash'), CardBrand.tonik);
      expect(CardBrand.detect('CIMB GSave'), CardBrand.cimb);
      expect(CardBrand.detect('Coins.ph BTC'), CardBrand.coins);
      expect(CardBrand.detect('Apple Cash'), CardBrand.appleCash);
      expect(CardBrand.detect('Google Wallet'), CardBrand.googleWallet);
    });

    test('detects Cash and defaults correctly', () {
      expect(CardBrand.detect('Cash Wallet'), CardBrand.cash);
      expect(CardBrand.detect('Random Unknown Bank'), CardBrand.custom);
    });

    test('generates dynamic custom gradient from base color', () {
      const base = Color(0xFF9C27B0);
      final gradient = CardBrand.customGradient(base);
      expect(gradient.colors.length, 3);
      expect(gradient.colors[1], base);
    });
  });

  group('PersonalizedCard Widget tests', () {
    testWidgets('renders MariBank physical card vector skin and balance overlay', (tester) async {
      const account = AccountModel(
        id: 'acc_maribank',
        name: 'MariBank',
        type: AccountType.bank,
        balance: 15420.50,
        icon: Icons.account_balance_rounded,
        color: Color(0xFFFF5200),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: const Scaffold(
            body: Center(
              child: PersonalizedCard(account: account),
            ),
          ),
        ),
      );

      expect(find.byType(SvgPicture), findsOneWidget);
      expect(find.text('MariBank'), findsOneWidget);
      expect(find.text('₱15,420.50'), findsOneWidget);
    });

    testWidgets('renders Wise physical card with vector skin and balance overlay', (tester) async {
      const account = AccountModel(
        id: 'acc_wise',
        name: 'Wise USD',
        type: AccountType.eWallet,
        balance: 500.00,
        icon: Icons.wallet_rounded,
        color: Color(0xFF9FE870),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: const Scaffold(
            body: Center(
              child: PersonalizedCard(account: account),
            ),
          ),
        ),
      );

      expect(find.byType(SvgPicture), findsOneWidget);
      expect(find.text('Wise USD'), findsOneWidget);
      expect(find.text('₱500.00'), findsOneWidget);
    });

    testWidgets('renders Apple Cash with vector skin and balance overlay', (tester) async {
      const account = AccountModel(
        id: 'acc_apple',
        name: 'Apple Cash',
        type: AccountType.eWallet,
        balance: 2450.00,
        icon: Icons.wallet_rounded,
        color: Color(0xFFE8ECEF),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: const Scaffold(
            body: Center(
              child: PersonalizedCard(account: account),
            ),
          ),
        ),
      );

      expect(find.byType(SvgPicture), findsOneWidget);
      expect(find.text('Apple Cash'), findsOneWidget);
      expect(find.text('₱2,450.00'), findsOneWidget);
    });

    testWidgets('renders GrabPay digital card with vector skin and balance overlay', (tester) async {
      const account = AccountModel(
        id: 'acc_grab',
        name: 'GrabPay',
        type: AccountType.eWallet,
        balance: 850.75,
        icon: Icons.wallet_rounded,
        color: Color(0xFF00B14F),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: const Scaffold(
            body: Center(
              child: PersonalizedCard(account: account),
            ),
          ),
        ),
      );

      expect(find.byType(SvgPicture), findsOneWidget);
      expect(find.text('GrabPay'), findsOneWidget);
      expect(find.text('₱850.75'), findsOneWidget);
    });

    testWidgets('renders custom account with programmatic fallback and custom gradient', (tester) async {
      const account = AccountModel(
        id: 'acc_custom',
        name: 'My Special Vault',
        type: AccountType.bank,
        balance: 99999.00,
        icon: Icons.lock_outline_rounded,
        color: Color(0xFF7B1FA2),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: const Scaffold(
            body: Center(
              child: PersonalizedCard(account: account),
            ),
          ),
        ),
      );

      expect(find.byType(SvgPicture), findsNothing);
      expect(find.text('DEBIT'), findsOneWidget);
      expect(find.text('MY SPECIAL VAULT'), findsOneWidget);
      expect(find.text('₱99,999.00'), findsOneWidget);
    });
  });
}
