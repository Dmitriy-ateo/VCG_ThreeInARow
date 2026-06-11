import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/hex_coord.dart';
import 'hex_cell_widget.dart';
import 'hex_item_widget.dart';

class HexBoardWidget extends StatelessWidget {
  final GameState gameState;

  const HexBoardWidget({
    super.key,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availWidth = constraints.maxWidth;
        final double availHeight = constraints.maxHeight;

        final cells = gameState.currentBoardShape.cells;
        if (cells.isEmpty) return const SizedBox.shrink();

        // 1. Calculate local coordinates at R = 1.0 for pointy-topped hexagons
        // x = (sqrt(3) * q + sqrt(3)/2 * r)
        // y = (3/2 * r)
        final double sqrt3 = sqrt(3);
        List<Offset> centers = [];
        double minX = double.infinity;
        double maxX = -double.infinity;
        double minY = double.infinity;
        double maxY = -double.infinity;

        for (var c in cells) {
          double cx = sqrt3 * c.q + (sqrt3 / 2.0) * c.r;
          double cy = 1.5 * c.r;
          centers.add(Offset(cx, cy));

          // Bound calculations (each hexagon has width = sqrt3, height = 2)
          double left = cx - sqrt3 / 2.0;
          double right = cx + sqrt3 / 2.0;
          double top = cy - 1.0;
          double bottom = cy + 1.0;

          if (left < minX) minX = left;
          if (right > maxX) maxX = right;
          if (top < minY) minY = top;
          if (bottom > maxY) maxY = bottom;
        }

        double boardWidth = maxX - minX;
        double boardHeight = maxY - minY;

        double centerX = (minX + maxX) / 2.0;
        double centerY = (minY + maxY) / 2.0;

        // 2. Scale size R to fit constraints with padding
        double scaleX = availWidth / boardWidth;
        double scaleY = availHeight / boardHeight;
        
        // Choose radius R to fit both dimensions nicely
        double R = min(scaleX, scaleY) * 0.90;

        // Clamp to prevent layout breakage on extreme aspect ratios
        R = R.clamp(18.0, 75.0);

        final double hexWidth = sqrt3 * R;
        final double hexHeight = 2.0 * R;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Layer 1: Render static cell backgrounds (isolated using RepaintBoundary)
            Positioned.fill(
              child: RepaintBoundary(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: List.generate(cells.length, (index) {
                    final cell = cells[index];
                    final center = centers[index];

                    // Translate center to container coordinates
                    double px = availWidth / 2.0 + (center.dx - centerX) * R;
                    double py = availHeight / 2.0 + (center.dy - centerY) * R;

                    // Top-left position of the hexagon container
                    double left = px - hexWidth / 2.0;
                    double top = py - hexHeight / 2.0;

                    bool isHighlighted = false;
                    if (gameState.level == 1) {
                      isHighlighted = (gameState.tutorialStep == 1 || gameState.tutorialStep == 3) &&
                          cell.q == 0 &&
                          cell.r == 0;
                    } else if (gameState.level == 5) {
                      if (gameState.tutorialStep == 1) {
                        isHighlighted = cell.q == 0 && cell.r == 0;
                      } else if (gameState.tutorialStep == 2) {
                        isHighlighted = cell.q == -1 && cell.r == 0;
                      }
                    }

                    return Positioned(
                      left: left,
                      top: top,
                      child: HexCellWidget(
                        size: R,
                        isEmpty: !gameState.grid.containsKey(cell),
                        isHighlighted: isHighlighted,
                        onTap: (Offset localPos) {
                          final double centerX = hexWidth / 2;
                          final double centerY = hexHeight / 2;
                          final double dx = localPos.dx - centerX;
                          final double dy = localPos.dy - centerY;
                          
                          final bool isOccupied = gameState.grid.containsKey(cell);
                          
                          if (isOccupied && dy > 0 && gameState.level != 1 && gameState.level != 5) {
                            HexCoord? neighbor;
                            if (dx > 0) {
                              // Bottom-right quadrant -> bottom-right neighbor
                              neighbor = cell + const HexCoord(0, 1);
                            } else if (dx < 0) {
                              // Bottom-left quadrant -> bottom-left neighbor
                              neighbor = cell + const HexCoord(-1, 1);
                            }
                            
                            if (neighbor != null &&
                                gameState.currentBoardShape.cells.contains(neighbor) &&
                                !gameState.grid.containsKey(neighbor)) {
                              gameState.placeItem(neighbor);
                              return;
                            }
                          }
                          gameState.placeItem(cell);
                        },
                      ),
                    );
                  }),
                ),
              ),
            ),

            // Layer 2: Render animated items (isolated overlay stack)
            Positioned.fill(
              child: Stack(
                clipBehavior: Clip.none,
                children: gameState.grid.entries.map((entry) {
                  final cell = entry.key;
                  final item = entry.value;

                  int cellIndex = cells.indexOf(cell);
                  if (cellIndex == -1) return const SizedBox.shrink();
                  final center = centers[cellIndex];

                  double px = availWidth / 2.0 + (center.dx - centerX) * R;
                  double py = availHeight / 2.0 + (center.dy - centerY) * R;

                  // Position the item centered in the cell
                  double ballSize = R * 1.55;
                  double left = px - ballSize / 2.0;
                  double top = py - ballSize / 2.0;

                  return Positioned(
                    key: ValueKey(item.id),
                    left: left,
                    top: top,
                    child: IgnorePointer(
                      child: HexItemWidget(
                        item: item,
                        size: R,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
