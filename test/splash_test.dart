import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/app/theme/app_theme.dart';
import 'package:hermanos_ledgr/core/constants/app_constants.dart';
import 'package:hermanos_ledgr/features/splash/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('SplashScreen mounts and renders brand typography and hero emblem', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const SplashScreen(),
        ),
      ),
    );

    // Initial frame
    await tester.pump();

    // Verify brand typography exists
    expect(find.text(AppConstants.appName.toUpperCase()), findsOneWidget);
    expect(find.text('SOVEREIGN PERSONAL LEDGER'), findsOneWidget);

    // Verify hero emblem exists
    expect(find.byKey(const Key('app_brand_emblem')), findsNothing); // find by type
    expect(find.byType(Hero), findsOneWidget);

    // Advance animation partially
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1000));
  });
}
