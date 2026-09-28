import 'package:flutter/material.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';

class HeroAmountDisplay extends StatefulWidget {
  final String label;
  final double amount;
  final double? changeAmount;
  final String? changeLabel;
  final bool isCompact;

  const HeroAmountDisplay({
    super.key,
    required this.label,
    required this.amount,
    this.changeAmount,
    this.changeLabel,
    this.isCompact = false,
  });

  @override
  State<HeroAmountDisplay> createState() => _HeroAmountDisplayState();
}

class _HeroAmountDisplayState extends State<HeroAmountDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _animation = Tween<double>(begin: 0, end: widget.amount).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
    _previousAmount = widget.amount;
  }

  @override
  void didUpdateWidget(covariant HeroAmountDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _previousAmount = oldWidget.amount;
      _animation = Tween<double>(begin: _previousAmount, end: widget.amount).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0.0);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Label above number
        Text(
          widget.label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: Spacing.xs),

        // 2. Animated count-up Hero Number with Tabular Figures
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final formatted = widget.isCompact
                ? CurrencyFormatter.formatCompact(_animation.value)
                : CurrencyFormatter.format(_animation.value);

            return Text(
              formatted,
              style: moneyStyle(
                fontSize: widget.isCompact ? 28 : 36,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            );
          },
        ),

        // 3. Change Indicator below
        if (widget.changeAmount != null || widget.changeLabel != null) ...[
          const SizedBox(height: Spacing.xs),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.changeAmount != null) ...[
                Icon(
                  widget.changeAmount! >= 0
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 14,
                  color: widget.changeAmount! >= 0
                      ? SemanticColors.income(isDark)
                      : SemanticColors.expense(isDark),
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  CurrencyFormatter.format(widget.changeAmount!, showSign: true),
                  style: moneyStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.changeAmount! >= 0
                        ? SemanticColors.income(isDark)
                        : SemanticColors.expense(isDark),
                  ),
                ),
              ],
              if (widget.changeLabel != null) ...[
                const SizedBox(width: Spacing.xs),
                Text(
                  widget.changeLabel!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
