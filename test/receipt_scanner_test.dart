import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/features/receipt_scanner/domain/receipt_parser.dart';
import 'package:hermanos_ledgr/features/receipt_scanner/domain/receipt_scan_result.dart';
import 'package:hermanos_ledgr/features/receipt_scanner/presentation/widgets/scan_result_sheet.dart';
import 'package:hermanos_ledgr/features/receipt_scanner/providers/receipt_scanner_provider.dart';

void main() {
  group('ReceiptParser Unit Tests (Task 10.2)', () {
    test('Correctly parses Jollibee receipt with VAT and Cash/Change rejection', () {
      const receiptText = '''
JOLLIBEE MEGAMALL
Store # 0451
1 C3 1pc Chicken w/ Drink   150.00
1 Jolly Spaghetti            60.00
SUBTOTAL                    210.00
12% VAT                      22.50
TOTAL AMOUNT DUE            210.00
CASH TENDERED               500.00
CHANGE                      290.00
Date: 2026-10-15 13:45
      ''';

      final result = ReceiptParser.parse(rawText: receiptText);

      expect(result.amount, equals(210.00));
      expect(result.merchant?.toLowerCase(), contains('jollibee'));
      expect(result.categoryId, equals('food'));
      expect(result.date?.year, equals(2026));
      expect(result.date?.month, equals(10));
      expect(result.date?.day, equals(15));
      expect(result.confidence, greaterThanOrEqualTo(0.8));
      expect(result.warningNote, isNotNull);
    });

    test('Correctly parses SM Supermarket receipt with comma thousands', () {
      const receiptText = '''
SM SUPERMARKET
SM North EDSA Branch
Fresh Milk 1L                95.00
Whole Wheat Bread            85.50
Pork Chops 1kg              350.00
TOTAL                     1,450.50
CASH                      2,000.00
CHANGE                      549.50
10/16/2026
      ''';

      final result = ReceiptParser.parse(rawText: receiptText);

      expect(result.amount, equals(1450.50));
      expect(result.merchant?.toLowerCase(), contains('sm supermarket'));
      expect(result.categoryId, equals('groceries'));
      expect(result.date?.year, equals(2026));
      expect(result.confidence, greaterThanOrEqualTo(0.8));
    });

    test('Correctly parses Mercury Drug receipt', () {
      const receiptText = '''
MERCURY DRUG
Cor. Ayala Ave, Makati City
BIOGESIC 500MG TAB           85.00
NEOZEP FORTE                 72.00
TOTAL AMOUNT DUE            157.00
CASH                        200.00
CHANGE                       43.00
2026/09/20
      ''';

      final result = ReceiptParser.parse(rawText: receiptText);

      expect(result.amount, equals(157.00));
      expect(result.merchant?.toLowerCase(), contains('mercury drug'));
      expect(result.categoryId, equals('health'));
      expect(result.date?.year, equals(2026));
      expect(result.date?.month, equals(9));
      expect(result.date?.day, equals(20));
    });

    test('Correctly parses Petron Gas receipt and categorizes as transport', () {
      const receiptText = '''
PETRON GASOLINE STATION
EDSA Philam Branch
TURBO DIESEL              1,200.00
GRAND TOTAL:              1,200.00
PAYMENT: CREDIT CARD
OCT 12, 2026
      ''';

      final result = ReceiptParser.parse(rawText: receiptText);

      expect(result.amount, equals(1200.00));
      expect(result.merchant?.toLowerCase(), contains('petron'));
      expect(result.categoryId, equals('transport'));
      expect(result.date?.year, equals(2026));
      expect(result.date?.month, equals(10));
      expect(result.date?.day, equals(12));
    });

    test('Handles noisy/crumpled receipt without failing', () {
      const noisyText = '''
--- NOISE ---
Random text 123
Crumpled section
###??
No clear total here
--- END ---
      ''';

      final result = ReceiptParser.parse(rawText: noisyText);

      expect(result.amount, isNull);
      expect(result.confidence, lessThan(0.5));
      expect(result.warningNote, isNotNull);
    });
  });

  group('ReceiptScannerState & Provider (Task 10.2, 10.6)', () {
    test('Initial state is idle with no result', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(receiptScannerProvider);

      expect(state.status, equals(ReceiptScanStatus.idle));
      expect(state.result, isNull);
      expect(state.errorMessage, isNull);
    });

    test('Reset restores state to idle', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(receiptScannerProvider.notifier).reset();
      final state = container.read(receiptScannerProvider);

      expect(state.status, equals(ReceiptScanStatus.idle));
      expect(state.result, isNull);
    });
  });

  group('ScanResultSheet Widget Tests (Task 10.4, 10.5)', () {
    testWidgets('Renders disclaimer banner and receipt details', (tester) async {
      final result = ReceiptScanResult(
        amount: 350.00,
        merchant: 'Jollibee',
        categoryId: 'food',
        categoryName: 'Food & Dining',
        date: DateTime(2026, 10, 15),
        confidence: 0.85,
        warningNote: ReceiptParser.accuracyNotice,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScanResultSheet(result: result),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check Scanned Receipt header
      expect(find.text('Scanned Receipt'), findsOneWidget);

      // Check Accuracy Disclaimer
      expect(find.text(ReceiptParser.accuracyNotice), findsOneWidget);

      // Check Merchant and Category
      expect(find.text('Jollibee'), findsOneWidget);
      expect(find.text('Food & Dining'), findsOneWidget);

      // Check Amount text field
      expect(find.text('350.00'), findsOneWidget);

      // Check Apply / Add to Ledger CTA button
      expect(find.text('Add to Ledger'), findsOneWidget);
    });
  });
}
