import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/app/theme/app_theme.dart';
import 'package:hermanos_ledgr/core/constants/app_constants.dart';
import 'package:hermanos_ledgr/features/settings/presentation/screens/settings_screen.dart';

void main() {
  testWidgets('SettingsScreen mounts with profile, sections, and version pill', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
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
    expect(find.text('APPEARANCE & DISPLAY'), findsOneWidget);
    expect(find.text('SOUND & TACTILE'), findsOneWidget);
    expect(find.text('LOCAL AI INTELLIGENCE'), findsOneWidget);
    expect(find.text('DATA & STORAGE'), findsOneWidget);
    expect(find.text('DANGER ZONE'), findsOneWidget);

    // Verify key action tiles
    expect(find.text('Display Theme'), findsOneWidget);
    expect(find.text('Compact Numbers'), findsOneWidget);
    expect(find.text('Haptic Feedback'), findsOneWidget);
    expect(find.text('Export Ledger'), findsOneWidget);
    expect(find.text('Reset Ledger Data'), findsOneWidget);
  });
}
