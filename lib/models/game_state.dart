import 'package:flutter/foundation.dart';
import 'score_service.dart';
import 'game_difficulty.dart';

enum GameStatus { initial, playing, paused, gameOver }

class GameState extends ChangeNotifier {
  int score = 0;
  GameStatus status = GameStatus.initial;
  int difficultyLevel = 1;
  int monthlyHighScore = 0;
  GameDifficulty currentDifficulty = GameDifficulty.easy;

  final ScoreService _scoreService = ScoreService();

  GameState() {
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    monthlyHighScore = await _scoreService.getMonthlyHighScore(
      currentDifficulty,
    );
    notifyListeners();
  }

  void setDifficulty(GameDifficulty difficulty) {
    currentDifficulty = difficulty;
    _loadHighScore(); // Reload high score for new difficulty
    notifyListeners();
  }

  void updateScore(int newScore) {
    score = newScore;
    // Simple difficulty scaling based on score for visual feedback if needed
    difficultyLevel = (score / 10).floor() + 1;
    notifyListeners();
  }

  void setStatus(GameStatus newStatus) {
    status = newStatus;
    notifyListeners();
  }

  void reset() {
    score = 0;
    difficultyLevel = 1;
    status = GameStatus.initial;
    notifyListeners();
  }

  void resumeGame() {
    status = GameStatus.playing;
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

  Future<void> endGame() async {
    status = GameStatus.gameOver;
    await _scoreService.saveScore(score, currentDifficulty);
    await _loadHighScore(); // Refresh high score
    notifyListeners();
  }

  void incrementScore() {
    score++;
    notifyListeners();
  }
}
