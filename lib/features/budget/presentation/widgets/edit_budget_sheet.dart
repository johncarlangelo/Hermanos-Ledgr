import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/constants/app_constants.dart';
import 'package:hermanos_ledgr/core/constants/category_defaults.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/budget/domain/budget_model.dart';
import 'package:hermanos_ledgr/features/budget/providers/budgets_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Custom bottom sheet for setting or editing monthly category budget limits.
/// Follows Hermanos-Stash styling with Zero Stock Android Native UI.
class EditBudgetSheet extends ConsumerStatefulWidget {
  final BudgetModel? budget;

  const EditBudgetSheet({
    super.key,
    this.budget,
  });

  static Future<void> show(BuildContext context, {BudgetModel? budget}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => EditBudgetSheet(budget: budget),
    );
  }

  @override
  ConsumerState<EditBudgetSheet> createState() => _EditBudgetSheetState();
}

class _EditBudgetSheetState extends ConsumerState<EditBudgetSheet> {
  late final TextEditingController _amountController;
  late CategoryItem _selectedCategory;

  @override
  void initState() {
    super.initState();
    final expenseCategories =
        CategoryDefaults.defaultCategories.where((c) => c.isExpense).toList();

    if (widget.budget != null) {
      _selectedCategory = CategoryDefaults.findById(widget.budget!.categoryId);
      _amountController = TextEditingController(
        text: widget.budget!.limitAmount.toStringAsFixed(0),
      );
    } else {
      _selectedCategory = expenseCategories.first;
      _amountController = TextEditingController(text: '5000');
    }

    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _enteredAmount => double.tryParse(_amountController.text) ?? 0.0;

  void _applyQuickPreset(double amount) {
    HapticFeedback.selectionClick();
    _amountController.text = amount.toStringAsFixed(0);
  }

  void _addAmount(double delta) {
    HapticFeedback.selectionClick();
    final current = _enteredAmount;
    _amountController.text = (current + delta).toStringAsFixed(0);
  }

  void _saveBudget() {
    final amount = _enteredAmount;
    if (amount <= 0) {
      UndoSnackbar.error(context, message: 'Please enter a valid monthly limit');
      return;
    }

    HapticFeedback.mediumImpact();

    final categoryId = _selectedCategory.id;
    final categoryName = _selectedCategory.name;
    final oldLimit = widget.budget?.limitAmount;
    final budgetId = widget.budget?.id ?? 'budget_$categoryId';

    final budgetsNotifier = ref.read(budgetsProvider.notifier);

    budgetsNotifier.setCategoryLimit(
      categoryId: categoryId,
      categoryName: categoryName,
      limitAmount: amount,
    );

    Navigator.of(context).pop();

    UndoSnackbar.show(
      context,
      message: 'Set monthly budget for $categoryName to ${CurrencyFormatter.format(amount, includeDecimals: false)}',
      onUndo: () {
        if (oldLimit != null) {
          budgetsNotifier.updateLimit(budgetId, oldLimit);
        } else {
          budgetsNotifier.deleteBudget(budgetId);
        }
      },
    );
  }

  void _deleteBudget() {
    if (widget.budget == null) return;
    HapticFeedback.mediumImpact();

    final budget = widget.budget!;
    final budgetsNotifier = ref.read(budgetsProvider.notifier);

    budgetsNotifier.deleteBudget(budget.id);

    Navigator.of(context).pop();

    UndoSnackbar.show(
      context,
      message: 'Removed budget limit for ${budget.categoryName}',
      onUndo: () {
        budgetsNotifier.setCategoryLimit(
          categoryId: budget.categoryId,
          categoryName: budget.categoryName,
          limitAmount: budget.limitAmount,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.budget != null;
    final expenseCategories =
        CategoryDefaults.defaultCategories.where((c) => c.isExpense).toList();

    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = (lastDayOfMonth - now.day).clamp(1, 31);
    final spentAmount = widget.budget?.spentAmount ?? 0.0;
    final limit = _enteredAmount;
    final remaining = (limit - spentAmount).clamp(0.0, limit);
    final dailyPacing = remaining / daysLeft;

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
          // Header Row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _selectedCategory.color.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _selectedCategory.icon,
                  size: 20,
                  color: _selectedCategory.color,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Edit Category Budget' : 'Set Category Budget',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _selectedCategory.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isEditing)
                IconButton(
                  tooltip: 'Remove Budget',
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: SemanticColors.expense(isDark),
                    size: 22,
                  ),
                  onPressed: _deleteBudget,
                ),
            ],
          ),
          const SizedBox(height: Spacing.lg),

          // Category Selector (if creating a new budget)
          if (!isEditing) ...[
            Text(
              'SELECT CATEGORY',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            SizedBox(
              height: 46,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: expenseCategories.length,
                separatorBuilder: (_, _) => const SizedBox(width: Spacing.xs),
                itemBuilder: (ctx, i) {
                  final cat = expenseCategories[i];
                  final isSelected = cat.id == _selectedCategory.id;
                  return ChoiceChip(
                    avatar: Icon(cat.icon, size: 16, color: cat.color),
                    label: Text(cat.name),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedCategory = cat);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: Spacing.lg),
          ],

          // Monthly Limit Amount Input
          Text(
            'MONTHLY SPENDING LIMIT',
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
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            style: moneyStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: StashColors.tealAccent,
            ),
            decoration: InputDecoration(
              prefixText: '${AppConstants.currencySymbol} ',
              prefixStyle: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: StashColors.tealAccent,
              ),
              hintText: '0',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),

          // Quick Presets
          Wrap(
            spacing: Spacing.xs,
            runSpacing: Spacing.xs,
            children: [
              ActionChip(
                label: const Text('+₱1,000'),
                onPressed: () => _addAmount(1000),
              ),
              ActionChip(
                label: const Text('+₱2,000'),
                onPressed: () => _addAmount(2000),
              ),
              ActionChip(
                label: const Text('+₱5,000'),
                onPressed: () => _addAmount(5000),
              ),
              ActionChip(
                label: const Text('₱5,000'),
                onPressed: () => _applyQuickPreset(5000),
              ),
              ActionChip(
                label: const Text('₱10,000'),
                onPressed: () => _applyQuickPreset(10000),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),

          // Monthly Pacing Readout Card
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: isDark ? StashColors.raised : theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: StashColors.tealAccent.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: StashColors.tealAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.speed_rounded,
                    size: 20,
                    color: StashColors.tealAccent,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pacing Allowance',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${CurrencyFormatter.format(dailyPacing, includeDecimals: false)} / day remaining for $daysLeft days',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isEditing && spentAmount > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Spent',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(spentAmount, includeDecimals: false),
                        style: moneyStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),

          // Save Button
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: StashColors.tealAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: Spacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _saveBudget,
            child: Text(
              isEditing ? 'Update Limit' : 'Save Budget Limit',
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
