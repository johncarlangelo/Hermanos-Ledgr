import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/app/theme/app_theme.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/accounts/providers/accounts_provider.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';
import 'package:hermanos_ledgr/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:hermanos_ledgr/features/transactions/presentation/widgets/transaction_card.dart';
import 'package:hermanos_ledgr/features/transactions/providers/transactions_provider.dart';

final _testAccount = const AccountModel(
  id: 'acc_gcash',
  name: 'GCash',
  type: AccountType.eWallet,
  balance: 5000.0,
  icon: Icons.account_balance_wallet_rounded,
  color: Color(0xFF005CEE),
  institution: 'Mynt',
  monthlyChange: 0.0,
);

final _testTx = TransactionModel(
  id: 'tx_swipe_test',
  title: 'Starbucks Coffee',
  amount: 195.0,
  type: TransactionType.expense,
  categoryId: 'cat_food',
  categoryName: 'Food & Dining',
  categoryIcon: Icons.restaurant_rounded,
  categoryColor: const Color(0xFFE53935),
  accountId: 'acc_gcash',
  accountName: 'GCash',
  date: DateTime.now(),
);

class _TestAccountsNotifier extends AccountsNotifier {
  @override
  List<AccountModel> build() => [_testAccount];
}

class _TestTransactionsNotifier extends TransactionsNotifier {
  @override
  List<TransactionModel> build() => [_testTx];
}

void main() {
  testWidgets('TransactionsScreen displays transaction cards, filters, and swipe actions', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountsProvider.overrideWith(_TestAccountsNotifier.new),
          transactionsProvider.overrideWith(_TestTransactionsNotifier.new),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const TransactionsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title and Search Bar
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Search transactions, notes, categories...'), findsOneWidget);

    // Verify Date Header & Transaction Card
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('Starbucks Coffee'), findsOneWidget);
    expect(find.text('-₱195.00'), findsOneWidget);

    // Test Swipe-Right to Edit
    final cardFinder = find.byType(TransactionCard);
    expect(cardFinder, findsOneWidget);

    // Drag from left to right (swipe right)
    await tester.drag(cardFinder, const Offset(300, 0));
    await tester.pumpAndSettle();

    // Edit sheet should now be open
    expect(find.text('Edit Transaction'), findsOneWidget);

    // Tap Hide Keypad to collapse numeric keypad and view form fields
    await tester.tap(find.text('Hide'));
    await tester.pumpAndSettle();

    expect(find.text('Attach Receipt / Proof (Optional)'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);

    // Close edit sheet
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();
  });
}
