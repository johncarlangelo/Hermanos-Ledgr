import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/features/transactions/providers/mock_transactions_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Custom bottom sheet for data export and backups.
/// Adheres strictly to Hermanos-Stash styling with zero native Android dialogs.
class ExportDialogSheet extends ConsumerWidget {
  const ExportDialogSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      builder: (_) => const ExportDialogSheet(),
    );
  }

  String _generateCsv(WidgetRef ref) {
    final transactions = ref.read(transactionsProvider);
    final buffer = StringBuffer();
    buffer.writeln('ID,Date,Title,Type,Category,Account,Amount,Note');
    for (final tx in transactions) {
      buffer.writeln(
        '${tx.id},${tx.date.toIso8601String()},"${tx.title}",${tx.type.name},"${tx.categoryName}","${tx.accountName}",${tx.amount},"${tx.note ?? ''}"',
      );
    }
    return buffer.toString();
  }

  String _generateJson(WidgetRef ref) {
    final transactions = ref.read(transactionsProvider);
    final list = transactions
        .map((tx) => {
              'id': tx.id,
              'title': tx.title,
              'amount': tx.amount,
              'type': tx.type.name,
              'categoryId': tx.categoryId,
              'categoryName': tx.categoryName,
              'accountId': tx.accountId,
              'accountName': tx.accountName,
              'date': tx.date.toIso8601String(),
              'note': tx.note,
            })
        .toList();

    return const JsonEncoder.withIndent('  ').convert({
      'exportDate': DateTime.now().toIso8601String(),
      'app': 'Hermanos Ledgr',
      'version': '0.2.0-alpha',
      'transactionsCount': list.length,
      'transactions': list,
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final txCount = ref.watch(transactionsProvider).length;

    return SafeArea(
      child: Padding(
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: isDark
                        ? StashColors.tealAccent.withValues(alpha: 0.15)
                        : theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.file_download_outlined,
                    size: 20,
                    color: isDark ? StashColors.tealAccent : theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Export Ledger Data',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '$txCount transactions ready for export',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),

            // Export CSV Option
            InkWell(
              onTap: () {
                final csv = _generateCsv(ref);
                Clipboard.setData(ClipboardData(text: csv));
                Navigator.of(context).pop();
                UndoSnackbar.info(
                  context,
                  message: 'CSV copied to clipboard ($txCount rows)',
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: isDark ? StashColors.raised : theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? StashColors.line.withValues(alpha: 0.8)
                        : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: SemanticColors.income(isDark).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.table_chart_rounded,
                        color: SemanticColors.income(isDark),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Export as CSV Spreadsheet',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Compatible with Excel, Google Sheets & Apple Numbers',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.copy_rounded,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Spacing.sm),

            // Export JSON Option
            InkWell(
              onTap: () {
                final jsonStr = _generateJson(ref);
                Clipboard.setData(ClipboardData(text: jsonStr));
                Navigator.of(context).pop();
                UndoSnackbar.info(
                  context,
                  message: 'JSON backup copied to clipboard',
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: isDark ? StashColors.raised : theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? StashColors.line.withValues(alpha: 0.8)
                        : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (isDark ? StashColors.tealAccent : theme.colorScheme.primary)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.data_object_rounded,
                        color: isDark ? StashColors.tealAccent : theme.colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Export JSON Backup',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Full snapshot for backup and device migration',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.copy_rounded,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
