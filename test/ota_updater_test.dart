import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/features/settings/domain/semver_comparator.dart';
import 'package:hermanos_ledgr/features/settings/domain/update_release_model.dart';
import 'package:hermanos_ledgr/features/settings/providers/updater_provider.dart';

void main() {
  group('SemVerComparator', () {
    test('clean strips leading v and prerelease identifiers', () {
      expect(SemVerComparator.clean('v0.20.0'), '0.20.0');
      expect(SemVerComparator.clean('V1.2.3'), '1.2.3');
      expect(SemVerComparator.clean('v0.19.0-alpha'), '0.19.0');
      expect(SemVerComparator.clean('0.18.9+48'), '0.18.9+48');
    });

    test('parseParts extracts major, minor, patch and build', () {
      expect(SemVerComparator.parseParts('v0.20.0+50'), [0, 20, 0, 50]);
      expect(SemVerComparator.parseParts('1.2.3'), [1, 2, 3, 0]);
      expect(SemVerComparator.parseParts('v2.0.0-rc1'), [2, 0, 0, 0]);
    });

    test('compare orders versions accurately', () {
      expect(SemVerComparator.compare('0.20.0', '0.19.0'), 1);
      expect(SemVerComparator.compare('0.19.0', '0.20.0'), -1);
      expect(SemVerComparator.compare('0.20.0', '0.20.0'), 0);
      expect(SemVerComparator.compare('v0.20.0', '0.20.0'), 0);
      expect(SemVerComparator.compare('0.20.1', '0.20.0'), 1);
      expect(SemVerComparator.compare('1.0.0', '0.20.0'), 1);
      expect(SemVerComparator.compare('0.20.0+51', '0.20.0+50'), 1);
    });

    test('isNewer returns true only when remote is strictly higher', () {
      expect(SemVerComparator.isNewer('0.20.0', '0.19.0'), isTrue);
      expect(SemVerComparator.isNewer('v0.20.1', 'v0.20.0-alpha'), isTrue);
      expect(SemVerComparator.isNewer('0.19.0', '0.19.0'), isFalse);
      expect(SemVerComparator.isNewer('0.18.9', '0.20.0'), isFalse);
    });
  });

  group('UpdateReleaseModel', () {
    test('parses GitHub release payload correctly', () {
      final json = {
        'tag_name': 'v0.20.0',
        'name': 'Hermanos Ledgr v0.20.0',
        'body': '• Added in-app OTA updates\n• Bug fixes',
        'published_at': '2026-11-08T10:00:00Z',
        'html_url': 'https://github.com/johncarlangelo/hermanos-ledgr/releases/v0.20.0',
        'assets': [
          {
            'name': 'hermanos-ledgr-v0.20.0.apk',
            'content_type': 'application/vnd.android.package-archive',
            'browser_download_url':
                'https://github.com/johncarlangelo/hermanos-ledgr/releases/download/v0.20.0/app-release.apk',
            'size': 35000000,
          }
        ],
      };

      final release = UpdateReleaseModel.fromJson(json);

      expect(release.tagName, 'v0.20.0');
      expect(release.version, '0.20.0');
      expect(release.name, 'Hermanos Ledgr v0.20.0');
      expect(release.body, contains('Added in-app OTA updates'));
      expect(release.apkFileName, 'hermanos-ledgr-v0.20.0.apk');
      expect(release.apkDownloadUrl, contains('app-release.apk'));
      expect(release.apkSizeBytes, 35000000);
    });

    test('handles missing assets gracefully', () {
      final json = {
        'tag_name': 'v0.21.0',
        'name': 'Pre-release',
      };

      final release = UpdateReleaseModel.fromJson(json);
      expect(release.version, '0.21.0');
      expect(release.apkDownloadUrl, '');
      expect(release.apkSizeBytes, 0);
    });
  });

  group('UpdaterNotifier State Flow', () {
    test('simulateUpdate sets available status with valid model', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(updaterProvider.notifier);
      expect(container.read(updaterProvider).status, UpdateStatus.idle);

      notifier.simulateUpdate(version: '0.21.0');
      expect(container.read(updaterProvider).status, UpdateStatus.available);
      expect(container.read(updaterProvider).latestRelease, isNotNull);
      expect(container.read(updaterProvider).latestRelease!.version, '0.21.0');

      notifier.reset();
      expect(container.read(updaterProvider).status, UpdateStatus.idle);
      expect(container.read(updaterProvider).latestRelease, isNull);
    });

    test('simulateDownload updates progress to completion', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(updaterProvider.notifier);
      notifier.simulateUpdate();

      await notifier.simulateDownload();
      expect(container.read(updaterProvider).status, UpdateStatus.readyToInstall);
      expect(container.read(updaterProvider).progress, 1.0);
      expect(container.read(updaterProvider).downloadedFilePath, isNotNull);
    });
  });
}
