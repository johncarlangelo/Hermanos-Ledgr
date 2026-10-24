import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Text theme for Hermanos Ledgr using Google Fonts Inter.
/// Adheres strictly to DESIGN.md and flutter-m3-premium-design skill.
///
/// Every role enables [FontFeature.tabularFigures] (DESIGN.md 3.1: "Inter with
/// tabular figures") so any digit — monetary or not — keeps a uniform width.
TextTheme buildTextTheme(TextTheme base, {Color? textColor}) {
  const tabular = [FontFeature.tabularFigures()];

  return GoogleFonts.interTextTheme(base).copyWith(
    // Kept at M3 base sizes; only tabular figures are added.
    displayLarge: GoogleFonts.inter(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      color: textColor,
      fontFeatures: tabular,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      color: textColor,
      fontFeatures: tabular,
    ),
    // Net worth hero number, big total
    displaySmall: GoogleFonts.inter(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
      color: textColor,
      fontFeatures: tabular,
    ),
    // Screen headers
    headlineLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
      color: textColor,
      fontFeatures: tabular,
    ),
    // Section headers
    headlineMedium: GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w500,
      color: textColor,
      fontFeatures: tabular,
    ),
    // Group headers, bottom sheet titles
    headlineSmall: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      color: textColor,
      fontFeatures: tabular,
    ),
    // Account card balances
    titleLarge: GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: textColor,
      fontFeatures: tabular,
    ),
    // Transaction list amounts, card titles
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: textColor,
      fontFeatures: tabular,
    ),
    // Category labels, chip text
    titleSmall: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: textColor,
      fontFeatures: tabular,
    ),
    // Form inputs, notes
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: textColor,
      fontFeatures: tabular,
    ),
    // Secondary list text, timestamps
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: textColor,
      fontFeatures: tabular,
    ),
    // Micro-captions, percentage text
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: textColor,
      fontFeatures: tabular,
    ),
    // Buttons, action links
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: textColor,
      fontFeatures: tabular,
    ),
    // Badges, micro tags
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: textColor,
      fontFeatures: tabular,
    ),
  );
}

/// Helper extension or style generator for monetary figures
TextStyle moneyStyle({
  required double fontSize,
  FontWeight fontWeight = FontWeight.w600,
  Color? color,
  double? letterSpacing,
}) {
  return GoogleFonts.inter(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
