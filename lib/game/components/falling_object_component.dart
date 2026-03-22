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
      final pulse = 0.7 + 0.3 * sin(_animTime * 4);

      // Outer glow
      canvas.drawCircle(
        center,
        radius + 2,
        Paint()
          ..color = theme.circleStrokeColor.withValues(alpha: 0.1 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      // Mid glow ring
      canvas.drawCircle(
        center,
        radius - 1,
        Paint()
          ..color = theme.circleStrokeColor.withValues(alpha: 0.2 * pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = theme.circleStrokeWidth + 2
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );

      // Main ring
      canvas.drawCircle(
        center,
        radius - 2,
        Paint()
          ..color = theme.circleStrokeColor.withValues(alpha: pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = theme.circleStrokeWidth,
      );

      // Inner ring — thinner
      canvas.drawCircle(
        center,
        radius - 8,
        Paint()
          ..color = theme.circleStrokeColor.withValues(alpha: pulse * 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      // Center star/dot with glow
      canvas.drawCircle(
        center,
        4,
        Paint()
          ..color = theme.circleCenterColor.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawCircle(center, 2.5, Paint()..color = theme.circleCenterColor);
    } else if (!theme.circleIsFilled) {
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
      // ── Filled styles ──
      if (theme.id == 'realistic') {
        // Coin with rim, embossing, and specular highlight
        canvas.drawCircle(
          center,
          radius - 1,
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.3, -0.3),
              radius: 0.9,
              colors: [
                Color.lerp(theme.circleFillColor, Colors.white, 0.4)!,
                Color.lerp(theme.circleFillColor, Colors.white, 0.15)!,
                theme.circleFillColor,
                Color.lerp(theme.circleFillColor, Colors.black, 0.25)!,
              ],
              stops: const [0.0, 0.3, 0.6, 1.0],
            ).createShader(Rect.fromCircle(center: center, radius: radius - 1)),
        );

        // Outer rim — darker edge
        canvas.drawCircle(
          center,
          radius - 1.5,
          Paint()
            ..color = Color.lerp(theme.circleFillColor, Colors.black, 0.3)!
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );

        // Inner ring (embossed)
        canvas.drawCircle(
          center,
          radius - 6,
          Paint()
            ..color = Color.lerp(theme.circleFillColor, Colors.white, 0.15)!
                .withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );

        // Star/dollar symbol in center — simple cross lines
        final symPaint = Paint()
          ..color = Color.lerp(theme.circleFillColor, Colors.black, 0.2)!
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          Offset(center.dx, center.dy - 5),
          Offset(center.dx, center.dy + 5),
          symPaint,
        );
        canvas.drawLine(
          Offset(center.dx - 4, center.dy - 2),
          Offset(center.dx + 4, center.dy - 2),
          symPaint,
        );
        canvas.drawLine(
          Offset(center.dx - 4, center.dy + 2),
          Offset(center.dx + 4, center.dy + 2),
          symPaint,
        );

        // Specular highlight — crescent
        canvas.save();
        canvas.clipRect(Rect.fromCircle(center: center, radius: radius - 2));
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(center.dx - 4, center.dy - 5),
            width: 10,
            height: 7,
          ),
          Paint()..color = Colors.white.withValues(alpha: 0.35),
        );
        canvas.restore();
      } else if (theme.id == 'retro') {
        // Chunky retro coin
        canvas.drawCircle(
          center,
          radius - 1,
          Paint()..color = theme.circleFillColor,
        );
        // Thick outline
        canvas.drawCircle(
          center,
          radius - 1,
          Paint()
            ..color = theme.circleStrokeColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = theme.circleStrokeWidth,
        );
        // Inner ring
        canvas.drawCircle(
          center,
          radius - 6,
          Paint()
            ..color = theme.circleStrokeColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        // Chunky center dot
        canvas.drawCircle(center, 4, Paint()..color = theme.circleCenterColor);
      } else {
        // Flat modern — clean with subtle depth
        canvas.drawCircle(
          center,
          radius - 2,
          Paint()..color = theme.circleFillColor,
        );
        // Subtle inner highlight
        canvas.drawCircle(
          Offset(center.dx - 2, center.dy - 2),
          radius - 6,
          Paint()..color = Color.lerp(theme.circleFillColor, Colors.white, 0.15)!,
        );
        // Clean center
        canvas.drawCircle(center, 3.5, Paint()..color = theme.circleCenterColor);
        // Checkmark in center
        final checkPath = Path();
        checkPath.moveTo(center.dx - 4, center.dy);
        checkPath.lineTo(center.dx - 1, center.dy + 3);
        checkPath.lineTo(center.dx + 5, center.dy - 3);
        canvas.drawPath(
          checkPath,
          Paint()
            ..color = theme.circleFillColor
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
    }
  }

  void _renderSquare(Canvas canvas) {
    final s = size.x;
    final rect = Rect.fromLTWH(0, 0, s, s);

    if (theme.squareHasGlow) {
      // ── Neon style — glowing warning sign ──
      final flicker = 0.7 + 0.3 * (Random().nextDouble());

      // Wide outer glow
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.inflate(3), const Radius.circular(4)),
        Paint()
          ..color = theme.squareStrokeColor.withValues(alpha: 0.08 * flicker)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );

      // Inner glow
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.inflate(1), const Radius.circular(3)),
        Paint()
          ..color = theme.squareStrokeColor.withValues(alpha: 0.2 * flicker)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      // Outline with rounded corners
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        Paint()
          ..color = theme.squareStrokeColor.withValues(alpha: flicker)
          ..style = PaintingStyle.stroke
          ..strokeWidth = theme.squareStrokeWidth,
      );

      // Inner border
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(5), const Radius.circular(2)),
        Paint()
          ..color = theme.squareStrokeColor.withValues(alpha: flicker * 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );

      // Glowing X
      final xPaint = Paint()
        ..color = theme.squareXColor.withValues(alpha: flicker)
        ..strokeWidth = theme.squareXStrokeWidth
        ..strokeCap = StrokeCap.round;
      // X glow
      canvas.drawLine(
        Offset(9, 9), Offset(s - 9, s - 9),
        Paint()
          ..color = theme.squareXColor.withValues(alpha: flicker * 0.3)
          ..strokeWidth = theme.squareXStrokeWidth + 3
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawLine(
        Offset(s - 9, 9), Offset(9, s - 9),
        Paint()
          ..color = theme.squareXColor.withValues(alpha: flicker * 0.3)
          ..strokeWidth = theme.squareXStrokeWidth + 3
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawLine(Offset(9, 9), Offset(s - 9, s - 9), xPaint);
      canvas.drawLine(Offset(s - 9, 9), Offset(9, s - 9), xPaint);
    } else if (theme.id == 'realistic') {
      // ── Realistic — 3D beveled warning block ──
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(5));

      // Gradient fill
      canvas.drawRRect(
        rrect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(theme.squareFillColor, Colors.white, 0.15)!,
              theme.squareFillColor,
              Color.lerp(theme.squareFillColor, Colors.black, 0.25)!,
            ],
            stops: const [0.0, 0.4, 1.0],
          ).createShader(rect),
      );

      // Top/left highlight edge
      final hlPath = Path();
      hlPath.moveTo(4, s - 2);
      hlPath.lineTo(2, 4);
      hlPath.quadraticBezierTo(2, 2, 4, 2);
      hlPath.lineTo(s - 4, 2);
      canvas.drawPath(
        hlPath,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.12)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );

      // Border
      if (theme.squareStrokeWidth > 0) {
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = theme.squareStrokeColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = theme.squareStrokeWidth,
        );
      }

      // Beveled X
      canvas.drawLine(
        Offset(9, 9), Offset(s - 9, s - 9),
        Paint()
          ..color = Color.lerp(theme.squareXColor, Colors.white, 0.25)!
          ..strokeWidth = theme.squareXStrokeWidth
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        Offset(s - 9, 9), Offset(9, s - 9),
        Paint()
          ..color = Color.lerp(theme.squareXColor, Colors.black, 0.15)!
          ..strokeWidth = theme.squareXStrokeWidth
          ..strokeCap = StrokeCap.round,
      );
      // Center dot where X crosses
      canvas.drawCircle(
        Offset(s / 2, s / 2),
        3,
        Paint()..color = Color.lerp(theme.squareXColor, Colors.white, 0.1)!,
      );
    } else if (theme.id == 'retro') {
      // ── Retro — chunky danger block ──
      canvas.drawRect(rect, Paint()..color = theme.squareFillColor);

      // Inner darker rect for depth
      canvas.drawRect(
        rect.deflate(4),
        Paint()..color = Color.lerp(theme.squareFillColor, Colors.black, 0.15)!,
      );

      // Thick outline
      canvas.drawRect(
        rect,
        Paint()
          ..color = theme.squareStrokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = theme.squareStrokeWidth,
      );

      // Bold X
      final xPaint = Paint()
        ..color = theme.squareXColor
        ..strokeWidth = theme.squareXStrokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawLine(Offset(7, 7), Offset(s - 7, s - 7), xPaint);
      canvas.drawLine(Offset(s - 7, 7), Offset(7, s - 7), xPaint);

      // Corner dots for retro flair
      final dotPaint = Paint()..color = theme.squareStrokeColor;
      for (final pos in [
        Offset(5, 5), Offset(s - 5, 5),
        Offset(5, s - 5), Offset(s - 5, s - 5),
      ]) {
        canvas.drawRect(
          Rect.fromCenter(center: pos, width: 3, height: 3),
          dotPaint,
        );
      }
    } else {
      // ── Flat modern — clean rounded square ──
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
      canvas.drawRRect(rrect, Paint()..color = theme.squareFillColor);

      // Subtle inner shading
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(3), const Radius.circular(6)),
        Paint()..color = Color.lerp(theme.squareFillColor, Colors.black, 0.08)!,
      );

      // Clean X
      final xPaint = Paint()
        ..color = theme.squareXColor
        ..strokeWidth = theme.squareXStrokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(10, 10), Offset(s - 10, s - 10), xPaint);
      canvas.drawLine(Offset(s - 10, 10), Offset(10, s - 10), xPaint);
    }
  }
}
