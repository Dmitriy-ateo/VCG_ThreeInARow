import 'dart:math';
import 'package:flutter/material.dart';

class GlassBallPainter extends CustomPainter {
  final Color color;
  final bool isTarget;

  GlassBallPainter({
    required this.color,
    this.isTarget = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double radius = min(w, h) / 2.0;
    final center = Offset(w / 2.0, h / 2.0);

    // 1. Draw outer neon glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.6),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.35));
    canvas.drawCircle(center, radius * 1.35, glowPaint);

    // 2. Draw shadow
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withValues(alpha: 0.4),
          Colors.black.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center + const Offset(2, 3), radius: radius));
    canvas.drawCircle(center + const Offset(2, 3), radius, shadowPaint);

    // 3. Base glass fill
    final basePaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 1.5, basePaint);

    // 4. Inner core glow
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.85),
          color.withValues(alpha: 0.65),
          color.withValues(alpha: 0.05),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius - 1.5));
    canvas.drawCircle(center, radius - 3, corePaint);

    // 5. Outer rim
    final rimPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius - 1.5, rimPaint);

    // 6. Highlight reflection
    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.75),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(w * 0.15, h * 0.15, w * 0.35, h * 0.35));
    
    canvas.drawOval(
      Rect.fromLTWH(w * 0.18, h * 0.18, w * 0.3, h * 0.3),
      highlightPaint,
    );

    // 7. Draw star core if it's a target item
    if (isTarget) {
      _drawStar(canvas, center, radius * 0.42);
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
      ..strokeWidth = 1.5;
    canvas.drawPath(starPath, glowPaint);

    // Draw solid white star center
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(starPath, fillPaint);
  }

  @override
  bool shouldRepaint(GlassBallPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isTarget != isTarget;
  }
}

class QueueWidget extends StatelessWidget {
  final List<Color> colors;
  final Function(int index)? onTapItem;

  const QueueWidget({
    super.key,
    required this.colors,
    this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) return const SizedBox.shrink();

    final bool showSwapTip = onTapItem != null && colors.length > 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            showSwapTip ? 'NEXT UP • TAP TO SWAP' : 'NEXT UP',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Next ball (Primary) - index 0, not interactive
              InteractiveQueueBall(
                color: colors[0],
                size: 44,
                isPrimary: true,
              ),
              const SizedBox(width: 14),
              
              // Arrow Indicator
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withValues(alpha: 0.25),
                size: 14,
              ),
              const SizedBox(width: 14),

              // Second ball
              if (colors.length > 1) ...[
                Opacity(
                  opacity: 0.75,
                  child: InteractiveQueueBall(
                    color: colors[1],
                    size: 32,
                    isPrimary: false,
                    onTap: onTapItem != null ? () => onTapItem!(1) : null,
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // Third ball
              if (colors.length > 2) ...[
                Opacity(
                  opacity: 0.75,
                  child: InteractiveQueueBall(
                    color: colors[2],
                    size: 32,
                    isPrimary: false,
                    onTap: onTapItem != null ? () => onTapItem!(2) : null,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class InteractiveQueueBall extends StatefulWidget {
  final Color color;
  final double size;
  final bool isPrimary;
  final VoidCallback? onTap;

  const InteractiveQueueBall({
    super.key,
    required this.color,
    required this.size,
    required this.isPrimary,
    this.onTap,
  });

  @override
  State<InteractiveQueueBall> createState() => _InteractiveQueueBallState();
}

class _InteractiveQueueBallState extends State<InteractiveQueueBall> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ball = SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: GlassBallPainter(
          color: widget.color,
          isTarget: false, // Queue items are never targets
        ),
      ),
    );

    if (widget.onTap == null) {
      return ball;
    }

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.15),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ball,
        ),
      ),
    );
  }
}
