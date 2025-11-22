import 'package:flutter/foundation.dart';

enum GameStatus { playing, paused, gameOver, initial }

class GameState extends ChangeNotifier {
  int score = 0;
  int highScore = 0;
  GameStatus status = GameStatus.initial;
  double difficultyMultiplier = 1.0;

  void reset() {
    score = 0;
    status = GameStatus.initial;
    difficultyMultiplier = 1.0;
    notifyListeners();
  }

  void startGame() {
    status = GameStatus.playing;
    notifyListeners();
  }

  void pauseGame() {
    status = GameStatus.paused;
    notifyListeners();
  }

  void resumeGame() {
    status = GameStatus.playing;
    notifyListeners();
  }

  void endGame() {
    status = GameStatus.gameOver;
    if (score > highScore) {
      highScore = score;
    }
    notifyListeners();
  }

  void incrementScore() {
    score++;
    // Increase difficulty every 10 points
    // Base is 1.0. Every 10 points, add 0.1 (10% speed increase).
    // Example: Score 0-9 -> 1.0x
    //          Score 10-19 -> 1.1x
    //          Score 20-29 -> 1.2x
    difficultyMultiplier = 1.0 + (score ~/ 10) * 0.1;

    // Cap at 2.5x speed
    if (difficultyMultiplier > 2.5) {
      difficultyMultiplier = 2.5;
    }
    notifyListeners();
  }
}
