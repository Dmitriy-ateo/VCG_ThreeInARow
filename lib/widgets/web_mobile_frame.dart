import 'package:flutter/material.dart';
class WebMobileFrame extends StatelessWidget {
  final Widget child;

  const WebMobileFrame({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Only apply the mobile frame on web/desktop viewports
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;

        // If the viewport is already mobile-sized (e.g. mobile browser or resized window)
        // or if it's not running on web and screen is narrow, render full-screen.
        if (screenWidth <= 600) {
          return child;
        }

        // Standard mobile phone aspect ratio layout (approx 1:2 aspect ratio)
        final double phoneWidth = 400.0;
        final double phoneHeight = screenHeight > 880.0 ? 820.0 : screenHeight - 60.0;

        return Scaffold(
          backgroundColor: const Color(0xFF08080C),
          body: Stack(
            children: [
              // 1. Premium Glowing Ambient Background
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(-0.6, -0.5),
                      radius: 1.2,
                      colors: [
                        Color(0x1F00E5FF), // Cyan glow
                        Color(0x0000E0FF),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0.6, 0.5),
                      radius: 1.2,
                      colors: [
                        Color(0x1FD500F9), // Purple glow
                        Color(0x00D500F9),
                      ],
                    ),
                  ),
                ),
              ),

              // Subtle Grid Background Overlay for high-tech premium feel
              Positioned.fill(
                child: Opacity(
                  opacity: 0.03,
                  child: Image.asset(
                    'assets/images/hex_match_landing.png', // Fallback or pattern
                    fit: BoxFit.cover,
                    errorBuilder: (context, _, __) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white10, Colors.transparent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Centered Phone Mockup Frame
              Center(
                child: Container(
                  width: phoneWidth,
                  height: phoneHeight,
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F14),
                    borderRadius: BorderRadius.circular(48),
                    border: Border.all(
                      color: const Color(0xFF2E2E38),
                      width: 12, // Thick bezel simulating phone chassis
                    ),
                    boxShadow: [
                      // Outer shadow to float
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 30,
                        spreadRadius: 2,
                        offset: const Offset(0, 15),
                      ),
                      // Neon ambient outline glow
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withOpacity(0.1),
                        blurRadius: 40,
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36), // Match inner corner radius
                    child: Stack(
                      children: [
                        // The actual game content
                        Positioned.fill(child: child),

                        // 3. Simulated Status Bar Mockup
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 32,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            color: Colors.black.withOpacity(0.2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '9:41',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.signal_cellular_alt_rounded,
                                      color: Colors.white.withOpacity(0.9),
                                      size: 13,
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.wifi_rounded,
                                      color: Colors.white.withOpacity(0.9),
                                      size: 13,
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.battery_5_bar_rounded,
                                      color: Colors.white.withOpacity(0.9),
                                      size: 13,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 4. Simulated Dynamic Island
                        Positioned(
                          top: 8,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 96,
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white10,
                                  width: 0.5,
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 4,
                                  height: 4,
                                  margin: const EdgeInsets.only(right: 60),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1A1C29),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 5. Simulated Home Indicator bar at the bottom
                        Positioned(
                          bottom: 6,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 120,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 6. Optional Desktop Controls/Details Sidebar Info (Left & Right)
              if (screenWidth > 900) ...[
                Positioned(
                  left: screenWidth * 0.05,
                  top: screenHeight * 0.4,
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'HEXA MATCH',
                        style: TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'A premium hexagonal match-3 puzzle game. Align matching spheres and clear targets to level up.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: screenWidth * 0.05,
                  top: screenHeight * 0.4,
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'CONTROLS',
                        style: TextStyle(
                          color: Color(0xFFD500F9),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildControlTip(
                        icon: Icons.mouse_rounded,
                        text: 'Click empty cells to place current active item.',
                      ),
                      const SizedBox(height: 8),
                      _buildControlTip(
                        icon: Icons.touch_app_rounded,
                        text: 'Tap queue items to swap with active item.',
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlTip({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          icon,
          color: const Color(0xFFD500F9),
          size: 16,
        ),
      ],
    );
  }
}
