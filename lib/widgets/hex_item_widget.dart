import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_item.dart';
import '../models/game_state.dart';
import '../models/hex_coord.dart';

class GlassBallPainter extends CustomPainter {
  final Color color;
  final bool isTarget;
  final bool isBomb;
  final bool isExploding;
  final double animationValue;

  GlassBallPainter({
    required this.color,
    this.isTarget = false,
    this.isBomb = false,
    this.isExploding = false,
    this.animationValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double radius = min(w, h) / 2.0;
    final center = Offset(w / 2.0, h / 2.0);

    if (isBomb && isExploding) {
      _paintBlackHoleExplosion(canvas, center, radius, w, h);
      return;
    }

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

    // 2. Draw sphere shadow (for depth)
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

    // 4. Draw inner glowing core
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

    // 6. Draw specular highlight reflection
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
      _drawStar(canvas, center, radius * 0.55);
    }

    // Draw fuse spark (if not exploded yet)
    if (isBomb) {
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
  }

  void _paintBlackHoleExplosion(Canvas canvas, Offset center, double radius, double w, double h) {
    final double t = animationValue;
    
    // Phase 1: Black Hole Collapse / Implosion (0.0 to 0.55)
    // Phase 2: Singularity / Critical Mass (0.55 to 0.65)
    // Phase 3: Supernova Blast / Shockwave (0.65 to 1.00)
    
    if (t < 0.55) {
      final double progress = t / 0.55;
      
      // 1. Draw Space-Time Warped Grid (funneling into center)
      _paintSpaceTimeGrid(canvas, center, radius, progress, 0.0);
      
      // 2. Accretion Disk (swirling colorful neon rings)
      _paintAccretionDisk(canvas, center, radius, t, progress);
      
      // 3. Gravitational Lensing (Einstein Ring refraction)
      _paintEinsteinRing(canvas, center, radius, progress, 0.0);
      
      // 4. Event Horizon (deep black sphere void)
      final double horizonRadius = radius * 0.75 * progress;
      final blackPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, horizonRadius, blackPaint);
      
      // Corona border
      final coronaPaint = Paint()
        ..color = const Color(0xFFFF3377).withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
      canvas.drawCircle(center, horizonRadius, coronaPaint);
      
    } else if (t < 0.65) {
      final double progress = (t - 0.55) / 0.10;
      
      // Space-time grid is distorted to the maximum and begins to break
      _paintSpaceTimeGrid(canvas, center, radius, 1.0, progress);
      
      // Einstein Ring flares up
      _paintEinsteinRing(canvas, center, radius, 1.0, progress);
      
      // Singularity point: event horizon collapses, replaced by white flash
      final double singularityRadius = radius * 0.75 * (1.0 - progress);
      if (singularityRadius > 1.0) {
        final blackPaint = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, singularityRadius, blackPaint);
      }
      
      // Bright white flash expanding in the center
      final flashPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white,
            const Color(0xFF00E5FF).withValues(alpha: 0.8),
            Colors.transparent,
          ],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 2.0 * progress));
      canvas.drawCircle(center, radius * 2.0 * progress, flashPaint);
      
    } else {
      final double blastProgress = (t - 0.65) / 0.35;
      final double opacity = (1.0 - blastProgress).clamp(0.0, 1.0);
      
      // 1. Shockwave rings expanding rapidly
      final double waveRadius = radius * 5.0 * blastProgress;
      
      // Fire ring paint (orange-red neon stroke)
      final wavePaint = Paint()
        ..color = const Color(0xFFFF4500).withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (8.0 - 6.0 * blastProgress)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
      canvas.drawCircle(center, waveRadius, wavePaint);
      
      // Inner yellow flame ring
      final innerWavePaint = Paint()
        ..color = const Color(0xFFFFEA00).withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (4.0 - 2.0 * blastProgress);
      canvas.drawCircle(center, waveRadius * 0.85, innerWavePaint);
      
      // 2. Blast Core expansion
      final coreFirePaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: opacity * 0.95),
            const Color(0xFFFFEA00).withValues(alpha: opacity * 0.75),
            const Color(0xFFFF3333).withValues(alpha: opacity * 0.35),
            Colors.transparent,
          ],
          stops: const [0.0, 0.25, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: waveRadius));
      canvas.drawCircle(center, waveRadius, coreFirePaint);
      
      // 3. Shockwave Rays (laser lines shooting out radially)
      final rayPaint = Paint()
        ..color = Colors.white.withValues(alpha: opacity * 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);
      for (int i = 0; i < 8; i++) {
        final double angle = i * (2 * pi / 8) + (t * 2.0);
        final double startDist = radius * 0.5 * blastProgress;
        final double endDist = waveRadius * 1.1;
        canvas.drawLine(
          center + Offset(cos(angle) * startDist, sin(angle) * startDist),
          center + Offset(cos(angle) * endDist, sin(angle) * endDist),
          rayPaint,
        );
      }
      
      // 4. Draw flying particles
      final double particleDistance = radius * 4.5 * blastProgress;
      final paintParticle = Paint()..style = PaintingStyle.fill;
      
      for (int i = 0; i < 12; i++) {
        final double angle = i * (2 * pi / 12) + (i * 0.4);
        final double px = center.dx + cos(angle) * (particleDistance * (0.85 + 0.15 * sin(i * 1.5)));
        final double py = center.dy + sin(angle) * (particleDistance * (0.85 + 0.15 * sin(i * 1.5)));
        
        final double pRadius = radius * 0.22 * (1.0 - blastProgress);
        if (pRadius > 0.5) {
          paintParticle.shader = RadialGradient(
            colors: [
              Colors.white.withValues(alpha: opacity),
              const Color(0xFFFFEA00).withValues(alpha: opacity * 0.9),
              const Color(0xFFFF3333).withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromCircle(center: Offset(px, py), radius: pRadius));
          
          canvas.drawCircle(Offset(px, py), pRadius, paintParticle);
        }
      }
    }
  }

  void _paintSpaceTimeGrid(Canvas canvas, Offset center, double radius, double progress, double dissolveProgress) {
    final double opacity = (1.0 - dissolveProgress).clamp(0.0, 1.0);
    if (opacity <= 0.0) return;
    
    final gridPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.18 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
      
    final gridPurplePaint = Paint()
      ..color = const Color(0xFFD500F9).withValues(alpha: 0.12 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final double maxGridRadius = radius * 3.5;
    
    Offset warpPoint(double r, double theta) {
      final double horizon = radius * 0.45 * progress;
      final double pinchStrength = 0.75 * progress;
      final double decay = exp(-r / (radius * 1.6));
      
      double rWarped = r - (r - horizon) * pinchStrength * decay;
      if (rWarped < horizon) rWarped = horizon;
      
      final double spinStrength = 2.5 * progress;
      final double thetaWarped = theta + spinStrength * exp(-r / (radius * 0.8));
      
      return center + Offset(cos(thetaWarped) * rWarped, sin(thetaWarped) * rWarped);
    }
    
    // Draw concentric warped circles
    for (int k = 1; k <= 7; k++) {
      final double rNominal = radius * (k * 0.5);
      final circlePath = Path();
      
      for (int i = 0; i <= 36; i++) {
        final double theta = i * (2 * pi / 36);
        final p = warpPoint(rNominal, theta);
        if (i == 0) {
          circlePath.moveTo(p.dx, p.dy);
        } else {
          circlePath.lineTo(p.dx, p.dy);
        }
      }
      
      canvas.drawPath(circlePath, k % 2 == 0 ? gridPaint : gridPurplePaint);
    }
    
    // Draw 12 radial warped lines
    for (int m = 0; m < 12; m++) {
      final double thetaNominal = m * (2 * pi / 12);
      final radialPath = Path();
      
      final double rStart = radius * 0.2;
      final double rEnd = maxGridRadius;
      
      for (double r = rStart; r <= rEnd; r += 5.0) {
        final p = warpPoint(r, thetaNominal);
        if (r == rStart) {
          radialPath.moveTo(p.dx, p.dy);
        } else {
          radialPath.lineTo(p.dx, p.dy);
        }
      }
      
      canvas.drawPath(radialPath, m % 2 == 0 ? gridPaint : gridPurplePaint);
    }
  }

  void _paintAccretionDisk(Canvas canvas, Offset center, double radius, double t, double progress) {
    final double diskRotation = t * 15.0;
    final diskPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
      
    for (int i = 0; i < 3; i++) {
      final double rDisk = radius * (0.7 + i * 0.2) * (1.0 - 0.25 * progress);
      final double opacity = (0.35 + 0.25 * sin(t * 12 + i)) * progress;
      if (opacity <= 0.0) continue;
      
      diskPaint.shader = SweepGradient(
        colors: [
          const Color(0xFFFF5500).withValues(alpha: opacity),
          const Color(0xFFFF0077).withValues(alpha: opacity),
          const Color(0xFF00E5FF).withValues(alpha: opacity),
          const Color(0xFFFF5500).withValues(alpha: opacity),
        ],
        transform: GradientRotation(diskRotation + i * pi / 3.0),
      ).createShader(Rect.fromCircle(center: center, radius: rDisk));
      
      canvas.drawCircle(center, rDisk, diskPaint);
    }
  }

  void _paintEinsteinRing(Canvas canvas, Offset center, double radius, double progress, double dissolveProgress) {
    final double opacity = (progress * (1.0 - dissolveProgress)).clamp(0.0, 1.0);
    if (opacity <= 0.0) return;
    
    final double ringRadius = radius * 0.75 * progress + 6.0;
    
    // Outer glow
    final haloPaint = Paint()
      ..color = const Color(0xFFD500F9).withValues(alpha: 0.45 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    canvas.drawCircle(center, ringRadius, haloPaint);
    
    // Core ring
    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5);
    canvas.drawCircle(center, ringRadius, corePaint);
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

    final glowPaint = Paint()
      ..color = const Color(0xFFFFEA00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawPath(starPath, glowPaint);

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
        oldDelegate.animationValue != animationValue;
  }
}

class HexItemWidget extends StatefulWidget {
  final GameItem item;
  final double size; // Radius of hex cell
  final GameState gameState;
  final HexCoord cell;

  const HexItemWidget({
    super.key,
    required this.item,
    required this.size,
    required this.gameState,
    required this.cell,
  });

  @override
  State<HexItemWidget> createState() => _HexItemWidgetState();
}

class _HexItemWidgetState extends State<HexItemWidget> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  Animation<Offset>? _pullAnimation;

  @override
  void initState() {
    super.initState();
    _pullAnimation = null;
    
    if (widget.item.isBomb && widget.item.isMatched) {
      // Newly placed detonating bomb (850ms multi-stage black hole & explosion timeline)
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 850),
      );
      
      _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
      _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
      
      _controller.forward();
    } else {
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
  }

  @override
  void didUpdateWidget(covariant HexItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.item.isMatched && !oldWidget.item.isMatched) {
      if (widget.item.isBomb) {
        _controller.duration = const Duration(milliseconds: 850);
        _controller.forward(from: 0.0);
      } else {
        // Detonation propagation wave delay:
        final bombEntry = widget.gameState.grid.entries.cast<MapEntry<HexCoord, GameItem>?>().firstWhere(
          (e) => e != null && e.value.isBomb && e.value.isMatched,
          orElse: () => null,
        );

        int delayMs = 0;
        if (bombEntry != null) {
          final int dist = widget.cell.distance(bombEntry.key);
          delayMs = dist * 100; // 100ms propagation delay per cell ring
          
          if (dist > 0) {
            final double dirX = (bombEntry.key.q - widget.cell.q) * sqrt(3) + 
                                (bombEntry.key.r - widget.cell.r) * (sqrt(3) / 2.0);
            final double dirY = (bombEntry.key.r - widget.cell.r) * 1.5;
            
            _pullAnimation = Tween<Offset>(
              begin: Offset.zero,
              end: Offset(dirX * widget.size, dirY * widget.size),
            ).animate(CurvedAnimation(
              parent: _controller,
              curve: Curves.easeInQuint,
            ));
          }
        }

        _scaleAnimation = Tween<double>(
          begin: _controller.value,
          end: 0.0,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInQuint,
        ));

        _opacityAnimation = Tween<double>(
          begin: _controller.value,
          end: 0.0,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeIn,
        ));

        _controller.duration = const Duration(milliseconds: 250);

        if (delayMs > 0) {
          Future.delayed(Duration(milliseconds: delayMs), () {
            if (mounted) {
              _controller.forward(from: 0.0);
            }
          });
        } else {
          _controller.forward(from: 0.0);
        }
      }
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
    final ballSize = widget.size * 1.55;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final bool isExploding = widget.item.isBomb && widget.item.isMatched;
        final double t = _controller.value;
        
        double currentScale = 1.0;
        double currentOpacity = 1.0;
        Color bombColor = color;

        if (isExploding) {
          if (t < 0.55) {
            // Implosion phase: bomb sphere collapses/shrinks
            final double localT = t / 0.55;
            currentScale = 1.0 - 0.7 * localT;
            currentOpacity = 1.0;
            bombColor = Color.lerp(color, Colors.black, localT)!;
          } else {
            // Singularity & Blast phase: bomb sphere is fully crushed/dissolved
            currentScale = 0.0;
            currentOpacity = 0.0;
          }
        } else {
          currentScale = _scaleAnimation.value;
          currentOpacity = _opacityAnimation.value;
        }

        Offset translationOffset = Offset.zero;
        if (_pullAnimation != null && widget.item.isMatched && !widget.item.isBomb) {
          translationOffset = _pullAnimation!.value;
        }

        return Transform.translate(
          offset: translationOffset,
          child: Transform.scale(
            scale: currentScale,
            child: Opacity(
              opacity: currentOpacity,
              child: SizedBox(
                width: ballSize,
                height: ballSize,
                child: CustomPaint(
                  size: Size(ballSize, ballSize),
                  painter: GlassBallPainter(
                    color: bombColor,
                    isTarget: widget.item.isTarget,
                    isBomb: widget.item.isBomb,
                    isExploding: isExploding,
                    animationValue: isExploding ? t : 0.0,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
