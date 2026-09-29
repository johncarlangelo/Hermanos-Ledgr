import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// GlobalKeys used to measure the exact screen coordinates of the destination
/// brand emblem in ShellScaffold and OnboardingScreen for pixel-perfect morph flights.
final GlobalKey shellBrandEmblemKey = GlobalKey();
final GlobalKey onboardingBrandEmblemKey = GlobalKey();

class SplashState {
  final bool isVisible;
  final bool isFlightActive;
  final bool isEmblemRevealed;

  const SplashState({
    required this.isVisible,
    required this.isFlightActive,
    this.isEmblemRevealed = false,
  });

  SplashState copyWith({
    bool? isVisible,
    bool? isFlightActive,
    bool? isEmblemRevealed,
  }) {
    return SplashState(
      isVisible: isVisible ?? this.isVisible,
      isFlightActive: isFlightActive ?? this.isFlightActive,
      isEmblemRevealed: isEmblemRevealed ?? this.isEmblemRevealed,
    );
  }
}

class SplashNotifier extends Notifier<SplashState> {
  @override
  SplashState build() {
    return const SplashState(
      isVisible: true,
      isFlightActive: false,
      isEmblemRevealed: false,
    );
  }

  void startFlight() {
    state = state.copyWith(isFlightActive: true);
  }

  void revealDestinationEmblem() {
    state = state.copyWith(isEmblemRevealed: true);
  }

  void complete() {
    state = const SplashState(
      isVisible: false,
      isFlightActive: false,
      isEmblemRevealed: true,
    );
  }

  void replay() {
    state = const SplashState(
      isVisible: true,
      isFlightActive: false,
      isEmblemRevealed: false,
    );
  }
}

final splashProvider = NotifierProvider<SplashNotifier, SplashState>(() {
  return SplashNotifier();
});
