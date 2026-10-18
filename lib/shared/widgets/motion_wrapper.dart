import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Staggered card/list item entrance animation conforming to M3 guidelines (Task 13.2).
/// Fades in and slides up by [slideOffset] dp with an incremental delay based on [index] (50ms per item).
class StaggeredEntrance extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;
  final Duration duration;
  final double slideOffset;

  const StaggeredEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.baseDelay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 220),
    this.slideOffset = 10.0,
  });

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    final delay = widget.baseDelay * widget.index;
    final totalDuration = delay + widget.duration;

    _controller = AnimationController(
      vsync: this,
      duration: totalDuration > Duration.zero ? totalDuration : const Duration(milliseconds: 1),
    );

    final Curve curve;
    if (delay == Duration.zero || totalDuration == Duration.zero) {
      curve = Curves.easeOutCubic;
    } else {
      final startRatio = (delay.inMicroseconds / totalDuration.inMicroseconds).clamp(0.0, 0.99);
      curve = Interval(
        startRatio,
        1.0,
        curve: Curves.easeOutCubic,
      );
    }

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: curve,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.slideOffset / 100),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: curve,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Spring-like bouncy pressable wrapper providing tactile micro-animation feedback (Task 13.2).
class BouncyPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;
  final Duration duration;
  final bool enableHaptic;

  const BouncyPressable({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.96,
    this.duration = const Duration(milliseconds: 100),
    this.enableHaptic = true,
  });

  @override
  State<BouncyPressable> createState() => _BouncyPressableState();
}

class _BouncyPressableState extends State<BouncyPressable> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap == null) return;
    if (widget.enableHaptic) {
      HapticFeedback.selectionClick();
    }
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    if (_isPressed) setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (_isPressed) setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleDown : 1.0,
        duration: widget.duration,
        curve: Curves.easeOutQuad,
        child: widget.child,
      ),
    );
  }
}
