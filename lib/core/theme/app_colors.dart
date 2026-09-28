/// Color palette extracted from the Stitch neumorphic design system.
/// Source: Tarsi Neumorphic Budget Tracker (Stitch Project #8386851386472986772)
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Neumorphic Surface (from Stitch design tokens) ──
  static const Color background = Color(0xFFF0F0F3);       // Main background
  static const Color surface = Color(0xFFF9F9FC);           // Card surface
  static const Color surfaceContainerLow = Color(0xFFF3F3F6);
  static const Color surfaceContainer = Color(0xFFEDEEF1);
  static const Color surfaceContainerHigh = Color(0xFFE8E8EB);
  static const Color surfaceVariant = Color(0xFFE2E2E5);

  // ── Neumorphic Shadow Pair ──
  static const Color shadowDark = Color(0xFFBEBEBE);       // Bottom-right shadow
  static const Color shadowLight = Color(0xFFFFFFFF);       // Top-left highlight

  // ── Primary (Green) ──
  static const Color primary = Color(0xFF2E673A);           // Primary green
  static const Color primaryContainer = Color(0xFF478151);  // Primary container
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFF7FFF3);
  static const Color primaryFixed = Color(0xFFB3F2B8);
  static const Color primaryFixedDim = Color(0xFF98D59D);
  static const Color inversePrimary = Color(0xFF98D59D);

  // ── Secondary ──
  static const Color secondary = Color(0xFF585F6C);
  static const Color secondaryContainer = Color(0xFFDCE2F3);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // ── Tertiary ──
  static const Color tertiary = Color(0xFF8C455A);
  static const Color tertiaryContainer = Color(0xFFAA5D72);

  // ── Error ──
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF93000A);

  // ── Text / On-surface ──
  static const Color textCharcoal = Color(0xFF2D2D2D);      // Primary text
  static const Color onSurface = Color(0xFF1A1C1E);
  static const Color onSurfaceVariant = Color(0xFF414940);   // Secondary text
  static const Color onBackground = Color(0xFF1A1C1E);

  // ── Outline ──
  static const Color outline = Color(0xFF71796F);
  static const Color outlineVariant = Color(0xFFC0C9BD);

  // ── Inverse ──
  static const Color inverseSurface = Color(0xFF2F3133);
  static const Color inverseOnSurface = Color(0xFFF0F0F3);

  // ── Semantic Colors (for transactions) ──
  static const Color income = Color(0xFF2E673A);            // Green (matches primary)
  static const Color expense = Color(0xFFBA1A1A);           // Red (matches error)
  static const Color warning = Color(0xFFF9A825);
  static const Color success = Color(0xFF388E3C);
}
