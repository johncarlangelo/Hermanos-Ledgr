import 'package:flutter/material.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/accounts/presentation/widgets/personalized_card.dart';

class AccountCard extends StatelessWidget {
  final AccountModel account;
  final VoidCallback? onTap;

  const AccountCard({
    super.key,
    required this.account,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PersonalizedCard(
      account: account,
      onTap: onTap,
    );
  }
}
