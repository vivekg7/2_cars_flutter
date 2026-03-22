import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/game_theme.dart';

/// Vertical speed lines at screen edges that intensify with speed.
class SpeedLines extends PositionComponent {
  GameTheme theme;
  double currentSpeed = 0;
  double maxSpeed = 600;

  final Random _random = Random();
  final List<_SpeedLine> _lines = [];

  SpeedLines({
    required this.theme,
    required Vector2 size,
  }) : super(size: size, position: Vector2.zero());

  @override
  void update(double dt) {
    super.update(dt);

    if (!theme.speedLinesEnabled) {
      _lines.clear();
      return;
    }

    final intensity = (currentSpeed / maxSpeed).clamp(0.0, 1.0);
    if (intensity < 0.3) {
      _lines.clear();
      return;
    }

    // Spawn new lines based on intensity
    final spawnRate = (intensity * 8).round(); // up to 8 lines per frame
    for (int i = 0; i < spawnRate; i++) {
      if (_random.nextDouble() < 0.4) {
        _lines.add(_SpeedLine(
          x: _randomEdgeX(),
          y: _random.nextDouble() * size.y * 0.3,
          length: 20 + _random.nextDouble() * 40 * intensity,
          speed: currentSpeed * (0.8 + _random.nextDouble() * 0.4),
          opacity: (0.1 + intensity * 0.4) * (_random.nextDouble() * 0.5 + 0.5),
        ));
      }
    }

    // Update existing lines
    for (final line in _lines) {
      line.y += line.speed * dt;
    }

    // Remove off-screen lines
    _lines.removeWhere((l) => l.y > size.y + l.length);
  }

  double _randomEdgeX() {
    // Lines appear in the outer 15% of each side
    final edgeWidth = size.x * 0.15;
    if (_random.nextBool()) {
      return _random.nextDouble() * edgeWidth;
    } else {
      return size.x - _random.nextDouble() * edgeWidth;
    }
  }

  @override
  void render(Canvas canvas) {
    if (!theme.speedLinesEnabled || _lines.isEmpty) return;

    for (final line in _lines) {
      final paint = Paint()
        ..color = theme.speedLineColor.withValues(alpha: line.opacity)
        ..strokeWidth = theme.speedLineWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(line.x, line.y),
        Offset(line.x, line.y + line.length),
        paint,
      );
    }
  }
}

class _SpeedLine {
  double x;
  double y;
  final double length;
  final double speed;
  final double opacity;

  _SpeedLine({
    required this.x,
    required this.y,
    required this.length,
    required this.speed,
    required this.opacity,
  });
}
