import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/falling_object.dart';
import '../../models/car.dart';

import 'package:flame/collisions.dart';

class FallingObjectComponent extends PositionComponent {
  final FallingObject object;
  final double laneWidth;

  FallingObjectComponent({required this.object, required this.laneWidth})
    : super(size: Vector2(40, 40), anchor: Anchor.center);

  @override
  void onLoad() {
    // Set initial position
    double startX = object.side == CarSide.left ? 0 : laneWidth * 2;
    double offset = object.laneIndex == 0 ? laneWidth / 2 : laneWidth * 1.5;
    position.x = startX + offset;
    position.y = -50; // Start above screen

    if (object.type == ObjectType.circle) {
      add(CircleHitbox());
    } else {
      add(RectangleHitbox());
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (object.type == ObjectType.circle) {
      _renderCircle(canvas);
    } else {
      _renderSquare(canvas);
    }
  }

  void _renderCircle(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x / 2;

    // Outer Ring
    final ringPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius - 2, ringPaint);

    // Inner Core
    final corePaint = Paint()
      ..color = Colors.yellow.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 8, corePaint);

    // Center Star/Diamond
    final starPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, 4, starPaint);
  }

  void _renderSquare(Canvas canvas) {
    // Hazard Block
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    // Main Body
    final bodyPaint = Paint()..color = Colors.grey.shade900;
    canvas.drawRect(rect, bodyPaint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(rect, borderPaint);

    // "X" Warning Symbol
    final xPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(8, 8), Offset(size.x - 8, size.y - 8), xPaint);
    canvas.drawLine(Offset(size.x - 8, 8), Offset(8, size.y - 8), xPaint);
  }
}
