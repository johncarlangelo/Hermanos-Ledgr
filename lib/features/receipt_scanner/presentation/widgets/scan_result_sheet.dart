import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/core/constants/category_defaults.dart';
import 'package:hermanos_ledgr/features/receipt_scanner/domain/receipt_scan_result.dart';
import 'package:hermanos_ledgr/features/transactions/presentation/widgets/add_transaction_sheet.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';

/// Modal bottom sheet presenting extracted receipt details with accuracy warnings (Tasks 10.4, 10.5).
class ScanResultSheet extends ConsumerStatefulWidget {
  final ReceiptScanResult result;

  const ScanResultSheet({
    super.key,
    required this.result,
  });

  static Future<void> show(
    BuildContext context, {
    required ReceiptScanResult result,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScanResultSheet(result: result),
    );
  }

  @override
  ConsumerState<ScanResultSheet> createState() => _ScanResultSheetState();
}

class _ScanResultSheetState extends ConsumerState<ScanResultSheet> {
  late TextEditingController _amountController;
  late TextEditingController _merchantController;
  late String _selectedCategoryId;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.result.amount != null
          ? widget.result.amount!.toStringAsFixed(2)
          : '',
    );
    _merchantController = TextEditingController(
      text: widget.result.merchant ?? 'Receipt Purchase',
    );
    _selectedCategoryId = widget.result.categoryId ?? 'food';
    _selectedDate = widget.result.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  void _applyToLedger() {
    final parsedAmount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;
    final merchant = _merchantController.text.trim();

    Navigator.pop(context); // Close scan result sheet

    // Connect scan result -> pre-filled add transaction sheet (Task 10.5)
    AddTransactionSheet.show(
      context,
      initialAmount: parsedAmount > 0 ? parsedAmount : null,
      initialTitle: merchant.isNotEmpty ? merchant : 'Receipt Purchase',
      initialCategoryId: _selectedCategoryId,
      initialReceiptImage: widget.result.imagePath,
      initialDate: _selectedDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final matchedCategory = CategoryDefaults.defaultCategories.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => CategoryDefaults.defaultCategories.first,
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + Spacing.lg,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xl, vertical: Spacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
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
                          Icons.receipt_long_rounded,
                          color: StashColors.tealAccent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        'Scanned Receipt',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (widget.result.usedLlmFallback
                              ? StashColors.tealAccent
                              : const Color(0xFFF59E0B))
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.result.usedLlmFallback ? 'Qwen AI Verified' : 'Tier 1 OCR',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: widget.result.usedLlmFallback
                            ? StashColors.tealAccent
                            : const Color(0xFFF59E0B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),

              // Accuracy Disclaimer Warning Banner
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
                      Icons.info_outline_rounded,
                      color: Color(0xFFF59E0B),
                      size: 18,
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Text(
                        widget.result.warningNote ??
                            'Note: OCR text detection may be inaccurate if the image is blurry, poorly lit, or the receipt is crumpled. Always verify details before adding to ledger.',
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
              const SizedBox(height: Spacing.lg),

              // Receipt Thumbnail & Main Amount
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.result.imagePath != null &&
                      File(widget.result.imagePath!).existsSync())
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(widget.result.imagePath!),
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL AMOUNT',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: StashColors.tealAccent,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            prefixText: '₱ ',
                            prefixStyle: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: StashColors.tealAccent,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // Merchant Field
              TextField(
                controller: _merchantController,
                decoration: const InputDecoration(
                  labelText: 'Merchant / Store',
                  prefixIcon: Icon(Icons.storefront_rounded),
                ),
              ),
              const SizedBox(height: Spacing.md),

              // Category & Date Row
              Row(
                children: [
                  Expanded(
                    child: M3Card(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                        vertical: Spacing.sm,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            matchedCategory.icon,
                            color: matchedCategory.color,
                            size: 18,
                          ),
                          const SizedBox(width: Spacing.xs),
                          Expanded(
                            child: Text(
                              matchedCategory.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: M3Card(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                        vertical: Spacing.sm,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: Spacing.xs),
                          Expanded(
                            child: Text(
                              '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.xl),

              // Action Buttons
              FilledButton.icon(
                onPressed: _applyToLedger,
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Add to Ledger'),
                style: FilledButton.styleFrom(
                  backgroundColor: StashColors.tealAccent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: Spacing.xs),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Discard Scan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
