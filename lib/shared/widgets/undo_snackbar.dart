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
}

class _UndoSnackbarContent extends StatefulWidget {
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
  State<_UndoSnackbarContent> createState() => _UndoSnackbarContentState();
}

class _UndoSnackbarContentState extends State<_UndoSnackbarContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..reverse(from: 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 5-second circular countdown ring with second counter inside
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final progress = _controller.value;
            final secondsLeft = (_controller.value * widget.duration.inSeconds).ceil().clamp(1, widget.duration.inSeconds);

            return SizedBox(
              width: 24,
              height: 24,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 2.2,
                    backgroundColor: StashColors.line,
                    valueColor: const AlwaysStoppedAnimation<Color>(StashColors.tealAccent),
                  ),
                  Text(
                    '$secondsLeft',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: StashColors.tealAccent,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: Spacing.md),

        // Message
        Expanded(
          child: Text(
            widget.message,
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
            onTap: widget.onUndo,
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
            onTap: widget.onDismiss,
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
