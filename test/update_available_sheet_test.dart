import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/app/theme/app_theme.dart';
import 'package:hermanos_ledgr/features/settings/domain/update_release_model.dart';
import 'package:hermanos_ledgr/features/settings/presentation/widgets/update_available_sheet.dart';

void main() {
  testWidgets('UpdateAvailableSheet renders version pills and changelog', (tester) async {
    final release = UpdateReleaseModel(
      tagName: 'v0.20.1',
      version: '0.20.1',
      name: 'Hermanos Ledgr v0.20.1',
      body: '### Highlights\n* Instant OTA updates\n* Performance fixes',
      apkDownloadUrl: 'https://example.com/app-release.apk',
      apkFileName: 'hermanos-ledgr-v0.20.1.apk',
      apkSizeBytes: 35000000,
      publishedAt: DateTime.now(),
      htmlUrl: 'https://github.com',
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: UpdateAvailableSheet(release: release),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Update Available'), findsOneWidget);
    expect(find.text('v0.20.1'), findsOneWidget);
    expect(find.text('Release Notes'), findsOneWidget);
    expect(find.text('Highlights'), findsOneWidget);
    expect(find.text('Instant OTA updates'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
    expect(find.text('Download & Install'), findsOneWidget);
  });
}
