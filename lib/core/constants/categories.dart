/// Predefined transaction categories with icons and colors.
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CategoryData {
  final String name;
  final IconData icon;
  final Color color;

  const CategoryData({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class Categories {
  Categories._();

  static const List<CategoryData> expense = [
    CategoryData(name: 'Food & Dining', icon: Icons.restaurant_rounded, color: Color(0xFFFF7043)),
    CategoryData(name: 'Transportation', icon: Icons.directions_car_rounded, color: Color(0xFF42A5F5)),
    CategoryData(name: 'Shopping', icon: Icons.shopping_bag_rounded, color: Color(0xFFAB47BC)),
    CategoryData(name: 'Entertainment', icon: Icons.movie_rounded, color: Color(0xFFEF5350)),
    CategoryData(name: 'Bills & Utilities', icon: Icons.receipt_long_rounded, color: Color(0xFF66BB6A)),
    CategoryData(name: 'Health', icon: Icons.local_hospital_rounded, color: Color(0xFF26A69A)),
    CategoryData(name: 'Education', icon: Icons.school_rounded, color: Color(0xFF5C6BC0)),
    CategoryData(name: 'Personal Care', icon: Icons.spa_rounded, color: Color(0xFFEC407A)),
    CategoryData(name: 'Groceries', icon: Icons.local_grocery_store_rounded, color: Color(0xFF8D6E63)),
    CategoryData(name: 'Subscriptions', icon: Icons.autorenew_rounded, color: Color(0xFF7E57C2)),
    CategoryData(name: 'Other', icon: Icons.more_horiz_rounded, color: AppColors.textSecondary),
  ];

  static const List<CategoryData> income = [
    CategoryData(name: 'Income', icon: Icons.account_balance_wallet_rounded, color: AppColors.income),
    CategoryData(name: 'Salary', icon: Icons.work_rounded, color: Color(0xFF43A047)),
    CategoryData(name: 'Freelance', icon: Icons.laptop_mac_rounded, color: Color(0xFF00897B)),
    CategoryData(name: 'Gift', icon: Icons.card_giftcard_rounded, color: Color(0xFFE91E63)),
    CategoryData(name: 'Refund', icon: Icons.replay_rounded, color: Color(0xFF1E88E5)),
    CategoryData(name: 'Other Income', icon: Icons.attach_money_rounded, color: Color(0xFF66BB6A)),
  ];

  static List<CategoryData> get all => [...expense, ...income];

  static CategoryData findByName(String name) {
    return all.firstWhere(
      (c) => c.name == name,
      orElse: () => expense.last,
    );
  }
}
