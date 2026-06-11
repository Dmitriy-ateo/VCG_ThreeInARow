import 'package:flutter/material.dart';

class GameItem {
  final String id;
  final Color color;
  final bool isNew;
  final bool isMatched;
  final bool isTarget;

  GameItem({
    required this.id,
    required this.color,
    this.isNew = true,
    this.isMatched = false,
    this.isTarget = false,
  });

  GameItem copyWith({
    String? id,
    Color? color,
    bool? isNew,
    bool? isMatched,
    bool? isTarget,
  }) {
    return GameItem(
      id: id ?? this.id,
      color: color ?? this.color,
      isNew: isNew ?? this.isNew,
      isMatched: isMatched ?? this.isMatched,
      isTarget: isTarget ?? this.isTarget,
    );
  }
}
