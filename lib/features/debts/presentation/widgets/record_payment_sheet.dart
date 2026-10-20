import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/constants/app_constants.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/accounts/providers/accounts_provider.dart';
import 'package:hermanos_ledgr/features/debts/domain/debt_model.dart';
import 'package:hermanos_ledgr/features/debts/providers/debts_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Custom bottom sheet for recording payments against a debt or receivable (Task 7.7).
class RecordPaymentSheet extends ConsumerStatefulWidget {
  final DebtModel debt;

  const RecordPaymentSheet({
    super.key,
    required this.debt,
  });

  static Future<void> show(BuildContext context, DebtModel debt) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => RecordPaymentSheet(debt: debt),
    );
  }

  @override
  ConsumerState<RecordPaymentSheet> createState() => _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends ConsumerState<RecordPaymentSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _enteredAmount => double.tryParse(_amountController.text) ?? 0.0;

  void _applyQuickAmount(double amount) {
    HapticFeedback.selectionClick();
    _amountController.text = amount.toStringAsFixed(0);
  }

  void _confirmPayment() {
    final amount = _enteredAmount;
    if (amount <= 0) {
      UndoSnackbar.error(context, message: 'Please enter a valid payment amount');
      return;
    }

    HapticFeedback.mediumImpact();

    final debtId = widget.debt.id;
    final person = widget.debt.personName;
    final isReceivable = widget.debt.type == DebtType.receivable;
    final accountId = _selectedAccountId;

    final debtsNotifier = ref.read(debtsProvider.notifier);
    final accountsNotifier = ref.read(accountsProvider.notifier);

    debtsNotifier.recordPayment(debtId, amount);

    if (accountId != null) {
      final delta = isReceivable ? amount : -amount;
      accountsNotifier.updateBalance(accountId, delta);
    }

    Navigator.of(context).pop();

    final remainingAfter = (widget.debt.remainingAmount - amount).clamp(0.0, widget.debt.originalAmount);
    final isNowSettled = remainingAfter <= 0;

    UndoSnackbar.show(
      context,
      message: isNowSettled
          ? (isReceivable ? '🎉 Received full payment from $person!' : '🎉 Settled debt to $person!')
          : (isReceivable
              ? 'Recorded ${CurrencyFormatter.format(amount)} received from $person'
              : 'Recorded ${CurrencyFormatter.format(amount)} payment to $person'),
      onUndo: () {
        // Reverse payment by recording negative amount
        debtsNotifier.recordPayment(debtId, -amount);
        if (accountId != null) {
          final reverseDelta = isReceivable ? -amount : amount;
          accountsNotifier.updateBalance(accountId, reverseDelta);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final accounts = ref.watch(accountsProvider);
    final isReceivable = widget.debt.type == DebtType.receivable;

    final primaryAccent = isReceivable
        ? SemanticColors.income(isDark)
        : SemanticColors.expense(isDark);

    final remaining = widget.debt.remainingAmount;

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
            isReceivable ? 'Record Collected Payment' : 'Record Debt Repayment',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isReceivable
                ? 'From ${widget.debt.personName} · ${CurrencyFormatter.format(remaining)} balance'
                : 'To ${widget.debt.personName} · ${CurrencyFormatter.format(remaining)} balance',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.lg),

          // Amount Field
          TextField(
            controller: _amountController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: moneyStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: primaryAccent,
            ),
            decoration: InputDecoration(
              prefixText: '${AppConstants.currencySymbol} ',
              prefixStyle: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: primaryAccent,
              ),
              hintText: '0',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),

          // Quick preset chips
          Wrap(
            spacing: Spacing.xs,
            runSpacing: Spacing.xs,
            children: [
              if (remaining > 500)
                ActionChip(
                  label: const Text('+₱500'),
                  onPressed: () => _applyQuickAmount(500),
                ),
              if (remaining > 1000)
                ActionChip(
                  label: const Text('+₱1,000'),
                  onPressed: () => _applyQuickAmount(1000),
                ),
              if (remaining > 5000)
                ActionChip(
                  label: const Text('+₱5,000'),
                  onPressed: () => _applyQuickAmount(5000),
                ),
              ActionChip(
                label: const Text('50%'),
                onPressed: () => _applyQuickAmount((remaining * 0.5).roundToDouble()),
              ),
              ActionChip(
                label: const Text('Full Payoff'),
                backgroundColor: primaryAccent.withValues(alpha: 0.15),
                onPressed: () => _applyQuickAmount(remaining),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),

          // Link to Account (Optional)
          if (accounts.isNotEmpty) ...[
            Text(
              isReceivable ? 'DEPOSIT INTO ACCOUNT (OPTIONAL)' : 'PAY FROM ACCOUNT (OPTIONAL)',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: accounts.length + 1,
                separatorBuilder: (_, _) => const SizedBox(width: Spacing.xs),
                itemBuilder: (ctx, i) {
                  if (i == 0) {
                    final isSelected = _selectedAccountId == null;
                    return ChoiceChip(
                      label: const Text('None (Record only)'),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedAccountId = null),
                    );
                  }
                  final acc = accounts[i - 1];
                  final isSelected = _selectedAccountId == acc.id;
                  return ChoiceChip(
                    avatar: Icon(acc.icon, size: 16, color: acc.color),
                    label: Text(acc.name),
                    selected: isSelected,
                    onSelected: (val) => setState(() {
                      _selectedAccountId = val ? acc.id : null;
                    }),
                  );
                },
              ),
            ),
            const SizedBox(height: Spacing.md),
          ],

          // Note
          TextField(
            controller: _noteController,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Note or receipt memo (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: Spacing.xl),

          // Action Button
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: primaryAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: Spacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _confirmPayment,
            child: Text(
              isReceivable ? 'Confirm Collected Payment' : 'Confirm Repayment',
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
