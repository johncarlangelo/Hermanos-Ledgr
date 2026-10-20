import 'package:flutter/material.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';

/// Clean starter accounts with zero balances for initial setup and ledger reset.
class AccountDefaults {
  AccountDefaults._();

  static const List<AccountModel> starterCleanAccounts = [
    AccountModel(
      id: 'acc_gcash',
      name: 'GCash',
      type: AccountType.eWallet,
      balance: 0.0,
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF005CEE),
      institution: 'Mynt',
      monthlyChange: 0.0,
    ),
    AccountModel(
      id: 'acc_cash',
      name: 'Cash Wallet',
      type: AccountType.cash,
      balance: 0.0,
      icon: Icons.payments_rounded,
      color: Color(0xFF00897B),
      institution: 'Cash',
      monthlyChange: 0.0,
    ),
    AccountModel(
      id: 'acc_bdo',
      name: 'BDO Savings',
      type: AccountType.bank,
      balance: 0.0,
      icon: Icons.account_balance_rounded,
      color: Color(0xFF0038A8),
      institution: 'BDO Unibank',
      monthlyChange: 0.0,
    ),
  ];
}
