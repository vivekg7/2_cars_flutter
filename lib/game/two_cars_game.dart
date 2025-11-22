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

  final Random _random = Random();
  double _timeSinceLastSpawn = 0;
  final double _spawnInterval = 1.0; // Seconds

  TwoCarsGame({required this.gameState, required this.onGameOver});

  @override
  Color backgroundColor() => const Color(0xFF2C3E50);

  @override
  Future<void> onLoad() async {
    // Calculate dimensions
    final laneWidth = size.x / 4;

    // Add Backgrounds
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
    leftCar = Car(side: CarSide.left);
    rightCar = Car(side: CarSide.right);

    leftCarComponent = CarComponent(
      car: leftCar,
      color: Colors.white,
      laneWidth: laneWidth,
    )..position = Vector2(0, size.y - 100); // Initial Y, X set by component

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

    // Spawning Logic
    _timeSinceLastSpawn += dt;
    // Decrease interval as difficulty increases
    double currentInterval = _spawnInterval / gameState.difficultyMultiplier;
    if (currentInterval < 0.4) currentInterval = 0.4; // Cap max spawn rate

    if (_timeSinceLastSpawn >= currentInterval) {
      _spawnObject();
      _timeSinceLastSpawn = 0;
    }

    // Move Objects
    double speed = 300 * gameState.difficultyMultiplier; // Pixels per second
    for (var component in children.whereType<FallingObjectComponent>()) {
      component.position.y += speed * dt;

      // Check for missed circles (passed bottom of screen)
      if (component.position.y > size.y) {
        if (component.object.type == ObjectType.circle) {
          // Missed a circle - Game Over
          // Small delay for consistency, though no explosion here usually
          // Or maybe add a "poof" effect at bottom?
          // For now just game over immediately or small delay
          gameOver();
        }
        component.removeFromParent();
      }
    }
  }

  void _spawnObject() {
    final laneWidth = size.x / 4;

    // Randomize side and lane
    final side = _random.nextBool() ? CarSide.left : CarSide.right;
    final laneIndex = _random.nextBool() ? 0 : 1;
    final type = _random.nextBool() ? ObjectType.circle : ObjectType.square;

    // Check overlap (simple check: don't spawn if something was just spawned there?
    // actually we just spawn based on timer, so overlap is rare unless very fast.
    // We can add a check if we want strict non-overlap)

    final obj = FallingObject(
      id: '', // Not needed for Flame
      type: type,
      side: side,
      laneIndex: laneIndex,
    );

    add(FallingObjectComponent(object: obj, laneWidth: laneWidth));
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
