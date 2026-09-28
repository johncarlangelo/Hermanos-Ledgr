/// App-wide ThemeData based on the Stitch neumorphic design system.
/// Font: Plus Jakarta Sans (from Stitch design tokens)
/// Shadow: 5px 5px 10px #BEBEBE, -5px -5px 10px #FFFFFF
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        tertiary: AppColors.tertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.background,
        onSurface: AppColors.onSurface,
        surfaceContainerHighest: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        inverseSurface: AppColors.inverseSurface,
        onInverseSurface: AppColors.inverseOnSurface,
        inversePrimary: AppColors.inversePrimary,
      ),
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _plusJakarta(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: _plusJakarta(
          color: AppColors.onSurfaceVariant,
          fontSize: 14,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        shape: CircleBorder(),
      ),
    );
  }

  // ── Text Theme (from Stitch design tokens) ──
  static TextTheme get _textTheme {
    return TextTheme(
      // numeric-lg: 32px, -0.03em tracking, 700 weight
      displayLarge: _plusJakarta(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textCharcoal,
        letterSpacing: -0.96, // -0.03em * 32
        height: 40 / 32,
      ),
      // headline-lg: 28px, -0.02em tracking, 700 weight
      displayMedium: _plusJakarta(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textCharcoal,
        letterSpacing: -0.56, // -0.02em * 28
        height: 36 / 28,
      ),
      // headline-lg-mobile: 24px, 700 weight
      headlineLarge: _plusJakarta(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textCharcoal,
        height: 32 / 24,
      ),
      // headline-md: 20px, 600 weight
      headlineMedium: _plusJakarta(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textCharcoal,
        height: 28 / 20,
      ),
      // body-lg: 16px, 500 weight
      titleLarge: _plusJakarta(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textCharcoal,
        height: 24 / 16,
      ),
      // body-md: 14px, 400 weight
      bodyLarge: _plusJakarta(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textCharcoal,
        height: 20 / 14,
      ),
      bodyMedium: _plusJakarta(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceVariant,
        height: 20 / 14,
      ),
      // label-caps: 12px, 0.05em tracking, 700 weight
      labelLarge: _plusJakarta(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurfaceVariant,
        letterSpacing: 0.6, // 0.05em * 12
        height: 16 / 12,
      ),
      labelMedium: _plusJakarta(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurfaceVariant,
        height: 16 / 12,
      ),
    );
  }

  /// Helper to create Plus Jakarta Sans text style via Google Fonts.
  static TextStyle _plusJakarta({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
}
