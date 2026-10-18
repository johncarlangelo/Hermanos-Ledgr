import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/features/backup/domain/backup_entry.dart';
import 'package:hermanos_ledgr/features/backup/presentation/widgets/restore_confirm_sheet.dart';
import 'package:hermanos_ledgr/features/backup/providers/backup_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/empty_state_view.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Bottom sheet displaying local backup snapshots with 1-tap restore and pruning (Tasks 11.6, 11.7).
class BackupHistorySheet extends ConsumerWidget {
  const BackupHistorySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BackupHistorySheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final backupState = ref.watch(backupProvider);
    final notifier = ref.read(backupProvider.notifier);
    final backups = backupState.localBackups;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.only(top: Spacing.md),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: Spacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(Spacing.sm),
                        decoration: BoxDecoration(
                          color: StashColors.tealAccent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.history_rounded,
                          color: StashColors.tealAccent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        'Local Backups',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: backupState.isLoading
                        ? null
                        : () async {
                            final file = await notifier.createManualBackup(openShareSheet: false);
                            if (file != null && context.mounted) {
                              UndoSnackbar.success(
                                context,
                                message: 'New backup created successfully',
                              );
                            }
                          },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Backup Now'),
                    style: TextButton.styleFrom(
                      foregroundColor: StashColors.tealAccent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.xs),

            // Subtitle info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
              child: Text(
                'Stored locally in app storage. Daily backups retain the last 7 snapshots to avoid bloat.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: Spacing.md),
            const Divider(height: 1),

            // Backup List
            Expanded(
              child: backups.isEmpty
                  ? const Center(
                      child: EmptyStateView(
                        icon: Icons.cloud_off_rounded,
                        title: 'No Local Backups Yet',
                        subtitle:
                            'Create a manual backup or enable daily auto-backup to secure your ledger data.',
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(Spacing.lg),
                      itemCount: backups.length,
                      separatorBuilder: (_, _) => const SizedBox(height: Spacing.sm),
                      itemBuilder: (context, index) {
                        final entry = backups[index];
                        return _buildBackupCard(context, entry, notifier, theme);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupCard(
    BuildContext context,
    BackupEntry entry,
    BackupNotifier notifier,
    ThemeData theme,
  ) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return M3Card(
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
        children: [
          // Icon badge
          Container(
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: (entry.isAutoBackup ? StashColors.tealAccent : const Color(0xFFF59E0B))
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              entry.isAutoBackup ? Icons.auto_mode_rounded : Icons.save_rounded,
              color: entry.isAutoBackup ? StashColors.tealAccent : const Color(0xFFF59E0B),
              size: 20,
            ),
          ),
          const SizedBox(width: Spacing.md),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.isAutoBackup ? 'Auto-Backup (Daily)' : 'Manual Snapshot',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: Spacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        entry.formattedSize,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  dateFormat.format(entry.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 18),
            tooltip: 'Share File',
            onPressed: () {
              // ignore: deprecated_member_use
              Share.shareXFiles(
                [XFile(entry.filePath)],
                text: 'Hermanos Ledgr Backup (${entry.fileName})',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.restore_rounded, size: 18),
            tooltip: 'Restore',
            color: StashColors.tealAccent,
            onPressed: () async {
              final content = await File(entry.filePath).readAsString();
              final validation = notifier.validateBackupJson(content);
              if (context.mounted) {
                RestoreConfirmSheet.show(
                  context,
                  validation: validation,
                  rawJson: content,
                  sourceDescription: entry.fileName,
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            tooltip: 'Delete',
            color: theme.colorScheme.error,
            onPressed: () async {
              await notifier.deleteBackup(entry.filePath);
              if (context.mounted) {
                UndoSnackbar.info(
                  context,
                  message: 'Deleted "${entry.fileName}"',
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
