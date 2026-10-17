import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/accounts/presentation/widgets/add_account_sheet.dart';
import 'package:hermanos_ledgr/features/accounts/presentation/widgets/personalized_card.dart';
import 'package:hermanos_ledgr/features/accounts/providers/accounts_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/hero_amount_display.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';

enum AccountTypeFilter { all, bank, eWallet, cash, creditCard }

/// Full dedicated screen for managing, organizing, and inspecting accounts & wallets.
class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  AccountTypeFilter _filter = AccountTypeFilter.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final accounts = ref.watch(accountsProvider);
    final netWorth = ref.watch(netWorthProvider);
    final totalAssets = ref.watch(totalAssetsProvider);
    final totalLiabilities = ref.watch(totalLiabilitiesProvider);

    final filteredAccounts = accounts.where((a) {
      switch (_filter) {
        case AccountTypeFilter.all:
          return true;
        case AccountTypeFilter.bank:
          return a.type == AccountType.bank;
        case AccountTypeFilter.eWallet:
          return a.type == AccountType.eWallet;
        case AccountTypeFilter.cash:
          return a.type == AccountType.cash;
        case AccountTypeFilter.creditCard:
          return a.type == AccountType.creditCard;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Accounts & Wallets',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Account',
            onPressed: () => AddAccountSheet.show(context),
          ),
          const SizedBox(width: Spacing.xs),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddAccountSheet.show(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Account'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: CustomScrollView(
        slivers: [
          // 1. Portfolio Net Worth Hero Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                Spacing.sm,
                Spacing.lg,
                Spacing.md,
              ),
              child: M3Card(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeroAmountDisplay(
                      label: 'Total Net Worth',
                      amount: netWorth,
                    ),
                    const SizedBox(height: Spacing.md),
                    const Divider(height: 1, thickness: 0.5),
                    const SizedBox(height: Spacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Assets',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(totalAssets),
                              style: moneyStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: SemanticColors.income(isDark),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total Liabilities',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(totalLiabilities),
                              style: moneyStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: SemanticColors.expense(isDark),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Filter Chips Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'All (${accounts.length})',
                      filter: AccountTypeFilter.all,
                      theme: theme,
                    ),
                    const SizedBox(width: Spacing.xs),
                    _buildFilterChip(
                      label: 'Banks (${accounts.where((a) => a.type == AccountType.bank).length})',
                      filter: AccountTypeFilter.bank,
                      theme: theme,
                    ),
                    const SizedBox(width: Spacing.xs),
                    _buildFilterChip(
                      label: 'E-Wallets (${accounts.where((a) => a.type == AccountType.eWallet).length})',
                      filter: AccountTypeFilter.eWallet,
                      theme: theme,
                    ),
                    const SizedBox(width: Spacing.xs),
                    _buildFilterChip(
                      label: 'Cash (${accounts.where((a) => a.type == AccountType.cash).length})',
                      filter: AccountTypeFilter.cash,
                      theme: theme,
                    ),
                    const SizedBox(width: Spacing.xs),
                    _buildFilterChip(
                      label: 'Cards (${accounts.where((a) => a.type == AccountType.creditCard).length})',
                      filter: AccountTypeFilter.creditCard,
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: Spacing.md),
          ),

          // 3. Accounts List or Empty State
          if (filteredAccounts.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: Spacing.md),
                      Text(
                        'No accounts found',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        'Tap the button below to add your first account or wallet.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: Spacing.lg),
                      FilledButton.icon(
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Account'),
                        onPressed: () => AddAccountSheet.show(context),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final account = filteredAccounts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.sm),
                      child: _buildAccountCardItem(
                        context: context,
                        theme: theme,
                        isDark: isDark,
                        account: account,
                      ),
                    );
                  },
                  childCount: filteredAccounts.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: Spacing.xxxl * 2), // Spacing for FAB
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCardItem({
    required BuildContext context,
    required ThemeData theme,
    required bool isDark,
    required AccountModel account,
  }) {
    final dangerColor = SemanticColors.expense(isDark);

    return M3Card(
      onTap: () => context.push('/accounts/${account.id}'),
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
        children: [
          // Mini Personalized Card thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 76,
              height: 48,
              child: FittedBox(
                fit: BoxFit.cover,
                child: PersonalizedCard(
                  account: account,
                  width: 224,
                  height: 138,
                ),
              ),
            ),
          ),
          const SizedBox(width: Spacing.md),

          // Name and Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        account.typeLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (account.institution != null &&
                        account.institution!.isNotEmpty &&
                        account.institution != account.name) ...[
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '• ${account.institution}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Balance & Chevron
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(account.balance),
                style: moneyStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: account.balance < 0
                      ? dangerColor
                      : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required AccountTypeFilter filter,
    required ThemeData theme,
  }) {
    final isSelected = _filter == filter;

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface,
      ),
      selectedColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide.none,
      onSelected: (_) => setState(() => _filter = filter),
    );
  }
}
