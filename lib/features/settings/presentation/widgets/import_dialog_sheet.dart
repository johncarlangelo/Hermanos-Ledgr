import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/features/backup/domain/backup_validation_result.dart';
import 'package:hermanos_ledgr/features/backup/providers/backup_provider.dart';
import 'package:hermanos_ledgr/features/settings/presentation/widgets/stash_switch.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Custom bottom sheet for restoring ledger data from JSON backups (Task 11.5).
/// Adheres strictly to Hermanos-Stash styling with zero native Android dialogs.
class ImportDialogSheet extends ConsumerStatefulWidget {
  const ImportDialogSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const ImportDialogSheet(),
    );
  }

  @override
  ConsumerState<ImportDialogSheet> createState() => _ImportDialogSheetState();
}

class _ImportDialogSheetState extends ConsumerState<ImportDialogSheet> {
  final TextEditingController _jsonController = TextEditingController();
  bool _replaceExisting = true;
  BackupValidationResult? _validationResult;
  bool _isRestoring = false;

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  void _onJsonChanged(String raw) {
    final text = raw.trim();
    if (text.isEmpty) {
      setState(() => _validationResult = null);
      return;
    }

    final notifier = ref.read(backupProvider.notifier);
    final result = notifier.validateBackupJson(text);
    setState(() => _validationResult = result);
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      _jsonController.text = data.text!.trim();
      _onJsonChanged(_jsonController.text);
    } else {
      if (mounted) {
        UndoSnackbar.error(context, message: 'Clipboard is empty');
      }
    }
  }

  Future<void> _pickBackupFile() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (file == null) return;

      final content = await file.xFile.readAsString();

      if (content.trim().isNotEmpty) {
        _jsonController.text = content.trim();
        _onJsonChanged(_jsonController.text);
      }
    } catch (e) {
      if (mounted) {
        UndoSnackbar.error(context, message: 'Failed to read file: $e');
      }
    }
  }

  Future<void> _importData() async {
    if (_validationResult == null || !_validationResult!.isValid) return;

    setState(() => _isRestoring = true);
    final notifier = ref.read(backupProvider.notifier);

    try {
      final counts = await notifier.restoreFromJson(
        _jsonController.text,
        replaceExisting: _replaceExisting,
      );

      if (mounted) {
        Navigator.pop(context);
        UndoSnackbar.success(
          context,
          message:
              'Restored ${counts['transactions'] ?? 0} transactions and ${counts['accounts'] ?? 0} accounts',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRestoring = false);
        UndoSnackbar.error(context, message: 'Restore error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final v = _validationResult;
    final isValid = v != null && v.isValid;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.xs,
            Spacing.lg,
            Spacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(Spacing.sm),
                    decoration: BoxDecoration(
                      color: (isDark ? StashColors.tealAccent : theme.colorScheme.primary)
                          .withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.restore_page_rounded,
                      color: isDark ? StashColors.tealAccent : theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Restore Ledger Backup',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Select a JSON file or paste backup contents',
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

              // Quick Actions Bar: Pick File & Paste Clipboard
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickBackupFile,
                      icon: const Icon(Icons.file_open_rounded, size: 16),
                      label: const Text('Pick JSON File'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? StashColors.tealAccent : theme.colorScheme.primary,
                        side: BorderSide(
                          color: (isDark ? StashColors.tealAccent : theme.colorScheme.primary)
                              .withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pasteFromClipboard,
                      icon: const Icon(Icons.content_paste_rounded, size: 16),
                      label: const Text('Paste Clipboard'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurface,
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),

              // Text Field for JSON
              TextField(
                controller: _jsonController,
                maxLines: 5,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 11.5,
                ),
                decoration: InputDecoration(
                  hintText: 'Paste backup JSON payload here or pick a file above...',
                  hintStyle: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    fontSize: 11.5,
                  ),
                  filled: true,
                  fillColor: isDark ? StashColors.raised : theme.colorScheme.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? StashColors.line.withValues(alpha: 0.8)
                          : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                onChanged: _onJsonChanged,
              ),
              const SizedBox(height: Spacing.sm),

              // Validation & Statistics Badge
              if (v != null) ...[
                if (v.isValid) ...[
                  Container(
                    padding: const EdgeInsets.all(Spacing.md),
                    decoration: BoxDecoration(
                      color: StashColors.tealAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: StashColors.tealAccent.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: StashColors.tealAccent,
                              size: 16,
                            ),
                            const SizedBox(width: Spacing.xs),
                            Text(
                              'Valid Ledger Backup (${v.totalRecords} total records)',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: StashColors.tealAccent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.xs),
                        Wrap(
                          spacing: Spacing.xs,
                          runSpacing: 4,
                          children: [
                            _miniChip(theme, '${v.detectedTransactions} txs'),
                            _miniChip(theme, '${v.detectedAccounts} accounts'),
                            if (v.detectedBudgets > 0)
                              _miniChip(theme, '${v.detectedBudgets} budgets'),
                            if (v.detectedGoals > 0)
                              _miniChip(theme, '${v.detectedGoals} goals'),
                            if (v.detectedDebts > 0)
                              _miniChip(theme, '${v.detectedDebts} debts'),
                            if (v.detectedRecurring > 0)
                              _miniChip(theme, '${v.detectedRecurring} recurring'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(Spacing.md),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.error.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: theme.colorScheme.error,
                          size: 16,
                        ),
                        const SizedBox(width: Spacing.xs),
                        Expanded(
                          child: Text(
                            v.errorMessage ?? 'Invalid backup payload.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: Spacing.md),
              ],

              // Mode: Replace vs Merge Toggle
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isDark ? StashColors.raised : theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? StashColors.line.withValues(alpha: 0.8)
                        : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Replace Existing Records',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _replaceExisting
                                ? 'Clears tables and restores clean snapshot'
                                : 'Merges without deleting current entries',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StashSwitch(
                      value: _replaceExisting,
                      onChanged: (val) => setState(() => _replaceExisting = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.lg),

              // Restore Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isValid && !_isRestoring ? _importData : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: StashColors.tealAccent,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isRestoring
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Text(
                          'Restore Ledger',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniChip(ThemeData theme, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: StashColors.tealAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: StashColors.tealAccent,
        ),
      ),
    );
  }
}
