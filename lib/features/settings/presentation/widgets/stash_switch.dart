import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';

/// A custom-tailored animated toggle pill adhering to Hermanos-Stash styling.
/// Replaces stock Android Switch with smooth micro-animations and zero native widgets.
class StashSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const StashSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const width = 48.0;
    const height = 28.0;
    const thumbSize = 22.0;
    const padding = 3.0;

    return Semantics(
      toggled: value,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onChanged(!value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: width,
          height: height,
          padding: const EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: value
                ? (isDark ? StashColors.tealAccent : theme.colorScheme.primary)
                : (isDark ? StashColors.raised : theme.colorScheme.surfaceContainerHigh),
            borderRadius: BorderRadius.circular(height / 2),
            border: Border.all(
              color: value
                  ? (isDark ? StashColors.tealAccent : theme.colorScheme.primary)
                  : (isDark ? StashColors.lineStrong : theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
              width: 1.2,
            ),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: thumbSize,
              height: thumbSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: value
                    ? (isDark ? StashColors.base : Colors.white)
                    : (isDark ? StashColors.dim : theme.colorScheme.onSurfaceVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
