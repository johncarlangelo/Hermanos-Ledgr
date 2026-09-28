import 'package:flutter/material.dart';

class CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isExpense;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isExpense = true,
  });
}

class CategoryDefaults {
  CategoryDefaults._();

  static const List<CategoryItem> defaultCategories = [
    // Expenses
    CategoryItem(
      id: 'food',
      name: 'Food & Dining',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFF57C00), // Deep orange
      isExpense: true,
    ),
    CategoryItem(
      id: 'groceries',
      name: 'Groceries',
      icon: Icons.shopping_cart_rounded,
      color: Color(0xFF43A047), // Green
      isExpense: true,
    ),
    CategoryItem(
      id: 'transport',
      name: 'Transportation',
      icon: Icons.directions_bus_rounded,
      color: Color(0xFF1E88E5), // Blue
      isExpense: true,
    ),
    CategoryItem(
      id: 'utilities',
      name: 'Utilities & Bills',
      icon: Icons.bolt_rounded,
      color: Color(0xFFFBC02D), // Amber
      isExpense: true,
    ),
    CategoryItem(
      id: 'housing',
      name: 'Housing & Rent',
      icon: Icons.home_rounded,
      color: Color(0xFF8E24AA), // Purple
      isExpense: true,
    ),
    CategoryItem(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFE91E63), // Pink
      isExpense: true,
    ),
    CategoryItem(
      id: 'health',
      name: 'Healthcare',
      icon: Icons.medical_services_rounded,
      color: Color(0xFFE53935), // Red
      isExpense: true,
    ),
    CategoryItem(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie_filter_rounded,
      color: Color(0xFF00ACC1), // Cyan
      isExpense: true,
    ),
    CategoryItem(
      id: 'personal',
      name: 'Personal Care',
      icon: Icons.face_rounded,
      color: Color(0xFF3949AB), // Indigo
      isExpense: true,
    ),
    CategoryItem(
      id: 'other_expense',
      name: 'Other',
      icon: Icons.more_horiz_rounded,
      color: Color(0xFF757575), // Grey
      isExpense: true,
    ),

    // Incomes
    CategoryItem(
      id: 'salary',
      name: 'Salary',
      icon: Icons.payments_rounded,
      color: Color(0xFF2E7D52), // Stash green
      isExpense: false,
    ),
    CategoryItem(
      id: 'freelance',
      name: 'Side Hustle',
      icon: Icons.laptop_chromebook_rounded,
      color: Color(0xFF00897B), // Teal
      isExpense: false,
    ),
    CategoryItem(
      id: 'investments',
      name: 'Investments',
      icon: Icons.trending_up_rounded,
      color: Color(0xFF1565C0), // Royal blue
      isExpense: false,
    ),
    CategoryItem(
      id: 'gift_income',
      name: 'Gifts & Allowance',
      icon: Icons.card_giftcard_rounded,
      color: Color(0xFFD81B60), // Vibrant pink
      isExpense: false,
    ),
    CategoryItem(
      id: 'other_income',
      name: 'Other Income',
      icon: Icons.attach_money_rounded,
      color: Color(0xFF689F38), // Light olive green
      isExpense: false,
    ),
  ];

  static CategoryItem findById(String id) {
    return defaultCategories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => const CategoryItem(
        id: 'unknown',
        name: 'General',
        icon: Icons.category_rounded,
        color: Color(0xFF757575),
      ),
    );
  }
}
