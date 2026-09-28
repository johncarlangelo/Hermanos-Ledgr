import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Text theme for Hermanos Ledgr using Google Fonts Inter.
/// Adheres strictly to DESIGN.md and flutter-m3-premium-design skill.
TextTheme buildTextTheme(TextTheme base, {Color? textColor}) {
  final inter = GoogleFonts.interTextTheme(base);

  return inter.copyWith(
    // Net worth hero number, big total
    displaySmall: GoogleFonts.inter(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
      color: textColor,
      fontFeatures: const [FontFeature.tabularFigures()],
    ),
    // Screen headers
    headlineLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
      color: textColor,
    ),
    // Section headers
    headlineMedium: GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
    // Group headers, bottom sheet titles
    headlineSmall: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
    // Account card balances
    titleLarge: GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: textColor,
      fontFeatures: const [FontFeature.tabularFigures()],
    ),
    // Transaction list amounts, card titles
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: textColor,
      fontFeatures: const [FontFeature.tabularFigures()],
    ),
    // Category labels, chip text
    titleSmall: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: textColor,
    ),
    // Form inputs, notes
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: textColor,
    ),
    // Secondary list text, timestamps
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: textColor,
    ),
    // Micro-captions, percentage text
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: textColor,
    ),
    // Buttons, action links
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: textColor,
    ),
    // Badges, micro tags
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: textColor,
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
