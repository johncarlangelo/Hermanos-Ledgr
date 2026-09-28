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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount greater than 0')),
      );
      return;
    }

    final accounts = ref.read(accountsProvider);
    final account = _selectedAccount ?? (accounts.isNotEmpty ? accounts.first : null);

    if (account == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account')),
      );
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
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quick Log',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.xs),

            // Type Segmented Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Expense'),
                    icon: Icon(Icons.arrow_downward_rounded, size: 16),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Income'),
                    icon: Icon(Icons.arrow_upward_rounded, size: 16),
                  ),
                  ButtonSegment(
                    value: TransactionType.transfer,
                    label: Text('Transfer'),
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
              padding: const EdgeInsets.symmetric(vertical: Spacing.md),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '₱',
                    style: moneyStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: displayColor.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    _amountString,
                    style: moneyStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      color: displayColor,
                      letterSpacing: -1.0,
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

                  // Account Selector
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedAccount?.id,
                          decoration: const InputDecoration(
                            labelText: 'Source Account',
                            prefixIcon: Icon(Icons.account_balance_wallet_rounded),
                          ),
                          items: accounts.map((acc) {
                            return DropdownMenuItem(
                              value: acc.id,
                              child: Text(acc.name),
                            );
                          }).toList(),
                          onChanged: (id) {
                            if (id != null) {
                              setState(() {
                                _selectedAccount = accounts.firstWhere((a) => a.id == id);
                              });
                            }
                          },
                        ),
                      ),
                      if (_type == TransactionType.transfer) ...[
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedDestinationAccount?.id,
                            decoration: const InputDecoration(
                              labelText: 'Destination Account',
                              prefixIcon: Icon(Icons.arrow_forward_rounded),
                            ),
                            items: accounts.map((acc) {
                              return DropdownMenuItem(
                                value: acc.id,
                                child: Text(acc.name),
                              );
                            }).toList(),
                            onChanged: (id) {
                              if (id != null) {
                                setState(() {
                                  _selectedDestinationAccount =
                                      accounts.firstWhere((a) => a.id == id);
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
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
}
