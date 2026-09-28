import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemePrefKey = 'user_theme_mode';

class ThemeNotifier extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() {
    _loadTheme();
    return AppThemeMode.dark;
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeIndex = prefs.getInt(_kThemePrefKey);
      if (savedThemeIndex != null &&
          savedThemeIndex >= 0 &&
          savedThemeIndex < AppThemeMode.values.length) {
        state = AppThemeMode.values[savedThemeIndex];
      }
    } catch (_) {
      // Fallback to default
    }
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kThemePrefKey, mode.index);
    } catch (_) {}
  }
}

final themeProvider =
    NotifierProvider<ThemeNotifier, AppThemeMode>(ThemeNotifier.new);

final activeThemeDataProvider = Provider<ThemeData>((ref) {
  final mode = ref.watch(themeProvider);
  switch (mode) {
    case AppThemeMode.light:
      return AppTheme.light();
    case AppThemeMode.dark:
      return AppTheme.dark();
    case AppThemeMode.amoled:
      return AppTheme.amoled();
    case AppThemeMode.system:
      return AppTheme.dark();
  }
});
