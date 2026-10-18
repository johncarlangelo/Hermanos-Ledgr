import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadProgress {
  final double progress; // 0.0 to 1.0
  final int downloadedBytes;
  final int totalBytes;
  final String status;
  final bool isCompleted;
  final String? error;
  final String? modelId;

  const DownloadProgress({
    required this.progress,
    required this.downloadedBytes,
    required this.totalBytes,
    required this.status,
    this.isCompleted = false,
    this.error,
    this.modelId,
  });
}

/// Metadata specification for supported GGUF LLM models (Task 12.6).
class ModelSpec {
  final String id;
  final String displayName;
  final String fileName;
  final String downloadUrl;
  final int expectedSizeBytes;
  final String description;
  final String quantization;
  final String parameterSize;
  final bool isRecommended;

  const ModelSpec({
    required this.id,
    required this.displayName,
    required this.fileName,
    required this.downloadUrl,
    required this.expectedSizeBytes,
    required this.description,
    required this.quantization,
    required this.parameterSize,
    this.isRecommended = false,
  });

  String get formattedExpectedSize {
    final mb = expectedSizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(0)} MB';
  }
}

/// Manages local storage, download, model switching, and verification of Tier 2 GGUF models (Tasks 9.4, 12.6).
class ModelManager {
  static const String _activeModelPrefKey = 'hermanos_active_llm_model_id';

  static const ModelSpec defaultSpec = ModelSpec(
    id: 'qwen_0_5b',
    displayName: 'Qwen 2.5 0.5B Instruct',
    fileName: 'qwen2.5-0.5b-instruct-q4_k_m.gguf',
    downloadUrl:
        'https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q4_k_m.gguf',
    expectedSizeBytes: 397825024, // ~380 MB
    description: 'Recommended default. Fastest on-chip latency (<150ms), minimal RAM (<400 MB).',
    quantization: 'Q4_K_M',
    parameterSize: '0.5B',
    isRecommended: true,
  );

  static const List<ModelSpec> availableModels = [
    defaultSpec,
    ModelSpec(
      id: 'smollm2_360m',
      displayName: 'SmolLM2 360M Instruct',
      fileName: 'smollm2-360m-instruct-q4_k_m.gguf',
      downloadUrl:
          'https://huggingface.co/HuggingFaceTB/SmolLM2-360M-Instruct-GGUF/resolve/main/smollm2-360m-instruct-q4_k_m.gguf',
      expectedSizeBytes: 229000000, // ~218 MB
      description: 'Ultra-lightweight featherweight model. Instant start-up, minimal battery drain.',
      quantization: 'Q4_K_M',
      parameterSize: '360M',
      isRecommended: false,
    ),
    ModelSpec(
      id: 'qwen_1_5b',
      displayName: 'Qwen 2.5 1.5B Instruct',
      fileName: 'qwen2.5-1.5b-instruct-q4_k_m.gguf',
      downloadUrl:
          'https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf',
      expectedSizeBytes: 986000000, // ~940 MB
      description: 'Deeper financial reasoning and multi-turn conversational summaries. Requires 8GB+ RAM.',
      quantization: 'Q4_K_M',
      parameterSize: '1.5B',
      isRecommended: false,
    ),
  ];

  // Backward-compatible static accessors
  static String get modelFileName => defaultSpec.fileName;
  static String get modelDisplayName => defaultSpec.displayName;
  static String get modelDownloadUrl => defaultSpec.downloadUrl;
  static int get expectedSizeBytes => defaultSpec.expectedSizeBytes;

  HttpClient? _activeClient;
  bool _isCancelled = false;
  String? _cachedActiveId;

  /// Gets the currently active model ID.
  Future<String> getActiveModelId() async {
    if (_cachedActiveId != null) return _cachedActiveId!;
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedActiveId = prefs.getString(_activeModelPrefKey) ?? defaultSpec.id;
    } catch (_) {
      _cachedActiveId = defaultSpec.id;
    }
    return _cachedActiveId!;
  }

  /// Sets the active model ID (Task 12.6: switch model).
  Future<void> setActiveModelId(String modelId) async {
    _cachedActiveId = modelId;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeModelPrefKey, modelId);
    } catch (_) {}
  }

  /// Gets the specification for the currently active model.
  Future<ModelSpec> getActiveModelSpec() async {
    final activeId = await getActiveModelId();
    return availableModels.firstWhere(
      (m) => m.id == activeId,
      orElse: () => defaultSpec,
    );
  }

  /// Resolves the dedicated local directory for storing AI models.
  Future<Directory> getModelsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory(p.join(appDir.path, 'models'));
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    return modelsDir;
  }

  /// Returns the target absolute file path for a model (or active model if [modelId] is omitted).
  Future<String> getModelPath([String? modelId]) async {
    final dir = await getModelsDirectory();
    final targetId = modelId ?? await getActiveModelId();
    final spec = availableModels.firstWhere(
      (m) => m.id == targetId,
      orElse: () => defaultSpec,
    );
    return p.join(dir.path, spec.fileName);
  }

  /// Checks if a model file is already present and valid on disk (>50MB).
  Future<bool> isModelDownloaded([String? modelId]) async {
    try {
      final path = await getModelPath(modelId);
      final file = File(path);
      if (await file.exists()) {
        final length = await file.length();
        return length > 50 * 1024 * 1024;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Returns current file size in bytes if file exists.
  Future<int> getDownloadedSizeBytes([String? modelId]) async {
    try {
      final path = await getModelPath(modelId);
      final file = File(path);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  /// Calculates total bytes occupied by all downloaded GGUF models.
  Future<int> getTotalModelsStorageBytes() async {
    try {
      final dir = await getModelsDirectory();
      final entities = await dir.list().toList();
      int total = 0;
      for (final entity in entities) {
        if (entity is File && entity.path.endsWith('.gguf')) {
          total += await entity.length();
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  /// Streams download progress while fetching a model over HTTP (Task 12.6).
  Stream<DownloadProgress> downloadModel([String? modelId]) async* {
    _isCancelled = false;
    final targetId = modelId ?? await getActiveModelId();
    final spec = availableModels.firstWhere(
      (m) => m.id == targetId,
      orElse: () => defaultSpec,
    );

    final path = await getModelPath(targetId);
    final targetFile = File(path);
    final tempFile = File('$path.download');

    yield DownloadProgress(
      progress: 0.0,
      downloadedBytes: 0,
      totalBytes: spec.expectedSizeBytes,
      status: 'Connecting to Hugging Face...',
      modelId: targetId,
    );

    try {
      _activeClient = HttpClient();
      final uri = Uri.parse(spec.downloadUrl);
      final request = await _activeClient!.getUrl(uri);
      request.followRedirects = true;

      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        yield DownloadProgress(
          progress: 0.0,
          downloadedBytes: 0,
          totalBytes: spec.expectedSizeBytes,
          status: 'Download failed',
          error: 'Server returned HTTP ${response.statusCode}',
          modelId: targetId,
        );
        return;
      }

      final contentLength =
          response.contentLength > 0 ? response.contentLength : spec.expectedSizeBytes;
      int receivedBytes = 0;

      final sink = tempFile.openWrite();

      await for (final chunk in response) {
        if (_isCancelled) {
          await sink.flush();
          await sink.close();
          if (await tempFile.exists()) await tempFile.delete();
          yield DownloadProgress(
            progress: 0.0,
            downloadedBytes: 0,
            totalBytes: contentLength,
            status: 'Cancelled',
            error: 'Download was cancelled',
            modelId: targetId,
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
          status: 'Downloading ${spec.displayName} (${(progress * 100).toStringAsFixed(1)}%)...',
          modelId: targetId,
        );
      }

      await sink.flush();
      await sink.close();

      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await tempFile.rename(targetFile.path);

      // Make this newly downloaded model the active model
      await setActiveModelId(targetId);

      yield DownloadProgress(
        progress: 1.0,
        downloadedBytes: receivedBytes,
        totalBytes: contentLength,
        status: 'Ready! ${spec.displayName} is loaded.',
        isCompleted: true,
        modelId: targetId,
      );
    } catch (e) {
      if (await tempFile.exists()) await tempFile.delete();
      yield DownloadProgress(
        progress: 0.0,
        downloadedBytes: 0,
        totalBytes: spec.expectedSizeBytes,
        status: 'Error',
        error: e.toString(),
        modelId: targetId,
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

  /// Imports a local .gguf file from device storage (Task 12.6).
  Future<bool> importLocalModel(String sourcePath, {String? targetModelId}) async {
    try {
      final source = File(sourcePath);
      if (!await source.exists()) return false;

      final targetPath = await getModelPath(targetModelId);
      final target = File(targetPath);
      if (await target.exists()) {
        await target.delete();
      }

      await source.copy(targetPath);
      if (targetModelId != null) {
        await setActiveModelId(targetModelId);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Deletes a model file to reclaim storage space (Task 12.6).
  Future<bool> deleteModel([String? modelId]) async {
    try {
      final path = await getModelPath(modelId);
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
