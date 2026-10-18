import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/features/ai_assistant/data/model_manager.dart';
import 'package:hermanos_ledgr/features/ai_assistant/providers/ai_assistant_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Custom Material 3 bottom sheet for downloading or importing the Tier 2 Sub-1B LLM model (Task 9.14).
/// Complies with Zero Stock Android Native UI rules (28dp top radius, tailored progress indicator).
class ModelDownloadSheet extends ConsumerStatefulWidget {
  const ModelDownloadSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ModelDownloadSheet(),
    );
  }

  @override
  ConsumerState<ModelDownloadSheet> createState() => _ModelDownloadSheetState();
}

class _ModelDownloadSheetState extends ConsumerState<ModelDownloadSheet> {
  StreamSubscription<DownloadProgress>? _downloadSub;
  DownloadProgress? _currentProgress;
  bool _isDownloading = false;
  bool _isChecking = true;
  bool _isModelReady = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final manager = ref.read(modelManagerProvider);
    final ready = await manager.isModelDownloaded();
    if (mounted) {
      setState(() {
        _isModelReady = ready;
        _isChecking = false;
      });
    }
  }

  @override
  void dispose() {
    _downloadSub?.cancel();
    super.dispose();
  }

  void _startDownload() {
    final manager = ref.read(modelManagerProvider);
    HapticFeedback.mediumImpact();

    setState(() {
      _isDownloading = true;
      _currentProgress = const DownloadProgress(
        progress: 0.0,
        downloadedBytes: 0,
        totalBytes: ModelManager.expectedSizeBytes,
        status: 'Starting download...',
      );
    });

    _downloadSub = manager.downloadModel().listen(
      (progress) {
        if (!mounted) return;
        setState(() {
          _currentProgress = progress;
          if (progress.isCompleted) {
            _isDownloading = false;
            _isModelReady = true;
          }
          if (progress.error != null) {
            _isDownloading = false;
          }
        });
      },
      onError: (err) {
        if (!mounted) return;
        setState(() {
          _isDownloading = false;
        });
        UndoSnackbar.error(context, message: 'Download error: $err');
      },
    );
  }

  Future<void> _cancelDownload() async {
    final manager = ref.read(modelManagerProvider);
    await manager.cancelDownload();
    _downloadSub?.cancel();
    if (mounted) {
      setState(() {
        _isDownloading = false;
        _currentProgress = null;
      });
    }
  }

  Future<void> _importLocalFile() async {
    HapticFeedback.selectionClick();
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['gguf'],
    );

    if (file != null && file.path != null) {
      final manager = ref.read(modelManagerProvider);
      final success = await manager.importLocalModel(file.path!);
      if (mounted) {
        if (success) {
          setState(() => _isModelReady = true);
          UndoSnackbar.info(context, message: 'Successfully imported Qwen model!');
        } else {
          UndoSnackbar.error(context, message: 'Failed to import model file');
        }
      }
    }
  }

  Future<void> _deleteModel() async {
    final manager = ref.read(modelManagerProvider);
    final success = await manager.deleteModel();
    if (mounted) {
      if (success) {
        setState(() => _isModelReady = false);
        UndoSnackbar.info(context, message: 'Model deleted. Storage reclaimed.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? StashColors.raised : theme.colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.md),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.md),

              // Title Row
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: StashColors.tealAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      color: StashColors.tealAccent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hermano Brain (Tier 2 LLM)',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Qwen 2.5 0.5B Instruct · 380 MB GGUF',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),

              // Status / Info Card
              M3Card(
                padding: const EdgeInsets.all(Spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isModelReady
                              ? Icons.check_circle_rounded
                              : Icons.info_outline_rounded,
                          size: 18,
                          color: _isModelReady ? StashColors.tealAccent : const Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: Spacing.xs),
                        Text(
                          _isChecking
                              ? 'Checking local storage...'
                              : _isModelReady
                                  ? 'Active & Ready on Device'
                                  : 'Not Downloaded Yet',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _isModelReady ? StashColors.tealAccent : const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      _isModelReady
                          ? 'The Qwen 2.5 0.5B model is active. Complex multi-item splits, conversational advice, and spending summaries run on your phone with Qualcomm/Adreno GPU acceleration.'
                          : 'Download the model once over Wi-Fi (~380 MB). It runs 100% offline on your device via llama.cpp. No data ever leaves your phone.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.md),

              // Progress Bar if Downloading
              if (_isDownloading && _currentProgress != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _currentProgress!.progress,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: const AlwaysStoppedAnimation(StashColors.tealAccent),
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _currentProgress!.status,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${(_currentProgress!.downloadedBytes / (1024 * 1024)).toStringAsFixed(1)} MB / ~380 MB',
                      style: moneyStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                OutlinedButton.icon(
                  onPressed: _cancelDownload,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Cancel Download'),
                ),
              ] else if (!_isModelReady) ...[
                // Download CTA Button
                FilledButton.icon(
                  onPressed: _startDownload,
                  style: FilledButton.styleFrom(
                    backgroundColor: StashColors.tealAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text(
                    'Download Model (~380 MB)',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: Spacing.sm),

                // Sideload Import from local device storage
                OutlinedButton.icon(
                  onPressed: _importLocalFile,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.folder_open_rounded, size: 18),
                  label: const Text('Import .GGUF from Device Storage'),
                ),
              ] else ...[
                // Already downloaded: Option to delete / reclaim space
                OutlinedButton.icon(
                  onPressed: _deleteModel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SemanticColors.expense(isDark),
                    side: BorderSide(color: SemanticColors.expense(isDark).withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Delete Model & Reclaim ~380 MB'),
                ),
              ],
              const SizedBox(height: Spacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
