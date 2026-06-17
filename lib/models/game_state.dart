import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'hex_coord.dart';
import 'board_shape.dart';
import 'game_item.dart';

class GameState extends ChangeNotifier {
  final Random _random = Random();
  int _itemIdCounter = 0;
  SharedPreferences? _prefs;

  // Board layout
  late BoardShape currentBoardShape;
  BoardShapeType _currentShapeType = BoardShapeType.hexagon;
  int _currentSize = 3;

  // Game state
  Map<HexCoord, GameItem> grid = {};
  List<Color> upcomingQueue = [];
  int score = 0;
  int highScore = 0;
  bool isGameOver = false;
  bool isAnimating = false;

  // Level Progression state
  int level = 1;
  int targetsLeft = 0;
  bool isLevelCompleted = false;

  // Daily Event state
  bool isDailyEvent = false;

  // Localization and Tutorial states
  String _currentLanguage = 'en';
  int tutorialStep = 0;

  // Bomb Inventory state
  int bombInventoryCount = 0;
  bool isBombModeActive = false;

  void toggleBombMode() {
    if (level < 5) return;
    if (bombInventoryCount > 0) {
      isBombModeActive = !isBombModeActive;
      notifyListeners();
    }
  }

  String get currentLanguage => _currentLanguage;

  void setLanguage(String langCode) {
    _currentLanguage = langCode;
    _prefs?.setString('language_code', langCode);
    notifyListeners();
  }

  void resetProgress() {
    level = 1;
    highScore = 0;
    bombInventoryCount = 0;
    if (_prefs != null) {
      _prefs!.setInt('unlocked_level', 1);
      _prefs!.setInt('high_score', 0);
      _prefs!.setInt('bomb_inventory', 0);
    }
    startNewGame(BoardShapeType.hexagon, 3);
  }

  // Configuration: Full Color Palette (Premium HSL-based bright colors)
  static const List<Color> colors = [
    Color(0xFFFF4D4D), // Red
    Color(0xFF3399FF), // Blue
    Color(0xFF2EE52E), // Green
    Color(0xFFFFCC00), // Yellow
    Color(0xFFCC66FF), // Purple
    Color(0xFFFF9933), // Orange
  ];

  GameState() {
    currentBoardShape = BoardShape.generate(_currentShapeType, size: _currentSize);
    startNewGame(_currentShapeType, _currentSize);
  }

  BoardShapeType get currentShapeType => _currentShapeType;
  int get currentSize => _currentSize;

  // PERSISTENCE: Initialize shared preferences and load progress
  Future<void> initPreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      level = _prefs!.getInt('unlocked_level') ?? 1;
      highScore = _prefs!.getInt('high_score') ?? 0;
      bombInventoryCount = _prefs!.getInt('bomb_inventory') ?? 0;
      _currentLanguage = _prefs!.getString('language_code') ?? 'en';
    } catch (e) {
      debugPrint('Warning: SharedPreferences initialization failed ($e). Falling back to in-memory state.');
    }
    
    // Re-initialize standard game with loaded level shape and size
    loadCampaignLevel();
  }

  // Load the correct campaign level parameters (shape and size)
  void loadCampaignLevel() {
    if (level == 5) {
      startNewGame(BoardShapeType.hexagon, 3);
      return;
    }
    final shapes = BoardShapeType.values.where((s) => s != BoardShapeType.letter).toList();
    final shape = shapes[(level - 1) % shapes.length];
    int size = 3;
    if (level > 4) {
      size = 4;
    }
    startNewGame(shape, size);
  }

  // BALANCED DIFFICULTY & COLOR POOL SCALING
  int get activeColorsCount {
    final int cellCount = currentBoardShape.cells.length;
    if (isDailyEvent) {
      return 3; // Daily challenge on Letter shape (17 cells) uses 3 colors to make matching possible
    }
    
    // Scale colors by grid size to make smaller grids solvable
    if (cellCount <= 40) return 3; // 3 colors for small & medium boards (e.g. Hexagon radius 3 = 37 cells)
    if (cellCount <= 70) return 4; // 4 colors for large boards (e.g. Hexagon radius 4 = 61 cells)
    return 5;                      // 5 colors for extremely large boards
  }

  List<Color> getActiveColors() {
    return colors.sublist(0, activeColorsCount);
  }

  // CALCULATE DIFFICULTY
  String get difficulty {
    final int colorCount = activeColorsCount;
    
    double shapeFactor = 1.0;
    switch (currentBoardShape.type) {
      case BoardShapeType.hexagon:
        shapeFactor = 1.0;
        break;
      case BoardShapeType.parallelogram:
        shapeFactor = 1.15;
        break;
      case BoardShapeType.triangle:
        shapeFactor = 1.30;
        break;
      case BoardShapeType.donut:
        shapeFactor = 1.45;
        break;
      case BoardShapeType.star:
        shapeFactor = 1.25;
        break;
      case BoardShapeType.hourglass:
        shapeFactor = 1.30;
        break;
      case BoardShapeType.butterfly:
        shapeFactor = 1.30;
        break;
      case BoardShapeType.heart:
        shapeFactor = 1.40;
        break;
      case BoardShapeType.letter:
        shapeFactor = 1.35;
        break;
    }

    final int cellCount = currentBoardShape.cells.length;
    final double rating = (colorCount * 1.5) * shapeFactor * (37.0 / cellCount);

    if (rating < 7.0) return 'Easy';
    if (rating < 11.0) return 'Normal';
    if (rating < 16.0) return 'Medium';
    if (rating < 22.0) return 'Hard';
    return 'Very Hard';
  }

  // BALANCED SPAWNING GETTERS
  int get spawnsPerTurn {
    final int cellCount = currentBoardShape.cells.length;
    if (cellCount <= 40) return 1; // 1 spawn per turn for small & medium fields (up to 40 cells)
    if (cellCount <= 70) return 2; // 2 spawns per turn for large fields (up to 70 cells)
    return 3;                      // 3 spawns per turn for extremely large fields
  }

  int get targetSpawnsCount {
    final int cellCount = currentBoardShape.cells.length;
    if (cellCount <= 20) {
      return ((level - 1) ~/ 3 + 2).clamp(2, 4); // Level 1-3: 2 targets, Level 4-6: 3 targets, Level 7+: 4 targets (capped)
    }
    if (cellCount <= 45) {
      return ((level - 1) ~/ 3 + 2).clamp(2, 5); // Level 1-3: 2, Level 4-6: 3, Level 7-9: 4, Level 10+: 5 (capped)
    }
    return ((level - 1) ~/ 2 + 3).clamp(3, 7);   // Level 1-2: 3, Level 3-4: 4, Level 5-6: 5, Level 7-8: 6, Level 9+: 7 (capped)
  }

  int get initialStandardSpawnsCount {
    final int cellCount = currentBoardShape.cells.length;
    if (cellCount <= 20) return 2;
    if (cellCount <= 45) return 2; // Reduced from 3 to allow more breathing room at startup
    return 3;                      // Reduced from 4
  }

  // Swap queue item to active position
  void swapQueueItem(int index) {
    if (isGameOver || isLevelCompleted || isAnimating) return;
    if (index < 0 || index >= upcomingQueue.length) return;
    if (index == 0) return; // Already the active next item

    // Level 5 Tutorial: Swaps disabled entirely
    if (level == 5) {
      return;
    }

    // Level 1 Tutorial Swap Restrictions
    if (level == 1) {
      if (tutorialStep == 2) {
        // Must swap index 1 (Green)
        if (index != 1) return;
        tutorialStep = 3;
      } else {
        // Swaps disabled in steps 1 and 3
        return;
      }
    }

    final Color temp = upcomingQueue[0];
    upcomingQueue[0] = upcomingQueue[index];
    upcomingQueue[index] = temp;
    
    notifyListeners();
  }

  String _generateUniqueId() {
    _itemIdCounter++;
    return 'ball_$_itemIdCounter';
  }

  Color _getRandomColor() {
    final activePool = getActiveColors();
    return activePool[_random.nextInt(activePool.length)];
  }

  // STANDARD GAME INITIALIZATION
  void startNewGame(BoardShapeType shapeType, int size) {
    isDailyEvent = false;
    if (level == 5) {
      _currentShapeType = BoardShapeType.hexagon;
      _currentSize = 3;
    } else {
      _currentShapeType = shapeType;
      _currentSize = size;
    }
    currentBoardShape = BoardShape.generate(_currentShapeType, size: _currentSize);
    
    grid.clear();
    isGameOver = false;
    isLevelCompleted = false;
    isAnimating = false;
    score = 0;
    isBombModeActive = false;
    
    if (level == 1) {
      tutorialStep = 1;
      targetsLeft = 2;

      // 1. Spawn fixed target items
      grid[const HexCoord(0, 1)] = GameItem(
        id: _generateUniqueId(),
        color: colors[0], // Red
        isNew: false,
        isTarget: true,
      );
      grid[const HexCoord(1, 0)] = GameItem(
        id: _generateUniqueId(),
        color: colors[2], // Green
        isNew: false,
        isTarget: true,
      );

      // 2. Initialize upcoming queue (Red, Blue, Green)
      upcomingQueue = [colors[0], colors[1], colors[2]];

      // 3. Spawn fixed standard items
      grid[const HexCoord(0, -1)] = GameItem(
        id: _generateUniqueId(),
        color: colors[0], // Red
        isNew: false,
        isTarget: false,
      );
      grid[const HexCoord(-1, 0)] = GameItem(
        id: _generateUniqueId(),
        color: colors[2], // Green
        isNew: false,
        isTarget: false,
      );
    } else if (level == 5) {
      tutorialStep = 1;
      targetsLeft = 1;

      // 1. Spawn fixed target item (Yellow star at (1, 0))
      grid[const HexCoord(1, 0)] = GameItem(
        id: _generateUniqueId(),
        color: colors[3], // Yellow (colors[3])
        isNew: false,
        isTarget: true,
      );

      // 2. Initialize upcoming queue (Red, Blue, Green)
      upcomingQueue = [colors[0], colors[1], colors[2]];

      // 3. Spawn fixed standard items
      // Red spheres pre-placed at (0, -1), (0, 1), and (0, 2).
      grid[const HexCoord(0, -1)] = GameItem(
        id: _generateUniqueId(),
        color: colors[0], // Red
        isNew: false,
        isTarget: false,
      );
      grid[const HexCoord(0, 1)] = GameItem(
        id: _generateUniqueId(),
        color: colors[0], // Red
        isNew: false,
        isTarget: false,
      );
      grid[const HexCoord(0, 2)] = GameItem(
        id: _generateUniqueId(),
        color: colors[0], // Red
        isNew: false,
        isTarget: false,
      );

      // Blue spheres pre-placed at (-1, -1) and (-1, 1).
      grid[const HexCoord(-1, -1)] = GameItem(
        id: _generateUniqueId(),
        color: colors[1], // Blue
        isNew: false,
        isTarget: false,
      );
      grid[const HexCoord(-1, 1)] = GameItem(
        id: _generateUniqueId(),
        color: colors[1], // Blue
        isNew: false,
        isTarget: false,
      );
    } else {
      tutorialStep = 0;
      targetsLeft = targetSpawnsCount;

      // 1. Spawn target items on start
      _spawnTargetItems(targetsLeft);

      // 2. Initialize upcoming queue
      upcomingQueue = List.generate(3, (_) => _getRandomColor());

      // 3. Spawn initial standard items based on board size
      _spawnRandomItems(initialStandardSpawnsCount, initial: true);
    }
    
    for (var key in grid.keys) {
      grid[key] = grid[key]!.copyWith(isNew: false);
    }
    
    notifyListeners();
  }

  // DAILY EVENT INITIALIZATION
  void startDailyEvent() {
    isDailyEvent = true;
    currentBoardShape = BoardShape.generate(BoardShapeType.letter);
    
    grid.clear();
    isGameOver = false;
    isLevelCompleted = false;
    isAnimating = false;
    score = 0;
    isBombModeActive = false;

    // Generate date seed: YYYYMMDD
    final now = DateTime.now();
    final int dateSeed = now.year * 10000 + now.month * 100 + now.day;
    final seededRandom = Random(dateSeed);

    targetsLeft = 4;

    // 1. Spawn target items with standard colors using seeded random
    _spawnTargetItemsSeeded(targetsLeft, seededRandom);

    // 2. Initialize upcoming queue using seeded colors
    upcomingQueue = List.generate(3, (_) => _getRandomColorSeeded(seededRandom));

    // 3. Spawn 2 initial standard items using seeded random
    _spawnRandomItemsSeeded(2, seededRandom, initial: true);

    for (var key in grid.keys) {
      grid[key] = grid[key]!.copyWith(isNew: false);
    }

    notifyListeners();
  }

  // Persistent completion checks for Daily Challenges
  bool isDailyCompletedToday() {
    if (_prefs == null) return false;
    final now = DateTime.now();
    final key = 'daily_completed_${now.year}_${now.month}_${now.day}';
    return _prefs!.getBool(key) ?? false;
  }

  void _markDailyCompletedToday() {
    if (_prefs == null) return;
    final now = DateTime.now();
    final key = 'daily_completed_${now.year}_${now.month}_${now.day}';
    _prefs!.setBool(key, true);
  }

  // ADVANCE STANDARD LEVELS
  void nextLevel() {
    if (isDailyEvent) {
      isDailyEvent = false;
      startNewGame(BoardShapeType.hexagon, 3);
      return;
    }

    level++;
    if (_prefs != null) {
      _prefs!.setInt('unlocked_level', level);
    }
    
    final shapes = BoardShapeType.values.where((s) => s != BoardShapeType.letter).toList();
    final nextShape = shapes[(level - 1) % shapes.length];
    
    int nextSize = 3;
    if (level > 4) {
      nextSize = 4;
    }
    
    startNewGame(nextShape, nextSize);
  }

  // Find all cells that are part of the board but currently empty
  List<HexCoord> getEmptyCells() {
    return currentBoardShape.cells.where((cell) => !grid.containsKey(cell)).toList();
  }

  // Tries to place the next item from the queue onto the selected cell
  Future<void> placeItem(HexCoord coord) async {
    if (isGameOver || isLevelCompleted || isAnimating) {
      return;
    }
    
    // Tapping occupied cells is only allowed in Bomb Mode
    if (!isBombModeActive && grid.containsKey(coord)) {
      return;
    }

    // Level 1 Tutorial Placement Restrictions
    if (level == 1) {
      if (tutorialStep == 1) {
        // Step 1: Must place at (0, 0)
        if (coord.q != 0 || coord.r != 0) return;
      } else if (tutorialStep == 3) {
        // Step 3: Must place at (0, 0)
        if (coord.q != 0 || coord.r != 0) return;
      } else {
        // Step 2: Placements disabled, must swap queue first
        return;
      }
    }

    // Level 5 Tutorial Placement Restrictions
    if (level == 5) {
      if (tutorialStep == 1) {
        // Step 1: Must place at (0, 0)
        if (coord.q != 0 || coord.r != 0) return;
      } else if (tutorialStep == 2) {
        // Step 2: Must place the bomb at (0, 0)
        if (!isBombModeActive) return;
        if (coord.q != 0 || coord.r != 0) return;
      } else {
        return;
      }
    }

    // DETONATE BOMB MODE
    if (isBombModeActive) {
      isAnimating = true;
      isBombModeActive = false;
      bombInventoryCount = max(0, bombInventoryCount - 1);
      if (_prefs != null) {
        _prefs!.setInt('bomb_inventory', bombInventoryCount);
      }
      notifyListeners();

      // Gather coordinates to clear: coord itself + its 6 neighbors
      Set<HexCoord> toClear = {coord};
      for (var dir in HexCoord.directions) {
        HexCoord neighbor = coord + dir;
        if (currentBoardShape.cells.contains(neighbor)) {
          toClear.add(neighbor);
        }
      }

      // Chain reactions
      final Set<HexCoord> resolvedClear = _resolveBombs(toClear);

      // Temporary bomb GameItem at coord to play the detonation animation
      grid[coord] = GameItem(
        id: _generateUniqueId(),
        color: Colors.grey,
        isBomb: true,
        isMatched: true,
        isNew: true,
      );

      int pointsEarned = resolvedClear.length * 10;
      if (resolvedClear.length > 3) {
        pointsEarned += (resolvedClear.length - 3) * 15;
      }
      score += pointsEarned;
      if (score > highScore) {
        highScore = score;
        if (_prefs != null) {
          _prefs!.setInt('high_score', highScore);
        }
      }

      int targetsCleared = resolvedClear.where((c) => grid[c]?.isTarget == true).length;
      targetsLeft = max(0, targetsLeft - targetsCleared);

      for (var c in resolvedClear) {
        if (c != coord && grid.containsKey(c)) {
          grid[c] = grid[c]!.copyWith(isMatched: true);
        }
      }
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 850));

      for (var c in resolvedClear) {
        grid.remove(c);
      }
      grid.remove(coord);

      _clearNewFlags();
      isAnimating = false;

      // Level 5 Tutorial Step Progression
      if (level == 5 && tutorialStep == 2) {
        tutorialStep = 0;
      }

      _checkLevelOrGameOver();
      notifyListeners();
      return;
    }

    // STANDARD PLACEMENT MODE
    Color nextColor = upcomingQueue.removeAt(0);
    upcomingQueue.add(_getRandomColor());

    grid[coord] = GameItem(
      id: _generateUniqueId(),
      color: nextColor,
      isNew: true,
      isTarget: false,
    );
    notifyListeners();

    isAnimating = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 150));

    Set<HexCoord> matches = checkMatches();

    if (matches.isNotEmpty) {
      final bool addBombToInventory = level >= 5 && matches.length >= 4;
      final Set<HexCoord> resolvedClear = _resolveBombs(matches);

      int pointsEarned = resolvedClear.length * 10;
      if (resolvedClear.length > 3) {
        pointsEarned += (resolvedClear.length - 3) * 15;
      }
      score += pointsEarned;
      if (score > highScore) {
        highScore = score;
        if (_prefs != null) {
          _prefs!.setInt('high_score', highScore);
        }
      }

      int targetsCleared = resolvedClear.where((c) => grid[c]?.isTarget == true).length;
      targetsLeft = max(0, targetsLeft - targetsCleared);

      for (var c in resolvedClear) {
        if (grid.containsKey(c)) {
          grid[c] = grid[c]!.copyWith(isMatched: true);
        }
      }
      notifyListeners();

      bool hasBomb = resolvedClear.any((c) => grid[c]?.isBomb == true);
      await Future.delayed(Duration(milliseconds: hasBomb ? 850 : 300));

      for (var c in resolvedClear) {
        grid.remove(c);
      }

      if (addBombToInventory) {
        bombInventoryCount++;
        if (_prefs != null) {
          _prefs!.setInt('bomb_inventory', bombInventoryCount);
        }
      }
      
      _clearNewFlags();
      isAnimating = false;
      
      // Tutorial step progression after match is successfully cleared
      if (level == 1) {
        if (tutorialStep == 1) {
          tutorialStep = 2;
        } else if (tutorialStep == 3) {
          tutorialStep = 0;
        }
      } else if (level == 5) {
        if (tutorialStep == 1) {
          tutorialStep = 2;
        }
      }
      
      _checkLevelOrGameOver();
      notifyListeners();
    } else {
      _clearNewFlags();
      
      // In tutorial levels, we do not spawn random items
      if (level == 1 || level == 5) {
        isAnimating = false;
        _checkLevelOrGameOver();
        notifyListeners();
        return;
      }
      
      bool spawnedAny = _spawnRandomItems(spawnsPerTurn);
      notifyListeners();

      if (spawnedAny) {
        await Future.delayed(const Duration(milliseconds: 150));
        
        Set<HexCoord> randomMatches = checkMatches();
        if (randomMatches.isNotEmpty) {
          final Set<HexCoord> resolvedRandomClear = _resolveBombs(randomMatches);

          int pointsEarned = resolvedRandomClear.length * 10;
          score += pointsEarned;
          if (score > highScore) {
            highScore = score;
            if (_prefs != null) {
              _prefs!.setInt('high_score', highScore);
            }
          }

          int targetsCleared = resolvedRandomClear.where((c) => grid[c]?.isTarget == true).length;
          targetsLeft = max(0, targetsLeft - targetsCleared);

          for (var c in resolvedRandomClear) {
            if (grid.containsKey(c)) {
              grid[c] = grid[c]!.copyWith(isMatched: true);
            }
          }
          notifyListeners();

          bool hasBomb = resolvedRandomClear.any((c) => grid[c]?.isBomb == true);
          await Future.delayed(Duration(milliseconds: hasBomb ? 850 : 300));

          for (var c in resolvedRandomClear) {
            grid.remove(c);
          }

          if (level >= 5 && randomMatches.length >= 4) {
            bombInventoryCount++;
            if (_prefs != null) {
              _prefs!.setInt('bomb_inventory', bombInventoryCount);
            }
          }
        }
      }

      _clearNewFlags();
      isAnimating = false;
      _checkLevelOrGameOver();
      notifyListeners();
    }
  }

  void _clearNewFlags() {
    for (var key in grid.keys) {
      if (grid[key]!.isNew) {
        grid[key] = grid[key]!.copyWith(isNew: false);
      }
    }
  }

  // Spawns targets at random empty cells on start
  void _spawnTargetItems(int count) {
    List<HexCoord> emptyCells = getEmptyCells();
    if (emptyCells.isEmpty) return;

    int actualToSpawn = min(count, emptyCells.length);
    emptyCells.shuffle(_random);

    for (int i = 0; i < actualToSpawn; i++) {
      HexCoord cell = emptyCells[i];
      grid[cell] = GameItem(
        id: _generateUniqueId(),
        color: _getRandomColor(),
        isNew: false,
        isTarget: true,
      );
    }
  }

  // Spawns up to `count` items at random empty cells
  bool _spawnRandomItems(int count, {bool initial = false}) {
    List<HexCoord> emptyCells = getEmptyCells();
    if (emptyCells.isEmpty) return false;

    int actualToSpawn = min(count, emptyCells.length);
    emptyCells.shuffle(_random);

    for (int i = 0; i < actualToSpawn; i++) {
      HexCoord cell = emptyCells[i];
      grid[cell] = GameItem(
        id: _generateUniqueId(),
        color: _getRandomColor(),
        isNew: !initial,
        isTarget: false,
      );
    }
    return true;
  }

  // SEEDED RANDOM HELPERS FOR CONSISTENT DAILY CHALLENGE GENERATION
  Color _getRandomColorSeeded(Random rand) {
    final activePool = colors.sublist(0, 3); // Seeded layout color pool also limited to 3 colors
    return activePool[rand.nextInt(activePool.length)];
  }

  void _spawnTargetItemsSeeded(int count, Random rand) {
    List<HexCoord> emptyCells = getEmptyCells();
    if (emptyCells.isEmpty) return;

    int actualToSpawn = min(count, emptyCells.length);
    emptyCells = _seededShuffle(emptyCells, rand);

    for (int i = 0; i < actualToSpawn; i++) {
      HexCoord cell = emptyCells[i];
      grid[cell] = GameItem(
        id: _generateUniqueId(),
        color: _getRandomColorSeeded(rand),
        isNew: false,
        isTarget: true,
      );
    }
  }

  bool _spawnRandomItemsSeeded(int count, Random rand, {bool initial = false}) {
    List<HexCoord> emptyCells = getEmptyCells();
    if (emptyCells.isEmpty) return false;

    int actualToSpawn = min(count, emptyCells.length);
    emptyCells = _seededShuffle(emptyCells, rand);

    for (int i = 0; i < actualToSpawn; i++) {
      HexCoord cell = emptyCells[i];
      grid[cell] = GameItem(
        id: _generateUniqueId(),
        color: _getRandomColorSeeded(rand),
        isNew: !initial,
        isTarget: false,
      );
    }
    return true;
  }

  List<T> _seededShuffle<T>(List<T> list, Random rand) {
    final copy = List<T>.from(list);
    for (int i = copy.length - 1; i > 0; i--) {
      int j = rand.nextInt(i + 1);
      var temp = copy[i];
      copy[i] = copy[j];
      copy[j] = temp;
    }
    return copy;
  }

  Set<HexCoord> _resolveBombs(Set<HexCoord> matchedCoords) {
    if (level < 5) return matchedCoords;

    Set<HexCoord> toClear = Set.from(matchedCoords);
    bool expanded = true;
    Set<HexCoord> explodedBombs = {};

    while (expanded) {
      expanded = false;
      
      List<MapEntry<HexCoord, GameItem>> activeBombs = grid.entries
          .where((entry) => entry.value.isBomb && !explodedBombs.contains(entry.key))
          .toList();

      for (var entry in activeBombs) {
        HexCoord bombCoord = entry.key;
        bool isTriggered = toClear.contains(bombCoord);
        if (!isTriggered) {
          for (var dir in HexCoord.directions) {
            HexCoord neighbor = bombCoord + dir;
            if (toClear.contains(neighbor)) {
              isTriggered = true;
              break;
            }
          }
        }

        if (isTriggered) {
          explodedBombs.add(bombCoord);
          toClear.add(bombCoord);
          
          for (var dir in HexCoord.directions) {
            HexCoord neighbor = bombCoord + dir;
            if (currentBoardShape.cells.contains(neighbor)) {
              toClear.add(neighbor);
            }
          }
          expanded = true;
          break;
        }
      }
    }

    return toClear;
  }

  // Scans the board for any 3-in-a-row connections
  Set<HexCoord> checkMatches() {
    Set<HexCoord> matchedCoords = {};

    for (var entry in grid.entries) {
      HexCoord start = entry.key;
      GameItem item = entry.value;
      if (item.isMatched || item.isBomb) continue;

      for (var dir in HexCoord.lineDirections) {
        HexCoord prev = start - dir;
        if (grid.containsKey(prev) &&
            !grid[prev]!.isBomb &&
            grid[prev]!.color == item.color &&
            !grid[prev]!.isMatched) {
          continue;
        }

        List<HexCoord> currentLine = [start];
        HexCoord next = start + dir;
        
        while (grid.containsKey(next) &&
            !grid[next]!.isBomb &&
            grid[next]!.color == item.color &&
            !grid[next]!.isMatched) {
          currentLine.add(next);
          next = next + dir;
        }

        if (currentLine.length >= 3) {
          matchedCoords.addAll(currentLine);
        }
      }
    }

    return matchedCoords;
  }

  void _checkLevelOrGameOver() {
    if (targetsLeft == 0) {
      isLevelCompleted = true;
      if (isDailyEvent) {
        _markDailyCompletedToday();
      }
    } else if (getEmptyCells().isEmpty && checkMatches().isEmpty) {
      isGameOver = true;
    }
  }
}
