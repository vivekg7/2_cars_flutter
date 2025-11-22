import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/game_state.dart';
import '../models/score_service.dart';

class GameOverlays extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onStart;
  final VoidCallback onResume;

  const GameOverlays({
    super.key,
    required this.gameState,
    required this.onStart,
    required this.onResume,
  });

  @override
  State<GameOverlays> createState() => _GameOverlaysState();
}

class _GameOverlaysState extends State<GameOverlays> {
  bool _showHighScores = false;

  @override
  Widget build(BuildContext context) {
    if (_showHighScores) {
      return _buildHighScoresOverlay(context);
    }

    switch (widget.gameState.status) {
      case GameStatus.initial:
        return _buildOverlay(
          context,
          title: '2 CARS',
          buttonText: 'PLAY',
          onPressed: widget.onStart,
          showHighScoresButton: true,
        );
      case GameStatus.paused:
        return _buildOverlay(
          context,
          title: 'PAUSED',
          buttonText: 'RESUME',
          onPressed: widget.onResume,
        );
      case GameStatus.gameOver:
        return _buildGameOverOverlay(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHighScoresOverlay(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'HIGH SCORES',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 30),
            Flexible(
              child: FutureBuilder<List<dynamic>>(
                future: Future.wait([
                  ScoreService().getTopScores(),
                  ScoreService().getMonthlyHighScore(),
                ]),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator(color: Colors.white);
                  }

                  final topScores = snapshot.data![0] as List<ScoreEntry>;
                  final monthlyHigh = snapshot.data![1] as int;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    constraints: const BoxConstraints(
                      maxWidth: 400,
                      maxHeight: 400,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Monthly Best: $monthlyHigh',
                          style: const TextStyle(
                            color: Colors.yellow,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: topScores.length,
                            itemBuilder: (context, index) {
                              final entry = topScores[index];
                              final dateStr = DateFormat(
                                'MMM d, HH:mm',
                              ).format(entry.date);
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${index + 1}. $dateStr',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      '${entry.score}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showHighScores = false;
                });
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 10,
                ),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('BACK'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 5,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Score: ${widget.gameState.score}',
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            // We can reuse the high scores view logic here or keep it simple
            // Let's keep it simple as before but maybe just top 3?
            // Or just the same list.
            Flexible(
              child: FutureBuilder<List<dynamic>>(
                future: Future.wait([
                  ScoreService().getTopScores(),
                  ScoreService().getMonthlyHighScore(),
                ]),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator(color: Colors.white);
                  }

                  final topScores = snapshot.data![0] as List<ScoreEntry>;
                  final monthlyHigh = snapshot.data![1] as int;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    constraints: const BoxConstraints(
                      maxWidth: 400,
                      maxHeight: 250,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Monthly Best: $monthlyHigh',
                          style: const TextStyle(
                            color: Colors.yellow,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Top Scores',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: topScores.length > 5
                                ? 5
                                : topScores.length, // Show top 5 on game over
                            itemBuilder: (context, index) {
                              final entry = topScores[index];
                              final dateStr = DateFormat(
                                'MMM d, HH:mm',
                              ).format(entry.date);
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${index + 1}. $dateStr',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '${entry.score}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: widget.onStart,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                textStyle: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('RETRY'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay(
    BuildContext context, {
    required String title,
    String? subtitle,
    required String buttonText,
    required VoidCallback onPressed,
    bool showHighScoresButton = false,
  }) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 5,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 20),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ],
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                textStyle: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Text(buttonText),
            ),
            if (showHighScoresButton) ...[
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showHighScores = true;
                  });
                },
                child: const Text(
                  'HIGH SCORES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
