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

class _BombInventoryButtonState extends State<BombInventoryButton> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final double progress = _pulseAnimation.value;
          final double opacity = 0.3 + 0.7 * progress;
          final double glowSpread = 2.0 + 4.0 * progress;

          // Determine border/shadow color
          Color borderColor = Colors.white.withOpacity(0.08);
          List<BoxShadow> shadows = [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ];

          if (widget.isActive) {
            final Color activeColor = const Color(0xFFFF5722); // Orange-Red neon
            borderColor = activeColor.withOpacity(opacity);
            shadows.add(
              BoxShadow(
                color: activeColor.withOpacity(opacity * 0.4),
                blurRadius: glowSpread * 3.0,
                spreadRadius: glowSpread * 0.5,
              ),
            );
          } else if (widget.pulseGold) {
            final Color goldColor = const Color(0xFFFFD700); // Gold
            borderColor = goldColor.withOpacity(opacity);
            shadows.add(
              BoxShadow(
                color: goldColor.withOpacity(opacity * 0.4),
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
              color: widget.isActive
                  ? const Color(0xFFFF5722).withOpacity(0.08)
                  : Colors.white.withOpacity(0.03),
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
                Row(
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
                      child: Text(
                        '${widget.count}',
                        style: TextStyle(
                          color: (widget.count > 0) ? Colors.white : Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
