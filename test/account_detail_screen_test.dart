import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/app/theme/app_theme.dart';
import 'package:hermanos_ledgr/core/providers/shared_preferences_provider.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/accounts/presentation/screens/account_detail_screen.dart';
import 'package:hermanos_ledgr/features/accounts/providers/accounts_provider.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';
import 'package:hermanos_ledgr/features/transactions/providers/mock_transactions_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('AccountDetailScreen displays personalized card, cashflow summary, actions, and transactions', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    const testAccount = AccountModel(
      id: 'acc_maribank',
      name: 'MariBank Savings',
      type: AccountType.bank,
      balance: 15000.0,
      icon: Icons.account_balance_rounded,
      color: Color(0xFFFF5722),
      institution: 'MariBank',
    );

    final testTransactions = [
      TransactionModel(
        id: 'tx_1',
        title: 'Salary Deposit',
        amount: 20000.0,
        type: TransactionType.income,
        categoryId: 'income',
        categoryName: 'Salary',
        categoryIcon: Icons.payments_rounded,
        categoryColor: const Color(0xFF43A047),
        accountId: 'acc_maribank',
        accountName: 'MariBank Savings',
        date: DateTime.now(),
      ),
      TransactionModel(
        id: 'tx_2',
        title: 'Groceries',
        amount: 2500.0,
        type: TransactionType.expense,
        categoryId: 'food',
        categoryName: 'Food & Dining',
        categoryIcon: Icons.restaurant_rounded,
        categoryColor: const Color(0xFFF57C00),
        accountId: 'acc_maribank',
        accountName: 'MariBank Savings',
        date: DateTime.now(),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          accountsProvider.overrideWith(() => _FakeAccountsNotifier([testAccount])),
          transactionsProvider.overrideWith(() => _FakeTransactionsNotifier(testTransactions)),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const AccountDetailScreen(accountId: 'acc_maribank'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify AppBar title and actions
    expect(find.text('MariBank Savings'), findsWidgets);
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);

    // Verify Action Tiles & Filter Chips
    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('Income'), findsWidgets);
    expect(find.text('Transfer'), findsOneWidget);

    // Verify Cashflow Summary
    expect(find.text('Cashflow Summary'), findsOneWidget);
    expect(find.text('Total Inflow'), findsOneWidget);
    expect(find.text('Total Outflow'), findsOneWidget);
    expect(find.text('Net Flow'), findsOneWidget);

    // Verify Activity Header and Filter Chips
    expect(find.text('Account Activity'), findsOneWidget);
    expect(find.text('All (2)'), findsOneWidget);
    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Transfers'), findsOneWidget);

    // Verify Transaction Items
    expect(find.text('Salary Deposit'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);

    // Tap Expenses filter chip
    await tester.tap(find.text('Expenses'));
    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Salary Deposit'), findsNothing);
  });

  testWidgets('AccountDetailScreen shows friendly empty state when no transactions exist', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    const testAccount = AccountModel(
      id: 'acc_empty',
      name: 'Empty Vault',
      type: AccountType.cash,
      balance: 0.0,
      icon: Icons.payments_rounded,
      color: Color(0xFF00897B),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          accountsProvider.overrideWith(() => _FakeAccountsNotifier([testAccount])),
          transactionsProvider.overrideWith(() => _FakeTransactionsNotifier([])),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const AccountDetailScreen(accountId: 'acc_empty'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No transactions for this account'), findsOneWidget);
    expect(find.text('Add Transaction'), findsOneWidget);
  });
}

class _FakeAccountsNotifier extends AccountsNotifier {
  final List<AccountModel> initial;
  _FakeAccountsNotifier(this.initial);

  @override
  List<AccountModel> build() => initial;
}

class _FakeTransactionsNotifier extends TransactionsNotifier {
  final List<TransactionModel> initial;
  _FakeTransactionsNotifier(this.initial);

  @override
  List<TransactionModel> build() => initial;
}
