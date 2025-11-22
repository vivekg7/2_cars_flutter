import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/car.dart';

import 'package:flame/collisions.dart';
import '../two_cars_game.dart'; // Assuming this import is needed for TwoCarsGame
import 'falling_object_component.dart'; // Assuming this import is needed for FallingObjectComponent

class CarComponent extends PositionComponent with CollisionCallbacks {
  final Car car;
  final Color color;
  final double laneWidth;

  // Target X position for smooth animation
  double _targetX = 0;

  CarComponent({
    required this.car,
    required this.color,
    required this.laneWidth,
  }) : super(size: Vector2(50, 80), anchor: Anchor.center);

  @override
  void onLoad() {
    _updateTargetPosition(immediate: true);
    add(RectangleHitbox());
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is FallingObjectComponent) {
      final game = findGame()! as TwoCarsGame;
      game.handleCollision(this, other);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Smoothly interpolate to target X
    if ((position.x - _targetX).abs() > 0.1) {
      // Simple lerp for smoothness
      position.x += (_targetX - position.x) * 15 * dt;
    } else {
      position.x = _targetX;
    }
  }

  void updateLane() {
    _updateTargetPosition(immediate: false);
  }

  void _updateTargetPosition({bool immediate = false}) {
    // Calculate target X based on side and lane
    // Parent is the Game, so coordinates are global
    // But we can simplify by assuming we know the lane centers

    // Left Side: Lane 0 center, Lane 1 center
    // Right Side: Lane 0 center, Lane 1 center

    // We need to know where the lanes are relative to the screen
    // Let's assume the parent passes the correct lane centers or we calculate them

    // Actually, let's calculate based on laneWidth and side
    double startX = car.side == CarSide.left ? 0 : laneWidth * 2;
    double offset = car.laneIndex == 0 ? laneWidth / 2 : laneWidth * 1.5;

    _targetX = startX + offset;

    if (immediate) {
      position.x = _targetX;
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw Car Body
    final rrect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(10),
    );
    canvas.drawRRect(rrect, Paint()..color = color);

    // Shadow
    canvas.drawShadow(Path()..addRRect(rrect), Colors.black, 3.0, true);

    // Windshield
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(5, 10, size.x - 10, 15),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.black.withOpacity(0.5),
    );

    // Lights
    canvas.drawRect(
      Rect.fromLTWH(5, size.y - 15, 8, 8),
      Paint()..color = Colors.yellow,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.x - 13, size.y - 15, 8, 8),
      Paint()..color = Colors.yellow,
    );
  }
}
