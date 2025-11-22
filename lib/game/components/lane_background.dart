import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LaneBackground extends PositionComponent {
  final Color color;

  LaneBackground({
    required this.color,
    required Vector2 size,
    required Vector2 position,
  }) : super(size: size, position: position);

  @override
  void render(Canvas canvas) {
    // Draw background
    canvas.drawRect(size.toRect(), Paint()..color = color.withOpacity(0.8));

    // Draw divider
    canvas.drawRect(
      Rect.fromLTWH(size.x / 2 - 1, 0, 2, size.y),
      Paint()..color = Colors.white.withOpacity(0.2),
    );
  }
}
