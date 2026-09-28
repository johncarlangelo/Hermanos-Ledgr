import 'package:flutter/material.dart';

enum AccountType {
  cash,
  bank,
  eWallet,
  creditCard,
}

class AccountModel {
  final String id;
  final String name;
  final AccountType type;
  final double balance;
  final IconData icon;
  final Color color;
  final String? institution;
  final double monthlyChange;

  const AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.icon,
    required this.color,
    this.institution,
    this.monthlyChange = 0.0,
  });

  AccountModel copyWith({
    String? id,
    String? name,
    AccountType? type,
    double? balance,
    IconData? icon,
    Color? color,
    String? institution,
    double? monthlyChange,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      institution: institution ?? this.institution,
      monthlyChange: monthlyChange ?? this.monthlyChange,
    );
  }

  String get typeLabel {
    switch (type) {
      case AccountType.cash:
        return 'Cash';
      case AccountType.bank:
        return 'Bank Account';
      case AccountType.eWallet:
        return 'E-Wallet';
      case AccountType.creditCard:
        return 'Credit Card';
    }
  }
}
