import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DownloadProgress {
  final double progress; // 0.0 to 1.0
  final int downloadedBytes;
  final int totalBytes;
  final String status;
  final bool isCompleted;
  final String? error;

  const DownloadProgress({
    required this.progress,
    required this.downloadedBytes,
    required this.totalBytes,
    required this.status,
    this.isCompleted = false,
    this.error,
  });
}

/// Manages local storage, download, and verification of Tier 2 Sub-1B GGUF models (Task 9.4).
class ModelManager {
  static const String modelFileName = 'qwen2.5-0.5b-instruct-q4_k_m.gguf';
  static const String modelDisplayName = 'Qwen 2.5 0.5B Instruct';
  static const String modelDownloadUrl =
      'https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q4_k_m.gguf';
  static const int expectedSizeBytes = 397825024; // ~380 MB

  HttpClient? _activeClient;
  bool _isCancelled = false;

  /// Returns the target absolute file path for the model inside app storage.
  Future<String> getModelPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory(p.join(appDir.path, 'models'));
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    return p.join(modelsDir.path, modelFileName);
  }

  /// Checks if the model file is already present and valid on disk.
  Future<bool> isModelDownloaded() async {
    try {
      final path = await getModelPath();
      final file = File(path);
      if (await file.exists()) {
        final length = await file.length();
        // File must be at least 50MB to be considered a valid GGUF model
        return length > 50 * 1024 * 1024;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Returns current file size in bytes if file exists.
  Future<int> getDownloadedSizeBytes() async {
    try {
      final path = await getModelPath();
      final file = File(path);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  /// Streams download progress while streaming the GGUF model over HTTP.
  Stream<DownloadProgress> downloadModel() async* {
    _isCancelled = false;
    final path = await getModelPath();
    final targetFile = File(path);
    final tempFile = File('$path.download');

    yield const DownloadProgress(
      progress: 0.0,
      downloadedBytes: 0,
      totalBytes: expectedSizeBytes,
      status: 'Connecting to Hugging Face...',
    );

    try {
      _activeClient = HttpClient();
      final uri = Uri.parse(modelDownloadUrl);
      final request = await _activeClient!.getUrl(uri);
      request.followRedirects = true;

      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        yield DownloadProgress(
          progress: 0.0,
          downloadedBytes: 0,
          totalBytes: expectedSizeBytes,
          status: 'Download failed',
          error: 'Server returned HTTP ${response.statusCode}',
        );
        return;
      }

      final contentLength = response.contentLength > 0 ? response.contentLength : expectedSizeBytes;
      int receivedBytes = 0;

      final sink = tempFile.openWrite();

      await for (final chunk in response) {
        if (_isCancelled) {
          await sink.flush();
          await sink.close();
          if (await tempFile.exists()) await tempFile.delete();
          yield const DownloadProgress(
            progress: 0.0,
            downloadedBytes: 0,
            totalBytes: expectedSizeBytes,
            status: 'Cancelled',
            error: 'Download was cancelled',
          );
          return;
        }

        sink.add(chunk);
        receivedBytes += chunk.length;
        final progress = (receivedBytes / contentLength).clamp(0.0, 1.0);

        yield DownloadProgress(
          progress: progress,
          downloadedBytes: receivedBytes,
          totalBytes: contentLength,
          status: 'Downloading Qwen 2.5 0.5B (${(progress * 100).toStringAsFixed(1)}%)...',
        );
      }

      await sink.flush();
      await sink.close();

      // Rename temp file to target model file
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await tempFile.rename(targetFile.path);

      yield DownloadProgress(
        progress: 1.0,
        downloadedBytes: receivedBytes,
        totalBytes: contentLength,
        status: 'Ready! Hermano brain is loaded.',
        isCompleted: true,
      );
    } catch (e) {
      if (await tempFile.exists()) await tempFile.delete();
      yield DownloadProgress(
        progress: 0.0,
        downloadedBytes: 0,
        totalBytes: expectedSizeBytes,
        status: 'Error',
        error: e.toString(),
      );
    } finally {
      _activeClient?.close();
      _activeClient = null;
    }
  }

  /// Cancels an in-progress download.
  Future<void> cancelDownload() async {
    _isCancelled = true;
    _activeClient?.close(force: true);
    _activeClient = null;
  }

  /// Imports a local .gguf file copied to device or picked by user.
  Future<bool> importLocalModel(String sourcePath) async {
    try {
      final source = File(sourcePath);
      if (!await source.exists()) return false;

      final targetPath = await getModelPath();
      final target = File(targetPath);
      if (await target.exists()) {
        await target.delete();
      }

      await source.copy(targetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Deletes the downloaded model file to reclaim storage space.
  Future<bool> deleteModel() async {
    try {
      final path = await getModelPath();
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
