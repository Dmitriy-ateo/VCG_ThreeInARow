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

class HexCellWidget extends StatefulWidget {
  final double size; // Radius of hexagon
  final VoidCallback onTap;
  final bool isEmpty;
  final bool isHighlighted;

  const HexCellWidget({
    super.key,
    required this.size,
    required this.onTap,
    required this.isEmpty,
    this.isHighlighted = false,
  });

  @override
  State<HexCellWidget> createState() => _HexCellWidgetState();
}

class _HexCellWidgetState extends State<HexCellWidget> with TickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _updateAnimation();
  }

  @override
  void didUpdateWidget(HexCellWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimation();
  }

  void _updateAnimation() {
    if (widget.isHighlighted) {
      if (_controller == null) {
        _controller = AnimationController(
          duration: const Duration(milliseconds: 750),
          vsync: this,
        );
        _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _controller!, curve: Curves.easeInOut),
        );
        _controller!.repeat(reverse: true);
      }
    } else {
      if (_controller != null) {
        _controller!.dispose();
        _controller = null;
        _pulseAnimation = null;
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = sqrt(3) * widget.size;
    final height = 2 * widget.size;

    final Widget cellBody = Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      child: _pulseAnimation != null
          ? AnimatedBuilder(
              animation: _pulseAnimation!,
              builder: (context, child) {
                final double progress = _pulseAnimation!.value;
                final double opacity = 0.4 + 0.6 * progress;
                final double borderWidth = 1.5 + 2.0 * progress;

                return CustomPaint(
                  size: Size(width, height),
                  painter: HexagonPainter(
                    fillColor: const Color(0xFF0B0A18),
                    borderColor: const Color(0xFFFFD700).withOpacity(opacity),
                    borderWidth: borderWidth,
                  ),
                );
              },
            )
          : CustomPaint(
              size: Size(width, height),
              painter: HexagonPainter(
                fillColor: const Color(0xFF0B0A18),
                borderColor: widget.isEmpty
                    ? const Color(0xFF00F0FF).withValues(alpha: 0.4)
                    : const Color(0xFFBD00FF).withValues(alpha: 0.2),
                borderWidth: widget.isEmpty ? 1.5 : 1.0,
              ),
            ),
    );

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: cellBody,
    );
  }
}
