import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../models/game_theme.dart';
import '../../models/car.dart';
import '../../models/falling_object.dart';
import 'components/lane_background.dart';
import 'components/car_component.dart';
import 'components/falling_object_component.dart';
import 'components/rect_particle.dart';
import 'components/score_popup.dart';
import 'components/speed_lines.dart';

class TwoCarsGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  final GameState gameState;
  final VoidCallback onGameOver;

  late Car leftCar;
  late Car rightCar;
  late CarComponent leftCarComponent;
  late CarComponent rightCarComponent;
  late LaneBackground leftLaneBg;
  late LaneBackground rightLaneBg;
  late SpeedLines speedLines;
  double _currentSpeed = 300;
  double _timeSinceLastSpawn = 0;
  double _distanceLeft = 0;
  double _distanceRight = 0;
  double _spawnInterval = 1.0;
  final Random _random = Random();

  /// Screen shake state — read by GamePage to offset the widget.
  double shakeOffsetX = 0;
  double shakeOffsetY = 0;
  double _shakeTimeRemaining = 0;

  TwoCarsGame({required this.gameState, required this.onGameOver});

  GameTheme get theme => gameState.currentTheme;

  @override
  Color backgroundColor() => theme.backgroundColor;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final laneWidth = size.x / 4;

    // Add Lane Backgrounds
    leftLaneBg = LaneBackground(
      theme: theme,
      isLeftSide: true,
      size: Vector2(size.x / 2, size.y),
      position: Vector2(0, 0),
    );
    rightLaneBg = LaneBackground(
      theme: theme,
      isLeftSide: false,
      size: Vector2(size.x / 2, size.y),
      position: Vector2(size.x / 2, 0),
    );
    add(leftLaneBg);
    add(rightLaneBg);

    // Initialize Cars
    leftCar = Car(side: CarSide.left, laneIndex: 0);
    rightCar = Car(side: CarSide.right, laneIndex: 3);

    leftCarComponent = CarComponent(
      car: leftCar,
      theme: theme,
      laneWidth: laneWidth,
    )..position = Vector2(0, size.y - 150);

    rightCarComponent = CarComponent(
      car: rightCar,
      theme: theme,
      laneWidth: laneWidth,
    )..position = Vector2(0, size.y - 150);

    add(leftCarComponent);
    add(rightCarComponent);

    // Speed lines overlay
    speedLines = SpeedLines(theme: theme, size: size);
    add(speedLines);
  }

  /// Refresh theme on all components (called when theme changes).
  void refreshTheme() {
    leftLaneBg.theme = theme;
    rightLaneBg.theme = theme;
    leftCarComponent.theme = theme;
    rightCarComponent.theme = theme;
    speedLines.theme = theme;
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

    // Screen shake (runs even when game ends)
    if (_shakeTimeRemaining > 0) {
      _shakeTimeRemaining -= dt;
      if (_shakeTimeRemaining <= 0) {
        shakeOffsetX = 0;
        shakeOffsetY = 0;
      } else {
        shakeOffsetX = (_random.nextDouble() * 8 - 4);
        shakeOffsetY = (_random.nextDouble() * 8 - 4);
      }
    }

    if (gameState.status != GameStatus.playing) return;

    // Update speed based on difficulty
    final difficulty = gameState.currentDifficulty;
    if (_currentSpeed < difficulty.maxSpeed) {
      _currentSpeed += 5 * dt;
    }

    // Update lane scroll speed & speed lines
    leftLaneBg.scrollSpeed = _currentSpeed;
    rightLaneBg.scrollSpeed = _currentSpeed;
    speedLines.currentSpeed = _currentSpeed;
    speedLines.maxSpeed = difficulty.maxSpeed;

    // Spawning Logic
    if (difficulty.useFixedSpacing) {
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
      _timeSinceLastSpawn += dt;
      if (_timeSinceLastSpawn >= _spawnInterval) {
        _spawnFallingObject();
        _timeSinceLastSpawn = 0;
        _spawnInterval = 0.8 + _random.nextDouble() * 0.7;
      }
    }

    // Move objects
    for (final child in children) {
      if (child is FallingObjectComponent) {
        child.position.y += _currentSpeed * dt;

        if (child.position.y > size.y + 50) {
          if (child.object.type == ObjectType.circle && !child.isRemoved) {
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

    _currentSpeed = gameState.currentDifficulty.initialSpeed;
    _timeSinceLastSpawn = 0;

    if (gameState.currentDifficulty.useFixedSpacing) {
      final maxOffset = gameState.currentDifficulty.spawnDistance * 0.5;
      _distanceLeft = _random.nextDouble() * maxOffset;
      _distanceRight = _random.nextDouble() * maxOffset;
    } else {
      _distanceLeft = 0;
      _distanceRight = 0;
    }

    _spawnInterval = 1.0;

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

    CarSide side;
    if (forceSide != null) {
      side = forceSide;
    } else {
      side = _random.nextBool() ? CarSide.left : CarSide.right;
    }

    int laneIndex;
    if (side == CarSide.left) {
      laneIndex = _random.nextBool() ? 0 : 1;
    } else {
      laneIndex = _random.nextBool() ? 2 : 3;
    }

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

    add(FallingObjectComponent(
      object: object,
      laneWidth: laneWidth,
      theme: theme,
    ));
  }

  void handleCollision(CarComponent car, FallingObjectComponent object) {
    if (object.isRemoved) return;

    if (object.object.type == ObjectType.circle) {
      gameState.incrementScore();
      _spawnCollectionParticles(object.position);
      // Score popup
      add(ScorePopup(position: object.position.clone(), theme: theme));
      object.removeFromParent();
    } else {
      object.removeFromParent();
      _spawnCollisionParticles(object.position);
      // Screen shake
      _triggerScreenShake();

      Future.delayed(const Duration(milliseconds: 500), () {
        gameOver();
      });
    }
  }

  void _triggerScreenShake() {
    _shakeTimeRemaining = 0.25; // ~4 frames at 60fps worth of shake
  }

  void _spawnCollectionParticles(Vector2 position) {
    final t = theme;
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: t.collectionParticleCount,
          lifespan: 0.8,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 300),
            speed:
                Vector2.random(Random()) * 400 - Vector2(200, 200),
            position: position.clone(),
            child: t.collectionParticleShape == ParticleShape.square
                ? RectParticle(
                    rectSize: Vector2.all(t.collectionParticleSize),
                    paint: Paint()..color = t.collectionParticleColor,
                  ) as Particle
                : CircleParticle(
                    radius: t.collectionParticleSize,
                    paint: Paint()..color = t.collectionParticleColor,
                  ),
          ),
        ),
      ),
    );
  }

  void _spawnCollisionParticles(Vector2 position) {
    final t = theme;
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: t.collisionParticleCount,
          lifespan: 0.8,
          generator: (i) => AcceleratedParticle(
            acceleration: t.collisionHasGravity
                ? Vector2(0, 500)
                : Vector2(0, 300),
            speed:
                Vector2.random(Random()) * 400 - Vector2(200, 200),
            position: position.clone(),
            child: CircleParticle(
              radius: t.collisionParticleSize,
              paint: Paint()..color = t.collisionParticleColor,
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
    // Refresh theme on all components in case it changed
    refreshTheme();

    // Clear shake
    shakeOffsetX = 0;
    shakeOffsetY = 0;
    _shakeTimeRemaining = 0;

    gameState.reset();
    gameState.startGame();
    leftCar.reset();
    rightCar.reset();
    leftCarComponent.updateLane();
    rightCarComponent.updateLane();

    _currentSpeed = gameState.currentDifficulty.initialSpeed;

    children.whereType<FallingObjectComponent>().forEach(remove);
    children.whereType<ScorePopup>().forEach(remove);

    _timeSinceLastSpawn = 0;
    if (gameState.currentDifficulty.useFixedSpacing) {
      final maxOffset = gameState.currentDifficulty.spawnDistance * 0.5;
      _distanceLeft = _random.nextDouble() * maxOffset;
      _distanceRight = _random.nextDouble() * maxOffset;
    } else {
      _distanceLeft = 0;
      _distanceRight = 0;
    }
    resumeEngine();
  }

  void clearGame() {
    // Refresh theme on all components in case it changed
    refreshTheme();

    // Clear shake
    shakeOffsetX = 0;
    shakeOffsetY = 0;
    _shakeTimeRemaining = 0;

    leftCar.reset();
    rightCar.reset();
    leftCarComponent.updateLane();
    rightCarComponent.updateLane();

    _currentSpeed = gameState.currentDifficulty.initialSpeed;

    children.whereType<FallingObjectComponent>().forEach(remove);
    children.whereType<ParticleSystemComponent>().forEach(remove);
    children.whereType<ScorePopup>().forEach(remove);

    _timeSinceLastSpawn = 0;

    if (gameState.currentDifficulty.useFixedSpacing) {
      final maxOffset = gameState.currentDifficulty.spawnDistance * 0.5;
      _distanceLeft = _random.nextDouble() * maxOffset;
      _distanceRight = _random.nextDouble() * maxOffset;
    } else {
      _distanceLeft = 0;
      _distanceRight = 0;
    }
  }
}
