import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/constants/app_constants.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/debts/domain/debt_model.dart';
import 'package:hermanos_ledgr/features/debts/providers/debts_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Bill Split Calculator sheet for shared dining, trips, or group expenses (Task 7.8).
/// Allows calculating equal splits and optionally saving attendees' shares as Receivables.
class BillSplitSheet extends ConsumerStatefulWidget {
  const BillSplitSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const BillSplitSheet(),
    );
  }

  @override
  ConsumerState<BillSplitSheet> createState() => _BillSplitSheetState();
}

class _BillSplitSheetState extends ConsumerState<BillSplitSheet> {
  final TextEditingController _totalBillController = TextEditingController();
  final TextEditingController _noteController = TextEditingController(text: 'Split expense');
  int _numPeople = 3;
  double _tipTaxPercent = 0.0;
  final List<String> _customNames = ['Friend 1', 'Friend 2'];

  @override
  void initState() {
    super.initState();
    _totalBillController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _totalBillController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _billAmount => double.tryParse(_totalBillController.text) ?? 0.0;
  double get _tipTaxAmount => _billAmount * (_tipTaxPercent / 100);
  double get _grandTotal => _billAmount + _tipTaxAmount;
  double get _perPersonAmount => _numPeople > 0 ? _grandTotal / _numPeople : 0.0;

  void _updatePeopleCount(int count) {
    if (count < 2 || count > 30) return;
    HapticFeedback.selectionClick();
    setState(() {
      _numPeople = count;
      // Adjust custom names list (excluding yourself)
      final neededFriends = count - 1;
      while (_customNames.length < neededFriends) {
        _customNames.add('Friend ${_customNames.length + 1}');
      }
      while (_customNames.length > neededFriends) {
        _customNames.removeLast();
      }
    });
  }

  void _saveAsReceivables() {
    if (_billAmount <= 0) {
      UndoSnackbar.error(context, message: 'Please enter a bill amount');
      return;
    }

    HapticFeedback.mediumImpact();

    final perPerson = _perPersonAmount;
    final note = _noteController.text.trim();
    final now = DateTime.now();

    final createdIds = <String>[];

    for (int i = 0; i < _customNames.length; i++) {
      final friendName = _customNames[i].trim().isEmpty
          ? 'Friend ${i + 1}'
          : _customNames[i].trim();

      final id = 'split_${now.millisecondsSinceEpoch}_$i';
      createdIds.add(id);

      final receivable = DebtModel(
        id: id,
        type: DebtType.receivable,
        personName: friendName,
        originalAmount: perPerson,
        remainingAmount: perPerson,
        note: note.isNotEmpty ? note : 'Split bill',
        dueDate: now.add(const Duration(days: 7)),
        createdAt: now,
      );

      ref.read(debtsProvider.notifier).addDebt(receivable);
    }

    Navigator.of(context).pop();

    UndoSnackbar.show(
      context,
      message: 'Created ${_customNames.length} receivables (${CurrencyFormatter.format(perPerson)} each)',
      onUndo: () {
        for (final id in createdIds) {
          ref.read(debtsProvider.notifier).deleteDebt(id);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: ListView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: StashColors.tealAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.call_split_rounded,
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
                      'Bill Split Calculator',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Calculate equal shares & track who owes you',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),

          // Hero Result Card: Each Person Pays
          M3Card(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EACH PERSON PAYS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: isDark ? StashColors.tealAccent : theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    CurrencyFormatter.format(_perPersonAmount),
                    style: moneyStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: isDark ? StashColors.tealAccent : theme.colorScheme.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  'Split between $_numPeople people (You + ${_numPeople - 1} others)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                if (_tipTaxPercent > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Includes ${_tipTaxPercent.toStringAsFixed(0)}% tax/tip (${CurrencyFormatter.format(_tipTaxAmount)} total)',
                    style: moneyStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? StashColors.dim : theme.colorScheme.outline,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),

          // Bill Amount Input
          Text(
            'TOTAL BILL AMOUNT',
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          TextField(
            controller: _totalBillController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: moneyStyle(fontSize: 20, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              prefixText: '${AppConstants.currencySymbol} ',
              hintText: '0',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),

          // Number of People Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NUMBER OF PEOPLE',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: theme.colorScheme.primary,
                ),
              ),
              Row(
                children: [
                  IconButton.filledTonal(
                    icon: const Icon(Icons.remove_rounded, size: 18),
                    onPressed: _numPeople > 2
                        ? () => _updatePeopleCount(_numPeople - 1)
                        : null,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Text(
                    '$_numPeople',
                    style: moneyStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: Spacing.sm),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.add_rounded, size: 18),
                    onPressed: _numPeople < 30
                        ? () => _updatePeopleCount(_numPeople + 1)
                        : null,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),

          // Tip & Tax Chips
          Text(
            'TAX OR SERVICE CHARGE',
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Wrap(
            spacing: Spacing.xs,
            children: [
              for (final percent in [0.0, 5.0, 10.0, 12.0])
                ChoiceChip(
                  label: Text('${percent.toStringAsFixed(0)}%'),
                  selected: _tipTaxPercent == percent,
                  onSelected: (selected) {
                    if (selected) {
                      HapticFeedback.selectionClick();
                      setState(() => _tipTaxPercent = percent);
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: Spacing.md),

          // Expense Label
          TextField(
            controller: _noteController,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Bill memo (e.g. Ramen dinner, Samgyup, Airbnb)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: Spacing.xl),

          // Actions
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: StashColors.tealAccent,
              foregroundColor: StashColors.base,
              padding: const EdgeInsets.symmetric(vertical: Spacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: Text(
              'Save ${_numPeople - 1} Receivables to Hermanos',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            onPressed: _billAmount > 0 ? _saveAsReceivables : null,
          ),
          const SizedBox(height: Spacing.lg),
        ],
      ),
    );
  }
}
