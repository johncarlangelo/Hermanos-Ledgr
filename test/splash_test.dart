import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/app/theme/app_theme.dart';
import 'package:hermanos_ledgr/core/constants/app_constants.dart';
import 'package:hermanos_ledgr/features/splash/presentation/screens/splash_screen.dart';
import 'package:hermanos_ledgr/features/splash/providers/splash_provider.dart';

void main() {
  testWidgets('SplashScreen mounts, renders brand typography, and executes flight', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const Scaffold(body: SplashScreen()),
        ),
      ),
    );

    // Initial frame
    await tester.pump();

    // Verify brand typography exists
    expect(find.text(AppConstants.appName.toUpperCase()), findsOneWidget);
    expect(find.text('SOVEREIGN PERSONAL LEDGER'), findsOneWidget);

    // Verify brand emblem icon exists
    expect(find.byIcon(Icons.account_balance_wallet_rounded), findsOneWidget);

    // Advance through intro and flight animation
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1000));

    // Verify splash state completed
    expect(container.read(splashProvider).isVisible, isFalse);
  });
}
