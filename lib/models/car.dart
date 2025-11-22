enum CarSide { left, right }

class Car {
  final CarSide side;
  // laneIndex: 0 for left lane of the side, 1 for right lane of the side
  int laneIndex;

  Car({required this.side, this.laneIndex = 0});

  void switchLane() {
    laneIndex = laneIndex == 0 ? 1 : 0;
  }

  void reset() {
    laneIndex = 0;
  }
}
