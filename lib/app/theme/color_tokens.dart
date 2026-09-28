import 'package:flutter/material.dart';

/// Semantic colors for financial tracking in Hermanos Ledgr.
/// Adheres strictly to DESIGN.md and flutter-m3-premium-design skill.
class SemanticColors {
  SemanticColors._();

  // Income — positive, green
  static const incomeLight = Color(0xFF2E7D32); // Green 800
  static const incomeDark = Color(0xFF81C784); // Green 300

  // Expense — clear red, not alarming
  static const expenseLight = Color(0xFFC62828); // Red 800
  static const expenseDark = Color(0xFFEF9A9A); // Red 200

  // Transfer — neutral action blue
  static const transferLight = Color(0xFF1565C0); // Blue 800
  static const transferDark = Color(0xFF64B5F6); // Blue 300

  // Warning / Due — orange
  static const warningLight = Color(0xFFE65100); // Orange 900
  static const warningDark = Color(0xFFFFB74D); // Orange 300

  // Budget progress status
  static const budgetSafeLight = Color(0xFF2E7D32);
  static const budgetSafeDark = Color(0xFF66BB6A); // < 75%

  static const budgetCautionLight = Color(0xFFEF6C00);
  static const budgetCautionDark = Color(0xFFFFA726); // 75% - 100%

  static const budgetOverLight = Color(0xFFC62828);
  static const budgetOverDark = Color(0xFFEF5350); // > 100%

  // Helper getters depending on brightness
  static Color income(bool isDark) => isDark ? incomeDark : incomeLight;
  static Color expense(bool isDark) => isDark ? expenseDark : expenseLight;
  static Color transfer(bool isDark) => isDark ? transferDark : transferLight;
  static Color warning(bool isDark) => isDark ? warningDark : warningLight;
  static Color budgetSafe(bool isDark) =>
      isDark ? budgetSafeDark : budgetSafeLight;
  static Color budgetCaution(bool isDark) =>
      isDark ? budgetCautionDark : budgetCautionLight;
  static Color budgetOver(bool isDark) =>
      isDark ? budgetOverDark : budgetOverLight;
}

/// Spacing scale based on 4dp grid system.
class Spacing {
  Spacing._();

  static const double xs = 4.0; // Icon-to-text gap
  static const double sm = 8.0; // Intra-component spacing, chip spacing
  static const double md = 12.0; // List item vertical spacing, form fields
  static const double lg = 16.0; // Screen padding, card internal padding
  static const double xl = 24.0; // Vertical spacing between major sections
  static const double xxl = 32.0; // Major section gaps
  static const double xxxl = 48.0; // Screen bottom padding / FAB buffer
}
