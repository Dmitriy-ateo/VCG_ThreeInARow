import 'package:flutter/material.dart';
import '../models/localization.dart';

class BombInventoryButton extends StatefulWidget {
  final int count;
  final bool isActive;
  final bool pulseGold;
  final String languageCode;
  final VoidCallback onTap;

  const BombInventoryButton({
    super.key,
    required this.count,
    required this.isActive,
    required this.pulseGold,
    required this.languageCode,
    required this.onTap,
  });

  @override
  State<BombInventoryButton> createState() => _BombInventoryButtonState();
}

class _BombInventoryButtonState extends State<BombInventoryButton> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _changeController;
  late Animation<double> _changeScale;
  late Animation<double> _flashIntensity;

  @override
  void initState() {
    super.initState();
    // Persistent breathing pulse
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // Count change animation
    _changeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Bouncy scale sequence (scale up to 1.35x then settle back to 1.0x)
    _changeScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.35)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.35, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
    ]).animate(_changeController);

    // Transient neon orange flash sequence
    _flashIntensity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 80,
      ),
    ]).animate(_changeController);
  }

  @override
  void didUpdateWidget(BombInventoryButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count) {
      _changeController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _changeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _changeController]),
        builder: (context, child) {
          final double progress = _pulseAnimation.value;
          final double opacity = 0.3 + 0.7 * progress;
          final double glowSpread = 2.0 + 4.0 * progress;
          final double flash = _flashIntensity.value;

          // Base styling
          Color borderColor = Colors.white.withOpacity(0.08);
          Color containerBg = widget.isActive
              ? const Color(0xFFFF5722).withOpacity(0.08)
              : Colors.white.withOpacity(0.03);

          List<BoxShadow> shadows = [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ];

          // Blend colors with flash intensity on count changes
          if (flash > 0) {
            final Color flashColor = const Color(0xFFFF5722);
            borderColor = Color.lerp(borderColor, flashColor, flash)!;
            containerBg = Color.lerp(containerBg, flashColor.withOpacity(0.18), flash)!;
            shadows.add(
              BoxShadow(
                color: flashColor.withOpacity(flash * 0.5),
                blurRadius: 10.0 + 15.0 * flash,
                spreadRadius: 1.0 + 3.0 * flash,
              ),
            );
          }

          // Apply state-based border and shadows
          if (widget.isActive) {
            final Color activeColor = const Color(0xFFFF5722); // Orange-Red neon
            borderColor = Color.lerp(borderColor, activeColor.withOpacity(opacity), 1.0 - flash)!;
            shadows.add(
              BoxShadow(
                color: activeColor.withOpacity(opacity * 0.4 * (1.0 - flash)),
                blurRadius: glowSpread * 3.0,
                spreadRadius: glowSpread * 0.5,
              ),
            );
          } else if (widget.pulseGold) {
            final Color goldColor = const Color(0xFFFFD700); // Gold
            borderColor = Color.lerp(borderColor, goldColor.withOpacity(opacity), 1.0 - flash)!;
            shadows.add(
              BoxShadow(
                color: goldColor.withOpacity(opacity * 0.4 * (1.0 - flash)),
                blurRadius: glowSpread * 3.0,
                spreadRadius: glowSpread * 0.5,
              ),
            );
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            height: 90,
            decoration: BoxDecoration(
              color: containerBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderColor,
                width: 1.5,
              ),
              boxShadow: shadows,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.translate('hud_bomb', widget.languageCode).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8),
                ScaleTransition(
                  scale: _changeScale,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '💣',
                        style: TextStyle(fontSize: 22),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (widget.count > 0)
                              ? const Color(0xFFFF4D4D).withOpacity(0.2)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: (widget.count > 0)
                                ? const Color(0xFFFF4D4D).withOpacity(0.5)
                                : Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            '${widget.count}',
                            key: ValueKey<int>(widget.count),
                            style: TextStyle(
                              color: (widget.count > 0) ? Colors.white : Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
