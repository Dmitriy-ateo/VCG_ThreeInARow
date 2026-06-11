class HexCoord {
  final int q;
  final int r;
  final int s;

  const HexCoord(this.q, this.r) : s = -q - r;

  const HexCoord.cube(this.q, this.r, this.s) : assert(q + r + s == 0);

  // Hexagon directions (cube coordinates)
  static const List<HexCoord> directions = [
    HexCoord(1, 0),   // East-Southeast
    HexCoord(1, -1),  // East-Northeast
    HexCoord(0, -1),  // North
    HexCoord(-1, 0),  // West-Northwest
    HexCoord(-1, 1),  // West-Southwest
    HexCoord(0, 1),   // South
  ];

  // The 3 line directions for match checking (positive directions)
  static const List<HexCoord> lineDirections = [
    HexCoord(1, 0),   // Constant r axis (moving in q and s)
    HexCoord(0, 1),   // Constant q axis (moving in r and s)
    HexCoord(1, -1),  // Constant s axis (moving in q and r)
  ];

  HexCoord operator +(HexCoord other) {
    return HexCoord(q + other.q, r + other.r);
  }

  HexCoord operator -(HexCoord other) {
    return HexCoord(q - other.q, r - other.r);
  }

  HexCoord operator *(int factor) {
    return HexCoord(q * factor, r * factor);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HexCoord && other.q == q && other.r == r;
  }

  @override
  int get hashCode => Object.hash(q, r);

  int distance(HexCoord other) {
    return ((q - other.q).abs() + (r - other.r).abs() + (s - other.s).abs()) ~/ 2;
  }

  HexCoord getNeighbor(int direction) {
    return this + directions[direction % 6];
  }

  @override
  String toString() => 'HexCoord($q, $r, $s)';
}
