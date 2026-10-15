import 'package:flutter/material.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';

/// Custom floating feedback toast for Hermanos Ledgr.
/// Replaces stock Android snackbars and toasts with custom-tailored floating pills.
class UndoSnackbar {
  UndoSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    required VoidCallback onUndo,
    Duration duration = const Duration(seconds: 5),
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    scaffoldMessenger.showSnackBar(
      SnackBar(
        elevation: 8,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, Spacing.lg),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
        backgroundColor: isDark ? StashColors.raised : StashColors.overlay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: StashColors.lineStrong, width: 1),
        ),
        duration: duration,
        content: _UndoSnackbarContent(
          message: message,
          duration: duration,
          onUndo: () {
            scaffoldMessenger.hideCurrentSnackBar();
            onUndo();
          },
          onDismiss: () {
            scaffoldMessenger.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void error(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    scaffoldMessenger.showSnackBar(
      SnackBar(
        elevation: 8,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, Spacing.lg),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.md),
        backgroundColor: isDark ? StashColors.raised : StashColors.overlay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: StashColors.danger.withValues(alpha: 0.5), width: 1),
        ),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: StashColors.danger.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, size: 16, color: StashColors.danger),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: StashColors.ink,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
        duration: duration,
      ),
    );
  }

  static void info(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    scaffoldMessenger.showSnackBar(
      SnackBar(
        elevation: 8,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, Spacing.lg),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.md),
        backgroundColor: isDark ? StashColors.raised : StashColors.overlay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: StashColors.line, width: 1),
        ),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: StashColors.tealAccent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.info_outline_rounded, size: 16, color: StashColors.tealAccent),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: StashColors.ink,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
        duration: duration,
      ),
    );
  }

  static void success(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    scaffoldMessenger.showSnackBar(
      SnackBar(
        elevation: 8,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, Spacing.lg),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.md),
        backgroundColor: isDark ? StashColors.raised : StashColors.overlay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: StashColors.lineStrong, width: 1),
        ),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: StashColors.tealAccent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, size: 16, color: StashColors.tealAccent),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: StashColors.ink,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
        duration: duration,
      ),
    );
  }
}

class _UndoSnackbarContent extends StatelessWidget {
  final String message;
  final VoidCallback onUndo;
  final VoidCallback onDismiss;
  final Duration duration;

  const _UndoSnackbarContent({
    required this.message,
    required this.onUndo,
    required this.onDismiss,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Calm Undo Icon badge (no ticking countdown ring)
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: StashColors.tealAccent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.undo_rounded,
            size: 16,
            color: StashColors.tealAccent,
          ),
        ),
        const SizedBox(width: Spacing.md),

        // Message
        Expanded(
          child: Text(
            message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: StashColors.ink,
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
        ),
        const SizedBox(width: Spacing.sm),

        // [UNDO] Action Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onUndo,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: StashColors.tealAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: StashColors.tealAccent.withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
              child: const Text(
                'UNDO',
                style: TextStyle(
                  color: StashColors.tealAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: Spacing.xs),

        // [X] Dismiss Early Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onDismiss,
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: StashColors.dim,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
