import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const String _keyScores = 'scores';

  Future<void> saveScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> scoresJson = prefs.getStringList(_keyScores) ?? [];

    List<ScoreEntry> scores = scoresJson
        .map((e) => ScoreEntry.fromJson(jsonDecode(e)))
        .toList();

    scores.add(ScoreEntry(score: score, date: DateTime.now()));

    // Sort by score descending
    scores.sort((a, b) => b.score.compareTo(a.score));

    // Keep only top 10
    if (scores.length > 10) {
      scores = scores.sublist(0, 10);
    }

    await prefs.setStringList(
      _keyScores,
      scores.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<List<ScoreEntry>> getTopScores() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> scoresJson = prefs.getStringList(_keyScores) ?? [];

    return scoresJson.map((e) => ScoreEntry.fromJson(jsonDecode(e))).toList();
  }

  Future<int> getMonthlyHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> scoresJson = prefs.getStringList(_keyScores) ?? [];

    final now = DateTime.now();
    final oneMonthAgo = now.subtract(const Duration(days: 30));

    int maxScore = 0;

    for (var jsonStr in scoresJson) {
      final entry = ScoreEntry.fromJson(jsonDecode(jsonStr));
      if (entry.date.isAfter(oneMonthAgo)) {
        if (entry.score > maxScore) {
          maxScore = entry.score;
        }
      }
    }

    return maxScore;
  }
}
