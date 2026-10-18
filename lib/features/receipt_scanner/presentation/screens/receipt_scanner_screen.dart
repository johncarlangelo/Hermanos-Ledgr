import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/features/receipt_scanner/presentation/widgets/scan_result_sheet.dart';
import 'package:hermanos_ledgr/features/receipt_scanner/providers/receipt_scanner_provider.dart';
import 'package:hermanos_ledgr/shared/widgets/undo_snackbar.dart';

/// Receipt Scanner Screen with animated viewfinder and hybrid OCR (Task 10.3, 10.6).
class ReceiptScannerScreen extends ConsumerStatefulWidget {
  const ReceiptScannerScreen({super.key});

  @override
  ConsumerState<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends ConsumerState<ReceiptScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  late Animation<double> _laserAnimation;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _laserAnimation = CurvedAnimation(
      parent: _laserController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  void _showScanningTips(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(Spacing.xl),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: Spacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(Spacing.sm),
                    decoration: BoxDecoration(
                      color: StashColors.tealAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: StashColors.tealAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Text(
                    'Best Scanning Results',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.lg),
              _tipRow(
                theme,
                Icons.wb_sunny_outlined,
                'Ensure Bright Lighting',
                'Avoid strong shadows across receipt totals and dates.',
              ),
              const SizedBox(height: Spacing.md),
              _tipRow(
                theme,
                Icons.crop_free_rounded,
                'Flatten Crumpled Paper',
                'Smooth out crumpled folds so all numbers align horizontally.',
              ),
              const SizedBox(height: Spacing.md),
              _tipRow(
                theme,
                Icons.center_focus_strong_rounded,
                'Fill The Viewfinder',
                'Keep the camera steady and perpendicular to the receipt.',
              ),
              const SizedBox(height: Spacing.md),
              Container(
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFF59E0B),
                      size: 18,
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Text(
                        'Note: OCR text detection may be inaccurate if the image is blurry, poorly lit, or the receipt is crumpled. Always verify details before adding to ledger.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11.5,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: StashColors.tealAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Got It',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tipRow(ThemeData theme, IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: StashColors.tealAccent),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scanState = ref.watch(receiptScannerProvider);
    final notifier = ref.read(receiptScannerProvider.notifier);

    // Listen to success / error transitions
    ref.listen<ReceiptScannerState>(receiptScannerProvider, (prev, next) {
      if (next.status == ReceiptScanStatus.success && next.result != null) {
        ScanResultSheet.show(context, result: next.result!);
      } else if (next.status == ReceiptScanStatus.error && next.errorMessage != null) {
        UndoSnackbar.error(context, message: next.errorMessage!);
      }
    });

    final isProcessing = scanState.status == ReceiptScanStatus.processing;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () {
                      notifier.reset();
                      context.pop();
                    },
                    tooltip: 'Back',
                  ),
                  Text(
                    'Receipt Scanner',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline_rounded, color: Colors.white70),
                    onPressed: () => _showScanningTips(context),
                    tooltip: 'Tips',
                  ),
                ],
              ),
            ),

            // Viewfinder Area
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Stack(
                      children: [
                        // Image Preview or Empty Viewfinder
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF141918),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 1.5,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: scanState.imagePath != null
                              ? Image.file(
                                  File(scanState.imagePath!),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                )
                              : Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.receipt_long_rounded,
                                        size: 56,
                                        color: Colors.white.withValues(alpha: 0.35),
                                      ),
                                      const SizedBox(height: Spacing.md),
                                      Text(
                                        'Position receipt within frame',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: Colors.white.withValues(alpha: 0.6),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Capture clearly under good lighting',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.white.withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),

                        // Corner Brackets for Viewfinder
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _ViewfinderCornersPainter(
                              cornerColor: StashColors.tealAccent,
                              cornerLength: 32,
                              strokeWidth: 4,
                            ),
                          ),
                        ),

                        // Animated Scanning Laser Beam
                        if (!isProcessing)
                          AnimatedBuilder(
                            animation: _laserAnimation,
                            builder: (context, child) {
                              return Align(
                                alignment: Alignment(
                                  0,
                                  (_laserAnimation.value * 2.0) - 1.0,
                                ),
                                child: Container(
                                  height: 3,
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        StashColors.tealAccent.withValues(alpha: 0.0),
                                        StashColors.tealAccent,
                                        StashColors.tealAccent,
                                        StashColors.tealAccent.withValues(alpha: 0.0),
                                      ],
                                      stops: const [0.0, 0.25, 0.75, 1.0],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: StashColors.tealAccent.withValues(alpha: 0.8),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                        // Processing Overlay
                        if (isProcessing)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 44,
                                    height: 44,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        StashColors.tealAccent,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: Spacing.lg),
                                  Text(
                                    'Analyzing receipt...',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Extracting amount, merchant & category',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Accuracy Disclaimer Pill
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.xl,
                vertical: Spacing.sm,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: StashColors.tealAccent,
                      size: 14,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      'Tier 1 OCR (<5ms) with optional Qwen AI verification',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Controls Bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.xxl,
                vertical: Spacing.lg,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF101413),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Pick from Gallery Button (Task 10.6)
                  _controlButton(
                    theme: theme,
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    onTap: isProcessing ? null : () => notifier.scanFromGallery(),
                  ),

                  // Camera Shutter Button (Task 10.3)
                  GestureDetector(
                    onTap: isProcessing ? null : () => notifier.scanFromCamera(),
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: StashColors.tealAccent,
                          width: 4,
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isProcessing ? Colors.grey : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: StashColors.tealAccent.withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                    ),
                  ),

                  // Retake / Result Button
                  _controlButton(
                    theme: theme,
                    icon: scanState.result != null
                        ? Icons.receipt_long_rounded
                        : Icons.refresh_rounded,
                    label: scanState.result != null ? 'View' : 'Reset',
                    onTap: isProcessing
                        ? null
                        : () {
                            if (scanState.result != null) {
                              ScanResultSheet.show(context, result: scanState.result!);
                            } else {
                              notifier.reset();
                            }
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlButton({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: onTap == null ? Colors.white30 : Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: onTap == null ? Colors.white30 : Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter that draws rounded corner guides for the scanner viewfinder.
class _ViewfinderCornersPainter extends CustomPainter {
  final Color cornerColor;
  final double cornerLength;
  final double strokeWidth;

  const _ViewfinderCornersPainter({
    required this.cornerColor,
    required this.cornerLength,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cornerColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const r = 24.0;

    // Top-Left
    final tlPath = Path()
      ..moveTo(0, cornerLength)
      ..lineTo(0, r)
      ..arcToPoint(const Offset(r, 0), radius: const Radius.circular(r))
      ..lineTo(cornerLength, 0);
    canvas.drawPath(tlPath, paint);

    // Top-Right
    final trPath = Path()
      ..moveTo(size.width - cornerLength, 0)
      ..lineTo(size.width - r, 0)
      ..arcToPoint(Offset(size.width, r), radius: const Radius.circular(r))
      ..lineTo(size.width, cornerLength);
    canvas.drawPath(trPath, paint);

    // Bottom-Left
    final blPath = Path()
      ..moveTo(0, size.height - cornerLength)
      ..lineTo(0, size.height - r)
      ..arcToPoint(Offset(r, size.height), radius: const Radius.circular(r))
      ..lineTo(cornerLength, size.height);
    canvas.drawPath(blPath, paint);

    // Bottom-Right
    final brPath = Path()
      ..moveTo(size.width - cornerLength, size.height)
      ..lineTo(size.width - r, size.height)
      ..arcToPoint(Offset(size.width, size.height - r), radius: const Radius.circular(r))
      ..lineTo(size.width, size.height - cornerLength);
    canvas.drawPath(brPath, paint);
  }

  @override
  bool shouldRepaint(covariant _ViewfinderCornersPainter oldDelegate) {
    return oldDelegate.cornerColor != cornerColor ||
        oldDelegate.cornerLength != cornerLength ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
