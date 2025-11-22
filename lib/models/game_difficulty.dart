enum GameDifficulty {
  easy,
  medium,
  hard;

  String get displayName {
    switch (this) {
      case GameDifficulty.easy:
        return 'EASY';
      case GameDifficulty.medium:
        return 'MEDIUM';
      case GameDifficulty.hard:
        return 'HARD';
    }
  }

  double get initialSpeed {
    switch (this) {
      case GameDifficulty.easy:
        return 300.0;
      case GameDifficulty.medium:
        return 400.0;
      case GameDifficulty.hard:
        return 500.0;
    }
  }

  double get maxSpeed {
    switch (this) {
      case GameDifficulty.easy:
        return 600.0;
      case GameDifficulty.medium:
        return 700.0;
      case GameDifficulty.hard:
        return 850.0;
    }
  }

  bool get useFixedSpacing {
    return this != GameDifficulty.easy;
  }

  double get spawnDistance {
    switch (this) {
      case GameDifficulty.easy:
        return 0; // Not used for easy
      case GameDifficulty.medium:
        return 350.0;
      case GameDifficulty.hard:
        return 250.0;
    }
  }
}
