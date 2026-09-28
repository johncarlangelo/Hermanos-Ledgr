import 'package:flutter/material.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';

enum AppThemeMode {
  system,
  light,
  dark,
  amoled,
}

class AppTheme {
  AppTheme._();

  // Hermanos-Stash Teal Seed
  static const Color seedColor = Color(0xFF00897B); // Stash Teal

  // Light Color Scheme (Fresh slate with Teal accents)
  static final ColorScheme lightScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  );

  // Dark Color Scheme (Hermanos-Stash "Deep Space Glass" surfaces)
  static final ColorScheme darkScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  ).copyWith(
    surface: const Color(0xFF08090D), // Stash Base
    surfaceContainerLowest: const Color(0xFF050608),
    surfaceContainerLow: const Color(0xFF0B0D13), // Stash Shell
    surfaceContainer: const Color(0xFF12151E), // Stash Surface (Cards)
    surfaceContainerHigh: const Color(0xFF1A1F2B), // Stash Raised (Modals)
    surfaceContainerHighest: const Color(0xFF212736), // Stash Overlay (Sheets)
    outline: const Color(0xFF232A38), // Stash Line
    outlineVariant: const Color(0xFF354055), // Stash Line Strong
    onSurface: const Color(0xFFECEEF4), // Stash Ink
    onSurfaceVariant: const Color(0xFF9BA5BA), // Stash Dim
    primary: const Color(0xFF7FB8AE), // Stash Teal Accent
    onPrimary: const Color(0xFF0E2320),
    primaryContainer: const Color(0xFF163833), // Deep Teal Tint
    onPrimaryContainer: const Color(0xFFA5E6DC),
    secondaryContainer: const Color(0xFF1A2624),
    onSecondaryContainer: const Color(0xFF88D8CB),
  );

  // AMOLED Color Scheme (Samsung True Black #000000 with Stash depth)
  static final ColorScheme amoledScheme = darkScheme.copyWith(
    surface: const Color(0xFF000000), // Pure OLED Black
    surfaceContainerLowest: const Color(0xFF000000),
    surfaceContainerLow: const Color(0xFF06080B),
    surfaceContainer: const Color(0xFF0C1017),
    surfaceContainerHigh: const Color(0xFF141923),
    surfaceContainerHighest: const Color(0xFF1C222E),
    outline: const Color(0xFF1D2330),
    outlineVariant: const Color(0xFF2B3446),
    onSurface: const Color(0xFFECEEF4),
    onSurfaceVariant: const Color(0xFF9BA5BA),
    primary: const Color(0xFF7FB8AE),
    onPrimary: const Color(0xFF0E2320),
    primaryContainer: const Color(0xFF163833),
    onPrimaryContainer: const Color(0xFFA5E6DC),
  );

  static ThemeData light() {
    return _buildTheme(lightScheme);
  }

  static ThemeData dark() {
    return _buildTheme(darkScheme);
  }

  static ThemeData amoled() {
    return _buildTheme(amoledScheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final baseTextTheme =
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    final textTheme = buildTextTheme(
      baseTextTheme,
      textColor: colorScheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: colorScheme.surfaceContainer,
        margin: EdgeInsets.zero,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        modalBackgroundColor: colorScheme.surfaceContainerHighest,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
        dragHandleColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        dragHandleSize: const Size(32, 4),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 66,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              fontSize: 11,
              letterSpacing: -0.2,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            );
          }
          return textTheme.labelSmall?.copyWith(
            fontSize: 11,
            letterSpacing: -0.2,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: colorScheme.onPrimaryContainer,
              size: 22,
            );
          }
          return IconThemeData(
            color: colorScheme.onSurfaceVariant,
            size: 22,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        actionTextColor: colorScheme.inversePrimary,
        elevation: 4,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(color: colorScheme.outlineVariant),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
