import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/game_theme.dart';

class LaneBackground extends PositionComponent {
  GameTheme theme;
  final bool isLeftSide;
  double scrollSpeed = 0;
  double _scrollOffset = 0;

  LaneBackground({
    required this.theme,
    required this.isLeftSide,
    required Vector2 size,
    required Vector2 position,
  }) : super(size: size, position: position);

  @override
  void update(double dt) {
    super.update(dt);
    if (theme.hasScrollingLanes || theme.hasGridLines) {
      _scrollOffset += scrollSpeed * dt;
      // Keep offset within a reasonable range to avoid overflow
      _scrollOffset %= 200;
    }
  }

  @override
  void render(Canvas canvas) {
    final tint = isLeftSide ? theme.leftLaneTint : theme.rightLaneTint;

    // Background fill
    canvas.drawRect(
      size.toRect(),
      Paint()..color = tint.withValues(alpha: theme.laneTintOpacity),
    );

    // ── Grid lines (neon only) ──
    if (theme.hasGridLines && theme.gridLineColor != null) {
      final gridPaint = Paint()
        ..color = theme.gridLineColor!
        ..strokeWidth = 0.5;

      // Vertical grid lines
      const gridSpacing = 40.0;
      for (double x = 0; x < size.x; x += gridSpacing) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.y), gridPaint);
      }

      // Horizontal scrolling grid lines
      const hSpacing = 50.0;
      final startY = _scrollOffset % hSpacing;
      for (double y = startY; y < size.y; y += hSpacing) {
        canvas.drawLine(Offset(0, y), Offset(size.x, y), gridPaint);
      }
    }

    // ── Lane divider (center of this half) ──
    _drawDivider(
      canvas,
      x: size.x / 2,
      color: theme.laneDividerColor,
      style: theme.laneDividerStyle,
      width: theme.laneDividerWidth,
    );

    // ── Center divider (between left and right halves) ──
    // Only draw on the right edge of left side, or left edge of right side
    if (!isLeftSide) {
      _drawDivider(
        canvas,
        x: 0,
        color: theme.centerDividerColor,
        style: theme.centerDividerStyle,
        width: theme.centerDividerWidth,
      );
    } else {
      _drawDivider(
        canvas,
        x: size.x,
        color: theme.centerDividerColor,
        style: theme.centerDividerStyle,
        width: theme.centerDividerWidth,
      );
    }

    // ── Outer edge border (retro) ──
    if (theme.laneDividerStyle == DividerStyle.dashed && theme.laneDividerWidth >= 3) {
      final edgeX = isLeftSide ? 1.0 : size.x - 1.0;
      canvas.drawLine(
        Offset(edgeX, 0),
        Offset(edgeX, size.y),
        Paint()
          ..color = theme.laneDividerColor.withValues(alpha: 0.3)
          ..strokeWidth = 2,
      );
    }

    // ── Vignette (realistic) ──
    if (theme.hasVignette) {
      final vignetteRect = size.toRect();
      final vignettePaint = Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.3),
          ],
          stops: const [0.6, 1.0],
        ).createShader(vignetteRect);
      canvas.drawRect(vignetteRect, vignettePaint);
    }
  }

  void _drawDivider(
    Canvas canvas, {
    required double x,
    required Color color,
    required DividerStyle style,
    required double width,
  }) {
    switch (style) {
      case DividerStyle.solid:
        canvas.drawLine(
          Offset(x - width / 2, 0),
          Offset(x - width / 2, size.y),
          Paint()
            ..color = color.withValues(alpha: 0.4)
            ..strokeWidth = width,
        );
        break;

      case DividerStyle.dashed:
        final paint = Paint()
          ..color = color
          ..strokeWidth = width
          ..strokeCap = StrokeCap.butt;
        const dashLength = 30.0;
        const gapLength = 20.0;
        final startY = _scrollOffset % (dashLength + gapLength);
        for (double y = startY - dashLength; y < size.y; y += dashLength + gapLength) {
          canvas.drawLine(
            Offset(x, y),
            Offset(x, min(y + dashLength, size.y)),
            paint,
          );
        }
        break;

      case DividerStyle.glow:
        // Outer glow
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.y),
          Paint()
            ..color = color.withValues(alpha: 0.15)
            ..strokeWidth = width + 6
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
        // Core line
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.y),
          Paint()
            ..color = color.withValues(alpha: 0.8)
            ..strokeWidth = width,
        );
        break;

      case DividerStyle.doubleLine:
        const gap = 4.0;
        final paint = Paint()
          ..color = color
          ..strokeWidth = width;

        // For dashed double line (realistic), scroll the dashes
        if (theme.hasScrollingLanes) {
          const dashLength = 30.0;
          const gapLength = 20.0;
          final startY = _scrollOffset % (dashLength + gapLength);
          for (double y = startY - dashLength; y < size.y; y += dashLength + gapLength) {
            canvas.drawLine(
              Offset(x - gap, y),
              Offset(x - gap, min(y + dashLength, size.y)),
              paint,
            );
            canvas.drawLine(
              Offset(x + gap, y),
              Offset(x + gap, min(y + dashLength, size.y)),
              paint,
            );
          }
        } else {
          canvas.drawLine(Offset(x - gap, 0), Offset(x - gap, size.y), paint);
          canvas.drawLine(Offset(x + gap, 0), Offset(x + gap, size.y), paint);
        }
        break;
    }
  }
}
