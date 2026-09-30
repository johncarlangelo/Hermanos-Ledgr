import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/app/app.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/core/providers/database_provider.dart';
import 'package:hermanos_ledgr/core/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'has_completed_onboarding': false,
    });
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('Onboarding does not reset page on typing name or toggling accounts',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          databaseProvider.overrideWithValue(db),
        ],
        child: const HermanosLedgrApp(),
      ),
    );

    // Initial splash settlement
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pumpAndSettle();

    // Verify Onboarding Welcome page is shown
    expect(find.text('Calm, Offline-First\nPersonal Finance'), findsOneWidget);

    // 1. Advance to Page 1 (Theme Page)
    final continueBtn = find.text('Continue');
    expect(continueBtn, findsOneWidget);
    await tester.tap(continueBtn);
    await tester.pumpAndSettle();

    expect(find.text('Tailored Aesthetic'), findsOneWidget);

    // Tap AMOLED Black theme card
    await tester.tap(find.text('AMOLED Black'));
    await tester.pumpAndSettle();

    // CRITICAL CHECK: Still on Theme Page!
    expect(find.text('Tailored Aesthetic'), findsOneWidget);

    // 2. Advance to Page 2 (Accounts & Personalize Page)
    await tester.tap(continueBtn);
    await tester.pumpAndSettle();

    expect(find.text('Personalize Setup'), findsOneWidget);

    // Type in Owner / Profile Name
    final nameField = find.byType(TextField);
    expect(nameField, findsOneWidget);
    await tester.enterText(nameField, 'Carlos M.');
    await tester.pumpAndSettle();

    // CRITICAL CHECK: Still on Personalize Setup Page after typing!
    expect(find.text('Personalize Setup'), findsOneWidget);
    expect(find.text('Carlos M.'), findsOneWidget);

    // Toggle starting accounts (e.g. Maya)
    await tester.tap(find.text('Maya'));
    await tester.pumpAndSettle();

    // CRITICAL CHECK: Still on Personalize Setup Page after toggling account!
    expect(find.text('Personalize Setup'), findsOneWidget);

    // 3. Advance to Page 3 (Ready Page)
    await tester.tap(continueBtn);
    await tester.pumpAndSettle();

    expect(find.text('Ready to Begin'), findsOneWidget);
    expect(find.text('Welcome, Carlos M.! Hermanos Ledgr is fully configured and ready for your first entry.'), findsOneWidget);

    // 4. Tap "Get Started"
    final getStartedBtn = find.text('Get Started');
    expect(getStartedBtn, findsOneWidget);
    await tester.tap(getStartedBtn);
    await tester.pumpAndSettle();

    // Verify main app dashboard is mounted
    expect(find.text('Hermanos Ledgr'), findsOneWidget);

    // Unmount and flush pending microtasks/timers
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });
}
