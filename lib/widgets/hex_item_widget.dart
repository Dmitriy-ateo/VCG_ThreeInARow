import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_item.dart';

class GlassBallPainter extends CustomPainter {
  final Color color;
  final bool isTarget;
  final bool isBomb;
  final bool isExploding;
  final double explosionProgress;

  GlassBallPainter({
    required this.color,
    this.isTarget = false,
    this.isBomb = false,
    this.isExploding = false,
    this.explosionProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double radius = min(w, h) / 2.0;
    final center = Offset(w / 2.0, h / 2.0);

    // Draw fuse behind the bomb sphere
    if (isBomb) {
      final fusePath = Path();
      fusePath.moveTo(center.dx, center.dy); // start inside the sphere
      fusePath.quadraticBezierTo(
        center.dx - radius * 0.25, center.dy - radius * 0.9,
        center.dx - radius * 0.45, center.dy - radius * 1.25,
      );
      final fusePaint = Paint()
        ..color = const Color(0xFF6E4A25) // Brown fuse
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(fusePath, fusePaint);
    }

    final glowColor = isBomb ? const Color(0xFFFF3333) : color;

    // 1. Draw outer neon glow (using radial gradient)
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          glowColor.withValues(alpha: 0.5),
          glowColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.35));
    canvas.drawCircle(center, radius * 1.35, glowPaint);

    // 2. Draw sphere black drop shadow (for depth)
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withValues(alpha: 0.45),
          Colors.black.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center + const Offset(3, 5), radius: radius));
    canvas.drawCircle(center + const Offset(3, 5), radius, shadowPaint);

    // 3. Draw glassy semi-transparent base fill
    final basePaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 2, basePaint);

    // 4. Draw inner glowing core (radial gradient from center)
    // Bombs have a glowing red core
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: isBomb
            ? [
                Colors.white.withValues(alpha: 0.95),
                const Color(0xFFFF3333).withValues(alpha: 0.85),
                const Color(0xFFFF3333).withValues(alpha: 0.05),
              ]
            : [
                Colors.white.withValues(alpha: 0.85),
                color.withValues(alpha: 0.65),
                color.withValues(alpha: 0.05),
              ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius - 2));
    canvas.drawCircle(center, radius - 4, corePaint);

    // 5. Draw thick outer neon rim
    final rimPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(center, radius - 2, rimPaint);

    // 6. Draw glossy specular highlight reflection (light source at top-left)
    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.75),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(w * 0.15, h * 0.15, w * 0.35, h * 0.35));
    
    // Specular highlight shape (oval)
    canvas.drawOval(
      Rect.fromLTWH(w * 0.18, h * 0.18, w * 0.3, h * 0.3),
      highlightPaint,
    );

    // 7. Draw star core if it's a target item (scaled up for visibility)
    if (isTarget) {
      _drawStar(canvas, center, radius * 0.55);
    }

    // Draw spark on top of everything
    if (isBomb && !isExploding) {
      final sparkCenter = Offset(center.dx - radius * 0.45, center.dy - radius * 1.25);
      
      // Glow behind spark
      final sparkGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFD700).withValues(alpha: 0.8), // Gold glow
            const Color(0xFFFFD700).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: sparkCenter, radius: radius * 0.45));
      canvas.drawCircle(sparkCenter, radius * 0.45, sparkGlow);

      // Draw spark lines
      final sparkPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      for (double angle = 0; angle < 2 * pi; angle += pi / 4) {
        final double len = radius * (0.15 + 0.1 * sin(angle * 2.5));
        canvas.drawLine(
          sparkCenter,
          sparkCenter + Offset(cos(angle) * len, sin(angle) * len),
          sparkPaint,
        );
      }
    }

    if (isExploding) {
      // Draw expanding fiery shockwave ring
      final double waveRadius = radius * 3.0 * explosionProgress;
      final double opacity = (1.0 - explosionProgress).clamp(0.0, 1.0);
      
      // Blast wave paint (orange-red neon stroke)
      final wavePaint = Paint()
        ..color = const Color(0xFFFF4500).withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (6.0 - 4.0 * explosionProgress)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
      canvas.drawCircle(center, waveRadius, wavePaint);

      // Inner yellow flame ring
      final innerWavePaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawCircle(center, waveRadius * 0.85, innerWavePaint);

      // Core fire expansion
      final coreFirePaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: opacity * 0.9),
            const Color(0xFFFFD700).withValues(alpha: opacity * 0.7),
            const Color(0xFFFF4500).withValues(alpha: opacity * 0.3),
            Colors.transparent,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: waveRadius));
      canvas.drawCircle(center, waveRadius, coreFirePaint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double starRadius) {
    final Path starPath = Path();
    double angle = -pi / 2;
    double add = pi / 5;
    
    for (int i = 0; i < 10; i++) {
      double r = (i % 2 == 0) ? starRadius : starRadius * 0.42;
      double x = center.dx + cos(angle) * r;
      double y = center.dy + sin(angle) * r;
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
      angle += add;
    }
    starPath.close();

    // Draw gold neon backing glow
    final glowPaint = Paint()
      ..color = const Color(0xFFFFEA00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawPath(starPath, glowPaint);

    // Draw solid white star center
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(starPath, fillPaint);
  }

  @override
  bool shouldRepaint(GlassBallPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isTarget != isTarget ||
        oldDelegate.isBomb != isBomb ||
        oldDelegate.isExploding != isExploding ||
        oldDelegate.explosionProgress != explosionProgress;
  }
}

class HexItemWidget extends StatefulWidget {
  final GameItem item;
  final double size; // Radius of hex cell

  const HexItemWidget({
    super.key,
    required this.item,
    required this.size,
  });

  @override
  State<HexItemWidget> createState() => _HexItemWidgetState();
}

class _HexItemWidgetState extends State<HexItemWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _scaleAnimation = Tween<double>(
      begin: widget.item.isNew ? 0.0 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _opacityAnimation = Tween<double>(
      begin: widget.item.isNew ? 0.0 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant HexItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If the item status changes to matched, animate exit
    if (widget.item.isMatched && !oldWidget.item.isMatched) {
      if (widget.item.isBomb) {
        _scaleAnimation = Tween<double>(
          begin: _controller.value,
          end: 2.2,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

        _opacityAnimation = Tween<double>(
          begin: _controller.value,
          end: 0.0,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInCubic));

        _controller.duration = const Duration(milliseconds: 380);
      } else {
        _scaleAnimation = Tween<double>(
          begin: _controller.value,
          end: 0.0,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInBack));

        _opacityAnimation = Tween<double>(
          begin: _controller.value,
          end: 0.0,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

        _controller.duration = const Duration(milliseconds: 280);
      }
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.item.color;
    final ballSize = widget.size * 1.55; // Enlarged to fill cells better and enhance readability

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final bool isExploding = widget.item.isBomb && widget.item.isMatched;
        final double progress = isExploding ? _controller.value : 0.0;

        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: SizedBox(
              width: ballSize,
              height: ballSize,
              child: CustomPaint(
                size: Size(ballSize, ballSize),
                painter: GlassBallPainter(
                  color: color,
                  isTarget: widget.item.isTarget,
                  isBomb: widget.item.isBomb,
                  isExploding: isExploding,
                  explosionProgress: progress,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
