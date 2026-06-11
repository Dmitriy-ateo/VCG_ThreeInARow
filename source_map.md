# Project Source Map - Hexa Match

This file provides a lightweight, detailed structural mapping of the codebase. Read this map first to understand the architecture, file roles, and dependencies instead of reading the entire codebase, saving a significant amount of context tokens.

## Codebase Architecture Overview

The project is built as a modular Flutter application using standard MVVM architecture. State management is handled through a centralized `ChangeNotifier` (`GameState`), which notifies UI components (`ListenableBuilder`) of changes.

```
DS3/
├── .github/
│   └── workflows/
│       └── deploy.yml        # GitHub Actions workflow for automatic Pages deploy
├── lib/
│   ├── main.dart             # Application Entry Point
│   ├── models/
│   │   ├── board_shape.dart  # Geometry and layouts generators
│   │   ├── game_item.dart    # Ball state model (IDs, colors, flags)
│   │   ├── game_state.dart   # Game loops, matches scan, levels state
│   │   └── hex_coord.dart    # Hexagonal coordinate math (q, r, s)
│   └── widgets/
│       ├── game_screen.dart     # Main view with flow states & HUD
│       ├── hex_board_widget.dart# Responsive bounds calculation & positioning
│       ├── hex_cell_widget.dart # CustomPainter cell drawing (neon bloom)
│       ├── hex_item_widget.dart # CustomPainter ball drawing (glassy neon 3D)
│       ├── queue_widget.dart    # Upcoming items preview
│       └── web_mobile_frame.dart# Centered responsive mobile chassis wrapper for web
```

---

## Detailed Component Map

### 1. Data Models (`lib/models/`)

#### [hex_coord.dart](file:///Users/dmitrijkabakov/Work/ThirdParty/FlutterApp/VibeGaming/DS3/lib/models/hex_coord.dart)
- **`HexCoord`**: Represents a hexagonal cell using **Cube Coordinates** `(q, r, s)` satisfying `q + r + s = 0`.
- **Functions**:
  - `operator +`, `operator -`, `operator *`: Basic coordinate math.
  - `distance(HexCoord other)`: Calculates distance between hexes.
  - `getNeighbor(int direction)`: Returns adjacent coordinate.
  - `lineDirections`: Identifies the 3 alignment axes for match scanning.

#### [board_shape.dart](file:///Users/dmitrijkabakov/Work/ThirdParty/FlutterApp/VibeGaming/DS3/lib/models/board_shape.dart)
- **`BoardShapeType`**: Enum for shapes: `hexagon`, `triangle`, `parallelogram`, `donut`, `star`, `hourglass`, `butterfly`, `heart`.
- **`BoardShape`**: Generator class. Automatically aggregates layout coordinates and centers them around `(0, 0)` so that they scale neatly.

#### [game_item.dart](file:///Users/dmitrijkabakov/Work/ThirdParty/FlutterApp/VibeGaming/DS3/lib/models/game_item.dart)
- **`GameItem`**: Model for placed items.
- **Fields**:
  - `String id`: Unique identifier (for continuous widget keys).
  - `Color color`: Base render color.
  - `bool isNew`: Triggers entry scale animation.
  - `bool isMatched`: Triggers exit match fade/scale animation.
  - `bool isTarget`: Identifies unique golden star items for level completion.

#### [game_state.dart](file:///Users/dmitrijkabakov/Work/ThirdParty/FlutterApp/VibeGaming/DS3/lib/models/game_state.dart)
- **`GameState`**: Central ChangeNotifier orchestrating rules and state.
- **State variables**:
  - `grid`: `Map<HexCoord, GameItem>` of occupied spaces.
  - `upcomingQueue`: `List<Color>` of next 3 colors.
  - `score`, `highScore`: Scoring values.
  - `level`: Current level (starts at 1).
  - `targetsLeft`: Number of golden target star items remaining.
  - `isGameOver`, `isLevelCompleted`, `isAnimating`: Action flags.
- **Key Methods**:
  - `startNewGame(BoardShapeType shape, int size)`: Initializes level board and target counts.
  - `nextLevel()`: Increments level and cycles layout shape.
  - `placeItem(HexCoord coord)`: Main placement turn controller (places ball, clears matches, handles delays, spawns random additions).
  - `swapQueueItem(int index)`: Swaps the next placing color with one of the secondary queue colors for tactical placement.
  - `checkMatches()`: Scans the board along the 3 hex axes to detect lines of length $\ge 3$.

---

### 2. UI Widgets (`lib/widgets/`)

#### [game_screen.dart](file:///Users/dmitrijkabakov/Work/ThirdParty/FlutterApp/VibeGaming/DS3/lib/widgets/game_screen.dart)
- **`GameScreen`**: Handles the main app flow states:
  - `AppFlowState.landing`: Features poster, logo, and "START GAME" action.
  - `AppFlowState.playing`: Standard playing layout with Level, Score, Targets Left, Board, and Queue.
  - **Overlays**: Victory completed screen ("NEXT LEVEL") and game over restart screens.

#### [hex_board_widget.dart](file:///Users/dmitrijkabakov/Work/ThirdParty/FlutterApp/VibeGaming/DS3/lib/widgets/hex_board_widget.dart)
- **`HexBoardWidget`**: Grid calculator. Uses a `LayoutBuilder` to compute coordinate centers, fits the grid width/height within constraints, calculates optimal cell size `R`, and translates `(q,r)` centers to stack coordinate positions.

#### [hex_cell_widget.dart](file:///Users/dmitrijkabakov/Work/ThirdParty/FlutterApp/VibeGaming/DS3/lib/widgets/hex_cell_widget.dart)
- **`HexCellWidget`**: Cell container.
- **`HexagonPainter`**: Draws flat pointy-topped hexagons with deep-indigo volumetric backgrounds and neon-glow borders (cyan for playability, purple for occupied).

#### [hex_item_widget.dart](file:///Users/dmitrijkabakov/Work/ThirdParty/FlutterApp/VibeGaming/DS3/lib/widgets/hex_item_widget.dart)
- **`HexItemWidget`**: Ball container with controller state for scale/fade animation triggers.
- **`GlassBallPainter`**: CustomPainter drawing glassy neon 3D crystal spheres with a glowing core, neon outer rim, linear specular reflections, and gold star overlays for target items.

#### [queue_widget.dart](file:///Users/dmitrijkabakov/Work/ThirdParty/FlutterApp/VibeGaming/DS3/lib/widgets/queue_widget.dart)
- **`QueueWidget`**: Displays upcoming colors in a frosted-glass panel. Supports interactive tapping of the second or third balls to swap them to the front (with scale animation tap feedback).

#### [web_mobile_frame.dart](file:///Users/dmitrijkabakov/Work/ThirdParty/FlutterApp/VibeGaming/DS3/lib/widgets/web_mobile_frame.dart)
- **`WebMobileFrame`**: Evaluates browser screen width. If the viewport is larger than `600` logical pixels, it wraps the viewport inside a floating mobile device mockup with glowing ambient backdrops, rounded corners, simulated status/home bars, a custom Dynamic Island, and floating desktop controls guide sidebars. Otherwise, runs standard full-bleed responsive layout.
