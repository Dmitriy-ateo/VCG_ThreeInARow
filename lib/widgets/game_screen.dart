import 'package:flutter/material.dart';
import '../models/game_state.dart';
import 'hex_board_widget.dart';
import 'queue_widget.dart';

enum AppFlowState {
  landing,
  menu,
  playing,
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameState _gameState = GameState();
  AppFlowState _flowState = AppFlowState.landing;

  @override
  void initState() {
    super.initState();
    // Load persisted state from SharedPreferences on startup
    _gameState.initPreferences().then((_) {
      if (mounted) setState(() {});
    });
  }



  @override
  Widget build(BuildContext context) {
    switch (_flowState) {
      case AppFlowState.landing:
        return _buildLandingScreen();
      case AppFlowState.menu:
        return _buildMenuScreen();
      case AppFlowState.playing:
        return _buildPlayingScreen();
    }
  }

  // 1. LANDING SCREEN
  Widget _buildLandingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0B1B),
      body: Stack(
        children: [
          // Background ambient glows
          Positioned(
            top: -120,
            left: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8E2DE2).withValues(alpha: 0.08),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Game Logo Header
                  Column(
                    children: [
                      Text(
                        'HEXA MATCH',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          shadows: [
                            Shadow(
                              color: Colors.cyanAccent.withValues(alpha: 0.8),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'VIBRANT NEON 3-IN-A-ROW',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),

                  // Marketing Poster Image
                  Container(
                    height: MediaQuery.of(context).size.height * 0.46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withValues(alpha: 0.15),
                          blurRadius: 25,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/images/hex_match_landing.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Start Game Button (Proceed to Menu Screen)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _flowState = AppFlowState.menu;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 8,
                        shadowColor: Colors.cyanAccent.withValues(alpha: 0.4),
                      ),
                      child: const Text(
                        'START GAME',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. MENU SCREEN (NEW)
  Widget _buildMenuScreen() {
    final bool dailyCompleted = _gameState.isDailyCompletedToday();

    return Scaffold(
      backgroundColor: const Color(0xFF0C0B1B),
      body: Stack(
        children: [
          // Background ambient glows
          Positioned(
            top: -120,
            left: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8E2DE2).withValues(alpha: 0.08),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Title / Header
                  Column(
                    children: [
                      Text(
                        'HEXA MATCH',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          shadows: [
                            Shadow(
                              color: Colors.cyanAccent.withValues(alpha: 0.8),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'SELECT YOUR CHALLENGE',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),

                  // Menu Option Cards
                  Column(
                    children: [
                      // Play Campaign Level Button
                      _buildMenuCard(
                        title: 'PLAY LEVEL ${_gameState.level}',
                        subtitle: 'Campaign progress saved on device',
                        icon: Icons.play_arrow_rounded,
                        accentColor: Colors.cyanAccent,
                        onTap: () {
                          _gameState.loadCampaignLevel();
                          setState(() {
                            _flowState = AppFlowState.playing;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Daily Challenge Event Button
                      _buildMenuCard(
                        title: 'DAILY EVENT',
                        subtitle: 'Unique layout shape • Updates daily',
                        icon: Icons.calendar_today_rounded,
                        accentColor: Colors.amberAccent,
                        badgeText: dailyCompleted ? 'COMPLETED' : 'NEW CHALLENGE',
                        badgeColor: dailyCompleted ? Colors.greenAccent : Colors.amberAccent,
                        onTap: () {
                          _gameState.startDailyEvent();
                          setState(() {
                            _flowState = AppFlowState.playing;
                          });
                        },
                      ),
                    ],
                  ),

                  // Stats Panel
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'YOUR STATS',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem('BEST SCORE', '${_gameState.highScore}'),
                            Container(
                              width: 1,
                              height: 30,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            _buildStatItem('LEVELS CLEARED', '${_gameState.level - 1}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
    String? badgeText,
    Color? badgeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Glowing Icon
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor!.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 7.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withValues(alpha: 0.2),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }



  // 4. MAIN GAME SCREEN
  Widget _buildPlayingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0B1B), // Deep space background
      body: ListenableBuilder(
        listenable: _gameState,
        builder: (context, _) {
          return Stack(
            children: [
              // Ambient Neon Background Glows
              Positioned(
                top: -120,
                left: -60,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                right: -100,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF8E2DE2).withValues(alpha: 0.06),
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Column(
                    children: [
                      // Header: Title, Subtitle, and Stats
                      _buildHeader(),
                      const SizedBox(height: 12),


                      
                      // The Hexagonal Board
                      Expanded(
                        child: Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
                            child: HexBoardWidget(gameState: _gameState),
                          ),
                        ),
                      ),

                      // Upcoming Items queue
                      const SizedBox(height: 10),
                      QueueWidget(
                        colors: _gameState.upcomingQueue,
                        onTapItem: _gameState.swapQueueItem,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Game Over Overlay
              if (_gameState.isGameOver) _buildGameOverOverlay(),

              // Level Completed Overlay
              if (_gameState.isLevelCompleted) _buildLevelCompletedOverlay(),
            ],
          );
        },
      ),
    );
  }

  // DIFFICULTY BADGE WIDGET
  Widget _buildDifficultyBadge(String difficulty) {
    Color badgeColor = Colors.grey;
    switch (difficulty) {
      case 'Easy':
        badgeColor = Colors.greenAccent;
        break;
      case 'Normal':
        badgeColor = Colors.blueAccent;
        break;
      case 'Medium':
        badgeColor = Colors.orangeAccent;
        break;
      case 'Hard':
        badgeColor = Colors.redAccent;
        break;
      case 'Very Hard':
        badgeColor = Colors.pinkAccent;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: TextStyle(
          color: badgeColor,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    final title = _gameState.isDailyEvent ? 'DAILY EVENT' : 'LEVEL ${_gameState.level}';
    final subtitle = _gameState.isDailyEvent 
        ? 'Clear all 4 target stars on today\'s board' 
        : 'Clear all target stars to advance';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side: Back button + Title Column (Title, Badge, Subtitle)
        Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _flowState = AppFlowState.menu;
                });
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.only(left: 6, right: 16),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: Colors.cyan.withValues(alpha: 0.8),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildDifficultyBadge(_gameState.difficulty),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Right side: Score & Targets Left capsules
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Score Capsule
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.cyanAccent,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_gameState.score}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      shadows: [
                        Shadow(
                          color: Colors.cyanAccent.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Targets Capsule
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Colors.amberAccent,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_gameState.targetsLeft}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      shadows: [
                        Shadow(
                          color: Colors.amberAccent.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }



  // GAME OVER OVERLAY
  Widget _buildGameOverOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32.0),
          padding: const EdgeInsets.all(28.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GAME OVER',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  shadows: [
                    Shadow(
                      color: Colors.redAccent.withValues(alpha: 0.4),
                      blurRadius: 15,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'The hexagonal field is fully occupied.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  children: [
                    Text(
                      'FINAL SCORE',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_gameState.score}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_gameState.isDailyEvent) {
                    _gameState.startDailyEvent();
                  } else {
                    _gameState.startNewGame(
                      _gameState.currentShapeType,
                      _gameState.currentSize,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: Colors.cyanAccent.withValues(alpha: 0.3),
                ),
                child: const Text(
                  'PLAY AGAIN',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // LEVEL COMPLETED OVERLAY
  Widget _buildLevelCompletedOverlay() {
    final title = _gameState.isDailyEvent ? 'EVENT COMPLETE!' : 'LEVEL CLEARED!';
    final desc = _gameState.isDailyEvent 
        ? 'You have completed today\'s special challenge!'
        : 'All target stars successfully matched.';
    final buttonText = _gameState.isDailyEvent ? 'BACK TO MENU' : 'NEXT LEVEL';
    final buttonColor = _gameState.isDailyEvent ? Colors.cyanAccent : Colors.amberAccent;

    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32.0),
          padding: const EdgeInsets.all(28.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: buttonColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                  shadows: [
                    Shadow(
                      color: buttonColor.withValues(alpha: 0.4),
                      blurRadius: 15,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  children: [
                    Text(
                      'CURRENT SCORE',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_gameState.score}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_gameState.isDailyEvent) {
                    setState(() {
                      _flowState = AppFlowState.menu;
                    });
                  } else {
                    _gameState.nextLevel();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: buttonColor.withValues(alpha: 0.3),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


