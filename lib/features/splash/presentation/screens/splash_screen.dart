import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/core/constants/app_constants.dart';
import 'package:hermanos_ledgr/core/providers/onboarding_provider.dart';

/// State-of-the-art startup morphing splash screen for Hermanos Ledgr.
/// Features a geometric vault morphing animation that seamlessly transitions
/// via Hero flight into the destination screen (Dashboard or Onboarding).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Geometry Morph Animations
  late final Animation<double> _sizeAnim;
  late final Animation<double> _radiusAnim;
  late final Animation<double> _rotationAnim;
  late final Animation<double> _glowAnim;

  // Icon Reveal
  late final Animation<double> _iconScaleAnim;
  late final Animation<double> _iconOpacityAnim;

  // Typography Stagger
  late final Animation<double> _textOpacityAnim;
  late final Animation<double> _textSlideAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1850),
    );

    // 1. Particle expansion (0% -> 55%)
    _sizeAnim = Tween<double>(begin: 8.0, end: 76.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Corner radius morph: Circle (38) -> Vault Diamond (10) -> Squircle (22)
    _radiusAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 38.0, end: 10.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 10.0, end: 22.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 60,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.10, 0.65),
      ),
    );

    // 3. Subtle Vault Diamond Tilt: 0 -> 45deg -> 0
    _rotationAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: math.pi / 4)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: math.pi / 4, end: 0.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.12, 0.65),
      ),
    );

    // 4. Ambient Aura Glow
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.75, curve: Curves.easeOut),
      ),
    );

    // 5. Emblem Pop
    _iconScaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.48, 0.82, curve: Curves.elasticOut),
      ),
    );

    _iconOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.68, curve: Curves.easeIn),
      ),
    );

    // 6. Typography Stagger
    _textOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.92, curve: Curves.easeOut),
      ),
    );

    _textSlideAnim = Tween<double>(begin: 18.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.95, curve: Curves.easeOutCubic),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateForward();
      }
    });

    _controller.forward();
  }

  void _navigateForward() {
    if (!mounted) return;
    final isCompleted = ref.read(onboardingProvider).isCompleted;
    if (isCompleted) {
      context.go('/');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final teal = isDark ? StashColors.tealAccent : theme.colorScheme.primary;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: StashColors.base,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: theme.colorScheme.surface,
            ),
      child: Scaffold(
        backgroundColor: isDark ? StashColors.base : theme.colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Central Morphing Emblem
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final size = _sizeAnim.value;
                  final radius = _radiusAnim.value;
                  final rotation = _rotationAnim.value;
                  final glow = _glowAnim.value;

                  return Transform.rotate(
                    angle: rotation,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(radius),
                        border: Border.all(
                          color: teal.withValues(alpha: 0.4 + 0.4 * glow),
                          width: 1.8,
                        ),
                        boxShadow: [
                          if (glow > 0.05) ...[
                            BoxShadow(
                              color: teal.withValues(alpha: 0.28 * glow),
                              blurRadius: 28 * glow,
                              spreadRadius: 2 * glow,
                            ),
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.5)
                                  : teal.withValues(alpha: 0.12 * glow),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ],
                      ),
                      child: child,
                    ),
                  );
                },
                child: Center(
                  child: Hero(
                    tag: 'app_brand_emblem',
                    flightShuttleBuilder: (
                      flightContext,
                      animation,
                      flightDirection,
                      fromHeroContext,
                      toHeroContext,
                    ) {
                      return toHeroContext.widget;
                    },
                    child: FadeTransition(
                      opacity: _iconOpacityAnim,
                      child: ScaleTransition(
                        scale: _iconScaleAnim,
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 34,
                          color: teal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.xl),

              // 2. Brand Typography Slide-Fade
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textOpacityAnim.value,
                    child: Transform.translate(
                      offset: Offset(0, _textSlideAnim.value),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    Text(
                      AppConstants.appName.toUpperCase(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.2,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: teal,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'SOVEREIGN PERSONAL LEDGER',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.4,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: teal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
