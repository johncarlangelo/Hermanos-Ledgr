import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/features/backup/domain/backup_validation_result.dart';
import 'package:hermanos_ledgr/features/backup/providers/backup_provider.dart';
import 'package:hermanos_ledgr/features/settings/presentation/widgets/stash_switch.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Confirmation bottom sheet before restoring a ledger backup (Task 11.5).
class RestoreConfirmSheet extends ConsumerStatefulWidget {
  final BackupValidationResult validation;
  final String rawJson;
  final String sourceDescription;

  const RestoreConfirmSheet({
    super.key,
    required this.validation,
    required this.rawJson,
    required this.sourceDescription,
  });

  static Future<void> show(
    BuildContext context, {
    required BackupValidationResult validation,
    required String rawJson,
    required String sourceDescription,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RestoreConfirmSheet(
        validation: validation,
        rawJson: rawJson,
        sourceDescription: sourceDescription,
      ),
    );
  }

  @override
  ConsumerState<RestoreConfirmSheet> createState() => _RestoreConfirmSheetState();
}

class _RestoreConfirmSheetState extends ConsumerState<RestoreConfirmSheet> {
  bool _replaceExisting = true;
  bool _isRestoring = false;

  Future<void> _performRestore() async {
    setState(() => _isRestoring = true);
    final notifier = ref.read(backupProvider.notifier);

    try {
      final counts = await notifier.restoreFromJson(
        widget.rawJson,
        replaceExisting: _replaceExisting,
      );

      if (mounted) {
        Navigator.pop(context); // Close sheet
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
    final v = widget.validation;
    final manifest = v.manifest;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: Spacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + Spacing.lg,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xl, vertical: Spacing.sm),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(Spacing.sm),
                    decoration: BoxDecoration(
                      color: StashColors.tealAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.restore_page_rounded,
                      color: StashColors.tealAccent,
                      size: 22,
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
                          widget.sourceDescription,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // Manifest / Date Info Card
              if (manifest != null) ...[
                Container(
                  padding: const EdgeInsets.all(Spacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Snapshot Date',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            DateFormat('MMM d, yyyy • h:mm a').format(manifest.exportDate),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: StashColors.tealAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          manifest.appVersion,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: StashColors.tealAccent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.md),
              ],

              // Detected Records Overview
              Text(
                'Detected Records (${v.totalRecords})',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Wrap(
                spacing: Spacing.xs,
                runSpacing: Spacing.xs,
                children: [
                  _statChip(theme, Icons.receipt_long_rounded, '${v.detectedTransactions} Transactions'),
                  _statChip(theme, Icons.account_balance_wallet_rounded, '${v.detectedAccounts} Accounts'),
                  if (v.detectedBudgets > 0)
                    _statChip(theme, Icons.pie_chart_rounded, '${v.detectedBudgets} Budgets'),
                  if (v.detectedGoals > 0)
                    _statChip(theme, Icons.savings_rounded, '${v.detectedGoals} Goals'),
                  if (v.detectedDebts > 0)
                    _statChip(theme, Icons.handshake_rounded, '${v.detectedDebts} Debts'),
                  if (v.detectedRecurring > 0)
                    _statChip(theme, Icons.event_repeat_rounded, '${v.detectedRecurring} Recurring'),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // Replacement Toggle
              Container(
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Replace Entire Database',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _replaceExisting
                                ? 'Clears existing records and writes this snapshot'
                                : 'Merges snapshot into existing records',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11.5,
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
              const SizedBox(height: Spacing.md),

              // Warning Note
              if (_replaceExisting)
                Container(
                  padding: const EdgeInsets.all(Spacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFF59E0B),
                        size: 18,
                      ),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: Text(
                          'Warning: Replacing will overwrite current database records with this backup snapshot. Unsaved recent entries will be lost.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 11.5,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: Spacing.xl),

              // Restore CTA Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isRestoring ? null : _performRestore,
                  style: FilledButton.styleFrom(
                    backgroundColor: StashColors.tealAccent,
                    foregroundColor: Colors.black,
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
                          'Confirm & Restore Ledger',
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

  Widget _statChip(ThemeData theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: StashColors.tealAccent),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
