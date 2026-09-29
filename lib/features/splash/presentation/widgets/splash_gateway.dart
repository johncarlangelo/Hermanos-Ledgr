import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/features/splash/presentation/screens/splash_screen.dart';
import 'package:hermanos_ledgr/features/splash/providers/splash_provider.dart';

/// Wraps the application root widget tree, seamlessly overlaying the
/// Sovereign Vault Morphing Splash Screen on cold startup or on-demand replay.
/// Because the destination screen (Dashboard or Onboarding) is mounted underneath,
/// the splash screen can gracefully dissolve and fly its emblem into the exact
/// top-left app bar position with zero jumps, black frames, or route cuts.
class SplashGateway extends ConsumerWidget {
  final Widget child;

  const SplashGateway({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splashState = ref.watch(splashProvider);

    return Stack(
      children: [
        child,
        if (splashState.isVisible)
          const Positioned.fill(
            child: SplashScreen(),
          ),
      ],
    );
  }
}
