import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hermanos_ledgr/app/theme/app_theme.dart';
import 'package:hermanos_ledgr/core/providers/shared_preferences_provider.dart';
import 'package:hermanos_ledgr/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:hermanos_ledgr/features/settings/presentation/screens/settings_screen.dart';
import 'package:hermanos_ledgr/features/settings/presentation/widgets/profile_edit_sheet.dart';
import 'package:hermanos_ledgr/shared/widgets/profile_avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Test clicking profile avatar in dashboard and opening profile edit sheet', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Find and tap profile avatar on dashboard -> navigates to settings
    final dashboardAvatar = find.byType(ProfileAvatar);
    expect(dashboardAvatar, findsOneWidget);
    await tester.tap(dashboardAvatar);
    await tester.pumpAndSettle();

    // 2. On SettingsScreen, find profile avatar and tap it -> opens ProfileEditSheet
    final settingsAvatar = find.byType(ProfileAvatar);
    expect(settingsAvatar, findsOneWidget);
    await tester.tap(settingsAvatar);
    await tester.pumpAndSettle();

    // 3. Verify ProfileEditSheet elements
    expect(find.byType(ProfileEditSheet), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Upload Photo'), findsOneWidget);
    expect(find.text('Supports PNG, JPG, and GIF (up to 5MB)'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);

    // 4. Close the sheet
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileEditSheet), findsNothing);

    // 5. Open sheet via edit icon button next to username
    await tester.tap(find.byIcon(Icons.edit_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileEditSheet), findsOneWidget);
  });
}
