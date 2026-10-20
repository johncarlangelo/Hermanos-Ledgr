import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/constants/app_constants.dart';
import 'package:hermanos_ledgr/features/debts/domain/debt_model.dart';
import 'package:hermanos_ledgr/features/debts/providers/debts_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Custom bottom sheet for creating or editing debts and receivables (Task 7.6).
/// Complies strictly with Zero Stock Android Native UI guidelines.
class AddDebtSheet extends ConsumerStatefulWidget {
  final DebtModel? initialDebt;
  final DebtType initialType;

  const AddDebtSheet({
    super.key,
    this.initialDebt,
    this.initialType = DebtType.debt,
  });

  static Future<void> show(
    BuildContext context, {
    DebtModel? debt,
    DebtType defaultType = DebtType.debt,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => AddDebtSheet(
        initialDebt: debt,
        initialType: debt?.type ?? defaultType,
      ),
    );
  }

  static Future<void> edit(BuildContext context, DebtModel debt) {
    return show(context, debt: debt);
  }

  @override
  ConsumerState<AddDebtSheet> createState() => _AddDebtSheetState();
}

class _AddDebtSheetState extends ConsumerState<AddDebtSheet> {
  late DebtType _selectedType;
  late final TextEditingController _personController;
  late final TextEditingController _amountController;
  late final TextEditingController _paidController;
  late final TextEditingController _noteController;
  DateTime? _selectedDueDate;

  bool get isEditing => widget.initialDebt != null;

  @override
  void initState() {
    super.initState();
    final d = widget.initialDebt;
    _selectedType = d?.type ?? widget.initialType;
    _personController = TextEditingController(text: d?.personName ?? '');
    _amountController = TextEditingController(
      text: d != null && d.originalAmount > 0
          ? d.originalAmount.toStringAsFixed(0)
          : '',
    );
    _paidController = TextEditingController(
      text: d != null && d.paidAmount > 0
          ? d.paidAmount.toStringAsFixed(0)
          : '',
    );
    _noteController = TextEditingController(text: d?.note ?? '');
    _selectedDueDate = d?.dueDate;

    _personController.addListener(() => setState(() {}));
    _amountController.addListener(() => setState(() {}));
    _paidController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _personController.dispose();
    _amountController.dispose();
    _paidController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _originalAmount => double.tryParse(_amountController.text) ?? 0.0;
  double get _paidAmount => double.tryParse(_paidController.text) ?? 0.0;

  void _saveDebt() {
    final person = _personController.text.trim();
    if (person.isEmpty) {
      UndoSnackbar.error(context, message: 'Please enter a person or lender name');
      return;
    }

    if (_originalAmount <= 0) {
      UndoSnackbar.error(context, message: 'Please enter a valid amount');
      return;
    }

    HapticFeedback.mediumImpact();

    final remaining = (_originalAmount - _paidAmount).clamp(0.0, _originalAmount);
    final isSettled = remaining <= 0;

    final debt = DebtModel(
      id: widget.initialDebt?.id ??
          'debt_${DateTime.now().millisecondsSinceEpoch}',
      type: _selectedType,
      personName: person,
      originalAmount: _originalAmount,
      remainingAmount: remaining,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      dueDate: _selectedDueDate,
      isSettled: isSettled,
      createdAt: widget.initialDebt?.createdAt ?? DateTime.now(),
    );

    if (isEditing) {
      ref.read(debtsProvider.notifier).updateDebt(debt);
      Navigator.of(context).pop();
      UndoSnackbar.info(
        context,
        message: 'Updated record for $person',
      );
    } else {
      ref.read(debtsProvider.notifier).addDebt(debt);
      Navigator.of(context).pop();
      UndoSnackbar.info(
        context,
        message: _selectedType == DebtType.debt
            ? 'Logged debt to $person'
            : 'Logged receivable from $person',
      );
    }
  }

  void _showDatePickerSheet() {
    final now = DateTime.now();
    DateTime tempDate = _selectedDueDate ?? now.add(const Duration(days: 30));

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Select Due Date',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    CalendarDatePicker(
                      initialDate: tempDate,
                      firstDate: DateTime(now.year - 1),
                      lastDate: DateTime(now.year + 10),
                      onDateChanged: (d) {
                        setModalState(() => tempDate = d);
                      },
                    ),
                    const SizedBox(height: Spacing.sm),
                    Row(
                      children: [
                        if (_selectedDueDate != null)
                          TextButton(
                            onPressed: () {
                              setState(() => _selectedDueDate = null);
                              Navigator.pop(ctx);
                            },
                            child: const Text('Clear Date'),
                          ),
                        const Spacer(),
                        FilledButton(
                          onPressed: () {
                            setState(() => _selectedDueDate = tempDate);
                            Navigator.pop(ctx);
                          },
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    final typeColor = _selectedType == DebtType.receivable
        ? SemanticColors.income(isDark)
        : SemanticColors.expense(isDark);

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: SafeArea(
        top: false,
        child: ListView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
        children: [
          // Title
          Text(
            isEditing
                ? 'Edit Record'
                : (_selectedType == DebtType.debt
                    ? 'Log Debt (Utang)'
                    : 'Log Receivable (Pautang)'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Spacing.md),

          // 1. Debt Type Segmented Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? StashColors.raised : theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedType = DebtType.debt);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedType == DebtType.debt
                            ? SemanticColors.expense(isDark).withValues(alpha: 0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: _selectedType == DebtType.debt
                            ? Border.all(
                                color: SemanticColors.expense(isDark),
                                width: 1.5,
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.call_made_rounded,
                            size: 16,
                            color: _selectedType == DebtType.debt
                                ? SemanticColors.expense(isDark)
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: Spacing.xs),
                          Text(
                            'I Owe (Utang)',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _selectedType == DebtType.debt
                                  ? SemanticColors.expense(isDark)
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedType = DebtType.receivable);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedType == DebtType.receivable
                            ? SemanticColors.income(isDark).withValues(alpha: 0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: _selectedType == DebtType.receivable
                            ? Border.all(
                                color: SemanticColors.income(isDark),
                                width: 1.5,
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.call_received_rounded,
                            size: 16,
                            color: _selectedType == DebtType.receivable
                                ? SemanticColors.income(isDark)
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: Spacing.xs),
                          Text(
                            'Owed to Me (Pautang)',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _selectedType == DebtType.receivable
                                  ? SemanticColors.income(isDark)
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),

          // 2. Person / Entity Name Field
          Text(
            _selectedType == DebtType.debt ? 'WHO DO YOU OWE?' : 'WHO OWES YOU?',
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: typeColor,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          TextField(
            controller: _personController,
            textCapitalization: TextCapitalization.words,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: _selectedType == DebtType.debt
                  ? 'e.g. Bank Loan, Alex, BPI Credit Card'
                  : 'e.g. Maria, John, Office Colleague',
              prefixIcon: Icon(Icons.person_outline_rounded, color: typeColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),

          // 3. Amount Fields
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL AMOUNT',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: moneyStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        prefixText: '${AppConstants.currencySymbol} ',
                        hintText: '0',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ALREADY PAID',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    TextField(
                      controller: _paidController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: moneyStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        prefixText: '${AppConstants.currencySymbol} ',
                        hintText: '0',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),

          // 4. Due Date Picker Tile
          Text(
            'REPAYMENT DEADLINE',
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: typeColor,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          InkWell(
            onTap: _showDatePickerSheet,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.md - 2,
              ),
              decoration: BoxDecoration(
                color: isDark ? StashColors.raised : theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 19,
                    color: typeColor,
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Text(
                      _selectedDueDate != null
                          ? DateFormat('MMMM d, yyyy').format(_selectedDueDate!)
                          : 'No due date set (Open-ended)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _selectedDueDate != null
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),

          // 5. Note / Memo
          Text(
            'NOTE (OPTIONAL)',
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          TextField(
            controller: _noteController,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'e.g. Split dinner bill, car downpayment loan',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: Spacing.xl),

          // 6. Action Button
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: typeColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: Spacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _saveDebt,
            child: Text(
              isEditing ? 'Save Changes' : 'Confirm Record',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: Spacing.lg),
        ],
      ),
    ),
  );
  }
}
