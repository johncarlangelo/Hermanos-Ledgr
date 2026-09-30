import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/app.dart';
import 'package:hermanos_ledgr/core/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  setGlobalSharedPreferences(prefs);

  // If the user already finished onboarding (or hasn't explicitly reset it),
  // ensure onboarding is marked as complete so it does not bounce back.
  if (prefs.getBool('has_completed_onboarding') != false) {
    await prefs.setBool('has_completed_onboarding', true);
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const HermanosLedgrApp(),
    ),
  );
}
