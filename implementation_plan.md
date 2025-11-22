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
