import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermanos_ledgr/core/constants/app_constants.dart';
import 'package:hermanos_ledgr/features/settings/data/github_update_service.dart';
import 'package:hermanos_ledgr/features/settings/domain/semver_comparator.dart';
import 'package:hermanos_ledgr/features/settings/domain/update_release_model.dart';

enum UpdateStatus {
  idle,
  checking,
  available,
  upToDate,
  downloading,
  readyToInstall,
  error,
}

class UpdateState {
  final UpdateStatus status;
  final UpdateReleaseModel? latestRelease;
  final double progress;
  final int receivedBytes;
  final int totalBytes;
  final String? downloadedFilePath;
  final String? errorMessage;
  final DateTime? lastChecked;

  const UpdateState({
    this.status = UpdateStatus.idle,
    this.latestRelease,
    this.progress = 0.0,
    this.receivedBytes = 0,
    this.totalBytes = 0,
    this.downloadedFilePath,
    this.errorMessage,
    this.lastChecked,
  });

  UpdateState copyWith({
    UpdateStatus? status,
    UpdateReleaseModel? latestRelease,
    double? progress,
    int? receivedBytes,
    int? totalBytes,
    String? downloadedFilePath,
    String? errorMessage,
    DateTime? lastChecked,
  }) {
    return UpdateState(
      status: status ?? this.status,
      latestRelease: latestRelease ?? this.latestRelease,
      progress: progress ?? this.progress,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedFilePath: downloadedFilePath ?? this.downloadedFilePath,
      errorMessage: errorMessage ?? this.errorMessage,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }
}

final githubUpdateServiceProvider = Provider<GitHubUpdateService>((ref) {
  return GitHubUpdateService();
});

class UpdaterNotifier extends Notifier<UpdateState> {
  GitHubUpdateService get _service => ref.read(githubUpdateServiceProvider);

  @override
  UpdateState build() {
    return const UpdateState();
  }

  /// Key used to throttle background update checks to at most once per 24 hours.
  static const String _kLastCheckKey = 'pref_last_update_check';

  /// Performs a throttled background check on startup (at most once every 24 hours).
  Future<void> checkForUpdatesOnStartup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheckMillis = prefs.getInt(_kLastCheckKey);
      if (lastCheckMillis != null) {
        final lastCheck = DateTime.fromMillisecondsSinceEpoch(lastCheckMillis);
        if (DateTime.now().difference(lastCheck).inHours < 24) {
          // Throttled: checked less than 24 hours ago
          return;
        }
      }

      await prefs.setInt(_kLastCheckKey, DateTime.now().millisecondsSinceEpoch);
      await checkForUpdates(isManual: false);
    } catch (_) {
      // Background checks fail silently without interrupting the user
    }
  }

  /// Checks GitHub Releases API for updates.
  Future<void> checkForUpdates({bool isManual = true}) async {
    state = state.copyWith(status: UpdateStatus.checking, errorMessage: null);

    try {
      final release = await _service.getLatestRelease();
      final now = DateTime.now();

      if (release == null) {
        // No release published yet
        state = state.copyWith(
          status: UpdateStatus.upToDate,
          lastChecked: now,
          latestRelease: null,
        );
        return;
      }

      final isNewer =
          SemVerComparator.isNewer(release.version, AppConstants.appVersion);

      if (isNewer) {
        state = state.copyWith(
          status: UpdateStatus.available,
          latestRelease: release,
          lastChecked: now,
        );
      } else {
        state = state.copyWith(
          status: UpdateStatus.upToDate,
          latestRelease: release,
          lastChecked: now,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: 'Unable to check for updates: $e',
        lastChecked: DateTime.now(),
      );
    }
  }

  /// Downloads the specified release APK with live stream progress.
  Future<void> startDownload(UpdateReleaseModel release) async {
    if (kIsWeb) {
      // In web browser, simulate download progress
      await simulateDownload();
      return;
    }

    state = state.copyWith(
      status: UpdateStatus.downloading,
      progress: 0.0,
      receivedBytes: 0,
      totalBytes: release.apkSizeBytes,
      errorMessage: null,
    );

    try {
      final tempDir = await getTemporaryDirectory();
      final savePath = p.join(tempDir.path, release.apkFileName);

      await for (final progress in _service.downloadApk(
        downloadUrl: release.apkDownloadUrl,
        savePath: savePath,
        onBytesProgress: (received, total) {
          state = state.copyWith(
            receivedBytes: received,
            totalBytes: total,
            progress: total > 0 ? (received / total).clamp(0.0, 1.0) : 0.5,
          );
        },
      )) {
        state = state.copyWith(progress: progress);
      }

      state = state.copyWith(
        status: UpdateStatus.readyToInstall,
        downloadedFilePath: savePath,
        progress: 1.0,
      );
    } catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: 'Failed to download update: $e',
      );
    }
  }

  /// Triggers the Android Package Installer for the downloaded APK.
  Future<bool> installDownloadedApk() async {
    final filePath = state.downloadedFilePath;
    if (filePath == null) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: 'No downloaded APK file found.',
      );
      return false;
    }

    final success = await _service.installApk(filePath);
    if (!success) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: 'Android package installer failed to launch.',
      );
    }
    return success;
  }

  /// Simulates an available update for instant UI/UX testing in Chrome or Emulator.
  void simulateUpdate({
    String version = '0.20.1',
    String? changelog,
  }) {
    final dummyRelease = UpdateReleaseModel(
      tagName: 'v$version',
      version: version,
      name: 'Hermanos Ledgr v$version',
      body: changelog ??
          '### What’s New in v$version\n'
              '• Instant OTA in-app auto-updater via GitHub Releases\n'
              '• Enhanced Samsung Galaxy Super AMOLED true black optimization\n'
              '• Tabular figure typography hardening on all balance totals\n'
              '• Responsive desktop companion layout support\n'
              '• Bug fixes and battery life improvements',
      apkDownloadUrl:
          'https://github.com/johncarlangelo/hermanos-ledgr/releases/download/v$version/app-release.apk',
      apkFileName: 'hermanos-ledgr-v$version.apk',
      apkSizeBytes: 34500000, // ~34.5 MB
      publishedAt: DateTime.now(),
      htmlUrl: 'https://github.com/johncarlangelo/hermanos-ledgr/releases',
    );

    state = state.copyWith(
      status: UpdateStatus.available,
      latestRelease: dummyRelease,
      lastChecked: DateTime.now(),
      progress: 0.0,
      errorMessage: null,
    );
  }

  /// Simulates a download progress animation (useful for testing on Web/Emulators).
  Future<void> simulateDownload() async {
    state = state.copyWith(
      status: UpdateStatus.downloading,
      progress: 0.0,
      receivedBytes: 0,
      totalBytes: 34500000,
    );

    for (int i = 1; i <= 20; i++) {
      await Future.delayed(const Duration(milliseconds: 60));
      final p = i / 20.0;
      state = state.copyWith(
        progress: p,
        receivedBytes: (p * 34500000).toInt(),
      );
    }

    state = state.copyWith(
      status: UpdateStatus.readyToInstall,
      downloadedFilePath: '/mock/path/hermanos-ledgr-simulated.apk',
      progress: 1.0,
    );
  }

  /// Resets status to idle.
  void reset() {
    state = const UpdateState();
  }
}

final updaterProvider =
    NotifierProvider<UpdaterNotifier, UpdateState>(UpdaterNotifier.new);
