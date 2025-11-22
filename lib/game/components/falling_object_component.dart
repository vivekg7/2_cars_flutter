import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/falling_object.dart';
import '../../models/car.dart';

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
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.white;

    if (object.type == ObjectType.circle) {
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(size.toRect(), const Radius.circular(4)),
        paint,
      );
    }

    // Shadow
    canvas.drawShadow(
      Path()..addOval(size.toRect()),
      Colors.black.withOpacity(0.2),
      2.0,
      true,
    );
  }
}
