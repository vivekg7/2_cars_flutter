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

    // Gold coin with gradient
    canvas.drawCircle(
      center,
      radius - 1,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.9,
          colors: [
            const Color(0xFFFFE87C),
            const Color(0xFFFFD700),
            const Color(0xFFB8860B),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius - 1)),
    );

    // Rim
    canvas.drawCircle(
      center,
      radius - 1.5,
      Paint()
        ..color = const Color(0xFFB8860B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Inner ring
    canvas.drawCircle(
      center,
      radius - 6,
      Paint()
        ..color = const Color(0xFFFFE87C).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Specular highlight
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - 3, center.dy - 4),
        width: 8,
        height: 5,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );

    // Center dot
    canvas.drawCircle(center, 3, Paint()..color = Colors.white.withValues(alpha: 0.6));
  }

  void _renderSquare(Canvas canvas, Size size) {
    final s = size.width;
    final rect = Rect.fromLTWH(0, 0, s, s);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(5));

    // Gradient fill
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFCC2222), Color(0xFF8B0000)],
        ).createShader(rect),
    );

    // Border
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFF555555)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Beveled X
    canvas.drawLine(
      Offset(9, 9), Offset(s - 9, s - 9),
      Paint()
        ..color = const Color(0xFFEEEEEE)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(s - 9, 9), Offset(9, s - 9),
      Paint()
        ..color = const Color(0xFFAAAAAA)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
