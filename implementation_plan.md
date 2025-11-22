# 2 Cars Game - Flame Migration Plan

## Goal Description
Migrate the existing "2 Cars" game from standard Flutter widgets to the **Flame Engine**. This is to improve performance and smoothness, especially on older devices, by utilizing Flame's optimized game loop and rendering system.

## User Review Required
> [!NOTE]
> This is a complete rewrite of the rendering and game loop logic. The high-level game rules remain the same.

## Proposed Changes

### Dependencies
- Add `flame` package.

### Architecture Changes
The `GameManager` (ChangeNotifier) will be replaced by `TwoCarsGame` (extending `FlameGame`).
UI widgets (`CarWidget`, `FallingObjectWidget`) will be replaced by Flame `Component`s.

#### [NEW] lib/game
- `two_cars_game.dart`: The main `FlameGame` class. Handles the game loop, input, and state.
- `components/car_component.dart`: `SpriteComponent` or `PositionComponent` for the car.
- `components/object_component.dart`: `ShapeComponent` (Circle/Rectangle) for falling objects.
- `components/lane_background.dart`: Background rendering.

#### [MODIFY] lib/main.dart
- Update to use `GameWidget` instead of `GameScreen`.

#### [DELETE]
- `lib/logic/game_manager.dart` (Replaced by `TwoCarsGame`)
- `lib/ui/game_screen.dart` (Replaced by `GameWidget`)
- `lib/ui/car_widget.dart`
- `lib/ui/falling_object_widget.dart`

### Logic Migration
- **Movement**: Use `update(dt)` in components for smooth movement based on delta time.
- **Collision**: Use Flame's `CollisionCallbacks` or manual AABB check in `update`.
- **State**: Keep `GameState` for score/status, but manage it within `TwoCarsGame`.

## Verification Plan
- **Performance**: Verify 60fps on device.
- **Gameplay**: Ensure same rules apply (lanes, collision, scoring).

## Score Persistence
- **Goal**: Persist top 10 scores with dates and track highest score of the last month.
- **Implementation**:
    - Create `ScoreEntry` model (score, timestamp).
    - Create `ScoreService` using `shared_preferences` to store list of scores (JSON encoded).
    - Update `GameState` to save score on game over.
    - Update `GameOverlays` to display the high scores.

## Home Screen Improvements
- **Goal**: Add a "High Scores" button to the initial start screen.
- **Implementation**:
    - Update `GameOverlays` to show a "High Scores" button in the `initial` state.
    - Create a new overlay state or dialog to show the high scores list (reusing the list from Game Over).

## Collision & Particles
- **Goal**: Improve collision realism and add visual feedback (particles).
- **Implementation**:
    - **Collision**:
        - Mixin `HasCollisionDetection` to `TwoCarsGame`.
        - Add `RectangleHitbox` to `CarComponent`.
        - Add `CircleHitbox`/`RectangleHitbox` to `FallingObjectComponent`.
        - Use `onCollisionStart` to handle impacts.
    - **Particles**:
        - Create `ParticleSystemComponent` for explosions/collection effects.
        - Trigger particles on:
            - Circle collection (Sparkles).
            - Square collision (Explosion).
            - Circle miss (Red poof).
            - Square miss (Small dust).

## Game Over Delay
- **Goal**: Ensure explosion animation plays before showing Game Over screen.
- **Implementation**:
    - In `TwoCarsGame.handleCollision` for squares:
        - Spawn explosion particles.
        - Pause the game engine *after* a delay (e.g., 1 second).
        - Or better, use a `Timer` or `Future.delayed` to trigger `gameState.endGame()` and `onGameOver()`.
        - Ensure particles continue to update even if other logic stops (or just don't pause engine immediately).

## Car Exhaust Particles
- **Goal**: Simulate forward movement with continuous exhaust particles.
- **Implementation**:
    - In `CarComponent.update`:
        - Periodically spawn particles at the bottom of the car.
        - Use `ParticleSystemComponent` with `AcceleratedParticle`.
        - Colors: Mix of Blue and Gray.
        - Direction: Downwards (opposite to movement direction simulation).

## Visual Overhaul
- **Goal**: Enhance the visual design of Cars, Circles, and Squares.
- **Implementation**:
    - **CarComponent**:
        - Draw a sleek car body using `RRect` (rounded rectangle).
        - Add details: Windshield (darker color), Headlights (yellow/white), and maybe a racing stripe.
        - Use gradients for a premium look.
    - **FallingObjectComponent**:
        - **Circles (Collectibles)**:
            - Draw a "halo" or ring effect.
            - Add an inner glowing core or a star/diamond shape.
            - Use a pulsing effect (optional, via update loop).
        - **Squares (Obstacles)**:
            - Draw as a "Hazard" block.
            - Add an "X" or cross symbol in the center.
            - Add a border/stroke to define the edge clearly.

## Play Store Preparation
- **Goal**: Configure app for Google Play Store publication.
- **Details**:
    - **Package Name**: `com.crylo.two_cars`
    - **App Label**: "2 Cars"
    - **Signing**: Configure `key.properties` and `build.gradle.kts`.
- **Implementation**:
    - **Rename Package**:
        - Update `applicationId` in `android/app/build.gradle.kts`.
        - Update `package` in `AndroidManifest.xml` (main, debug, profile).
        - Move `MainActivity.kt` to `com/crylo/two_cars` and update package statement.
    - **App Label**:
        - Update `android:label` in `android/app/src/main/AndroidManifest.xml`.
    - **Signing Configuration**:
        - Create `android/key.properties` (template).
        - Update `android/app/build.gradle.kts` to load keystore info.
    - **Build**:
        - Run `flutter build appbundle`.
