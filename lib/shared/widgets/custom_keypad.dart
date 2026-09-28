import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';

class CustomKeypad extends StatelessWidget {
  final ValueChanged<String> onKeyPress;
  final VoidCallback onDelete;
  final ValueChanged<double>? onQuickAdd;

  const CustomKeypad({
    super.key,
    required this.onKeyPress,
    required this.onDelete,
    this.onQuickAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Quick amount chips
        if (onQuickAdd != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickChip(context, '+₱100', 100),
                _buildQuickChip(context, '+₱500', 500),
                _buildQuickChip(context, '+₱1,000', 1000),
                _buildQuickChip(context, '+₱5,000', 5000),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),
        ],

        // 3x4 Keypad Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
          child: Column(
            children: [
              _buildRow(context, ['1', '2', '3']),
              const SizedBox(height: Spacing.sm),
              _buildRow(context, ['4', '5', '6']),
              const SizedBox(height: Spacing.sm),
              _buildRow(context, ['7', '8', '9']),
              const SizedBox(height: Spacing.sm),
              Row(
                children: [
                  _buildButton(context, '.', isSpecial: true),
                  const SizedBox(width: Spacing.sm),
                  _buildButton(context, '0'),
                  const SizedBox(width: Spacing.sm),
                  _buildDeleteButton(context),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickChip(BuildContext context, String label, double amount) {
    final theme = Theme.of(context);
    return ActionChip(
      label: Text(label),
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.primary,
      ),
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide.none,
      onPressed: () {
        HapticFeedback.lightImpact();
        onQuickAdd?.call(amount);
      },
    );
  }

  Widget _buildRow(BuildContext context, List<String> labels) {
    return Row(
      children: [
        for (int i = 0; i < labels.length; i++) ...[
          if (i > 0) const SizedBox(width: Spacing.sm),
          _buildButton(context, labels[i]),
        ],
      ],
    );
  }

  Widget _buildButton(BuildContext context, String text, {bool isSpecial = false}) {
    final theme = Theme.of(context);
    return Expanded(
      child: SizedBox(
        height: 54,
        child: Material(
          color: isSpecial
              ? theme.colorScheme.surfaceContainer
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              HapticFeedback.lightImpact();
              onKeyPress(text);
            },
            child: Center(
              child: Text(
                text,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: SizedBox(
        height: 54,
        child: Material(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              HapticFeedback.lightImpact();
              onDelete();
            },
            child: Center(
              child: Icon(
                Icons.backspace_outlined,
                size: 22,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
