import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/core/providers/database_provider.dart';
import 'package:hermanos_ledgr/features/settings/presentation/widgets/stash_switch.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Custom bottom sheet for restoring ledger data from JSON backups.
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
  int _detectedTxCount = 0;
  int _detectedAccCount = 0;
  String? _validationError;
  bool _isParsed = false;
  List<Map<String, dynamic>> _txList = [];
  List<Map<String, dynamic>> _accList = [];

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  void _parseJson(String raw) {
    final text = raw.trim();
    if (text.isEmpty) {
      setState(() {
        _isParsed = false;
        _validationError = null;
        _detectedTxCount = 0;
        _detectedAccCount = 0;
        _txList = [];
        _accList = [];
      });
      return;
    }

    try {
      final decoded = jsonDecode(text);
      List<Map<String, dynamic>> txList = [];
      List<Map<String, dynamic>> accList = [];

      if (decoded is List) {
        // Plain list of transactions
        txList = decoded.whereType<Map<String, dynamic>>().toList();
      } else if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('transactions') && decoded['transactions'] is List) {
          final rawTxs = decoded['transactions'] as List;
          txList = rawTxs
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
        if (decoded.containsKey('accounts') && decoded['accounts'] is List) {
          final rawAccs = decoded['accounts'] as List;
          accList = rawAccs
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      } else {
        throw const FormatException('Expected JSON object or list');
      }

      if (txList.isEmpty && accList.isEmpty) {
        setState(() {
          _isParsed = false;
          _validationError = 'No valid transaction or account entries found in JSON';
          _detectedTxCount = 0;
          _detectedAccCount = 0;
          _txList = [];
          _accList = [];
        });
        return;
      }

      setState(() {
        _isParsed = true;
        _validationError = null;
        _detectedTxCount = txList.length;
        _detectedAccCount = accList.length;
        _txList = txList;
        _accList = accList;
      });
    } catch (e) {
      setState(() {
        _isParsed = false;
        _validationError = 'Invalid JSON syntax: ${e.toString().split('\n').first}';
        _detectedTxCount = 0;
        _detectedAccCount = 0;
        _txList = [];
        _accList = [];
      });
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      _jsonController.text = data.text!.trim();
      _parseJson(_jsonController.text);
    } else {
      if (mounted) {
        UndoSnackbar.error(context, message: 'Clipboard is empty');
      }
    }
  }

  Future<void> _importData() async {
    if (!_isParsed || (_detectedTxCount == 0 && _detectedAccCount == 0)) return;

    final db = ref.read(databaseProvider);

    try {
      await db.transaction(() async {
        if (_replaceExisting) {
          await db.delete(db.transactionsTable).go();
          if (_accList.isNotEmpty) {
            await db.delete(db.accountsTable).go();
          }
        }

        // Insert accounts
        for (var i = 0; i < _accList.length; i++) {
          final a = _accList[i];
          final id = a['id'] as String? ?? 'acc_${DateTime.now().millisecondsSinceEpoch}_$i';
          final name = a['name'] as String? ?? 'Imported Account';
          final type = a['type'] as String? ?? 'bank';
          final balance = (a['balance'] as num?)?.toDouble() ?? 0.0;
          final iconCode = (a['iconCode'] as num?)?.toInt() ?? Icons.account_balance_rounded.codePoint;
          final colorValue = (a['colorValue'] as num?)?.toInt() ?? 0xFF00897B;
          final institution = a['institution'] as String? ?? '';
          final monthlyChange = (a['monthlyChange'] as num?)?.toDouble() ?? 0.0;

          await db.into(db.accountsTable).insert(
            AccountsTableCompanion.insert(
              id: id,
              name: name,
              type: type,
              balance: balance,
              iconCode: iconCode,
              colorValue: colorValue,
              institution: institution,
              monthlyChange: drift.Value(monthlyChange),
            ),
            mode: drift.InsertMode.insertOrReplace,
          );
        }

        // Insert transactions
        for (var i = 0; i < _txList.length; i++) {
          final t = _txList[i];
          final id = t['id'] as String? ?? 'tx_${DateTime.now().millisecondsSinceEpoch}_$i';
          final title = t['title'] as String? ?? 'Imported Transaction';
          final amount = (t['amount'] as num?)?.toDouble() ?? 0.0;
          final type = t['type'] as String? ?? 'expense';
          final categoryId = t['categoryId'] as String? ?? 'cat_food';
          final categoryName = t['categoryName'] as String? ?? 'Food & Dining';
          final iconCode = (t['categoryIconCode'] as num?)?.toInt() ?? Icons.fastfood_rounded.codePoint;
          final colorValue = (t['categoryColorValue'] as num?)?.toInt() ?? 0xFFFF8F00;
          final accountId = t['accountId'] as String? ?? 'acc_cash';
          final accountName = t['accountName'] as String? ?? 'Cash Wallet';
          final destinationAccountId = t['destinationAccountId'] as String?;
          final destinationAccountName = t['destinationAccountName'] as String?;
          final date = t['date'] != null
              ? (DateTime.tryParse(t['date'].toString()) ?? DateTime.now())
              : DateTime.now();
          final note = t['note'] as String?;

          await db.into(db.transactionsTable).insert(
            TransactionsTableCompanion.insert(
              id: id,
              title: title,
              amount: amount,
              type: type,
              categoryId: categoryId,
              categoryName: categoryName,
              categoryIconCode: iconCode,
              categoryColorValue: colorValue,
              accountId: accountId,
              accountName: accountName,
              destinationAccountId: drift.Value(destinationAccountId),
              destinationAccountName: drift.Value(destinationAccountName),
              date: date,
              note: drift.Value(note),
            ),
            mode: drift.InsertMode.insertOrReplace,
          );
        }
      });

      if (mounted) {
        Navigator.of(context).pop();
        UndoSnackbar.info(
          context,
          message: 'Restored $_detectedTxCount transactions${_detectedAccCount > 0 ? " and $_detectedAccCount accounts" : ""}',
        );
      }
    } catch (e) {
      if (mounted) {
        UndoSnackbar.error(context, message: 'Restore failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                      color: isDark
                          ? StashColors.tealAccent.withValues(alpha: 0.15)
                          : theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.file_upload_outlined,
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
                          'Restore Ledger Backup',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Import and restore records from JSON data',
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
              const SizedBox(height: Spacing.md),

              // Paste Action Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'JSON Payload',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Row(
                    children: [
                      if (_jsonController.text.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            _jsonController.clear();
                            _parseJson('');
                          },
                          child: const Text('Clear'),
                        ),
                      TextButton.icon(
                        icon: const Icon(Icons.content_paste_rounded, size: 16),
                        label: const Text('Paste Clipboard'),
                        onPressed: _pasteFromClipboard,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: Spacing.xs),

              // Multi-line JSON TextField
              TextField(
                controller: _jsonController,
                onChanged: _parseJson,
                minLines: 4,
                maxLines: 8,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
                decoration: InputDecoration(
                  hintText: '{\n  "transactions": [...],\n  "accounts": [...]\n}',
                  hintStyle: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? StashColors.raised
                      : theme.colorScheme.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? StashColors.line
                          : theme.colorScheme.outlineVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.md),

              // Parse status feedback
              if (_isParsed) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: SemanticColors.income(isDark).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: SemanticColors.income(isDark).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: SemanticColors.income(isDark),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: Text(
                          'Valid Backup: $_detectedTxCount transactions${_detectedAccCount > 0 ? ", $_detectedAccCount accounts" : ""} detected',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: SemanticColors.income(isDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.md),
              ] else if (_validationError != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: SemanticColors.expense(isDark).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: SemanticColors.expense(isDark).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 18,
                        color: SemanticColors.expense(isDark),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: Text(
                          _validationError!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: SemanticColors.expense(isDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.md),
              ],

              // Replace vs Merge Toggle
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
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
                    Icon(
                      _replaceExisting
                          ? Icons.published_with_changes_rounded
                          : Icons.call_merge_rounded,
                      size: 20,
                      color: isDark ? StashColors.tealAccent : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _replaceExisting
                                ? 'Replace Current Data'
                                : 'Merge with Current Data',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            _replaceExisting
                                ? 'Clears existing records before restoring'
                                : 'Adds new records and updates matching IDs',
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

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.restore_rounded, size: 18),
                      label: const Text('Restore Data'),
                      onPressed: (_isParsed && (_detectedTxCount > 0 || _detectedAccCount > 0))
                          ? _importData
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
