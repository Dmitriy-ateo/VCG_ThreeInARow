import 'dart:math';
import 'package:flutter/material.dart';

class HexagonPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;

  HexagonPainter({
    required this.fillColor,
    required this.borderColor,
    this.borderWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(w / 2, 0);
    path.lineTo(w, h / 4);
    path.lineTo(w, 3 * h / 4);
    path.lineTo(w / 2, h);
    path.lineTo(0, 3 * h / 4);
    path.lineTo(0, h / 4);
    path.close();

    canvas.drawPath(path, paint);

    if (borderWidth > 0) {
      // 1. Draw outer neon glow (bloom effect) by layering wider transparent strokes
      for (int i = 3; i > 0; i--) {
        final glowPaint = Paint()
          ..color = borderColor.withValues(alpha: 0.15 / i)
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth + (i * 2.5)
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(path, glowPaint);
      }

      // 2. Draw core neon line
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(HexagonPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}

class HexCellWidget extends StatelessWidget {
  final double size; // Radius of hexagon
  final VoidCallback onTap;
  final bool isEmpty;

  const HexCellWidget({
    super.key,
    required this.size,
    required this.onTap,
    required this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    final width = sqrt(3) * size;
    final height = 2 * size;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        child: CustomPaint(
          size: Size(width, height),
          painter: HexagonPainter(
            // Deep dark-indigo volumetric background
            fillColor: const Color(0xFF0B0A18),
            // Bright neon cyan outline for empty placeable cells, neon purple for filled cells
            borderColor: isEmpty 
                ? const Color(0xFF00F0FF).withValues(alpha: 0.4) 
                : const Color(0xFFBD00FF).withValues(alpha: 0.2),
            borderWidth: isEmpty ? 1.5 : 1.0,
          ),
        ),
      ),
    );
  }
}
