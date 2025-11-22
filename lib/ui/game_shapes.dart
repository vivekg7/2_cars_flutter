import 'package:flutter/material.dart';

enum GameShapeType { circle, square }

class GameShapeWidget extends StatelessWidget {
  final GameShapeType type;
  final double size;

  const GameShapeWidget({super.key, required this.type, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: GameShapePainter(type: type),
    );
  }
}

class GameShapePainter extends CustomPainter {
  final GameShapeType type;

  GameShapePainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    if (type == GameShapeType.circle) {
      _renderCircle(canvas, size);
    } else {
      _renderSquare(canvas, size);
    }
  }

  void _renderCircle(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer Ring
    final ringPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius - 2, ringPaint);

    // Inner Core
    final corePaint = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 8, corePaint);

    // Center Star/Diamond
    final starPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, 4, starPaint);
  }

  void _renderSquare(Canvas canvas, Size size) {
    // Hazard Block
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Main Body
    final bodyPaint = Paint()..color = Colors.yellow;
    canvas.drawRect(rect, bodyPaint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(rect, borderPaint);

    // "X" Warning Symbol
    final xPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      const Offset(8, 8),
      Offset(size.width - 8, size.height - 8),
      xPaint,
    );
    canvas.drawLine(
      Offset(size.width - 8, 8),
      Offset(8, size.height - 8),
      xPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
