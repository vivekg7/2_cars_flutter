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
    final color = _carColor;
    final w = size.x;
    final h = size.y;

    // Aerodynamic body path — narrow nose, wide hips, tapered rear
    final bodyPath = Path();
    // Start at front-left of nose
    bodyPath.moveTo(w * 0.38, 0);
    // Nose curve across top
    bodyPath.quadraticBezierTo(w * 0.5, -2, w * 0.62, 0);
    // Right side — flares out from nose to shoulder
    bodyPath.quadraticBezierTo(w * 0.78, 3, w * 0.88, h * 0.18);
    // Right shoulder to widest point (hips)
    bodyPath.quadraticBezierTo(w * 1.0, h * 0.35, w * 1.0, h * 0.55);
    // Right hip to rear
    bodyPath.quadraticBezierTo(w * 1.0, h * 0.85, w * 0.88, h * 0.95);
    // Rear curve
    bodyPath.quadraticBezierTo(w * 0.82, h, w * 0.72, h);
    bodyPath.lineTo(w * 0.28, h);
    bodyPath.quadraticBezierTo(w * 0.18, h, w * 0.12, h * 0.95);
    // Left hip to shoulder
    bodyPath.quadraticBezierTo(0, h * 0.85, 0, h * 0.55);
    bodyPath.quadraticBezierTo(0, h * 0.35, w * 0.12, h * 0.18);
    // Left shoulder back to nose
    bodyPath.quadraticBezierTo(w * 0.22, 3, w * 0.38, 0);
    bodyPath.close();

    canvas.drawPath(bodyPath, Paint()..color = color);

    // Body crease line — subtle darker line along the side
    final creasePaint = Paint()
      ..color = Color.lerp(color, Colors.black, 0.15)!
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final creasePath = Path();
    creasePath.moveTo(w * 0.18, h * 0.25);
    creasePath.quadraticBezierTo(w * 0.12, h * 0.5, w * 0.18, h * 0.8);
    canvas.drawPath(creasePath, creasePaint);
    final creasePath2 = Path();
    creasePath2.moveTo(w * 0.82, h * 0.25);
    creasePath2.quadraticBezierTo(w * 0.88, h * 0.5, w * 0.82, h * 0.8);
    canvas.drawPath(creasePath2, creasePaint);

    // Windshield — rounded trapezoid
    final wsPath = Path();
    wsPath.moveTo(w * 0.24, h * 0.15);
    wsPath.lineTo(w * 0.76, h * 0.15);
    wsPath.quadraticBezierTo(w * 0.82, h * 0.15, w * 0.80, h * 0.30);
    wsPath.lineTo(w * 0.20, h * 0.30);
    wsPath.quadraticBezierTo(w * 0.18, h * 0.15, w * 0.24, h * 0.15);
    wsPath.close();
    canvas.drawPath(wsPath, Paint()..color = theme.windshieldColor);

    // Rear window
    final rwPath = Path();
    rwPath.moveTo(w * 0.22, h * 0.68);
    rwPath.lineTo(w * 0.78, h * 0.68);
    rwPath.quadraticBezierTo(w * 0.80, h * 0.78, w * 0.74, h * 0.78);
    rwPath.lineTo(w * 0.26, h * 0.78);
    rwPath.quadraticBezierTo(w * 0.20, h * 0.78, w * 0.22, h * 0.68);
    rwPath.close();
    canvas.drawPath(rwPath, Paint()..color = theme.windshieldColor);

    // Side mirrors — small rounded protrusions
    for (final mirror in [
      [w * -0.02, h * 0.20, w * 0.08],
      [w * 1.02, h * 0.20, w * 0.92],
    ]) {
      final mirrorPath = Path();
      mirrorPath.addOval(Rect.fromCenter(
        center: Offset(mirror[0], mirror[1]),
        width: 6,
        height: 4,
      ));
      canvas.drawPath(mirrorPath, Paint()..color = Color.lerp(color, Colors.black, 0.1)!);
    }

    // Headlights — clean rounded rectangles
    for (final lx in [w * 0.14, w * 0.74]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(lx, h * 0.04, w * 0.12, 4),
          const Radius.circular(2),
        ),
        Paint()..color = theme.headlightColor,
      );
    }

    // Tail lights — wider, flat modern style
    final tailColor = Color.lerp(Colors.red, color, 0.3)!;
    for (final lx in [w * 0.14, w * 0.68]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(lx, h * 0.92, w * 0.18, 3.5),
          const Radius.circular(2),
        ),
        Paint()..color = tailColor,
      );
    }
  }

  // ── Retro Pixel-ish ──
  void _renderBoxy(Canvas canvas) {
    final color = _carColor;
    final w = size.x;
    final h = size.y;
    final strokeColor = Color.lerp(color, Colors.black, 0.4)!;

    // Wheels — draw first so body overlaps them
    if (theme.hasWheels) {
      final wheelPaint = Paint()..color = const Color(0xFF111111);
      final hubPaint = Paint()..color = const Color(0xFF444444);
      const ws = 9.0;
      const wh = 14.0;
      const wp = 4.0;
      // Front wheels
      canvas.drawRect(Rect.fromLTWH(-wp, 10, ws, wh), wheelPaint);
      canvas.drawRect(Rect.fromLTWH(-wp + 2, 14, ws - 4, wh - 6), hubPaint);
      canvas.drawRect(Rect.fromLTWH(w - ws + wp, 10, ws, wh), wheelPaint);
      canvas.drawRect(Rect.fromLTWH(w - ws + wp + 2, 14, ws - 4, wh - 6), hubPaint);
      // Rear wheels
      canvas.drawRect(Rect.fromLTWH(-wp, h - 22, ws, wh), wheelPaint);
      canvas.drawRect(Rect.fromLTWH(-wp + 2, h - 18, ws - 4, wh - 6), hubPaint);
      canvas.drawRect(Rect.fromLTWH(w - ws + wp, h - 22, ws, wh), wheelPaint);
      canvas.drawRect(Rect.fromLTWH(w - ws + wp + 2, h - 18, ws - 4, wh - 6), hubPaint);
    }

    // Body — slightly shaped, not just a rectangle
    final bodyPath = Path();
    bodyPath.moveTo(4, 0);
    bodyPath.lineTo(w - 4, 0);
    bodyPath.lineTo(w, 6);
    bodyPath.lineTo(w, h - 4);
    bodyPath.lineTo(w - 2, h);
    bodyPath.lineTo(2, h);
    bodyPath.lineTo(0, h - 4);
    bodyPath.lineTo(0, 6);
    bodyPath.close();
    canvas.drawPath(bodyPath, Paint()..color = color);

    // Thick outline
    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = theme.carStrokeWidth,
    );

    // Hood panel line
    canvas.drawLine(
      Offset(6, h * 0.12),
      Offset(w - 6, h * 0.12),
      Paint()
        ..color = strokeColor
        ..strokeWidth = 2,
    );

    // Hood scoop — small rectangle on hood
    canvas.drawRect(
      Rect.fromLTWH(w * 0.35, 4, w * 0.3, 5),
      Paint()..color = Color.lerp(color, Colors.black, 0.25)!,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.35, 4, w * 0.3, 5),
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Windshield
    canvas.drawRect(
      Rect.fromLTWH(6, h * 0.16, w - 12, h * 0.18),
      Paint()..color = theme.windshieldColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(6, h * 0.16, w - 12, h * 0.18),
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Roof panel
    canvas.drawRect(
      Rect.fromLTWH(6, h * 0.36, w - 12, h * 0.22),
      Paint()..color = Color.lerp(color, Colors.white, 0.08)!,
    );

    // Rear window
    canvas.drawRect(
      Rect.fromLTWH(8, h * 0.60, w - 16, h * 0.12),
      Paint()..color = theme.windshieldColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(8, h * 0.60, w - 16, h * 0.12),
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Side mirrors — boxy rectangles sticking out
    final mirrorPaint = Paint()..color = Color.lerp(color, Colors.black, 0.2)!;
    canvas.drawRect(Rect.fromLTWH(-5, h * 0.17, 7, 5), mirrorPaint);
    canvas.drawRect(
      Rect.fromLTWH(-5, h * 0.17, 7, 5),
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawRect(Rect.fromLTWH(w - 2, h * 0.17, 7, 5), mirrorPaint);
    canvas.drawRect(
      Rect.fromLTWH(w - 2, h * 0.17, 7, 5),
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Headlights
    canvas.drawRect(
      Rect.fromLTWH(5, 1, 10, 6),
      Paint()..color = theme.headlightColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(w - 15, 1, 10, 6),
      Paint()..color = theme.headlightColor,
    );

    // Tail lights — chunky red blocks
    canvas.drawRect(
      Rect.fromLTWH(4, h - 8, 12, 6),
      Paint()..color = const Color(0xFFCC0000),
    );
    canvas.drawRect(
      Rect.fromLTWH(w - 16, h - 8, 12, 6),
      Paint()..color = const Color(0xFFCC0000),
    );

    // Rear bumper detail
    canvas.drawRect(
      Rect.fromLTWH(w * 0.3, h - 3, w * 0.4, 2),
      Paint()..color = strokeColor,
    );
  }

  // ── Realistic-lite ──
  void _renderTapered(Canvas canvas) {
    final color = _carColor;
    final w = size.x;
    final h = size.y;

    // Drop shadow — shaped to match body
    if (theme.carHasShadow) {
      final shadowPath = _buildSportBodyPath(w, h, offsetX: 3, offsetY: 4);
      canvas.drawPath(
        shadowPath,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }

    // Wheels — draw before body so body overlaps
    if (theme.hasWheels) {
      final wheelPaint = Paint()..color = const Color(0xFF1A1A1A);
      final hubPaint = Paint()..color = const Color(0xFF555555);
      final spokePaint = Paint()
        ..color = const Color(0xFF444444)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      // Front wheels — oval for perspective
      for (final wx in [1.0, w - 1.0]) {
        canvas.drawOval(
          Rect.fromCenter(center: Offset(wx, h * 0.20), width: 8, height: 14),
          wheelPaint,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(wx, h * 0.20), width: 4, height: 8),
          hubPaint,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(wx, h * 0.20), width: 6, height: 11),
          spokePaint,
        );
      }
      // Rear wheels — slightly larger
      for (final wx in [1.0, w - 1.0]) {
        canvas.drawOval(
          Rect.fromCenter(center: Offset(wx, h * 0.78), width: 9, height: 15),
          wheelPaint,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(wx, h * 0.78), width: 4.5, height: 8),
          hubPaint,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(wx, h * 0.78), width: 7, height: 12),
          spokePaint,
        );
      }
    }

    // Sporty body path
    final bodyPath = _buildSportBodyPath(w, h);

    // Gradient fill — vertical with a highlight band
    if (theme.carHasGradient) {
      final lighter = Color.lerp(color, Colors.white, 0.2)!;
      final mid = color;
      final darker = Color.lerp(color, Colors.black, 0.18)!;
      canvas.drawPath(
        bodyPath,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, 0),
            Offset(w, h),
            [lighter, mid, darker, Color.lerp(darker, Colors.black, 0.1)!],
            [0.0, 0.3, 0.7, 1.0],
          ),
      );
    } else {
      canvas.drawPath(bodyPath, Paint()..color = color);
    }

    // Subtle body edge highlight — left side light reflection
    final highlightPath = Path();
    highlightPath.moveTo(w * 0.14, h * 0.15);
    highlightPath.quadraticBezierTo(w * 0.04, h * 0.4, w * 0.06, h * 0.7);
    canvas.drawPath(
      highlightPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Body crease lines
    final creaseColor = Color.lerp(color, Colors.black, 0.12)!;
    // Left crease
    final leftCrease = Path();
    leftCrease.moveTo(w * 0.16, h * 0.28);
    leftCrease.quadraticBezierTo(w * 0.10, h * 0.50, w * 0.14, h * 0.75);
    canvas.drawPath(leftCrease, Paint()
      ..color = creaseColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke);
    // Right crease
    final rightCrease = Path();
    rightCrease.moveTo(w * 0.84, h * 0.28);
    rightCrease.quadraticBezierTo(w * 0.90, h * 0.50, w * 0.86, h * 0.75);
    canvas.drawPath(rightCrease, Paint()
      ..color = creaseColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke);

    // Hood line
    canvas.drawLine(
      Offset(w * 0.20, h * 0.13),
      Offset(w * 0.80, h * 0.13),
      Paint()
        ..color = creaseColor
        ..strokeWidth = 0.7,
    );

    // Windshield — curved trapezoid
    final wsPath = Path();
    wsPath.moveTo(w * 0.20, h * 0.155);
    wsPath.lineTo(w * 0.80, h * 0.155);
    wsPath.quadraticBezierTo(w * 0.86, h * 0.16, w * 0.84, h * 0.32);
    wsPath.lineTo(w * 0.16, h * 0.32);
    wsPath.quadraticBezierTo(w * 0.14, h * 0.16, w * 0.20, h * 0.155);
    wsPath.close();
    canvas.drawPath(wsPath, Paint()..color = theme.windshieldColor);

    // Windshield reflection — diagonal streak
    canvas.save();
    canvas.clipPath(wsPath);
    final reflPath = Path();
    reflPath.moveTo(w * 0.15, h * 0.18);
    reflPath.lineTo(w * 0.35, h * 0.16);
    reflPath.lineTo(w * 0.30, h * 0.28);
    reflPath.lineTo(w * 0.12, h * 0.28);
    reflPath.close();
    canvas.drawPath(reflPath, Paint()..color = Colors.white.withValues(alpha: 0.25));
    canvas.restore();

    // Rear window
    final rwPath = Path();
    rwPath.moveTo(w * 0.20, h * 0.65);
    rwPath.lineTo(w * 0.80, h * 0.65);
    rwPath.quadraticBezierTo(w * 0.84, h * 0.66, w * 0.78, h * 0.76);
    rwPath.lineTo(w * 0.22, h * 0.76);
    rwPath.quadraticBezierTo(w * 0.16, h * 0.66, w * 0.20, h * 0.65);
    rwPath.close();
    canvas.drawPath(rwPath, Paint()..color = theme.windshieldColor);

    // Side mirrors — teardrop shape
    for (final isLeft in [true, false]) {
      final mx = isLeft ? w * -0.04 : w * 1.04;
      final my = h * 0.20;
      final mirrorPath = Path();
      if (isLeft) {
        mirrorPath.moveTo(w * 0.08, my - 1);
        mirrorPath.quadraticBezierTo(mx, my - 3, mx, my);
        mirrorPath.quadraticBezierTo(mx, my + 3, w * 0.08, my + 1);
      } else {
        mirrorPath.moveTo(w * 0.92, my - 1);
        mirrorPath.quadraticBezierTo(mx, my - 3, mx, my);
        mirrorPath.quadraticBezierTo(mx, my + 3, w * 0.92, my + 1);
      }
      mirrorPath.close();
      canvas.drawPath(mirrorPath, Paint()..color = Color.lerp(color, Colors.black, 0.15)!);
      // Mirror glass
      canvas.drawCircle(
        Offset(mx, my),
        1.5,
        Paint()..color = theme.windshieldColor,
      );
    }

    // Headlights — elongated with glow
    for (final isLeft in [true, false]) {
      final hx = isLeft ? w * 0.14 : w * 0.70;
      final hlRect = Rect.fromLTWH(hx, h * 0.02, w * 0.16, 5);

      // Glow
      canvas.drawRRect(
        RRect.fromRectAndRadius(hlRect.inflate(3), const Radius.circular(4)),
        Paint()
          ..color = theme.headlightColor.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      // Light
      canvas.drawRRect(
        RRect.fromRectAndRadius(hlRect, const Radius.circular(3)),
        Paint()..color = theme.headlightColor,
      );
      // Inner bright spot
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(hx + 2, h * 0.03, w * 0.08, 2.5),
          const Radius.circular(2),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.6),
      );
    }

    // Tail lights — wider LED strip style
    for (final isLeft in [true, false]) {
      final tx = isLeft ? w * 0.12 : w * 0.64;
      final tlRect = Rect.fromLTWH(tx, h * 0.93, w * 0.24, 4);

      // Glow
      canvas.drawRRect(
        RRect.fromRectAndRadius(tlRect.inflate(2), const Radius.circular(3)),
        Paint()
          ..color = Colors.red.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      // Light
      canvas.drawRRect(
        RRect.fromRectAndRadius(tlRect, const Radius.circular(2)),
        Paint()..color = const Color(0xFFCC1111),
      );
    }

    // Exhaust tips — small dark circles at rear
    for (final ex in [w * 0.35, w * 0.65]) {
      canvas.drawCircle(
        Offset(ex, h * 0.99),
        2,
        Paint()..color = const Color(0xFF333333),
      );
      canvas.drawCircle(
        Offset(ex, h * 0.99),
        1,
        Paint()..color = const Color(0xFF1A1A1A),
      );
    }
  }

  /// Builds the sporty aerodynamic body path used by realistic theme.
  Path _buildSportBodyPath(double w, double h, {double offsetX = 0, double offsetY = 0}) {
    final path = Path();
    final ox = offsetX;
    final oy = offsetY;
    // Front nose — narrow, pointed
    path.moveTo(w * 0.35 + ox, oy);
    path.quadraticBezierTo(w * 0.5 + ox, -3 + oy, w * 0.65 + ox, oy);
    // Right side — front fender flare
    path.quadraticBezierTo(w * 0.82 + ox, 2 + oy, w * 0.92 + ox, h * 0.12 + oy);
    // Right side — door area (slight indent then out to rear fender)
    path.quadraticBezierTo(w * 0.98 + ox, h * 0.22 + oy, w * 0.96 + ox, h * 0.38 + oy);
    path.quadraticBezierTo(w * 0.94 + ox, h * 0.48 + oy, w * 0.96 + ox, h * 0.58 + oy);
    // Right rear fender flare — widest point
    path.quadraticBezierTo(w * 1.02 + ox, h * 0.72 + oy, w * 0.96 + ox, h * 0.88 + oy);
    // Right rear corner
    path.quadraticBezierTo(w * 0.94 + ox, h * 0.97 + oy, w * 0.82 + ox, h + oy);
    // Rear
    path.lineTo(w * 0.18 + ox, h + oy);
    // Left rear corner
    path.quadraticBezierTo(w * 0.06 + ox, h * 0.97 + oy, w * 0.04 + ox, h * 0.88 + oy);
    // Left rear fender flare
    path.quadraticBezierTo(-w * 0.02 + ox, h * 0.72 + oy, w * 0.04 + ox, h * 0.58 + oy);
    path.quadraticBezierTo(w * 0.06 + ox, h * 0.48 + oy, w * 0.04 + ox, h * 0.38 + oy);
    // Left side — door area
    path.quadraticBezierTo(w * 0.02 + ox, h * 0.22 + oy, w * 0.08 + ox, h * 0.12 + oy);
    // Left front fender
    path.quadraticBezierTo(w * 0.18 + ox, 2 + oy, w * 0.35 + ox, oy);
    path.close();
    return path;
  }

  // ── Neon/Synthwave ──
  void _renderOutline(Canvas canvas) {
    final color = _carColor;
    final w = size.x;
    final h = size.y;

    // Build sporty car outline path
    final bodyPath = _buildSportBodyPath(w, h);

    // Outer glow — wide blurred stroke
    if (theme.carHasGlow) {
      canvas.drawPath(
        bodyPath,
        Paint()
          ..color = color.withValues(alpha: 0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = theme.carStrokeWidth + 8
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      // Mid glow
      canvas.drawPath(
        bodyPath,
        Paint()
          ..color = color.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = theme.carStrokeWidth + 3
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }

    // Main outline
    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = theme.carStrokeWidth
        ..strokeJoin = StrokeJoin.round,
    );

    // Windshield outline — curved trapezoid
    final wsPath = Path();
    wsPath.moveTo(w * 0.22, h * 0.16);
    wsPath.lineTo(w * 0.78, h * 0.16);
    wsPath.quadraticBezierTo(w * 0.84, h * 0.17, w * 0.82, h * 0.30);
    wsPath.lineTo(w * 0.18, h * 0.30);
    wsPath.quadraticBezierTo(w * 0.16, h * 0.17, w * 0.22, h * 0.16);
    wsPath.close();
    final wsPaint = Paint()
      ..color = theme.windshieldColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(wsPath, wsPaint);

    // Rear window outline
    final rwPath = Path();
    rwPath.moveTo(w * 0.22, h * 0.65);
    rwPath.lineTo(w * 0.78, h * 0.65);
    rwPath.quadraticBezierTo(w * 0.82, h * 0.66, w * 0.76, h * 0.75);
    rwPath.lineTo(w * 0.24, h * 0.75);
    rwPath.quadraticBezierTo(w * 0.18, h * 0.66, w * 0.22, h * 0.65);
    rwPath.close();
    canvas.drawPath(rwPath, wsPaint);

    // Body crease line — glowing
    final creasePath = Path();
    creasePath.moveTo(w * 0.16, h * 0.28);
    creasePath.quadraticBezierTo(w * 0.10, h * 0.50, w * 0.14, h * 0.75);
    canvas.drawPath(creasePath, Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke);
    final creasePath2 = Path();
    creasePath2.moveTo(w * 0.84, h * 0.28);
    creasePath2.quadraticBezierTo(w * 0.90, h * 0.50, w * 0.86, h * 0.75);
    canvas.drawPath(creasePath2, Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke);

    // Side mirrors — small glowing lines
    for (final isLeft in [true, false]) {
      final mx = isLeft ? w * -0.02 : w * 1.02;
      final bx = isLeft ? w * 0.08 : w * 0.92;
      final my = h * 0.20;
      final mirrorPaint = Paint()
        ..color = color.withValues(alpha: 0.7)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(bx, my), Offset(mx, my), mirrorPaint);
      // Mirror tip dot
      if (theme.carHasGlow) {
        canvas.drawCircle(
          Offset(mx, my),
          3,
          Paint()
            ..color = color.withValues(alpha: 0.15)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
      canvas.drawCircle(Offset(mx, my), 1.5, Paint()..color = color);
    }

    // Headlights — glowing elongated shapes
    for (final isLeft in [true, false]) {
      final hx = isLeft ? w * 0.16 : w * 0.68;
      final hlCenter = Offset(hx + w * 0.08, h * 0.04);
      if (theme.carHasGlow) {
        canvas.drawCircle(
          hlCenter,
          6,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.15)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
      }
      // Headlight line
      canvas.drawLine(
        Offset(hx, h * 0.04),
        Offset(hx + w * 0.16, h * 0.04),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.9)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }

    // Tail lights — glowing red
    for (final isLeft in [true, false]) {
      final tx = isLeft ? w * 0.14 : w * 0.62;
      final tlCenter = Offset(tx + w * 0.12, h * 0.95);
      // Glow
      if (theme.carHasGlow) {
        canvas.drawCircle(
          tlCenter,
          5,
          Paint()
            ..color = const Color(0xFFFF0044).withValues(alpha: 0.2)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
      }
      // Light line
      canvas.drawLine(
        Offset(tx, h * 0.95),
        Offset(tx + w * 0.24, h * 0.95),
        Paint()
          ..color = const Color(0xFFFF0044).withValues(alpha: 0.8)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }
  }
}
