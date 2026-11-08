import 'dart:async';
import 'dart:convert';
import 'dart:io' show File, Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:hermanos_ledgr/features/settings/domain/update_release_model.dart';

/// Service responsible for communicating with the GitHub Releases API,
/// downloading update APK bundles, and invoking the Android installer.
class GitHubUpdateService {
  final http.Client _client;
  static const String defaultRepo = 'johncarlangelo/hermanos-ledgr';
  static const MethodChannel _installerChannel =
      MethodChannel('com.hermanos.hermanos_ledgr/installer');

  GitHubUpdateService({http.Client? client}) : _client = client ?? http.Client();

  /// Queries GitHub Releases API for the latest published release.
  /// Returns `null` if no release is found (404) or on network failure.
  Future<UpdateReleaseModel?> getLatestRelease({
    String repo = defaultRepo,
  }) async {
    final uri = Uri.parse('https://api.github.com/repos/$repo/releases/latest');
    try {
      final response = await _client.get(
        uri,
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'HermanosLedgr-App',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return UpdateReleaseModel.fromJson(data);
      } else if (response.statusCode == 404) {
        // No releases have been published yet
        return null;
      } else {
        debugPrint(
            'GitHubUpdateService: unexpected status code ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('GitHubUpdateService getLatestRelease error: $e');
      return null;
    }
  }

  /// Downloads an APK from [downloadUrl] and streams progress (0.0 to 1.0).
  /// Saves the file to [savePath].
  Stream<double> downloadApk({
    required String downloadUrl,
    required String savePath,
    void Function(int received, int total)? onBytesProgress,
  }) async* {
    if (kIsWeb) {
      // In web browser, direct file download streaming is handled by browser
      yield 1.0;
      return;
    }

    final request = http.Request('GET', Uri.parse(downloadUrl))
      ..headers['User-Agent'] = 'HermanosLedgr-App';

    final response = await _client.send(request);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'Failed to download APK. Server returned HTTP ${response.statusCode}');
    }

    final totalBytes = response.contentLength ?? 0;
    int receivedBytes = 0;

    final file = File(savePath);
    final sink = file.openWrite();

    try {
      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (onBytesProgress != null) {
          onBytesProgress(receivedBytes, totalBytes);
        }
        if (totalBytes > 0) {
          yield receivedBytes / totalBytes;
        } else {
          yield 0.5; // indeterminate fallback
        }
      }
    } finally {
      await sink.flush();
      await sink.close();
    }

    yield 1.0;
  }

  /// Invokes the native Android Package Installer for the specified APK [filePath].
  Future<bool> installApk(String filePath) async {
    if (kIsWeb || !Platform.isAndroid) {
      debugPrint(
          'GitHubUpdateService: installApk is only supported on Android devices.');
      return false;
    }

    try {
      final result = await _installerChannel.invokeMethod<bool>(
        'installApk',
        {'filePath': filePath},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('GitHubUpdateService installApk PlatformException: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('GitHubUpdateService installApk error: $e');
      return false;
    }
  }
}

