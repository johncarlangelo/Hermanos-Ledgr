import 'package:flutter/material.dart';

/// Design tokens and palette derived from Hermanos-Stash.
class StashColors {
  StashColors._();

  // Surfaces: base < shell < surface < raised < overlay
  static const base = Color(0xFF08090D);
  static const shell = Color(0xFF0B0D13);
  static const surface = Color(0xFF12151E);
  static const raised = Color(0xFF1A1F2B);
  static const overlay = Color(0xFF212736);

  // Lines
  static const line = Color(0xFF232A38);
  static const lineStrong = Color(0xFF354055);

  // Text
  static const ink = Color(0xFFECEEF4);
  static const dim = Color(0xFF9BA5BA);
  static const faint = Color(0xFF6D7789);

  // Teal Accent
  static const tealAccent = Color(0xFF7FB8AE);
  static const tealHover = Color(0xFF91C7BE);
  static const tealSoft = Color(0x247FB8AE);
  static const tealGlow = Color(0x597FB8AE);

  // Status
  static const ok = Color(0xFF7FC08D);
  static const warn = Color(0xFFD9BD72);
  static const danger = Color(0xFFE08373);
  static const steel = Color(0xFF7FA3C4);
}

/// Semantic colors for financial tracking in Hermanos Ledgr.
/// Harmonized with Hermanos-Stash status and accent tokens.
class SemanticColors {
  SemanticColors._();

  // Income — Stash Ok (#7FC08D)
  static const incomeLight = Color(0xFF2E7D52);
  static const incomeDark = Color(0xFF7FC08D);

  // Expense — Stash Danger (#E08373)
  static const expenseLight = Color(0xFFC8372D);
  static const expenseDark = Color(0xFFE08373);

  // Transfer — Stash Steel Blue (#7FA3C4)
  static const transferLight = Color(0xFF1E60B5);
  static const transferDark = Color(0xFF7FA3C4);

  // Warning / Due — Stash Warn (#D9BD72)
  static const warningLight = Color(0xFFB47805);
  static const warningDark = Color(0xFFD9BD72);

  // Budget progress status
  static const budgetSafeLight = Color(0xFF2E7D52);
  static const budgetSafeDark = Color(0xFF7FC08D); // < 75%

  static const budgetCautionLight = Color(0xFFB47805);
  static const budgetCautionDark = Color(0xFFD9BD72); // 75% - 100%

  static const budgetOverLight = Color(0xFFC8372D);
  static const budgetOverDark = Color(0xFFE08373); // > 100%

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
