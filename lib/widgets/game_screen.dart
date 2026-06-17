import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/localization.dart';
import 'hex_board_widget.dart';
import 'queue_widget.dart';
import 'bomb_inventory_button.dart';

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



  void _showSettingsModal() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Settings',
      barrierColor: Colors.black.withOpacity(0.75),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: ListenableBuilder(
            listenable: _gameState,
            builder: (context, _) {
              final String lang = _gameState.currentLanguage;
              return Container(
                width: 320,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF151426),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F0FF).withOpacity(0.08),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.translate('settings_title', lang),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded, color: Colors.white60),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Language Section
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.translate('settings_language', lang),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Language Selector Options
                      _buildLanguageOption('en', '🇬🇧 English', lang),
                      const SizedBox(height: 8),
                      _buildLanguageOption('de', '🇩🇪 Deutsch', lang),
                      const SizedBox(height: 8),
                      _buildLanguageOption('uk', '🇺🇦 Українська', lang),
                      const SizedBox(height: 24),

                      // Reset Progress Option
                      ElevatedButton(
                        onPressed: () {
                          _gameState.resetProgress();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.translate('settings_reset_confirm', lang),
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: Colors.cyanAccent,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4D4D).withOpacity(0.1),
                          foregroundColor: const Color(0xFFFF4D4D),
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: Color(0xFFFF4D4D), width: 1.0),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.translate('settings_reset', lang),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack).value,
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  Widget _buildLanguageOption(String code, String name, String currentLang) {
    final bool isSelected = code == currentLang;
    return GestureDetector(
      onTap: () => _gameState.setLanguage(code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00F0FF).withOpacity(0.08) : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF00F0FF).withOpacity(0.5) : Colors.white.withOpacity(0.05),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00F0FF).withOpacity(0.1),
                    blurRadius: 8,
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF00F0FF),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialCard() {
    final int step = _gameState.tutorialStep;
    final int level = _gameState.level;
    if (step == 0 || (level != 1 && level != 5)) return const SizedBox.shrink();

    String titleKey = level == 5 
        ? 'tutorial_l5_step${step}_title' 
        : 'tutorial_step${step}_title';
    String msgKey = level == 5 
        ? 'tutorial_l5_step${step}_msg' 
        : 'tutorial_step${step}_msg';

    if (level == 5 && step == 2 && _gameState.isBombModeActive) {
      titleKey = 'tutorial_l5_step2_active_title';
      msgKey = 'tutorial_l5_step2_active_msg';
    }
    
    final String lang = _gameState.currentLanguage;
    final String title = AppLocalizations.translate(titleKey, lang);
    final String message = AppLocalizations.translate(msgKey, lang);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151426).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Color(0xFFFFD700),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _gameState,
      builder: (context, _) {
        switch (_flowState) {
          case AppFlowState.landing:
            return _buildLandingScreen();
          case AppFlowState.menu:
            return _buildMenuScreen();
          case AppFlowState.playing:
            return _buildPlayingScreen();
        }
      },
    );
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
                        AppLocalizations.translate('title_hexa_match', _gameState.currentLanguage),
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
                        AppLocalizations.translate('subtitle_neon', _gameState.currentLanguage),
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
                      child: Text(
                        AppLocalizations.translate('btn_start_game', _gameState.currentLanguage),
                        style: const TextStyle(
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
                        AppLocalizations.translate('title_hexa_match', _gameState.currentLanguage),
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
                        AppLocalizations.translate('menu_subtitle', _gameState.currentLanguage),
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
                        title: AppLocalizations.translate('card_play_campaign', _gameState.currentLanguage, args: {'level': '${_gameState.level}'}),
                        subtitle: AppLocalizations.translate('card_campaign_sub', _gameState.currentLanguage),
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
                        title: AppLocalizations.translate('card_daily_event', _gameState.currentLanguage),
                        subtitle: AppLocalizations.translate('card_daily_sub', _gameState.currentLanguage),
                        icon: Icons.calendar_today_rounded,
                        accentColor: Colors.amberAccent,
                        badgeText: dailyCompleted 
                            ? AppLocalizations.translate('badge_completed', _gameState.currentLanguage) 
                            : AppLocalizations.translate('badge_new_challenge', _gameState.currentLanguage),
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
                          AppLocalizations.translate('panel_stats', _gameState.currentLanguage),
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
                            _buildStatItem(AppLocalizations.translate('stat_best_score', _gameState.currentLanguage), '${_gameState.highScore}'),
                            Container(
                              width: 1,
                              height: 30,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            _buildStatItem(AppLocalizations.translate('stat_levels_cleared', _gameState.currentLanguage), '${_gameState.level - 1}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: IconButton(
                onPressed: _showSettingsModal,
                icon: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: const Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
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
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
      body: Stack(
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
                  _buildTutorialCard(),
                  
                  // The Hexagonal Board
                  Expanded(
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
                        child: HexBoardWidget(gameState: _gameState),
                      ),
                    ),
                  ),

                  // Upcoming Items queue and Bomb Inventory
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      QueueWidget(
                        colors: _gameState.upcomingQueue,
                        onTapItem: _gameState.swapQueueItem,
                        highlightIndex: _gameState.level == 1 && _gameState.tutorialStep == 2 ? 1 : null,
                        languageCode: _gameState.currentLanguage,
                      ),
                      if (_gameState.level >= 5 && !_gameState.isDailyEvent) ...[
                        const SizedBox(width: 12),
                        BombInventoryButton(
                          count: _gameState.bombInventoryCount,
                          isActive: _gameState.isBombModeActive,
                          pulseGold: _gameState.level == 5 && _gameState.tutorialStep == 2 && !_gameState.isBombModeActive,
                          languageCode: _gameState.currentLanguage,
                          onTap: _gameState.toggleBombMode,
                        ),
                      ],
                    ],
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
      ),
    );
  }

  // DIFFICULTY BADGE WIDGET
  Widget _buildDifficultyBadge(String difficulty) {
    final lang = _gameState.currentLanguage;
    final String key = 'badge_difficulty_${difficulty.toLowerCase().replaceAll(' ', '_')}';
    final String localizedDifficulty = AppLocalizations.translate(key, lang);

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
        localizedDifficulty.toUpperCase(),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool isCompact = width < 400;

        final lang = _gameState.currentLanguage;
        final title = _gameState.isDailyEvent 
            ? AppLocalizations.translate('card_daily_event', lang) 
            : AppLocalizations.translate('hud_level_title', lang, args: {'level': '${_gameState.level}'});
        final subtitle = _gameState.isDailyEvent 
            ? AppLocalizations.translate('hud_daily_sub', lang) 
            : AppLocalizations.translate('hud_campaign_sub', lang);

        final Widget backButton = IconButton(
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
          padding: const EdgeInsets.only(left: 6, right: 12),
        );

        final Widget titleAndBadge = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _buildDifficultyBadge(_gameState.difficulty),
          ],
        );

        final Widget settingsButton = IconButton(
          onPressed: _showSettingsModal,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: const Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
        );

        final Widget scoreCapsule = Container(
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
        );

        final Widget targetsCapsule = Container(
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
        );

        if (isCompact) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Back + Title/Badge + Settings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        backButton,
                        Expanded(child: titleAndBadge),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  settingsButton,
                ],
              ),
              const SizedBox(height: 6),
              // Row 2: Subtitle + Score/Targets
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      scoreCapsule,
                      const SizedBox(width: 8),
                      targetsCapsule,
                    ],
                  ),
                ],
              ),
            ],
          );
        }

        // Standard Layout
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  backButton,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        titleAndBadge,
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                scoreCapsule,
                const SizedBox(width: 8),
                targetsCapsule,
                const SizedBox(width: 8),
                settingsButton,
              ],
            ),
          ],
        );
      },
    );
  }



  // GAME OVER OVERLAY
  Widget _buildGameOverOverlay() {
    final lang = _gameState.currentLanguage;
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
                AppLocalizations.translate('overlay_game_over', lang),
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
                AppLocalizations.translate('overlay_game_over_sub', lang),
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
                      AppLocalizations.translate('stat_final_score', lang),
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
                child: Text(
                  AppLocalizations.translate('btn_play_again', lang),
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

  // LEVEL COMPLETED OVERLAY
  Widget _buildLevelCompletedOverlay() {
    final lang = _gameState.currentLanguage;
    final title = _gameState.isDailyEvent 
        ? AppLocalizations.translate('overlay_victory_daily', lang)
        : AppLocalizations.translate('overlay_victory', lang);
    final desc = _gameState.isDailyEvent 
        ? AppLocalizations.translate('overlay_victory_daily_congrats', lang)
        : AppLocalizations.translate('overlay_victory_congrats', lang);
    final buttonText = _gameState.isDailyEvent 
        ? AppLocalizations.translate('btn_main_menu', lang)
        : AppLocalizations.translate('btn_next_level', lang);
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
                      AppLocalizations.translate('stat_current_score', lang),
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


