import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/constants/app_constants.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/accounts/providers/accounts_provider.dart';
import 'package:hermanos_ledgr/features/goals/domain/goal_model.dart';
import 'package:hermanos_ledgr/features/goals/presentation/widgets/goal_progress_ring.dart';
import 'package:hermanos_ledgr/features/goals/providers/goals_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Custom bottom sheet for logging a financial contribution towards a savings goal (Task 6.7).
/// Adheres strictly to Hermanos-Stash styling with Zero Stock Android native UI.
class AddContributionSheet extends ConsumerStatefulWidget {
  final GoalModel goal;

  const AddContributionSheet({
    super.key,
    required this.goal,
  });

  static Future<void> show(BuildContext context, GoalModel goal) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => AddContributionSheet(goal: goal),
    );
  }

  @override
  ConsumerState<AddContributionSheet> createState() =>
      _AddContributionSheetState();
}

class _AddContributionSheetState extends ConsumerState<AddContributionSheet> {
  final TextEditingController _amountController = TextEditingController();
  AccountModel? _selectedAccount;

  @override
  void initState() {
    super.initState();
    final accounts = ref.read(accountsProvider);
    if (accounts.isNotEmpty) {
      _selectedAccount = accounts.first;
    }
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _enteredAmount => double.tryParse(_amountController.text) ?? 0.0;

  void _addQuickPreset(double preset) {
    HapticFeedback.selectionClick();
    final current = _enteredAmount;
    final updated = current + preset;
    _amountController.text = updated.toStringAsFixed(0);
  }

  void _fillRemaining() {
    HapticFeedback.selectionClick();
    if (widget.goal.remainingAmount > 0) {
      _amountController.text =
          widget.goal.remainingAmount.toStringAsFixed(0);
    }
  }

  Future<void> _submitContribution() async {
    final amount = _enteredAmount;
    if (amount <= 0) {
      UndoSnackbar.error(context, message: 'Please enter a valid amount');
      return;
    }

    HapticFeedback.mediumImpact();
    final goalId = widget.goal.id;
    final goalName = widget.goal.name;
    final selectedAcc = _selectedAccount;

    // 1. Add contribution to Goal
    await ref.read(goalsProvider.notifier).addContribution(
          goalId: goalId,
          amount: amount,
        );

    // 2. If funding account was chosen, deduct from account balance
    if (selectedAcc != null) {
      ref.read(accountsProvider.notifier).updateBalance(selectedAcc.id, -amount);
    }

    if (!mounted) return;
    Navigator.of(context).pop();

    // 3. Show undo toast banner
    UndoSnackbar.show(
      context,
      message: 'Added ${CurrencyFormatter.format(amount)} to $goalName',
      onUndo: () async {
        // Rollback contribution
        await ref.read(goalsProvider.notifier).addContribution(
              goalId: goalId,
              amount: -amount,
            );
        if (selectedAcc != null) {
          ref.read(accountsProvider.notifier).updateBalance(selectedAcc.id, amount);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accounts = ref.watch(accountsProvider);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    final newTotal = widget.goal.currentAmount + _enteredAmount;
    final newPercent = widget.goal.targetAmount > 0
        ? ((newTotal / widget.goal.targetAmount) * 100).clamp(0, 100).toInt()
        : 0;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: widget.goal.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.goal.icon,
                        size: 20,
                        color: widget.goal.color,
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Text(
                      'Deposit to Goal',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),

            // Goal Info Pill
            Container(
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.goal.color.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  GoalProgressRing(
                    percentage: widget.goal.targetAmount > 0
                        ? (newTotal / widget.goal.targetAmount).clamp(0.0, 1.0)
                        : 0.0,
                    color: widget.goal.color,
                    size: 46,
                    strokeWidth: 4,
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.goal.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${CurrencyFormatter.format(newTotal)} of ${CurrencyFormatter.format(widget.goal.targetAmount)} ($newPercent%)',
                          style: moneyStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.lg),

            // Amount Field
            Text(
              'CONTRIBUTION AMOUNT',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            TextField(
              controller: _amountController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: moneyStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                prefixText: '${AppConstants.currencySymbol} ',
                prefixStyle: moneyStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
                hintText: '0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: Spacing.sm),

            // Quick Preset Buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPresetChip('+₱500', 500),
                  const SizedBox(width: Spacing.xs),
                  _buildPresetChip('+₱1,000', 1000),
                  const SizedBox(width: Spacing.xs),
                  _buildPresetChip('+₱2,500', 2500),
                  const SizedBox(width: Spacing.xs),
                  _buildPresetChip('+₱5,000', 5000),
                  if (widget.goal.remainingAmount > 0) ...[
                    const SizedBox(width: Spacing.xs),
                    InkWell(
                      onTap: _fillRemaining,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: widget.goal.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: widget.goal.color.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          'Fill ${CurrencyFormatter.format(widget.goal.remainingAmount)}',
                          style: moneyStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: widget.goal.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: Spacing.lg),

            // Funding Account Selector (Zero Stock Native Dropdown!)
            if (accounts.isNotEmpty) ...[
              Text(
                'FUND FROM ACCOUNT (OPTIONAL)',
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
                  itemCount: accounts.length + 1,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: Spacing.xs),
                  itemBuilder: (ctx, i) {
                    if (i == 0) {
                      final isSelected = _selectedAccount == null;
                      return _buildAccountChip(
                        label: 'No deduction',
                        icon: Icons.money_off_csred_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                        isSelected: isSelected,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedAccount = null);
                        },
                      );
                    }
                    final acc = accounts[i - 1];
                    final isSelected = _selectedAccount?.id == acc.id;
                    return _buildAccountChip(
                      label: acc.name,
                      icon: acc.icon,
                      color: acc.color,
                      balance: CurrencyFormatter.format(acc.balance),
                      isSelected: isSelected,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedAccount = acc);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: Spacing.xl),
            ],

            // Confirm Button
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _submitContribution,
              child: Text(
                _enteredAmount > 0
                    ? 'Deposit ${CurrencyFormatter.format(_enteredAmount)}'
                    : 'Confirm Deposit',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: Spacing.md),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildPresetChip(String label, double amount) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => _addQuickPreset(amount),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? StashColors.raised : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark
                ? StashColors.line.withValues(alpha: 0.8)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        child: Text(
          label,
          style: moneyStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountChip({
    required String label,
    required IconData icon,
    required Color color,
    String? balance,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.6)
              : (isDark ? StashColors.raised : theme.colorScheme.surfaceContainerHigh),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: Spacing.xs + 2),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 11.5,
                  ),
                ),
                if (balance != null)
                  Text(
                    balance,
                    style: moneyStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
