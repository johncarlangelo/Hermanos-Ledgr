import 'package:flutter/material.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';

/// Reusable settings tile formatted with Hermanos-Stash container hierarchy.
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool showDivider;

  const SettingsTile({
    super.key,
    required this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = isDestructive
        ? SemanticColors.expense(isDark)
        : (iconColor ?? (isDark ? StashColors.tealAccent : theme.colorScheme.primary));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Icon Container
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: Spacing.md),

                  // Title & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDestructive
                                ? SemanticColors.expense(isDark)
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDestructive
                                  ? SemanticColors.expense(isDark).withValues(alpha: 0.8)
                                  : theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Trailing widget
                  if (trailing != null) ...[
                    const SizedBox(width: Spacing.sm),
                    trailing!,
                  ] else if (onTap != null) ...[
                    const SizedBox(width: Spacing.xs),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 62,
            endIndent: 14,
            thickness: 0.6,
            color: isDark
                ? StashColors.line.withValues(alpha: 0.4)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
          ),
      ],
    );
  }
}
