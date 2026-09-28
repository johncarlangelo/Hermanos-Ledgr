/// Reusable neumorphic container widget.
/// Shadow values extracted from Stitch design system:
///   - Extruded: 5px 5px 10px #BEBEBE, -5px -5px 10px #FFFFFF
///   - Sunken:   inset 5px 5px 10px #BEBEBE, inset -5px -5px 10px #FFFFFF
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// The three neumorphic states from the Stitch design.
enum NeumorphicState {
  /// Raised/extruded — outer dual-shadow (cards, buttons at rest)
  extruded,
  /// Pressed/sunken — inner dual-shadow (active state, inset fields)
  sunken,
  /// No shadow
  flat,
}

class NeumorphicContainer extends StatelessWidget {
  final Widget? child;
  final NeumorphicState state;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? color;

  const NeumorphicContainer({
    super.key,
    this.child,
    this.state = NeumorphicState.extruded,
    this.borderRadius = 12.0, // rounded-xl from Stitch = 0.75rem ≈ 12px
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? AppColors.background;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: _buildShadows(),
      ),
      child: child,
    );
  }

  List<BoxShadow> _buildShadows() {
    switch (state) {
      case NeumorphicState.extruded:
        // Stitch: box-shadow: 5px 5px 10px #BEBEBE, -5px -5px 10px #FFFFFF
        return const [
          BoxShadow(
            color: AppColors.shadowDark,
            offset: Offset(5, 5),
            blurRadius: 10,
          ),
          BoxShadow(
            color: AppColors.shadowLight,
            offset: Offset(-5, -5),
            blurRadius: 10,
          ),
        ];
      case NeumorphicState.sunken:
        // Stitch: box-shadow: inset 5px 5px 10px #BEBEBE, inset -5px -5px 10px #FFFFFF
        // Flutter doesn't have "inset", so we simulate with reversed offset + spread
        return const [
          BoxShadow(
            color: AppColors.shadowDark,
            offset: Offset(3, 3),
            blurRadius: 6,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: AppColors.shadowLight,
            offset: Offset(-3, -3),
            blurRadius: 6,
            spreadRadius: -2,
          ),
        ];
      case NeumorphicState.flat:
        return [];
    }
  }
}

/// Sunken (inset) neumorphic container using inner shadow simulation.
/// Uses a gradient overlay approach for more accurate inset shadow rendering.
class NeumorphicSunkenContainer extends StatelessWidget {
  final Widget? child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  const NeumorphicSunkenContainer({
    super.key,
    this.child,
    this.borderRadius = 12.0,
    this.padding,
    this.margin,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          // Inner shadow simulation — smaller, tighter shadows
          BoxShadow(
            color: Color(0x40BEBEBE),
            offset: Offset(2, 2),
            blurRadius: 4,
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Color(0x80FFFFFF),
            offset: Offset(-2, -2),
            blurRadius: 4,
            spreadRadius: -1,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.background.withValues(alpha: 0.95),
            AppColors.surfaceContainerHigh,
          ],
        ),
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }
}

/// Neumorphic button with animated press state.
/// Transitions from extruded → sunken on press (Stitch active state).
class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const NeumorphicButton({
    super.key,
    required this.child,
    this.onPressed,
    this.borderRadius = 12.0,
    this.padding,
    this.color,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: NeumorphicContainer(
          state: _isPressed ? NeumorphicState.sunken : NeumorphicState.extruded,
          borderRadius: widget.borderRadius,
          padding: widget.padding ?? const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
          color: widget.color,
          child: widget.child,
        ),
      ),
    );
  }
}
