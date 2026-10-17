import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/constants/app_constants.dart';
import 'package:hermanos_ledgr/core/constants/category_defaults.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/accounts/providers/accounts_provider.dart';
import 'package:hermanos_ledgr/features/recurring/domain/recurring_model.dart';
import 'package:hermanos_ledgr/features/recurring/providers/recurring_provider.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Custom bottom sheet for creating or editing recurring transaction rules (Task 8.5).
/// Conforms strictly to Zero Stock Android Native UI guidelines.
class AddRecurringSheet extends ConsumerStatefulWidget {
  final RecurringModel? initialRule;

  const AddRecurringSheet({
    super.key,
    this.initialRule,
  });

  static Future<void> show(BuildContext context, {RecurringModel? rule}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => AddRecurringSheet(initialRule: rule),
    );
  }

  @override
  ConsumerState<AddRecurringSheet> createState() => _AddRecurringSheetState();
}

class _AddRecurringSheetState extends ConsumerState<AddRecurringSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;

  late TransactionType _type;
  late RecurringFrequency _frequency;
  late CategoryItem _selectedCategory;
  AccountModel? _selectedAccount;
  late DateTime _startDate;
  late DateTime _nextDueDate;

  @override
  void initState() {
    super.initState();
    final rule = widget.initialRule;

    _titleController = TextEditingController(text: rule?.title ?? '');
    _amountController = TextEditingController(
      text: rule != null ? rule.amount.toStringAsFixed(0) : '',
    );
    _type = rule?.type ?? TransactionType.expense;
    _frequency = rule?.frequency ?? RecurringFrequency.monthly;

    _selectedCategory = rule != null
        ? CategoryDefaults.defaultCategories.firstWhere(
            (c) => c.id == rule.categoryId,
            orElse: () => CategoryDefaults.defaultCategories.first,
          )
        : CategoryDefaults.defaultCategories.first;

    _startDate = rule?.startDate ?? DateTime.now();
    _nextDueDate = rule?.nextDueDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final accounts = ref.read(accountsProvider);
    final account = _selectedAccount ?? (accounts.isNotEmpty ? accounts.first : null);

    if (account == null) {
      UndoSnackbar.error(context, message: 'Please select an account first');
      return;
    }

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      UndoSnackbar.error(context, message: 'Amount must be greater than 0');
      return;
    }

    HapticFeedback.mediumImpact();

    final isEditing = widget.initialRule != null;
    final id = widget.initialRule?.id ?? 'rec_${DateTime.now().millisecondsSinceEpoch}';

    final rule = RecurringModel(
      id: id,
      title: _titleController.text.trim(),
      amount: amount,
      type: _type,
      categoryId: _selectedCategory.id,
      categoryName: _selectedCategory.name,
      accountId: account.id,
      accountName: account.name,
      frequency: _frequency,
      startDate: _startDate,
      nextDueDate: _nextDueDate,
      isActive: widget.initialRule?.isActive ?? true,
    );

    if (isEditing) {
      ref.read(recurringProvider.notifier).updateRule(rule);
      Navigator.of(context).pop();
      UndoSnackbar.show(
        context,
        message: 'Updated recurring rule "${rule.title}"',
        onUndo: () => ref.read(recurringProvider.notifier).updateRule(widget.initialRule!),
      );
    } else {
      ref.read(recurringProvider.notifier).addRule(rule);
      Navigator.of(context).pop();
      UndoSnackbar.show(
        context,
        message: 'Scheduled "${rule.title}" (${rule.frequency.displayName})',
        onUndo: () => ref.read(recurringProvider.notifier).deleteRule(id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final accounts = ref.watch(accountsProvider);

    if (_selectedAccount == null && accounts.isNotEmpty) {
      if (widget.initialRule != null) {
        _selectedAccount = accounts.cast<AccountModel?>().firstWhere(
          (a) => a?.id == widget.initialRule!.accountId,
          orElse: () => accounts.first,
        );
      } else {
        _selectedAccount = accounts.first;
      }
    }

    final primaryAccent = _type == TransactionType.income
        ? SemanticColors.income(isDark)
        : SemanticColors.expense(isDark);

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.md,
          ),
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: Spacing.md),

            // Header Title
            Text(
              widget.initialRule != null ? 'Edit Recurring Rule' : 'New Recurring Rule',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              'Subscriptions, bills, rent, and scheduled salary income',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.lg),

            // 1. Transaction Type Segmented Bar (Expense vs Income)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTypeSegment(
                      title: 'Expense / Bill',
                      isSelected: _type == TransactionType.expense,
                      color: SemanticColors.expense(isDark),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _type = TransactionType.expense);
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildTypeSegment(
                      title: 'Income / Salary',
                      isSelected: _type == TransactionType.income,
                      color: SemanticColors.income(isDark),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _type = TransactionType.income);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.lg),

            // 2. Title Field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Rule Title / Description',
                hintText: 'e.g. Netflix, Fiber WiFi, Apartment Rent',
                prefixIcon: const Icon(Icons.description_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
            ),
            const SizedBox(height: Spacing.md),

            // 3. Amount Field
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: moneyStyle(fontSize: 20, fontWeight: FontWeight.w700, color: primaryAccent),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '${AppConstants.currencySymbol} ',
                prefixStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: primaryAccent,
                ),
                hintText: '0',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter an amount';
                final val = double.tryParse(v.trim());
                if (val == null || val <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: Spacing.lg),

            // 4. Frequency Selector
            Text(
              'RECURRENCE FREQUENCY',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Wrap(
              spacing: Spacing.xs,
              runSpacing: Spacing.xs,
              children: [
                for (final freq in RecurringFrequency.values)
                  ChoiceChip(
                    label: Text(freq.displayName),
                    selected: _frequency == freq,
                    onSelected: (selected) {
                      if (selected) {
                        HapticFeedback.selectionClick();
                        setState(() => _frequency = freq);
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: Spacing.lg),

            // 5. Account & Category Pickers Row
            Row(
              children: [
                // Account selector
                Expanded(
                  child: InkWell(
                    onTap: () => _showAccountPicker(context, accounts),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.md),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ACCOUNT',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedAccount?.name ?? 'Select Account',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.md),

                // Category selector
                Expanded(
                  child: InkWell(
                    onTap: () => _showCategoryPicker(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.md),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CATEGORY',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedCategory.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),

            // 6. Next Due Date Picker
            InkWell(
              onTap: () => _pickDate(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FIRST / NEXT DUE DATE',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(_nextDueDate),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.calendar_today_rounded, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Spacing.xl),

            // Save Action Button
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primaryAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _save,
              child: Text(
                widget.initialRule != null ? 'Save Changes' : 'Create Recurring Rule',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: Spacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSegment({
    required String title,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? StashColors.raised : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  void _showAccountPicker(BuildContext context, List<AccountModel> accounts) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(Spacing.md),
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: Spacing.md),
            const Text(
              'Select Account',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: Spacing.sm),
            for (final acc in accounts)
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: acc.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(acc.icon, size: 18, color: acc.color),
                ),
                title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(acc.institution ?? acc.type.name),
                trailing: Text(
                  CurrencyFormatter.format(acc.balance),
                  style: moneyStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                selected: _selectedAccount?.id == acc.id,
                onTap: () {
                  setState(() => _selectedAccount = acc);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(BuildContext context) {
    final categories = CategoryDefaults.defaultCategories
        .where((c) => _type == TransactionType.income ? !c.isExpense : c.isExpense)
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(Spacing.md),
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: Spacing.md),
            const Text(
              'Select Category',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: Spacing.sm),
            for (final cat in categories)
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cat.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(cat.icon, size: 18, color: cat.color),
                ),
                title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                selected: _selectedCategory.id == cat.id,
                onTap: () {
                  setState(() => _selectedCategory = cat);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    DateTime temp = _nextDueDate;

    await showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  'Select Due Date',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.md),
                CalendarDatePicker(
                  initialDate: temp,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                  onDateChanged: (d) {
                    setSheetState(() => temp = d);
                  },
                ),
                const SizedBox(height: Spacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark ? StashColors.tealAccent : theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _startDate = temp;
                        _nextDueDate = temp;
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text('Confirm Date'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
