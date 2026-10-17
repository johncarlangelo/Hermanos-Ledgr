import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/app/theme/app_theme.dart';
import 'package:hermanos_ledgr/features/debts/domain/debt_model.dart';
import 'package:hermanos_ledgr/features/debts/presentation/screens/debts_screen.dart';
import 'package:hermanos_ledgr/features/debts/presentation/widgets/bill_split_sheet.dart';
import 'package:hermanos_ledgr/features/debts/presentation/widgets/debt_card.dart';
import 'package:hermanos_ledgr/features/debts/presentation/widgets/record_payment_sheet.dart';
import 'package:hermanos_ledgr/features/debts/providers/debts_provider.dart';

class _MockDebtsNotifier extends DebtsNotifier {
  final List<DebtModel> _initial;
  _MockDebtsNotifier(this._initial);

  @override
  List<DebtModel> build() => _initial;

  @override
  Future<void> addDebt(DebtModel debt) async {
    state = [...state, debt];
  }

  @override
  Future<void> recordPayment(String debtId, double paymentAmount) async {
    state = state.map<DebtModel>((d) {
      if (d.id == debtId) {
        final newRemaining = (d.remainingAmount - paymentAmount).clamp(0.0, d.originalAmount);
        return d.copyWith(
          remainingAmount: newRemaining,
          isSettled: newRemaining <= 0,
        );
      }
      return d;
    }).toList();
  }

  @override
  Future<DebtModel?> deleteDebt(String id) async {
    final match = state.cast<DebtModel?>().firstWhere((d) => d?.id == id, orElse: () => null);
    state = state.where((d) => d.id != id).toList();
    return match;
  }
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

  final samplePayable = DebtModel(
    id: 'd_1',
    type: DebtType.debt,
    personName: 'Carlos Mendoza',
    originalAmount: 10000.0,
    remainingAmount: 6000.0,
    dueDate: now.add(const Duration(days: 10)),
    note: 'Laptop purchase share',
    createdAt: now,
  );

  final sampleReceivable = DebtModel(
    id: 'd_2',
    type: DebtType.receivable,
    personName: 'Sarah Jenkins',
    originalAmount: 4000.0,
    remainingAmount: 4000.0,
    dueDate: now.add(const Duration(days: 5)),
    note: 'Buffet bill advance',
    createdAt: now,
  );

  testWidgets('DebtCard renders initials, progress, and responds to actions', (tester) async {
    bool paymentTapped = false;
    bool editTapped = false;
    bool deleteTapped = false;

    await tester.pumpWidget(
      _buildTestApp(
        child: DebtCard(
          debt: samplePayable,
          onRecordPayment: () => paymentTapped = true,
          onEdit: () => editTapped = true,
          onDelete: () => deleteTapped = true,
        ),
      ),
    );

    // Initial avatar letters
    expect(find.text('CM'), findsOneWidget);
    expect(find.text('Carlos Mendoza'), findsOneWidget);
    expect(find.textContaining('40% paid'), findsOneWidget);

    // Tap Pay button ('Pay Debt')
    await tester.tap(find.text('Pay Debt'));
    await tester.pump();
    expect(paymentTapped, isTrue);

    // Open options sheet using more_vert_rounded icon
    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();

    // Verify actions sheet opened
    expect(find.text('Carlos Mendoza'), findsWidgets);
    expect(find.text('Edit Details'), findsOneWidget);
    expect(find.text('Delete Record'), findsOneWidget);

    await tester.tap(find.text('Edit Details'));
    await tester.pumpAndSettle();
    expect(editTapped, isTrue);
  });

  testWidgets('DebtsScreen renders net hero position and allows tab switching', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        overrides: [
          debtsProvider.overrideWith(() => _MockDebtsNotifier([samplePayable, sampleReceivable])),
        ],
        child: const DebtsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Debts & Receivables'), findsOneWidget);
    expect(find.text('NET DEBT POSITION'), findsOneWidget);

    // Tabs
    expect(find.textContaining('I Owe'), findsOneWidget);
    expect(find.textContaining('Owed to Me'), findsOneWidget);
    expect(find.textContaining('Settled'), findsOneWidget);

    // Default tab is 'I Owe' -> shows samplePayable
    expect(find.text('Carlos Mendoza'), findsOneWidget);
    expect(find.text('Sarah Jenkins'), findsNothing);

    // Switch tab to 'Owed to Me'
    await tester.tap(find.textContaining('Owed to Me'));
    await tester.pumpAndSettle();

    expect(find.text('Sarah Jenkins'), findsOneWidget);
    expect(find.text('Carlos Mendoza'), findsNothing);

    // Switch tab to 'Settled'
    await tester.tap(find.textContaining('Settled'));
    await tester.pumpAndSettle();

    expect(find.text('No settled records'), findsOneWidget);
  });

  testWidgets('BillSplitSheet calculates split per person and updates with tip/tax', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => BillSplitSheet.show(context),
            child: const Text('Open Bill Split'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Bill Split'));
    await tester.pumpAndSettle();

    expect(find.text('Bill Split Calculator'), findsOneWidget);
    expect(find.text('EACH PERSON PAYS'), findsOneWidget);

    // Default people count is 3
    expect(find.text('3'), findsOneWidget);

    // Enter bill amount 1500
    await tester.enterText(find.byType(TextField).first, '1500');
    await tester.pumpAndSettle();

    // 1500 / 3 = 500 per person
    expect(find.text('₱500.00'), findsWidgets);

    // Increment people count from 3 to 4
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    // 1500 / 4 = 375 per person
    expect(find.text('4'), findsOneWidget);
    expect(find.text('₱375.00'), findsWidgets);

    // Select 10% Tip/Tax chip
    final chipFinder = find.text('10%');
    await tester.ensureVisible(chipFinder);
    await tester.tap(chipFinder);
    await tester.pumpAndSettle();

    // Total with 10% = 1650 / 4 = 412.50
    expect(find.text('₱412.50'), findsWidgets);
  });

  testWidgets('RecordPaymentSheet sets payoff amount and displays keypad', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        overrides: [
          debtsProvider.overrideWith(() => _MockDebtsNotifier([samplePayable])),
        ],
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => RecordPaymentSheet.show(context, samplePayable),
            child: const Text('Open Pay Sheet'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Pay Sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Record Debt Repayment'), findsOneWidget);
    expect(find.textContaining('Carlos Mendoza'), findsWidgets);

    // Tap 'Full Payoff' quick chip
    await tester.tap(find.text('Full Payoff'));
    await tester.pumpAndSettle();

    // Amount should display 6000
    expect(find.text('6000'), findsOneWidget);
    expect(find.text('Confirm Repayment'), findsOneWidget);
  });
}
