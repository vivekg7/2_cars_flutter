import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/score_service.dart';
import 'package:intl/intl.dart';
import 'game_shapes.dart';

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
  bool _showInstructions = false;

  @override
  Widget build(BuildContext context) {
    if (_showHighScores) {
      return _buildHighScoresOverlay(context);
    }

    if (_showInstructions) {
      return _buildInstructionsOverlay(context);
    }

    switch (widget.gameState.status) {
      case GameStatus.initial:
        return _buildStartOverlay(context);
      case GameStatus.playing:
        return const SizedBox.shrink();
      case GameStatus.paused:
        return _buildPauseOverlay(context);
      case GameStatus.gameOver:
        return _buildGameOverOverlay(context);
    }
  }

  Widget _buildStartOverlay(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '2 CARS',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: widget.onStart,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              backgroundColor: Colors.white,
            ),
            child: const Text(
              'PLAY',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              setState(() {
                _showHighScores = true;
              });
            },
            child: const Text(
              'HIGH SCORES',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              setState(() {
                _showInstructions = true;
              });
            },
            child: const Text(
              'HOW TO PLAY',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPauseOverlay(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'PAUSED',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: widget.onResume,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              backgroundColor: Colors.white,
            ),
            child: const Text(
              'RESUME',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsOverlay(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'HOW TO PLAY',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              _buildInstructionItem(
                icon: Icons.touch_app,
                text: 'Tap Left/Right to switch lanes',
                color: Colors.white,
              ),
              const SizedBox(height: 15),
              _buildInstructionItem(
                shapeType: GameShapeType.circle,
                text: 'Collect Circles',
              ),
              const SizedBox(height: 15),
              _buildInstructionItem(
                shapeType: GameShapeType.square,
                text: 'Avoid Squares',
              ),
              const SizedBox(height: 15),
              _buildInstructionItem(
                icon: Icons.warning_amber_rounded,
                text: "Don't miss any Circles!",
                color: Colors.orange,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showInstructions = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  backgroundColor: Colors.white,
                ),
                child: const Text(
                  'BACK',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem({
    IconData? icon,
    GameShapeType? shapeType,
    required String text,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (shapeType != null)
          GameShapeWidget(type: shapeType, size: 30)
        else
          Icon(icon, color: color, size: 30),
        const SizedBox(width: 15),
        Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
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
}
