import 'package:flutter/material.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';

class M3Card extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double borderRadius;
  final Border? border;

  const M3Card({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
    this.borderRadius = 16.0,
    this.border,
  });

  @override
  State<M3Card> createState() => _M3CardState();
}

class _M3CardState extends State<M3Card> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = widget.color ?? theme.colorScheme.surfaceContainer;

    Widget content = Container(
      padding: widget.padding ?? const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: widget.border,
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      content = GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: content,
        ),
      );
    }

    return content;
  }
}
