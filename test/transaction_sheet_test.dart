import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/app/theme/app_theme.dart';
import 'package:hermanos_ledgr/features/transactions/presentation/widgets/add_transaction_sheet.dart';
import 'package:hermanos_ledgr/shared/widgets/custom_keypad.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AddTransactionSheet prioritizes keypad at the top', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => AddTransactionSheet.show(context),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    // Open sheet
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Keypad and quick chips should be immediately visible
    expect(find.byType(CustomKeypad), findsOneWidget);
    expect(find.text('+₱100'), findsOneWidget);
    expect(find.text('+₱500'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    // Tapping keypad updates the amount
    await tester.tap(find.text('5'));
    await tester.pumpAndSettle();
    expect(find.text('5'), findsWidgets);

    await tester.tap(find.text('6'));
    await tester.pumpAndSettle();
    expect(find.text('56'), findsOneWidget);

    // Save button is present
    expect(find.text('Save Expense'), findsOneWidget);
  });

  testWidgets('UndoSnackbar.success displays checkmark with no countdown timer', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => UndoSnackbar.success(context, message: 'Logged "Initial Balance" (₱56.00)'),
              child: const Text('Show Success'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Success'));
    await tester.pump();

    // Check message and checkmark icon
    expect(find.text('Logged "Initial Balance" (₱56.00)'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    // Should NOT have an UNDO button or countdown timer
    expect(find.text('UNDO'), findsNothing);
  });
}
