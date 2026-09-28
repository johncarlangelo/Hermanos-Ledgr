import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/router.dart';
import 'package:hermanos_ledgr/core/providers/theme_provider.dart';

class HermanosLedgrApp extends ConsumerWidget {
  const HermanosLedgrApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(activeThemeDataProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Hermanos Ledgr',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      routerConfig: router,
    );
  }
}
