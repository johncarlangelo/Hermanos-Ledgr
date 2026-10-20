import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/constants/app_constants.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/accounts/domain/card_brand.dart';
import 'package:hermanos_ledgr/features/accounts/presentation/widgets/personalized_card.dart';
import 'package:hermanos_ledgr/features/accounts/providers/accounts_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Custom bottom sheet for adding or editing a bank, e-wallet, or cash account with live card preview.
class AddAccountSheet extends ConsumerStatefulWidget {
  final AccountModel? initialAccount;

  const AddAccountSheet({
    super.key,
    this.initialAccount,
  });

  static Future<void> show(BuildContext context, {AccountModel? account}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => AddAccountSheet(initialAccount: account),
    );
  }

  static Future<void> edit(BuildContext context, AccountModel account) {
    return show(context, account: account);
  }

  @override
  ConsumerState<AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends ConsumerState<AddAccountSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late AccountType _selectedType;

  bool get isEditing => widget.initialAccount != null;

  @override
  void initState() {
    super.initState();
    final acc = widget.initialAccount;
    _nameController = TextEditingController(text: acc?.name ?? '');
    _balanceController = TextEditingController(
      text: acc != null ? acc.balance.toStringAsFixed(2) : '0.00',
    );
    _selectedType = acc?.type ?? AccountType.bank;

    _nameController.addListener(_onTextChanged);
    _balanceController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_onTextChanged);
    _balanceController.removeListener(_onTextChanged);
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

    final brand = CardBrand.detect(name);
    final color = brand != CardBrand.custom
        ? brand.gradient.colors.first
        : switch (_selectedType) {
            AccountType.bank => const Color(0xFF1E88E5),
            AccountType.eWallet => const Color(0xFF00897B),
            AccountType.cash => const Color(0xFF43A047),
            AccountType.creditCard => const Color(0xFFE53935),
          };

    if (isEditing) {
      final updatedAccount = widget.initialAccount!.copyWith(
        name: name,
        type: _selectedType,
        balance: balance,
        icon: icon,
        color: color,
        institution: name,
      );

      ref.read(accountsProvider.notifier).updateAccount(updatedAccount);
      Navigator.of(context).pop();

      UndoSnackbar.success(
        context,
        message: 'Updated $name',
      );
    } else {
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

      UndoSnackbar.success(
        context,
        message: 'Added $name to your ledger',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final defaultPlaceholder = isEditing ? (widget.initialAccount?.name ?? 'Account') : 'New Account';
    final name = _nameController.text.trim().isEmpty ? defaultPlaceholder : _nameController.text.trim();
    final balance = double.tryParse(_balanceController.text.replaceAll(',', '').trim()) ?? 0.0;
    final brand = CardBrand.detect(name);

    final icon = switch (_selectedType) {
      AccountType.bank => Icons.account_balance_rounded,
      AccountType.eWallet => Icons.wallet_rounded,
      AccountType.cash => Icons.payments_rounded,
      AccountType.creditCard => Icons.credit_card_rounded,
    };

    final defaultColor = switch (_selectedType) {
      AccountType.bank => const Color(0xFF1E88E5),
      AccountType.eWallet => const Color(0xFF00897B),
      AccountType.cash => const Color(0xFF43A047),
      AccountType.creditCard => const Color(0xFFE53935),
    };

    final previewAccount = AccountModel(
      id: widget.initialAccount?.id ?? 'preview',
      name: name,
      type: _selectedType,
      balance: balance,
      icon: icon,
      color: brand != CardBrand.custom ? brand.gradient.colors.first : defaultColor,
      institution: name,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.md,
            Spacing.lg,
            Spacing.xl + bottomInset,
          ),
          child: Column(
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
                          isEditing ? Icons.edit_rounded : Icons.add_card_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Text(
                        isEditing ? 'Edit Account' : 'Add Account / Wallet',
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
              const SizedBox(height: Spacing.md),

              // Live Personalized Physical Card Preview
              Center(
                child: PersonalizedCard(
                  account: previewAccount,
                  width: 250,
                  height: 154,
                ),
              ),
              const SizedBox(height: Spacing.lg),

              // Quick Select Institution Preset Chips
              Text(
                'Quick Select Institution',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPresetChip('GCash', AccountType.eWallet),
                    _buildPresetChip('Maya', AccountType.eWallet),
                    _buildPresetChip('MariBank', AccountType.bank),
                    _buildPresetChip('GrabPay', AccountType.eWallet),
                    _buildPresetChip('ShopeePay', AccountType.eWallet),
                    _buildPresetChip('Tonik', AccountType.bank),
                    _buildPresetChip('CIMB', AccountType.bank),
                    _buildPresetChip('Coins.ph', AccountType.eWallet),
                    _buildPresetChip('Apple Cash', AccountType.eWallet),
                    _buildPresetChip('Google Wallet', AccountType.eWallet),
                    _buildPresetChip('BDO', AccountType.bank),
                    _buildPresetChip('BPI', AccountType.bank),
                    _buildPresetChip('UnionBank', AccountType.bank),
                    _buildPresetChip('GoTyme', AccountType.bank),
                    _buildPresetChip('Metrobank', AccountType.bank),
                    _buildPresetChip('Security Bank', AccountType.bank),
                    _buildPresetChip('RCBC', AccountType.bank),
                    _buildPresetChip('China Bank', AccountType.bank),
                    _buildPresetChip('LandBank', AccountType.bank),
                    _buildPresetChip('PSBank', AccountType.bank),
                    _buildPresetChip('UnoBank', AccountType.bank),
                    _buildPresetChip('Wise', AccountType.eWallet),
                    _buildPresetChip('PayPal', AccountType.eWallet),
                    _buildPresetChip('Venmo', AccountType.eWallet),
                    _buildPresetChip('Cash Wallet', AccountType.cash),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.md),

              // Account Name Input
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Account or Provider Name',
                  hintText: 'e.g. MariBank, Wise, GCash, PayPal',
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
                    label: 'Credit Card',
                    icon: Icons.credit_card_rounded,
                    type: AccountType.creditCard,
                    theme: theme,
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),

              // Initial Balance Input
              TextField(
                controller: _balanceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: isEditing ? 'Current Balance' : 'Initial Balance',
                  hintText: '0.00',
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
                      child: Text(isEditing ? 'Save Changes' : 'Save Account'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Widget _buildPresetChip(String name, AccountType type) {
    final isSelected = _nameController.text.toLowerCase().trim() == name.toLowerCase();
    final brand = CardBrand.detect(name);

    return Padding(
      padding: const EdgeInsets.only(right: Spacing.xs),
      child: FilterChip(
        selected: isSelected,
        label: Text(name),
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        selectedColor: brand.gradient.colors.first,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
        onSelected: (_) {
          setState(() {
            _nameController.text = name;
            _selectedType = type;
          });
        },
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
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.primary
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
