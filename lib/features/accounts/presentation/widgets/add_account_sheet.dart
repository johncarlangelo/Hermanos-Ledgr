import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/constants/app_constants.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/accounts/providers/mock_accounts_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Custom bottom sheet for adding a new bank, e-wallet, or custom account.
class AddAccountSheet extends ConsumerStatefulWidget {
  const AddAccountSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const AddAccountSheet(),
    );
  }

  @override
  ConsumerState<AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends ConsumerState<AddAccountSheet> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController(text: '0.00');
  AccountType _selectedType = AccountType.bank;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _saveAccount() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      UndoSnackbar.error(context, message: 'Please enter an account name');
      return;
    }

    final balanceText = _balanceController.text.replaceAll(',', '').trim();
    final balance = double.tryParse(balanceText) ?? 0.0;

    final icon = switch (_selectedType) {
      AccountType.bank => Icons.account_balance_rounded,
      AccountType.eWallet => Icons.wallet_rounded,
      AccountType.cash => Icons.payments_rounded,
      AccountType.creditCard => Icons.credit_card_rounded,
    };

    final color = switch (_selectedType) {
      AccountType.bank => const Color(0xFF1E88E5),
      AccountType.eWallet => const Color(0xFF00897B),
      AccountType.cash => const Color(0xFF43A047),
      AccountType.creditCard => const Color(0xFFE53935),
    };

    final newAccount = AccountModel(
      id: 'acc_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: _selectedType,
      balance: balance,
      icon: icon,
      color: color,
      institution: name,
      monthlyChange: 0.0,
    );

    ref.read(accountsProvider.notifier).addAccount(newAccount);
    Navigator.of(context).pop();

    UndoSnackbar.info(
      context,
      message: 'Added $name to your ledger',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.md,
        Spacing.lg,
        Spacing.xl + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(Spacing.sm),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.add_card_rounded,
                      size: 22,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Text(
                    'Add Account / Wallet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),

          // Account Name
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Account or Provider Name',
              hintText: 'e.g. SeaBank, GoTyme, UnionBank, PayPal',
              prefixIcon: Icon(Icons.account_balance_outlined),
            ),
          ),
          const SizedBox(height: Spacing.md),

          // Account Type Selector
          Text(
            'Account Type',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Row(
            children: [
              _buildTypeOption(
                label: 'Bank',
                icon: Icons.account_balance_rounded,
                type: AccountType.bank,
                theme: theme,
              ),
              const SizedBox(width: Spacing.xs),
              _buildTypeOption(
                label: 'E-Wallet',
                icon: Icons.wallet_rounded,
                type: AccountType.eWallet,
                theme: theme,
              ),
              const SizedBox(width: Spacing.xs),
              _buildTypeOption(
                label: 'Cash',
                icon: Icons.payments_rounded,
                type: AccountType.cash,
                theme: theme,
              ),
              const SizedBox(width: Spacing.xs),
              _buildTypeOption(
                label: 'Credit',
                icon: Icons.credit_card_rounded,
                type: AccountType.creditCard,
                theme: theme,
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),

          // Initial Balance
          TextField(
            controller: _balanceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: moneyStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              labelText: 'Starting Balance',
              prefixText: '${AppConstants.currencySymbol} ',
              prefixStyle: moneyStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: Spacing.xl),

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
                child: FilledButton(
                  onPressed: _saveAccount,
                  child: const Text('Save Account'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption({
    required String label,
    required IconData icon,
    required AccountType type,
    required ThemeData theme,
  }) {
    final isSelected = _selectedType == type;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedType = type),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
