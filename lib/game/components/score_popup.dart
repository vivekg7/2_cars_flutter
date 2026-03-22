import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/game_theme.dart';

/// A "+1" text that floats upward and fades out.
class ScorePopup extends PositionComponent {
  final GameTheme theme;
  double _elapsed = 0;
  static const double _duration = 0.6;
  static const double _riseDistance = 60;

  final double _startY;

  ScorePopup({
    required Vector2 position,
    required this.theme,
  })  : _startY = position.y,
        super(position: position.clone(), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= _duration) {
      removeFromParent();
      return;
    }

    final progress = _elapsed / _duration;
    position.y = _startY - (_riseDistance * progress);
  }

  @override
  void render(Canvas canvas) {
    final progress = _elapsed / _duration;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    final textPainter = TextPainter(
      text: TextSpan(
        text: '+1',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: theme.scorePopupColor.withValues(alpha: opacity),
          shadows: theme.titleHasGlow
              ? [
                  Shadow(
                    color: theme.scorePopupColor.withValues(alpha: opacity * 0.6),
                    blurRadius: 8,
                  ),
                ]
              : theme.titleHasOutline && theme.titleOutlineColor != null
                  ? [
                      Shadow(
                        color: theme.titleOutlineColor!.withValues(alpha: opacity),
                        offset: const Offset(1, 1),
                        blurRadius: 0,
                      ),
                      Shadow(
                        color: theme.titleOutlineColor!.withValues(alpha: opacity),
                        offset: const Offset(-1, -1),
                        blurRadius: 0,
                      ),
                    ]
                  : null,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }
}
