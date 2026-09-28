import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/constants/category_defaults.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/accounts/providers/mock_accounts_provider.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';
import 'package:hermanos_ledgr/features/transactions/providers/mock_transactions_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/custom_keypad.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  final TransactionType initialType;

  const AddTransactionSheet({
    super.key,
    this.initialType = TransactionType.expense,
  });

  static Future<void> show(BuildContext context, {TransactionType initialType = TransactionType.expense}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      builder: (_) => AddTransactionSheet(initialType: initialType),
    );
  }

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  late TransactionType _type;
  String _amountString = '0';
  late CategoryItem _selectedCategory;
  AccountModel? _selectedAccount;
  AccountModel? _selectedDestinationAccount;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _showKeypad = true;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _selectedCategory = CategoryDefaults.defaultCategories.firstWhere(
      (c) => c.isExpense == (_type == TransactionType.expense),
      orElse: () => CategoryDefaults.defaultCategories.first,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onKeyPress(String key) {
    setState(() {
      if (key == '.') {
        if (!_amountString.contains('.')) {
          _amountString += '.';
        }
      } else {
        if (_amountString == '0') {
          _amountString = key;
        } else {
          // Max 2 decimal digits
          if (_amountString.contains('.')) {
            final parts = _amountString.split('.');
            if (parts.length > 1 && parts[1].length >= 2) return;
          }
          if (_amountString.length < 9) {
            _amountString += key;
          }
        }
      }
    });
  }

  void _onDelete() {
    setState(() {
      if (_amountString.length > 1) {
        _amountString = _amountString.substring(0, _amountString.length - 1);
        if (_amountString.isEmpty) _amountString = '0';
      } else {
        _amountString = '0';
      }
    });
  }

  void _onQuickAdd(double amount) {
    setState(() {
      final current = double.tryParse(_amountString) ?? 0.0;
      final updated = current + amount;
      _amountString = updated.toStringAsFixed(updated.truncateToDouble() == updated ? 0 : 2);
    });
  }

  void _save() {
    final amount = double.tryParse(_amountString) ?? 0.0;
    if (amount <= 0) {
      UndoSnackbar.error(context, message: 'Please enter an amount greater than 0');
      return;
    }

    final accounts = ref.read(accountsProvider);
    final account = _selectedAccount ?? (accounts.isNotEmpty ? accounts.first : null);

    if (account == null) {
      UndoSnackbar.error(context, message: 'Please select a source account');
      return;
    }

    if (_type == TransactionType.transfer && _selectedDestinationAccount == null) {
      UndoSnackbar.error(context, message: 'Please select a destination account');
      return;
    }

    if (_type == TransactionType.transfer && _selectedAccount?.id == _selectedDestinationAccount?.id) {
      UndoSnackbar.error(context, message: 'Source and destination accounts must be different');
      return;
    }

    final title = _titleController.text.trim().isEmpty
        ? (_type == TransactionType.transfer
            ? 'Transfer to ${_selectedDestinationAccount?.name ?? "Account"}'
            : _selectedCategory.name)
        : _titleController.text.trim();

    final tx = TransactionModel(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      amount: amount,
      type: _type,
      categoryId: _selectedCategory.id,
      categoryName: _selectedCategory.name,
      categoryIcon: _selectedCategory.icon,
      categoryColor: _selectedCategory.color,
      accountId: account.id,
      accountName: account.name,
      destinationAccountId: _selectedDestinationAccount?.id,
      destinationAccountName: _selectedDestinationAccount?.name,
      date: DateTime.now(),
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    ref.read(transactionsProvider.notifier).addTransaction(tx);
    Navigator.of(context).pop();

    // 5-second undo toast
    UndoSnackbar.show(
      context,
      message: 'Logged ${CurrencyFormatter.format(tx.amount)} (${tx.title})',
      onUndo: () {
        ref.read(transactionsProvider.notifier).deleteTransaction(tx.id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accounts = ref.watch(accountsProvider);

    _selectedAccount ??= accounts.isNotEmpty ? accounts.first : null;
    if (_selectedDestinationAccount == null && accounts.length > 1) {
      _selectedDestinationAccount = accounts[1];
    }

    final displayColor = switch (_type) {
      TransactionType.expense => SemanticColors.expense(isDark),
      TransactionType.income => SemanticColors.income(isDark),
      TransactionType.transfer => SemanticColors.transfer(isDark),
    };

    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Top Section (Fixed Header)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                Spacing.xs,
                Spacing.sm,
                Spacing.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Log',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        'Record a new entry to your ledger',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
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
            ),
            const SizedBox(height: Spacing.sm),

            // Type Segmented Selector (showSelectedIcon false to prevent text wrapping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: SegmentedButton<TransactionType>(
                showSelectedIcon: false,
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: Spacing.xs, vertical: Spacing.xs),
                  ),
                ),
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text(
                      'Expense',
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    icon: Icon(Icons.arrow_downward_rounded, size: 16),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text(
                      'Income',
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    icon: Icon(Icons.arrow_upward_rounded, size: 16),
                  ),
                  ButtonSegment(
                    value: TransactionType.transfer,
                    label: Text(
                      'Transfer',
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    icon: Icon(Icons.swap_horiz_rounded, size: 16),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (set) {
                  setState(() {
                    _type = set.first;
                    // update default category
                    _selectedCategory = CategoryDefaults.defaultCategories.firstWhere(
                      (c) => c.isExpense == (_type == TransactionType.expense),
                      orElse: () => CategoryDefaults.defaultCategories.first,
                    );
                  });
                },
              ),
            ),
            const SizedBox(height: Spacing.md),

            // Hero Amount Display (Centrally Highlighted)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '₱',
                    style: moneyStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: displayColor.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Text(
                    _amountString,
                    style: moneyStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: displayColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Body Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                children: [
                  // Title / Note input
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: _type == TransactionType.transfer
                          ? 'Transfer note (optional)'
                          : 'Description (e.g. Starbucks, Grocery)',
                      prefixIcon: const Icon(Icons.edit_note_rounded),
                    ),
                  ),
                  const SizedBox(height: Spacing.md),

                  // Custom Tailored Account Selector (Zero native dropdowns, zero overflow)
                  _buildAccountSection(theme, accounts),
                  const SizedBox(height: Spacing.md),

                  // Category Selector (if not transfer)
                  if (_type != TransactionType.transfer) ...[
                    Text(
                      'Category',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    _buildCategoryGrid(theme),
                    const SizedBox(height: Spacing.md),
                  ],

                  // Keypad Toggle / Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Amount Keypad',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton.icon(
                        icon: Icon(
                          _showKeypad
                              ? Icons.keyboard_hide_rounded
                              : Icons.dialpad_rounded,
                          size: 18,
                        ),
                        label: Text(_showKeypad ? 'Hide' : 'Show Keypad'),
                        onPressed: () =>
                            setState(() => _showKeypad = !_showKeypad),
                      ),
                    ],
                  ),
                  if (_showKeypad) ...[
                    CustomKeypad(
                      onKeyPress: _onKeyPress,
                      onDelete: _onDelete,
                      onQuickAdd: _onQuickAdd,
                    ),
                  ],

                  const SizedBox(height: Spacing.xl),

                  // Save Button
                  FilledButton(
                    onPressed: _save,
                    child: Text(
                      'Save ${_type == TransactionType.expense ? "Expense" : _type == TransactionType.income ? "Income" : "Transfer"}',
                    ),
                  ),
                  const SizedBox(height: Spacing.xxl),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryGrid(ThemeData theme) {
    final categories = CategoryDefaults.defaultCategories
        .where((c) => c.isExpense == (_type == TransactionType.expense))
        .toList();

    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: categories.map((cat) {
        final isSelected = cat.id == _selectedCategory.id;
        return FilterChip(
          selected: isSelected,
          avatar: Icon(
            cat.icon,
            size: 16,
            color: isSelected ? theme.colorScheme.onPrimary : cat.color,
          ),
          label: Text(cat.name),
          labelStyle: theme.textTheme.labelSmall?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
          selectedColor: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide.none,
          onSelected: (_) {
            HapticFeedback.selectionClick();
            setState(() => _selectedCategory = cat);
          },
        );
      }).toList(),
    );
  }

  Widget _buildAccountSection(ThemeData theme, List<AccountModel> accounts) {
    final account = _selectedAccount ?? (accounts.isNotEmpty ? accounts.first : null);
    final destination = _selectedDestinationAccount;

    if (_type == TransactionType.transfer) {
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            // FROM Row
            InkWell(
              onTap: () => _openAccountPicker(context, accounts, isDestination: false),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: (account?.color ?? theme.colorScheme.primary).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        account?.icon ?? Icons.account_balance_wallet_rounded,
                        size: 18,
                        color: account?.color ?? theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FROM SOURCE',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            account?.name ?? 'Select Source',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (account != null)
                      Text(
                        CurrencyFormatter.format(account.balance),
                        style: moneyStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(width: Spacing.xs),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),

            // Divider with interactive Swap Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
                      height: 1,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        final temp = _selectedAccount;
                        _selectedAccount = _selectedDestinationAccount;
                        _selectedDestinationAccount = temp;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        Icons.swap_vert_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),

            // TO Row
            InkWell(
              onTap: () => _openAccountPicker(context, accounts, isDestination: true),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: (destination?.color ?? theme.colorScheme.secondary).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        destination?.icon ?? Icons.arrow_downward_rounded,
                        size: 18,
                        color: destination?.color ?? theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TO DESTINATION',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            destination?.name ?? 'Select Destination Account',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: destination == null
                                  ? theme.colorScheme.onSurfaceVariant
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (destination != null)
                      Text(
                        CurrencyFormatter.format(destination.balance),
                        style: moneyStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(width: Spacing.xs),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Expense & Income Single Account Tile
    return InkWell(
      onTap: () => _openAccountPicker(context, accounts, isDestination: false),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: (account?.color ?? theme.colorScheme.primary).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                account?.icon ?? Icons.account_balance_wallet_rounded,
                size: 20,
                color: account?.color ?? theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACCOUNT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    account?.name ?? 'Select Account',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (account != null) ...[
              Text(
                CurrencyFormatter.format(account.balance),
                style: moneyStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: Spacing.xs),
            ],
            Icon(
              Icons.unfold_more_rounded,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _openAccountPicker(
    BuildContext context,
    List<AccountModel> accounts, {
    required bool isDestination,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final selectedId = isDestination
            ? _selectedDestinationAccount?.id
            : _selectedAccount?.id;

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
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDestination
                                ? 'Select Destination Account'
                                : 'Select Account',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            isDestination
                                ? 'Funds will be deposited to this account'
                                : 'Funds will be drawn from this account',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                ...accounts.map((acc) {
                  final isSelected = acc.id == selectedId;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.xs),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (isDestination) {
                              _selectedDestinationAccount = acc;
                            } else {
                              _selectedAccount = acc;
                            }
                          });
                          Navigator.of(ctx).pop();
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.md,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary.withValues(alpha: 0.08)
                                : theme.colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant
                                      .withValues(alpha: 0.3),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: acc.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  acc.icon,
                                  size: 20,
                                  color: acc.color,
                                ),
                              ),
                              const SizedBox(width: Spacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      acc.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    if (acc.institution != null && acc.institution!.isNotEmpty)
                                      Text(
                                        acc.institution!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                          fontSize: 11,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    CurrencyFormatter.format(acc.balance),
                                    style: moneyStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'Balance',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontSize: 10,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: Spacing.sm),
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 18,
                                  color: theme.colorScheme.primary,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
