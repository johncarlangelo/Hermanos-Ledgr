import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/features/ai_assistant/data/model_manager.dart';
import 'package:hermanos_ledgr/features/ai_assistant/providers/ai_assistant_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Custom Material 3 bottom sheet for managing, downloading, switching, and deleting LLM models (Tasks 9.14, 12.6).
/// Conforms to Zero Stock Android Native UI rules (28dp top radius, tailored progress indicator).
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
  String? _downloadingModelId;
  String _activeModelId = ModelManager.defaultSpec.id;
  final Map<String, bool> _modelReadyMap = {};
  final Map<String, int> _modelSizeMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshModelStatuses();
  }

  Future<void> _refreshModelStatuses() async {
    final manager = ref.read(modelManagerProvider);
    final activeId = await manager.getActiveModelId();

    for (final spec in ModelManager.availableModels) {
      final isReady = await manager.isModelDownloaded(spec.id);
      final size = await manager.getDownloadedSizeBytes(spec.id);
      _modelReadyMap[spec.id] = isReady;
      _modelSizeMap[spec.id] = size;
    }

    if (mounted) {
      setState(() {
        _activeModelId = activeId;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _downloadSub?.cancel();
    super.dispose();
  }

  void _startDownload(ModelSpec spec) {
    final manager = ref.read(modelManagerProvider);
    HapticFeedback.mediumImpact();

    setState(() {
      _downloadingModelId = spec.id;
      _currentProgress = DownloadProgress(
        progress: 0.0,
        downloadedBytes: 0,
        totalBytes: spec.expectedSizeBytes,
        status: 'Starting download...',
        modelId: spec.id,
      );
    });

    _downloadSub?.cancel();
    _downloadSub = manager.downloadModel(spec.id).listen(
      (progress) {
        if (!mounted) return;
        setState(() {
          _currentProgress = progress;
          if (progress.isCompleted) {
            _downloadingModelId = null;
            _refreshModelStatuses();
            UndoSnackbar.success(context, message: '${spec.displayName} is ready and active!');
          }
          if (progress.error != null) {
            _downloadingModelId = null;
            UndoSnackbar.error(context, message: progress.error!);
          }
        });
      },
      onError: (err) {
        if (!mounted) return;
        setState(() => _downloadingModelId = null);
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
        _downloadingModelId = null;
        _currentProgress = null;
      });
    }
  }

  Future<void> _switchActiveModel(ModelSpec spec) async {
    HapticFeedback.selectionClick();
    final manager = ref.read(modelManagerProvider);
    final llm = ref.read(llmServiceProvider);

    // Unload existing in-memory weights
    await llm.unloadModel();
    await manager.setActiveModelId(spec.id);

    if (mounted) {
      setState(() => _activeModelId = spec.id);
      UndoSnackbar.info(context, message: 'Active brain switched to ${spec.displayName}');
    }
  }

  Future<void> _deleteModel(ModelSpec spec) async {
    final manager = ref.read(modelManagerProvider);
    final llm = ref.read(llmServiceProvider);

    if (_activeModelId == spec.id) {
      await llm.unloadModel();
    }

    final success = await manager.deleteModel(spec.id);
    if (mounted) {
      if (success) {
        await _refreshModelStatuses();
        if (!mounted) return;
        UndoSnackbar.info(context, message: '${spec.displayName} deleted. Storage reclaimed.');
      } else {
        UndoSnackbar.error(context, message: 'Could not delete model');
      }
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
      final activeSpec = await manager.getActiveModelSpec();
      final success = await manager.importLocalModel(file.path!, targetModelId: activeSpec.id);

      if (mounted) {
        if (success) {
          await _refreshModelStatuses();
          if (!mounted) return;
          UndoSnackbar.success(context, message: 'Imported custom GGUF model successfully!');
        } else {
          UndoSnackbar.error(context, message: 'Failed to import model file');
        }
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
                          'LLM Model Management',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Select, download, or switch on-device GGUF brains',
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

              // Privacy Banner
              Container(
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: BoxDecoration(
                  color: isDark
                      ? StashColors.base.withValues(alpha: 0.6)
                      : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, size: 16, color: StashColors.tealAccent),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Text(
                        '100% offline FFI execution. Models run locally inside background isolates with zero data transmitted over the internet.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.lg),

              // Available Models Section
              Text(
                'AVAILABLE ON-DEVICE BRAINS',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.sm),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(Spacing.xl),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                ...ModelManager.availableModels.map((spec) => _buildModelCard(
                      context: context,
                      theme: theme,
                      isDark: isDark,
                      spec: spec,
                    )),

              const SizedBox(height: Spacing.md),

              // Import Local GGUF Card
              InkWell(
                onTap: _importLocalFile,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.file_open_outlined, size: 20),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Import Local .GGUF File',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Sideload an existing model from Downloads or SD card',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModelCard({
    required BuildContext context,
    required ThemeData theme,
    required bool isDark,
    required ModelSpec spec,
  }) {
    final isActive = _activeModelId == spec.id;
    final isReady = _modelReadyMap[spec.id] ?? false;
    final downloadedSize = _modelSizeMap[spec.id] ?? 0;
    final isDownloadingThis = _downloadingModelId == spec.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? StashColors.base : theme.colorScheme.surface)
              : theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? StashColors.tealAccent
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: isActive ? 1.5 : 1.0,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: StashColors.tealAccent.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Name & Badges
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: Spacing.xs,
                        runSpacing: 4,
                        children: [
                          Text(
                            spec.displayName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (spec.isRecommended)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: StashColors.tealAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Recommended',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: StashColors.tealAccent,
                                ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              spec.quantization,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        spec.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11.5,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: StashColors.tealAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F1E1B),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Spacing.md),

            // Size / Status Row
            Row(
              children: [
                Icon(
                  isReady ? Icons.check_circle_rounded : Icons.cloud_download_outlined,
                  size: 16,
                  color: isReady ? StashColors.tealAccent : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  isReady
                      ? 'Ready (${(downloadedSize / (1024 * 1024)).toStringAsFixed(0)} MB)'
                      : 'Size: ${spec.formattedExpectedSize}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11.5,
                    fontWeight: isReady ? FontWeight.w600 : FontWeight.normal,
                    color: isReady ? StashColors.tealAccent : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            // Progress Bar if Downloading
            if (isDownloadingThis && _currentProgress != null) ...[
              const SizedBox(height: Spacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _currentProgress!.progress,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: const AlwaysStoppedAnimation(StashColors.tealAccent),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _currentProgress!.status,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                  Text(
                    '${(_currentProgress!.downloadedBytes / (1024 * 1024)).toStringAsFixed(1)} / ${(_currentProgress!.totalBytes / (1024 * 1024)).toStringAsFixed(0)} MB',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: Spacing.sm),

            // Actions Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isDownloadingThis)
                  TextButton.icon(
                    onPressed: _cancelDownload,
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Cancel'),
                    style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                  )
                else if (isReady) ...[
                  if (!isActive)
                    FilledButton.tonal(
                      onPressed: () => _switchActiveModel(spec),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text('Set as Active Brain'),
                    ),
                  const SizedBox(width: Spacing.xs),
                  IconButton(
                    onPressed: () => _showDeleteConfirmation(spec),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                    tooltip: 'Delete to free space',
                    visualDensity: VisualDensity.compact,
                  ),
                ] else
                  FilledButton.icon(
                    onPressed: () => _startDownload(spec),
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: Text('Download (${spec.formattedExpectedSize})'),
                    style: FilledButton.styleFrom(
                      backgroundColor: StashColors.tealAccent,
                      foregroundColor: const Color(0xFF0F1E1B),
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(ModelSpec spec) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? StashColors.raised : theme.colorScheme.surfaceContainerHigh,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(Spacing.lg),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 36),
                const SizedBox(height: Spacing.sm),
                Text(
                  'Delete "${spec.displayName}"?',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  'This will reclaim ~${spec.formattedExpectedSize} of device storage. You can re-download anytime.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: Spacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _deleteModel(spec);
                        },
                        style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                        child: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
