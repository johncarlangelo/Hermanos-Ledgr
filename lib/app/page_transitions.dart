import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Builds a Material Design 3 Shared Axis X (horizontal) page transition (Task 13.1).
/// Features a subtle 300ms easeOutCubic slide + fade entrance and subtle exit,
/// conforming to M3 motion specifications in flutter-m3-premium-design skill.
CustomTransitionPage<T> buildSharedAxisXTransition<T>({
  required Widget child,
  required GoRouterState state,
  Duration duration = const Duration(milliseconds: 300),
  Duration reverseDuration = const Duration(milliseconds: 250),
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: reverseDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Primary entrance: Slide from right + Fade in
      final inSlide = Tween<Offset>(
        begin: const Offset(0.08, 0.0), // subtle 8% horizontal shift
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ),
      );

      final inFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
        ),
      );

      // Secondary exit: subtle slide to left + slight fade when child pushed on top
      final outSlide = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.04, 0.0),
      ).animate(
        CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeOutCubic,
        ),
      );

      final outFade = Tween<double>(begin: 1.0, end: 0.85).animate(
        CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeOut,
        ),
      );

      return SlideTransition(
        position: inSlide,
        child: FadeTransition(
          opacity: inFade,
          child: SlideTransition(
            position: outSlide,
            child: FadeTransition(
              opacity: outFade,
              child: child,
            ),
          ),
        ),
      );
    },
  );
}

/// Builds a Material Design 3 Cross-Fade tab transition (Task 13.1).
/// Provides smooth 200ms easeInOut cross-fading for shell bottom navigation destinations.
CustomTransitionPage<T> buildCrossFadeTransition<T>({
  required Widget child,
  required GoRouterState state,
  Duration duration = const Duration(milliseconds: 200),
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: child,
      );
    },
  );
}
