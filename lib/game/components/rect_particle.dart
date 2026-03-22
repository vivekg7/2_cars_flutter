import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart' show Vector2;

/// A rectangular particle — Flame only ships CircleParticle.
class RectParticle extends Particle {
  final Vector2 rectSize;
  final Paint paint;

  RectParticle({
    required this.rectSize,
    required this.paint,
    super.lifespan = 0.5,
  });

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: rectSize.x,
        height: rectSize.y,
      ),
      paint,
    );
  }
}
