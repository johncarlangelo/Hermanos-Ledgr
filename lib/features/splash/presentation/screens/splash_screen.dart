import 'dart:math' as math;
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/core/constants/app_constants.dart';
import 'package:hermanos_ledgr/features/splash/providers/splash_provider.dart';

/// State-of-the-art startup morphing splash screen for Hermanos Ledgr.
/// Features a geometric vault morphing intro followed by a seamless live flight
/// transition directly into the destination app bar brand emblem.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Phase 1: Intro Geometry Morph Animations (0.00 -> 0.70)
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

  // Phase 2: Live Flight Transition to App Bar (0.70 -> 1.00)
  late final Animation<double> _flightAnim;
  late final Animation<double> _textExitOpacityAnim;
  late final Animation<double> _textExitSlideAnim;
  late final Animation<double> _backdropOpacityAnim;

  bool _hasFlightStarted = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // 1. Particle expansion (0% -> 24%)
    _sizeAnim = Tween<double>(begin: 8.0, end: 76.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.24, curve: Curves.easeOutCubic),
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
        curve: const Interval(0.05, 0.32),
      ),
    );

    // 3. Vault Diamond Tilt: 0 -> 45deg -> 0
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
        curve: const Interval(0.06, 0.32),
      ),
    );

    // 4. Ambient Aura Glow
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.40, curve: Curves.easeOut),
      ),
    );

    // 5. Emblem Pop
    _iconScaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.24, 0.46, curve: Curves.elasticOut),
      ),
    );

    _iconOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.22, 0.36, curve: Curves.easeIn),
      ),
    );

    // 6. Typography Entrance
    _textOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.58, curve: Curves.easeOut),
      ),
    );

    _textSlideAnim = Tween<double>(begin: 16.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.58, curve: Curves.easeOutCubic),
      ),
    );

    // --- Phase 2: Live Flight Transition ---
    // 7. Live Flight Motion into Top-Left App Bar
    _flightAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.68, 1.00, curve: Curves.fastOutSlowIn),
      ),
    );

    // 8. Typography Exit
    _textExitOpacityAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.68, 0.82, curve: Curves.easeIn),
      ),
    );

    _textExitSlideAnim = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.68, 0.82, curve: Curves.easeIn),
      ),
    );

    // 9. Backdrop Curtain Reveal
    _backdropOpacityAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.70, 0.98, curve: Curves.easeInOutCubic),
      ),
    );

    _controller.addListener(() {
      if (_controller.value >= 0.68 && !_hasFlightStarted) {
        _hasFlightStarted = true;
        ref.read(splashProvider.notifier).startFlight();
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        ref.read(splashProvider.notifier).complete();
      }
    });

    _controller.forward();
  }

  void _skipToFlight() {
    if (_controller.value < 0.68) {
      _controller.animateTo(
        1.0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Offset _getTargetCenter(BuildContext context) {
    RenderBox? box;
    if (shellBrandEmblemKey.currentContext?.findRenderObject() is RenderBox) {
      box = shellBrandEmblemKey.currentContext!.findRenderObject() as RenderBox;
    } else if (onboardingBrandEmblemKey.currentContext?.findRenderObject()
        is RenderBox) {
      box = onboardingBrandEmblemKey.currentContext!.findRenderObject()
          as RenderBox;
    }

    if (box != null && box.hasSize && box.size.width > 0) {
      final pos = box.localToGlobal(Offset.zero);
      return Offset(pos.dx + box.size.width / 2, pos.dy + box.size.height / 2);
    }

    final top = MediaQuery.paddingOf(context).top;
    return Offset(32.0, top + 28.0);
  }

  Size _getTargetSize() {
    RenderBox? box;
    if (shellBrandEmblemKey.currentContext?.findRenderObject() is RenderBox) {
      box = shellBrandEmblemKey.currentContext!.findRenderObject() as RenderBox;
    } else if (onboardingBrandEmblemKey.currentContext?.findRenderObject()
        is RenderBox) {
      box = onboardingBrandEmblemKey.currentContext!.findRenderObject()
          as RenderBox;
    }

    if (box != null && box.hasSize && box.size.width > 0) {
      return box.size;
    }

    return const Size(32.0, 32.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    if (media.width <= 10 || media.height <= 10) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final teal = isDark ? StashColors.tealAccent : theme.colorScheme.primary;

    final screenCenter = Offset(media.width / 2, media.height / 2);
    final targetCenter = _getTargetCenter(context);
    final targetSize = _getTargetSize();

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
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final flight = _flightAnim.value;
            final introSize = _sizeAnim.value;
            final introRadius = _radiusAnim.value;
            final introRotation = _rotationAnim.value;
            final introGlow = _glowAnim.value;

            // Geometry interpolations during live flight
            final currentCenter = Offset.lerp(screenCenter, targetCenter, flight)!;
            final currentWidth = lerpDouble(introSize, targetSize.width, flight)!;
            final currentHeight = lerpDouble(introSize, targetSize.height, flight)!;
            final currentRadius = lerpDouble(introRadius, 8.0, flight)!;
            final currentRotation = (1.0 - flight) * introRotation;
            final currentGlow = (1.0 - flight) * introGlow;
            final currentBorderAlpha = (1.0 - flight) * (0.35 + 0.35 * introGlow);
            final currentIconSize = lerpDouble(34.0, 18.0, flight)!;

            final backdropOpacity = _backdropOpacityAnim.value.clamp(0.0, 1.0);
            final textOpacity = (_textOpacityAnim.value * _textExitOpacityAnim.value)
                .clamp(0.0, 1.0);
            final textTranslateY = _textSlideAnim.value + _textExitSlideAnim.value;

            return Stack(
              children: [
                // 1. Splash Dark Backdrop (Gracefully dissolves to reveal underlying screen)
                Positioned.fill(
                  child: Opacity(
                    opacity: backdropOpacity,
                    child: Container(
                      color: isDark ? StashColors.base : theme.colorScheme.surface,
                    ),
                  ),
                ),

                // 2. Brand Typography Slide-Fade
                Positioned(
                  top: screenCenter.dy + 54,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: textOpacity,
                    child: Transform.translate(
                      offset: Offset(0, textTranslateY),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                    ),
                  ),

                // 3. Central Morphing Emblem Traveling Along Smooth Vector
                Positioned(
                  left: currentCenter.dx - currentWidth / 2,
                  top: currentCenter.dy - currentHeight / 2,
                  width: currentWidth,
                  height: currentHeight,
                  child: Transform.rotate(
                    angle: currentRotation,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(currentRadius),
                        border: currentBorderAlpha > 0.02
                            ? Border.all(
                                color: teal.withValues(alpha: currentBorderAlpha),
                                width: 1.8 * (1.0 - flight),
                              )
                            : null,
                        boxShadow: [
                          if (currentGlow > 0.05) ...[
                            BoxShadow(
                              color: teal.withValues(alpha: 0.28 * currentGlow),
                              blurRadius: 28 * currentGlow,
                              spreadRadius: 2 * currentGlow,
                            ),
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.5)
                                  : teal.withValues(alpha: 0.12 * currentGlow),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ],
                      ),
                      child: Center(
                        child: Hero(
                          tag: 'app_brand_emblem',
                          child: FadeTransition(
                            opacity: _iconOpacityAnim,
                            child: ScaleTransition(
                              scale: _iconScaleAnim,
                              child: Icon(
                                Icons.account_balance_wallet_rounded,
                                size: currentIconSize,
                                color: teal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 4. Tap to Fast-Forward Flight (Quality-of-Life)
                if (flight < 0.6)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _skipToFlight,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
