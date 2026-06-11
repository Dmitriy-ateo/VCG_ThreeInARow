import 'dart:math';
import 'hex_coord.dart';

enum BoardShapeType {
  hexagon,
  triangle,
  parallelogram,
  donut,
  star,
  hourglass,
  butterfly,
  heart,
  letter,
}

class BoardShape {
  final BoardShapeType type;
  final String name;
  final List<HexCoord> cells;

  BoardShape({
    required this.type,
    required this.name,
    required this.cells,
  });

  factory BoardShape.generate(BoardShapeType type, {int size = 3}) {
    List<HexCoord> cells = [];
    switch (type) {
      case BoardShapeType.hexagon:
        // Classic Hexagon centered at (0,0)
        // size acts as radius
        for (int q = -size; q <= size; q++) {
          int r1 = max(-size, -q - size);
          int r2 = min(size, -q + size);
          for (int r = r1; r <= r2; r++) {
            cells.add(HexCoord(q, r));
          }
        }
        return BoardShape(
          type: type,
          name: 'Hexagon (Radius $size)',
          cells: cells,
        );

      case BoardShapeType.donut:
        // Hexagon with a hole in the middle
        int radius = size;
        int innerHoleRadius = size > 2 ? size - 2 : 1;
        for (int q = -radius; q <= radius; q++) {
          int r1 = max(-radius, -q - radius);
          int r2 = min(radius, -q + radius);
          for (int r = r1; r <= r2; r++) {
            var c = HexCoord(q, r);
            if (c.distance(const HexCoord(0, 0)) >= innerHoleRadius) {
              cells.add(c);
            }
          }
        }
        return BoardShape(
          type: type,
          name: 'Donut (Radius $size)',
          cells: cells,
        );

      case BoardShapeType.triangle:
        // Triangle shape of given side length (size + 3)
        int side = size + 3;
        List<HexCoord> rawCells = [];
        int sumQ = 0;
        int sumR = 0;
        for (int q = 0; q < side; q++) {
          for (int r = 0; r < side - q; r++) {
            rawCells.add(HexCoord(q, r));
            sumQ += q;
            sumR += r;
          }
        }
        // Center the triangle coordinates
        int avgQ = sumQ ~/ rawCells.length;
        int avgR = sumR ~/ rawCells.length;
        for (var c in rawCells) {
          cells.add(HexCoord(c.q - avgQ, c.r - avgR));
        }
        return BoardShape(
          type: type,
          name: 'Triangle (Side $side)',
          cells: cells,
        );

      case BoardShapeType.parallelogram:
        // Parallelogram of size x size
        int width = size + 2;
        int height = size + 2;
        List<HexCoord> rawCells = [];
        int sumQ = 0;
        int sumR = 0;
        for (int q = 0; q < width; q++) {
          for (int r = 0; r < height; r++) {
            rawCells.add(HexCoord(q, r));
            sumQ += q;
            sumR += r;
          }
        }
        // Center the coordinates
        int avgQ = sumQ ~/ rawCells.length;
        int avgR = sumR ~/ rawCells.length;
        for (var c in rawCells) {
          cells.add(HexCoord(c.q - avgQ, c.r - avgR));
        }
        return BoardShape(
          type: type,
          name: 'Parallelogram (${width}x$height)',
          cells: cells,
        );

      case BoardShapeType.star:
        // 6-pointed Star of David shape formed by two overlapping triangles
        int limit = size;
        for (int q = -limit - 1; q <= limit + 1; q++) {
          for (int r = -limit - 1; r <= limit + 1; r++) {
            int s = -q - r;
            bool inTriangleA = q <= limit && r <= limit && s <= limit;
            bool inTriangleB = q >= -limit && r >= -limit && s >= -limit;
            if (inTriangleA || inTriangleB) {
              if (q.abs() <= limit + 1 && r.abs() <= limit + 1 && s.abs() <= limit + 1) {
                cells.add(HexCoord(q, r));
              }
            }
          }
        }
        return BoardShape(
          type: type,
          name: 'Star (Size $size)',
          cells: cells,
        );

      case BoardShapeType.hourglass:
        // Hourglass shape: wider at top and bottom, narrow waist in middle
        int limit = size;
        for (int r = -limit; r <= limit; r++) {
          int halfWidth = r.abs() + 1;
          int centerQ = -r ~/ 2;
          for (int q = centerQ - halfWidth; q <= centerQ + halfWidth; q++) {
            cells.add(HexCoord(q, r));
          }
        }
        return BoardShape(
          type: type,
          name: 'Hourglass (Size $size)',
          cells: cells,
        );

      case BoardShapeType.butterfly:
        // Butterfly shape: wider at left and right sides, narrow waist in middle
        int limit = size;
        for (int q = -limit; q <= limit; q++) {
          int halfHeight = q.abs() + 1;
          int centerR = -q ~/ 2;
          for (int r = centerR - halfHeight; r <= centerR + halfHeight; r++) {
            cells.add(HexCoord(q, r));
          }
        }
        return BoardShape(
          type: type,
          name: 'Butterfly (Size $size)',
          cells: cells,
        );

      case BoardShapeType.heart:
        // Heart shape: bottom tip, rounding lobes at top, central dip
        int limit = size;
        for (int r = -limit; r <= limit; r++) {
          if (r > 0) {
            // Tapering bottom part
            int bound = limit - r;
            for (int q = -bound; q <= bound; q++) {
              cells.add(HexCoord(q, r));
            }
          } else if (r == 0) {
            // Middle line
            for (int q = -limit; q <= limit; q++) {
              cells.add(HexCoord(q, r));
            }
          } else {
            // Upper lobes part (r < 0)
            if (r == -limit) {
              // Two top peaks
              cells.add(HexCoord(-limit + 1, r));
              cells.add(HexCoord(limit - 1, r));
            } else {
              // Lobes with a central dip
              int leftBound = -limit + (r.abs() ~/ 2);
              int rightBound = limit - (r.abs() ~/ 2);
              bool hasDip = r <= -limit ~/ 2;
              
              for (int q = leftBound; q <= rightBound; q++) {
                if (hasDip && q == 0) continue;
                cells.add(HexCoord(q, r));
              }
            }
          }
        }
        return BoardShape(
          type: type,
          name: 'Heart (Size $size)',
          cells: cells,
        );

      case BoardShapeType.letter:
        // Letter 'V' shape
        List<HexCoord> rawCells = [
          const HexCoord(0, 0),
          const HexCoord(0, 1),
          const HexCoord(0, -1),
          // Left arm
          const HexCoord(-1, 1), const HexCoord(-1, 2),
          const HexCoord(-2, 2), const HexCoord(-2, 3),
          const HexCoord(-3, 3), const HexCoord(-3, 4),
          // Right arm
          const HexCoord(1, -1), const HexCoord(1, -2),
          const HexCoord(2, -2), const HexCoord(2, -3),
          const HexCoord(3, -3), const HexCoord(3, -4),
          // Extra padding for connectivity
          const HexCoord(-1, 0), const HexCoord(1, 0),
        ];
        List<HexCoord> centeredCells = [];
        // Center the letter coordinates
        int sumQ = 0, sumR = 0;
        for (var c in rawCells) {
          sumQ += c.q;
          sumR += c.r;
        }
        int avgQ = sumQ ~/ rawCells.length;
        int avgR = sumR ~/ rawCells.length;
        for (var c in rawCells) {
          centeredCells.add(HexCoord(c.q - avgQ, c.r - avgR));
        }
        return BoardShape(
          type: type,
          name: 'Daily "V" Challenge',
          cells: centeredCells,
        );
    }
  }
}
