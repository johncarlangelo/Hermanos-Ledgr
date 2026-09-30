import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences? _injectedPrefs;

void setGlobalSharedPreferences(SharedPreferences prefs) {
  _injectedPrefs = prefs;
}

/// Provider for SharedPreferences instance, pre-loaded in main()
/// to ensure synchronous, zero-latency access across the entire app.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  if (_injectedPrefs != null) {
    return _injectedPrefs!;
  }
  throw UnimplementedError('sharedPreferencesProvider must be overridden in ProviderScope');
});
