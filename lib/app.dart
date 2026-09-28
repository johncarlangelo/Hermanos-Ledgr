import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/login/login_screen.dart';
import 'navigation/app_shell.dart';

class HermanosLedgrApp extends StatefulWidget {
  const HermanosLedgrApp({super.key});

  @override
  State<HermanosLedgrApp> createState() => _HermanosLedgrAppState();
}

class _HermanosLedgrAppState extends State<HermanosLedgrApp> {
  bool _isLoggedIn = false;

  void _onLogin() => setState(() => _isLoggedIn = true);
  void _onSkip() => setState(() => _isLoggedIn = true);
  void _onLogout() => setState(() => _isLoggedIn = false);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hermanos Ledgr',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        child: _isLoggedIn
            ? AppShell(key: const ValueKey('shell'), onLogout: _onLogout)
            : LoginScreen(key: const ValueKey('login'), onLogin: _onLogin, onSkip: _onSkip),
      ),
    );
  }
}
