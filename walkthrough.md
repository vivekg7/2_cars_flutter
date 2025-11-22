# 2 Cars Game Walkthrough

I have successfully implemented the "2 Cars" game in Flutter.

## Architecture
The app follows a clean architecture separating logic, models, and UI.

- **Models**: `GameState`, `Car`, `FallingObject` define the data.
- **Logic**: `GameManager` (ChangeNotifier) handles the game loop, spawning, movement, and collision.
- **UI**: `GameScreen` listens to `GameManager` and renders the game state using `CarWidget`, `FallingObjectWidget`, and `GameOverlays`.

## Features
- **Split Screen Gameplay**: Control two cars independently.
- **Lane Switching**: Tap left/right to switch lanes.
- **Falling Objects**: Circles (collect) and Squares (avoid).
- **Score & Difficulty**: Score increases with circles; speed increases with score.
- **Game States**: Start, Playing, Paused, Game Over.
- **High Score**: Tracks the highest score in the session (persistence can be added easily).

## Verification
- **Gameplay**: Verified that tapping switches lanes correctly.
- **Collision**: Verified that hitting a square or missing a circle ends the game.
- **Visuals**: Verified that cars and objects are aligned with the lanes.
- **Performance**: Using `Timer` for game loop ensures smooth performance for this simple 2D game.

## Next Steps
- Add sound effects.
- Persist high score using `shared_preferences`.
- Add more visual effects (particles on collection).
