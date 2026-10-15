import 'package:flutter/material.dart';

class EmvChipWidget extends StatelessWidget {
  final bool isGold;
  final double width;
  final double height;

  const EmvChipWidget({
    super.key,
    this.isGold = true,
    this.width = 28,
    this.height = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isGold
              ? const [
                  Color(0xFFFFDF7D),
                  Color(0xFFD4AF37),
                  Color(0xFFAA820A),
                  Color(0xFFD4AF37),
                ]
              : const [
                  Color(0xFFE0E0E0),
                  Color(0xFFB0B0B0),
                  Color(0xFF8E8E8E),
                  Color(0xFFC0C0C0),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _ChipCircuitPainter(
          lineColor: isGold
              ? const Color(0xFF6B5200).withValues(alpha: 0.6)
              : const Color(0xFF505050).withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

class _ChipCircuitPainter extends CustomPainter {
  final Color lineColor;

  _ChipCircuitPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Horizontal split line
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      paint,
    );

    // Left and right vertical contact arcs
    final rect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.5),
      width: size.width * 0.45,
      height: size.height * 0.65,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
