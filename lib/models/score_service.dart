import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_difficulty.dart';

class ScoreEntry {
  final int score;
  final DateTime date;

  ScoreEntry({required this.score, required this.date});

  Map<String, dynamic> toJson() => {
    'score': score,
    'date': date.toIso8601String(),
  };

  factory ScoreEntry.fromJson(Map<String, dynamic> json) {
    return ScoreEntry(score: json['score'], date: DateTime.parse(json['date']));
  }
}

class ScoreService {
  static const String _highScoresKeyPrefix = 'high_scores_';

  String _getKey(GameDifficulty difficulty) {
    return '$_highScoresKeyPrefix${difficulty.name}';
  }

  Future<void> saveScore(int score, GameDifficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(difficulty);
    final List<String> scoresJson = prefs.getStringList(key) ?? [];

    final List<ScoreEntry> scores = scoresJson
        .map((s) => ScoreEntry.fromJson(jsonDecode(s)))
        .toList();

    scores.add(ScoreEntry(score: score, date: DateTime.now()));

    // Sort descending
    scores.sort((a, b) => b.score.compareTo(a.score));

    // Keep top 10
    if (scores.length > 10) {
      scores.removeRange(10, scores.length);
    }

    final List<String> updatedScoresJson = scores
        .map((s) => jsonEncode(s.toJson()))
        .toList();

    await prefs.setStringList(key, updatedScoresJson);
  }

  Future<List<ScoreEntry>> getHighScores(GameDifficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(difficulty);
    final List<String> scoresJson = prefs.getStringList(key) ?? [];

    return scoresJson.map((s) => ScoreEntry.fromJson(jsonDecode(s))).toList();
  }

  Future<int> getMonthlyHighScore(GameDifficulty difficulty) async {
    final scores = await getHighScores(difficulty);
    final now = DateTime.now();

    int monthlyHigh = 0;
    for (var entry in scores) {
      if (entry.date.year == now.year && entry.date.month == now.month) {
        if (entry.score > monthlyHigh) {
          monthlyHigh = entry.score;
        }
      }
    }
    return monthlyHigh;
  }
}
