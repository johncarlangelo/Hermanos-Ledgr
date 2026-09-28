import 'package:flutter/material.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/core/constants/app_constants.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// A sleek custom pill displaying the current SemVer build.
/// Formatted with Hermanos-Stash tokens and tabular figures.
class VersionPill extends StatelessWidget {
  final VoidCallback? onTap;
  final bool showDot;

  const VersionPill({
    super.key,
    this.onTap,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ??
            () {
              UndoSnackbar.info(
                context,
                message:
                    '${AppConstants.appName} ${AppConstants.appVersionDisplay} · 100% Offline',
              );
            },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
          decoration: BoxDecoration(
            color: isDark
                ? StashColors.raised
                : theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark
                  ? StashColors.line.withValues(alpha: 0.8)
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showDot) ...[
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark
                        ? StashColors.tealAccent
                        : theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
              ],
              Text(
                AppConstants.appVersionDisplay,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: isDark
                      ? StashColors.dim
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
