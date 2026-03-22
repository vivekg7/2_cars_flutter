import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/car.dart';
import '../../models/game_state.dart';
import '../../models/game_theme.dart';

import 'package:flame/collisions.dart';
import 'package:flame/particles.dart';
import '../two_cars_game.dart';
import 'falling_object_component.dart';
import 'rect_particle.dart';

class CarComponent extends PositionComponent with CollisionCallbacks {
  final Car car;
  GameTheme theme;
  final double laneWidth;

  double _targetX = 0;

  CarComponent({
    required this.car,
    required this.theme,
    required this.laneWidth,
  }) : super(size: Vector2(50, 80), anchor: Anchor.center);

  Color get _carColor =>
      car.side == CarSide.left ? theme.leftCarColor : theme.rightCarColor;

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

    // Smooth movement
    if ((position.x - _targetX).abs() > 0.1) {
      double moveAmount = (_targetX - position.x) * 10 * dt;
      position.x += moveAmount;
    } else {
      position.x = _targetX;
    }

    // Exhaust Particles
    if (theme.exhaustEnabled && Random().nextDouble() < 0.6) {
      final game = findGame()! as TwoCarsGame;
      if (game.gameState.status == GameStatus.playing) {
        _spawnExhaustParticle();
      }
    }
  }

  void _spawnExhaustParticle() {
    final game = findGame()! as TwoCarsGame;
    final random = Random();
    final color = theme.exhaustColor.withValues(alpha: 0.6);

    final leftExhaustPos = position.clone() + Vector2(-15, size.y / 2);
    final rightExhaustPos = position.clone() + Vector2(15, size.y / 2);

    for (final pos in [leftExhaustPos, rightExhaustPos]) {
      final particle = theme.exhaustParticleShape == ParticleShape.square
          ? RectParticle(
              rectSize: Vector2.all(random.nextDouble() * 3 + 1.5),
              paint: Paint()..color = color,
            ) as Particle
          : CircleParticle(
              radius: random.nextDouble() * 2 + 1,
              paint: Paint()..color = color,
              lifespan: 0.5,
            );

      game.add(
        ParticleSystemComponent(
          particle: AcceleratedParticle(
            acceleration: Vector2(0, 100),
            speed: Vector2(
              random.nextDouble() * 10 - 5,
              100 + random.nextDouble() * 50,
            ),
            position: pos,
            child: particle,
          ),
        ),
      );
    }
  }

  void updateLane() {
    _updateTargetPosition(immediate: false);
  }

  void _updateTargetPosition({bool immediate = false}) {
    double startX = car.side == CarSide.left ? 0 : laneWidth * 2;
    double offset = car.laneIndex == 0 ? laneWidth / 2 : laneWidth * 1.5;
    _targetX = startX + offset;

    if (immediate) {
      position.x = _targetX;
    }
  }

  @override
  void render(Canvas canvas) {
    switch (theme.carBodyStyle) {
      case CarBodyStyle.rounded:
        _renderRounded(canvas);
        break;
      case CarBodyStyle.boxy:
        _renderBoxy(canvas);
        break;
      case CarBodyStyle.tapered:
        _renderTapered(canvas);
        break;
      case CarBodyStyle.outlineOnly:
        _renderOutline(canvas);
        break;
    }
  }

  // ── Flat Modern ──
  void _renderRounded(Canvas canvas) {
    // Slightly tapered: narrower at top
    final bodyPath = Path();
    const topInset = 4.0;
    const radius = 10.0;

    bodyPath.moveTo(topInset + radius, 0);
    bodyPath.lineTo(size.x - topInset - radius, 0);
    bodyPath.quadraticBezierTo(size.x - topInset, 0, size.x - topInset, radius);
    bodyPath.lineTo(size.x, size.y - radius);
    bodyPath.quadraticBezierTo(size.x, size.y, size.x - radius, size.y);
    bodyPath.lineTo(radius, size.y);
    bodyPath.quadraticBezierTo(0, size.y, 0, size.y - radius);
    bodyPath.lineTo(topInset, radius);
    bodyPath.quadraticBezierTo(topInset, 0, topInset + radius, 0);
    bodyPath.close();

    canvas.drawPath(bodyPath, Paint()..color = _carColor);

    // Windshield
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(topInset + 4, 10, size.x - topInset * 2 - 8, 14),
        const Radius.circular(4),
      ),
      Paint()..color = theme.windshieldColor,
    );

    // Headlights — small dots
    canvas.drawCircle(
      Offset(8, size.y - 12),
      3.5,
      Paint()..color = theme.headlightColor,
    );
    canvas.drawCircle(
      Offset(size.x - 8, size.y - 12),
      3.5,
      Paint()..color = theme.headlightColor,
    );
  }

  // ── Retro Pixel-ish ──
  void _renderBoxy(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final color = _carColor;
    final strokeColor = Color.lerp(color, Colors.black, 0.4)!;

    // Body
    canvas.drawRect(rect, Paint()..color = color);

    // Thick outline
    canvas.drawRect(
      rect,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = theme.carStrokeWidth,
    );

    // Windshield
    canvas.drawRect(
      Rect.fromLTWH(5, 10, size.x - 10, 14),
      Paint()..color = theme.windshieldColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(5, 10, size.x - 10, 14),
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Wheels — small squares protruding from sides
    if (theme.hasWheels) {
      final wheelPaint = Paint()..color = Colors.black;
      const ws = 8.0; // wheel size
      const wp = 3.0; // protrusion
      // Top-left
      canvas.drawRect(Rect.fromLTWH(-wp, 14, ws, 12), wheelPaint);
      // Top-right
      canvas.drawRect(Rect.fromLTWH(size.x - ws + wp, 14, ws, 12), wheelPaint);
      // Bottom-left
      canvas.drawRect(Rect.fromLTWH(-wp, size.y - 24, ws, 12), wheelPaint);
      // Bottom-right
      canvas.drawRect(
          Rect.fromLTWH(size.x - ws + wp, size.y - 24, ws, 12), wheelPaint);
    }

    // Headlights
    canvas.drawRect(
      Rect.fromLTWH(5, size.y - 14, 8, 8),
      Paint()..color = theme.headlightColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.x - 13, size.y - 14, 8, 8),
      Paint()..color = theme.headlightColor,
    );
  }

  // ── Realistic-lite ──
  void _renderTapered(Canvas canvas) {
    final color = _carColor;

    // Drop shadow
    if (theme.carHasShadow) {
      final shadowPath = Path();
      shadowPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(3, 5, size.x - 2, size.y - 2),
        const Radius.circular(8),
      ));
      canvas.drawPath(
        shadowPath,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }

    // Tapered body
    final bodyPath = Path();
    const frontInset = 8.0;
    bodyPath.moveTo(frontInset + 6, 0);
    bodyPath.lineTo(size.x - frontInset - 6, 0);
    bodyPath.quadraticBezierTo(size.x - frontInset, 0, size.x - frontInset + 2, 12);
    bodyPath.lineTo(size.x, size.y - 8);
    bodyPath.quadraticBezierTo(size.x, size.y, size.x - 6, size.y);
    bodyPath.lineTo(6, size.y);
    bodyPath.quadraticBezierTo(0, size.y, 0, size.y - 8);
    bodyPath.lineTo(frontInset - 2, 12);
    bodyPath.quadraticBezierTo(frontInset, 0, frontInset + 6, 0);
    bodyPath.close();

    // Gradient fill
    if (theme.carHasGradient) {
      final lighter = Color.lerp(color, Colors.white, 0.15)!;
      final darker = Color.lerp(color, Colors.black, 0.15)!;
      canvas.drawPath(
        bodyPath,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(size.x / 2, 0),
            Offset(size.x / 2, size.y),
            [lighter, darker],
          ),
      );
    } else {
      canvas.drawPath(bodyPath, Paint()..color = color);
    }

    // Windshield with reflection
    final wsRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(frontInset + 2, 8, size.x - frontInset * 2 - 4, 16),
      const Radius.circular(6),
    );
    canvas.drawRRect(wsRect, Paint()..color = theme.windshieldColor);
    // Reflection streak
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(frontInset + 6, 10, (size.x - frontInset * 2) * 0.4, 3),
        const Radius.circular(2),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );

    // Wheels
    if (theme.hasWheels) {
      final wheelPaint = Paint()..color = const Color(0xFF222222);
      final hubPaint = Paint()..color = const Color(0xFF666666);
      // Front wheels
      canvas.drawCircle(Offset(3, 18), 5, wheelPaint);
      canvas.drawCircle(Offset(3, 18), 2, hubPaint);
      canvas.drawCircle(Offset(size.x - 3, 18), 5, wheelPaint);
      canvas.drawCircle(Offset(size.x - 3, 18), 2, hubPaint);
      // Rear wheels
      canvas.drawCircle(Offset(3, size.y - 16), 5, wheelPaint);
      canvas.drawCircle(Offset(3, size.y - 16), 2, hubPaint);
      canvas.drawCircle(Offset(size.x - 3, size.y - 16), 5, wheelPaint);
      canvas.drawCircle(Offset(size.x - 3, size.y - 16), 2, hubPaint);
    }

    // Headlights with glow
    final hlCenter1 = Offset(frontInset + 2, size.y - 10);
    final hlCenter2 = Offset(size.x - frontInset - 2, size.y - 10);
    final glowPaint = Paint()
      ..color = theme.headlightColor.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(hlCenter1, 6, glowPaint);
    canvas.drawCircle(hlCenter2, 6, glowPaint);
    canvas.drawCircle(hlCenter1, 3, Paint()..color = theme.headlightColor);
    canvas.drawCircle(hlCenter2, 3, Paint()..color = theme.headlightColor);
  }

  // ── Neon/Synthwave ──
  void _renderOutline(Canvas canvas) {
    final color = _carColor;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(4, 0, size.x - 8, size.y),
      const Radius.circular(8),
    );

    // Outer glow
    if (theme.carHasGlow) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = color.withValues(alpha: 0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = theme.carStrokeWidth + 6
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    // Main outline
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = theme.carStrokeWidth,
    );

    // Windshield line
    final wsY = 14.0;
    canvas.drawLine(
      Offset(10, wsY),
      Offset(size.x - 10, wsY),
      Paint()
        ..color = theme.windshieldColor.withValues(alpha: 0.7)
        ..strokeWidth = 1.5,
    );

    // Headlights as glowing dots
    for (final x in [12.0, size.x - 12.0]) {
      final center = Offset(x, size.y - 10);
      if (theme.carHasGlow) {
        canvas.drawCircle(
          center,
          5,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.2)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
      }
      canvas.drawCircle(center, 2.5, Paint()..color = Colors.white);
    }
  }
}
