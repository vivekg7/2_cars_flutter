import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/falling_object.dart';
import '../../models/car.dart';
import '../../models/game_theme.dart';

import 'package:flame/collisions.dart';

class FallingObjectComponent extends PositionComponent {
  final FallingObject object;
  final double laneWidth;
  final GameTheme theme;

  // For neon pulse/flicker
  double _animTime = 0;

  FallingObjectComponent({
    required this.object,
    required this.laneWidth,
    required this.theme,
  }) : super(size: Vector2(40, 40), anchor: Anchor.center);

  @override
  void onLoad() {
    double startX = object.side == CarSide.left ? 0 : laneWidth * 2;
    double offset = object.laneIndex == 0 ? laneWidth / 2 : laneWidth * 1.5;
    position.x = startX + offset;
    position.y = -50;

    if (object.type == ObjectType.circle) {
      add(CircleHitbox());
    } else {
      add(RectangleHitbox());
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animTime += dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Apply rotation for retro squares
    if (object.type == ObjectType.square && theme.squareHasRotation) {
      canvas.save();
      canvas.translate(size.x / 2, size.y / 2);
      canvas.rotate(theme.squareRotationDegrees * pi / 180);
      canvas.translate(-size.x / 2, -size.y / 2);
    }

    // Shadow
    if (theme.objectHasShadow) {
      final shadowOffset = Offset(2, 3);
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      if (object.type == ObjectType.circle) {
        canvas.drawCircle(
          Offset(size.x / 2 + shadowOffset.dx, size.y / 2 + shadowOffset.dy),
          size.x / 2 - 2,
          shadowPaint,
        );
      } else {
        canvas.drawRect(
          Rect.fromLTWH(shadowOffset.dx, shadowOffset.dy, size.x, size.y),
          shadowPaint,
        );
      }
    }

    if (object.type == ObjectType.circle) {
      _renderCircle(canvas);
    } else {
      _renderSquare(canvas);
    }

    if (object.type == ObjectType.square && theme.squareHasRotation) {
      canvas.restore();
    }
  }

  void _renderCircle(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x / 2;

    if (theme.circleHasGlow) {
      // ── Neon style ──
      // Pulsing opacity
      final pulse = 0.7 + 0.3 * sin(_animTime * 4);

      // Outer glow
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = theme.circleStrokeColor.withValues(alpha: 0.15 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      // Ring
      canvas.drawCircle(
        center,
        radius - 2,
        Paint()
          ..color = theme.circleStrokeColor.withValues(alpha: pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = theme.circleStrokeWidth,
      );

      // Center dot
      canvas.drawCircle(center, 3, Paint()..color = theme.circleCenterColor);
    } else if (!theme.circleIsFilled) {
      // Outline only (shouldn't normally hit this path given current themes)
      canvas.drawCircle(
        center,
        radius - 2,
        Paint()
          ..color = theme.circleStrokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = theme.circleStrokeWidth,
      );
      canvas.drawCircle(center, 3, Paint()..color = theme.circleCenterColor);
    } else {
      // ── Filled styles (flat modern, retro, realistic) ──

      // Main fill
      if (theme.id == 'realistic') {
        // Radial gradient for coin look
        canvas.drawCircle(
          center,
          radius - 2,
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.3, -0.3),
              radius: 1.0,
              colors: [
                Color.lerp(theme.circleFillColor, Colors.white, 0.3)!,
                theme.circleFillColor,
                Color.lerp(theme.circleFillColor, Colors.black, 0.2)!,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(Rect.fromCircle(center: center, radius: radius - 2)),
        );

        // Inner ring (embossed)
        canvas.drawCircle(
          center,
          radius - 7,
          Paint()
            ..color = theme.circleFillColor.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );

        // Specular highlight
        canvas.drawCircle(
          Offset(center.dx - 5, center.dy - 5),
          4,
          Paint()..color = Colors.white.withValues(alpha: 0.4),
        );
      } else {
        // Solid fill (flat modern / retro)
        canvas.drawCircle(
          center,
          radius - 2,
          Paint()..color = theme.circleFillColor,
        );

        // Stroke outline (retro has thick black outline)
        if (theme.circleStrokeWidth > 0) {
          canvas.drawCircle(
            center,
            radius - 2,
            Paint()
              ..color = theme.circleStrokeColor
              ..style = PaintingStyle.stroke
              ..strokeWidth = theme.circleStrokeWidth,
          );
        }

        // Center
        canvas.drawCircle(center, 4, Paint()..color = theme.circleCenterColor);
      }
    }
  }

  void _renderSquare(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    if (theme.squareHasGlow) {
      // ── Neon style ──
      final flicker = 0.7 + 0.3 * (Random().nextDouble());

      // Outer glow
      canvas.drawRect(
        rect.inflate(2),
        Paint()
          ..color = theme.squareStrokeColor.withValues(alpha: 0.15 * flicker)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      // Outline
      canvas.drawRect(
        rect,
        Paint()
          ..color = theme.squareStrokeColor.withValues(alpha: flicker)
          ..style = PaintingStyle.stroke
          ..strokeWidth = theme.squareStrokeWidth,
      );

      // Glowing X
      final xPaint = Paint()
        ..color = theme.squareXColor.withValues(alpha: flicker)
        ..strokeWidth = theme.squareXStrokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(8, 8), Offset(size.x - 8, size.y - 8), xPaint);
      canvas.drawLine(Offset(size.x - 8, 8), Offset(8, size.y - 8), xPaint);
    } else if (theme.id == 'realistic') {
      // ── Realistic with gradient + beveled X ──
      // Gradient fill
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(theme.squareFillColor, Colors.white, 0.1)!,
              theme.squareFillColor,
              Color.lerp(theme.squareFillColor, Colors.black, 0.2)!,
            ],
          ).createShader(rect),
      );

      // Border
      if (theme.squareStrokeWidth > 0) {
        canvas.drawRect(
          rect,
          Paint()
            ..color = theme.squareStrokeColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = theme.squareStrokeWidth,
        );
      }

      // Beveled X — lighter top-left, darker bottom-right
      canvas.drawLine(
        const Offset(8, 8),
        Offset(size.x - 8, size.y - 8),
        Paint()
          ..color = Color.lerp(theme.squareXColor, Colors.white, 0.2)!
          ..strokeWidth = theme.squareXStrokeWidth
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        Offset(size.x - 8, 8),
        Offset(8, size.y - 8),
        Paint()
          ..color = Color.lerp(theme.squareXColor, Colors.black, 0.2)!
          ..strokeWidth = theme.squareXStrokeWidth
          ..strokeCap = StrokeCap.round,
      );
    } else {
      // ── Flat modern / Retro ──
      // Solid fill
      canvas.drawRect(rect, Paint()..color = theme.squareFillColor);

      // Border
      if (theme.squareStrokeWidth > 0) {
        canvas.drawRect(
          rect,
          Paint()
            ..color = theme.squareStrokeColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = theme.squareStrokeWidth,
        );
      }

      // X
      final xPaint = Paint()
        ..color = theme.squareXColor
        ..strokeWidth = theme.squareXStrokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(8, 8), Offset(size.x - 8, size.y - 8), xPaint);
      canvas.drawLine(Offset(size.x - 8, 8), Offset(8, size.y - 8), xPaint);
    }
  }
}
