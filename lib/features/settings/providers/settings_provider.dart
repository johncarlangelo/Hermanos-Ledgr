import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kHapticsKey = 'pref_haptics_enabled';
const _kCompactNumbersKey = 'pref_compact_numbers';
const _kDefaultTabKey = 'pref_default_tab';

class UserPreferencesState {
  final bool hapticsEnabled;
  final bool compactNumbers;
  final int defaultLandingTab;
  final bool isLoading;

  const UserPreferencesState({
    this.hapticsEnabled = true,
    this.compactNumbers = false,
    this.defaultLandingTab = 0,
    this.isLoading = false,
  });

  UserPreferencesState copyWith({
    bool? hapticsEnabled,
    bool? compactNumbers,
    int? defaultLandingTab,
    bool? isLoading,
  }) {
    return UserPreferencesState(
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      compactNumbers: compactNumbers ?? this.compactNumbers,
      defaultLandingTab: defaultLandingTab ?? this.defaultLandingTab,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class UserPreferencesNotifier extends Notifier<UserPreferencesState> {
  @override
  UserPreferencesState build() {
    _loadPreferences();
    return const UserPreferencesState();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = state.copyWith(
        hapticsEnabled: prefs.getBool(_kHapticsKey) ?? true,
        compactNumbers: prefs.getBool(_kCompactNumbersKey) ?? false,
        defaultLandingTab: prefs.getInt(_kDefaultTabKey) ?? 0,
        isLoading: false,
      );
    } catch (_) {}
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    state = state.copyWith(hapticsEnabled: enabled);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kHapticsKey, enabled);
    } catch (_) {}
  }

  Future<void> setCompactNumbers(bool enabled) async {
    state = state.copyWith(compactNumbers: enabled);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kCompactNumbersKey, enabled);
    } catch (_) {}
  }

  Future<void> setDefaultLandingTab(int tabIndex) async {
    state = state.copyWith(defaultLandingTab: tabIndex);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kDefaultTabKey, tabIndex);
    } catch (_) {}
  }
}

final userPreferencesProvider =
    NotifierProvider<UserPreferencesNotifier, UserPreferencesState>(
  UserPreferencesNotifier.new,
);
