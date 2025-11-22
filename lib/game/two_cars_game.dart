import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../models/car.dart';
import '../../models/falling_object.dart';
import 'components/lane_background.dart';
import 'components/car_component.dart';
import 'components/falling_object_component.dart';

class TwoCarsGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  final GameState gameState;
  final VoidCallback onGameOver;

  late Car leftCar;
  late Car rightCar;
  late CarComponent leftCarComponent;
  late CarComponent rightCarComponent;
  double _currentSpeed = 300;
  double _timeSinceLastSpawn = 0;
  double _distanceLeft = 0;
  double _distanceRight = 0;
  double _spawnInterval = 1.0; // Seconds
  final Random _random = Random();

  TwoCarsGame({required this.gameState, required this.onGameOver});

  @override
  Color backgroundColor() => const Color(0xFF2C3E50);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Calculate dimensions
    final laneWidth = size.x / 4;

    // Add Lane Backgrounds
    add(
      LaneBackground(
        color: const Color(0xFFE74C3C),
        size: Vector2(size.x / 2, size.y),
        position: Vector2(0, 0),
      ),
    );
    add(
      LaneBackground(
        color: const Color(0xFF3498DB),
        size: Vector2(size.x / 2, size.y),
        position: Vector2(size.x / 2, 0),
      ),
    );

    // Initialize Cars
    leftCar = Car(side: CarSide.left, laneIndex: 0);
    rightCar = Car(side: CarSide.right, laneIndex: 3);

    leftCarComponent = CarComponent(
      car: leftCar,
      color: Colors.white,
      laneWidth: laneWidth,
    )..position = Vector2(0, size.y - 100);

    rightCarComponent = CarComponent(
      car: rightCar,
      color: Colors.white,
      laneWidth: laneWidth,
    )..position = Vector2(0, size.y - 100);

    add(leftCarComponent);
    add(rightCarComponent);
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (gameState.status != GameStatus.playing) return;

    final touchX = event.localPosition.x;
    if (touchX < size.x / 2) {
      leftCar.switchLane();
      leftCarComponent.updateLane();
    } else {
      rightCar.switchLane();
      rightCarComponent.updateLane();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameState.status != GameStatus.playing) return;

    // Update speed based on difficulty
    final difficulty = gameState.currentDifficulty;
    if (_currentSpeed < difficulty.maxSpeed) {
      _currentSpeed += 5 * dt;
    }

    // Spawning Logic
    if (difficulty.useFixedSpacing) {
      // Fixed Distance Spawning (Medium/Hard) - Per Side
      _distanceLeft += _currentSpeed * dt;
      _distanceRight += _currentSpeed * dt;

      if (_distanceLeft >= difficulty.spawnDistance) {
        _spawnFallingObject(forceSide: CarSide.left);
        _distanceLeft = 0;
      }

      if (_distanceRight >= difficulty.spawnDistance) {
        _spawnFallingObject(forceSide: CarSide.right);
        _distanceRight = 0;
      }
    } else {
      // Random Time Spawning (Easy) - Global
      _timeSinceLastSpawn += dt;
      if (_timeSinceLastSpawn >= _spawnInterval) {
        _spawnFallingObject();
        _timeSinceLastSpawn = 0;
        // Randomize next interval between 0.8 and 1.5 seconds
        _spawnInterval = 0.8 + _random.nextDouble() * 0.7;
      }
    }

    // Move objects
    for (final child in children) {
      if (child is FallingObjectComponent) {
        child.position.y += _currentSpeed * dt;

        // Check if object missed (passed bottom)
        if (child.position.y > size.y + 50) {
          if (child.object.type == ObjectType.circle && !child.isRemoved) {
            // Missed a circle -> Game Over
            gameOver();
          }
          child.removeFromParent();
        }
      }
    }
  }

  void startGame() {
    gameState.setStatus(GameStatus.playing);
    gameState.score = 0;

    // Set initial speed based on difficulty
    _currentSpeed = gameState.currentDifficulty.initialSpeed;

    _timeSinceLastSpawn = 0;
    _distanceLeft = 0;
    _distanceRight = 0;
    _spawnInterval = 1.0;

    // Clear existing objects
    children.whereType<FallingObjectComponent>().forEach(
      (c) => c.removeFromParent(),
    );
    children.whereType<ParticleSystemComponent>().forEach(
      (c) => c.removeFromParent(),
    );

    resumeEngine();
  }

  void _spawnFallingObject({CarSide? forceSide}) {
    final laneWidth = size.x / 4;

    // Determine Side
    CarSide side;
    if (forceSide != null) {
      side = forceSide;
    } else {
      side = _random.nextBool() ? CarSide.left : CarSide.right;
    }

    // Determine Lane (0 or 1 for left, 2 or 3 for right)
    int laneIndex;
    if (side == CarSide.left) {
      laneIndex = _random.nextBool() ? 0 : 1;
    } else {
      laneIndex = _random.nextBool() ? 2 : 3;
    }

    // Determine Type (Circle or Square)
    ObjectType type = _random.nextBool()
        ? ObjectType.circle
        : ObjectType.square;

    final object = FallingObject(
      id:
          DateTime.now().millisecondsSinceEpoch.toString() +
          _random.nextInt(1000).toString(),
      type: type,
      side: side,
      laneIndex: laneIndex,
      verticalPosition: -0.1,
    );

    add(FallingObjectComponent(object: object, laneWidth: laneWidth));
  }

  void handleCollision(CarComponent car, FallingObjectComponent object) {
    if (object.isRemoved) return;

    if (object.object.type == ObjectType.circle) {
      // Collect circle
      gameState.incrementScore();
      object.removeFromParent();
      _spawnParticles(object.position, Colors.yellow, 10);
    } else {
      // Hit square - Game Over
      object.removeFromParent();
      _spawnParticles(
        object.position,
        Colors.red,
        40,
      ); // More particles for explosion

      // Delay game over to show explosion
      Future.delayed(const Duration(milliseconds: 500), () {
        gameOver();
      });
    }
  }

  void _spawnParticles(Vector2 position, Color color, int count) {
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: count,
          lifespan: 0.8, // Longer lifespan
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 300),
            speed:
                Vector2.random(Random()) * 400 -
                Vector2(200, 200), // Faster explosion
            position: position.clone(),
            child: CircleParticle(
              radius: 3, // Larger particles
              paint: Paint()..color = color,
            ),
          ),
        ),
      ),
    );
  }

  void gameOver() {
    if (gameState.status == GameStatus.playing) {
      gameState.endGame();
      onGameOver();
      pauseEngine();
    }
  }

  void resetGame() {
    gameState.reset();
    gameState.startGame();
    leftCar.reset();
    rightCar.reset();
    leftCarComponent.updateLane();
    rightCarComponent.updateLane();

    // Remove all objects
    children.whereType<FallingObjectComponent>().forEach(remove);

    _timeSinceLastSpawn = 0;
    resumeEngine();
  }
}
