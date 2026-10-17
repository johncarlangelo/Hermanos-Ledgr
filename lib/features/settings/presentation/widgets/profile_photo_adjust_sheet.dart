import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/shared/utils/image_cropper_util.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Interactive modal sheet allowing users to pan, scale, and adjust a profile image
/// to a 1:1 proportion before committing it.
class ProfilePhotoAdjustSheet extends StatefulWidget {
  final Uint8List rawImageBytes;

  const ProfilePhotoAdjustSheet({
    super.key,
    required this.rawImageBytes,
  });

  /// Opens the cropper sheet and returns the cropped Base64 PNG string if confirmed.
  static Future<String?> show(BuildContext context, {required Uint8List rawImageBytes}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => ProfilePhotoAdjustSheet(rawImageBytes: rawImageBytes),
    );
  }

  @override
  State<ProfilePhotoAdjustSheet> createState() => _ProfilePhotoAdjustSheetState();
}

class _ProfilePhotoAdjustSheetState extends State<ProfilePhotoAdjustSheet> {
  static const double _viewportSize = 260.0;
  static const double _minScale = 1.0;
  static const double _maxScale = 3.5;

  double _origWidth = 1.0;
  double _origHeight = 1.0;
  double _baseDisplayedWidth = _viewportSize;
  double _baseDisplayedHeight = _viewportSize;

  double _scale = 1.0;
  Offset _offset = Offset.zero;
  bool _isProcessing = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initImageDimensions();
  }

  void _initImageDimensions() {
    final dims = ImageCropperUtil.getImageDimensions(widget.rawImageBytes);
    if (dims != null) {
      _origWidth = dims.$1.toDouble();
      _origHeight = dims.$2.toDouble();

      // Fit covering the 1:1 viewport
      if (_origWidth > _origHeight) {
        // Landscape
        _baseDisplayedHeight = _viewportSize;
        _baseDisplayedWidth = _viewportSize * (_origWidth / _origHeight);
      } else {
        // Portrait or square
        _baseDisplayedWidth = _viewportSize;
        _baseDisplayedHeight = _viewportSize * (_origHeight / _origWidth);
      }

      // Center initial position
      _scale = 1.0;
      _offset = Offset(
        (_viewportSize - _baseDisplayedWidth) / 2,
        (_viewportSize - _baseDisplayedHeight) / 2,
      );
    }
    _isInitialized = true;
  }

  /// Clamps the offset so the image always completely covers the 1:1 viewport
  Offset _clampOffset(Offset rawOffset, double scale) {
    final currentW = _baseDisplayedWidth * scale;
    final currentH = _baseDisplayedHeight * scale;

    final minX = _viewportSize - currentW;
    const maxX = 0.0;
    final minY = _viewportSize - currentH;
    const maxY = 0.0;

    return Offset(
      rawOffset.dx.clamp(minX, maxX),
      rawOffset.dy.clamp(minY, maxY),
    );
  }

  void _onScaleChanged(double newScale) {
    setState(() {
      // Zoom centered on viewport center (130, 130)
      const center = Offset(_viewportSize / 2, _viewportSize / 2);
      final currentW = _baseDisplayedWidth * _scale;
      final currentH = _baseDisplayedHeight * _scale;
      final newW = _baseDisplayedWidth * newScale;
      final newH = _baseDisplayedHeight * newScale;

      final normalizedX = (center.dx - _offset.dx) / currentW;
      final normalizedY = (center.dy - _offset.dy) / currentH;

      final newOffsetX = center.dx - (normalizedX * newW);
      final newOffsetY = center.dy - (normalizedY * newH);

      _scale = newScale;
      _offset = _clampOffset(Offset(newOffsetX, newOffsetY), _scale);
    });
  }

  void _reset() {
    setState(() {
      _scale = 1.0;
      _offset = Offset(
        (_viewportSize - _baseDisplayedWidth) / 2,
        (_viewportSize - _baseDisplayedHeight) / 2,
      );
    });
  }

  Future<void> _applyCrop() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final croppedBase64 = ImageCropperUtil.cropToSquare(
        rawBytes: widget.rawImageBytes,
        viewportSize: _viewportSize,
        displayedWidth: _baseDisplayedWidth,
        displayedHeight: _baseDisplayedHeight,
        offsetX: _offset.dx,
        offsetY: _offset.dy,
        scale: _scale,
        outputSize: 512,
      );

      if (croppedBase64 != null && mounted) {
        Navigator.of(context).pop(croppedBase64);
      } else if (mounted) {
        UndoSnackbar.error(context, message: 'Failed to process cropped image');
      }
    } catch (e) {
      if (mounted) {
        UndoSnackbar.error(context, message: 'Crop error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? StashColors.tealAccent : theme.colorScheme.primary;

    final currentW = _baseDisplayedWidth * _scale;
    final currentH = _baseDisplayedHeight * _scale;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.lg,
          Spacing.sm,
          Spacing.lg,
          Spacing.xl,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(Spacing.sm),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.crop_rotate_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adjust 1:1 Crop',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Pan & zoom to fit your avatar',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // 1:1 Interactive Viewport
              Center(
                child: Container(
                  width: _viewportSize,
                  height: _viewportSize,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          _offset = _clampOffset(_offset + details.delta, _scale);
                        });
                      },
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          // Underlying Image
                          if (_isInitialized)
                            Positioned(
                              left: _offset.dx,
                              top: _offset.dy,
                              width: currentW,
                              height: currentH,
                              child: Image.memory(
                                widget.rawImageBytes,
                                fit: BoxFit.fill,
                                width: currentW,
                                height: currentH,
                              ),
                            ),

                          // Circular Scrim & Guide Overlay
                          Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: _AvatarApertureOverlayPainter(
                                  accentColor: accentColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.md),

              // Reset / Center Action
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.center_focus_strong_rounded, size: 16),
                    label: const Text('Center & Reset'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),

              // Zoom Slider Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
                decoration: BoxDecoration(
                  color: isDark ? StashColors.raised : theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.zoom_out_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    Expanded(
                      child: Slider(
                        value: _scale,
                        min: _minScale,
                        max: _maxScale,
                        activeColor: accentColor,
                        inactiveColor: theme.colorScheme.outlineVariant,
                        onChanged: _onScaleChanged,
                      ),
                    ),
                    Icon(
                      Icons.zoom_in_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_scale.toStringAsFixed(1)}x',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.xl),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isProcessing ? null : _applyCrop,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_rounded, size: 18),
                      label: Text(_isProcessing ? 'Processing...' : 'Apply 1:1 Crop'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter rendering a dimmed outer scrim and circular avatar guide ring
class _AvatarApertureOverlayPainter extends CustomPainter {
  final Color accentColor;

  const _AvatarApertureOverlayPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4.0;

    // 1. Dark scrim outside circle
    final scrimPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.50)
      ..style = PaintingStyle.fill;

    final scrimPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(scrimPath, scrimPaint);

    // 2. Subtle rule-of-thirds grid inside circle
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));

    final third = size.width / 3;
    canvas.drawLine(Offset(third, 0), Offset(third, size.height), gridPaint);
    canvas.drawLine(Offset(third * 2, 0), Offset(third * 2, size.height), gridPaint);
    canvas.drawLine(Offset(0, third), Offset(size.width, third), gridPaint);
    canvas.drawLine(Offset(0, third * 2), Offset(size.width, third * 2), gridPaint);

    canvas.restore();

    // 3. Stash Teal Ring
    final borderPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _AvatarApertureOverlayPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor;
  }
}
