import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/app.dart';
import 'package:hermanos_ledgr/core/providers/shared_preferences_provider.dart';
import 'package:hermanos_ledgr/core/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  setGlobalSharedPreferences(prefs);
  await NotificationService().initialize();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const HermanosLedgrApp(),
    ),
  );
}
