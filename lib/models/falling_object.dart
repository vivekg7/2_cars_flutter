import 'car.dart';

enum ObjectType { circle, square }

class FallingObject {
  final String id;
  final ObjectType type;
  final CarSide side;
  final int laneIndex; // 0 or 1
  double verticalPosition; // 0.0 (top) to 1.0 (bottom)

  FallingObject({
    required this.id,
    required this.type,
    required this.side,
    required this.laneIndex,
    this.verticalPosition = -0.1, // Start slightly above screen
  });
}
