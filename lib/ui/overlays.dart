import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/score_service.dart';
import 'package:intl/intl.dart';
import 'game_shapes.dart';
import '../models/game_difficulty.dart';

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
          const SizedBox(height: 30),
          _buildDifficultySelector(),
          const SizedBox(height: 30),
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

  Widget _buildDifficultySelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: GameDifficulty.values.map((difficulty) {
        final isSelected = widget.gameState.currentDifficulty == difficulty;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ChoiceChip(
            label: Text(difficulty.displayName),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                widget.gameState.setDifficulty(difficulty);
              }
            },
            selectedColor: Colors.white,
            backgroundColor: Colors.black,
            labelStyle: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
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
      color: Colors.black.withValues(alpha: 0.85),
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
            Text(
              'HIGH SCORES (${widget.gameState.currentDifficulty.displayName})',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: FutureBuilder<List<ScoreEntry>>(
                future: ScoreService().getHighScores(
                  widget.gameState.currentDifficulty,
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final scores = snapshot.data!;
                  if (scores.isEmpty) {
                    return const Text(
                      'No scores yet',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    );
                  }
                  return Container(
                    constraints: const BoxConstraints(
                      maxWidth: 400,
                      maxHeight: 400,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: scores.length,
                      itemBuilder: (context, index) {
                        final e = scores[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 20,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${index + 1}. ${DateFormat('MMM d, HH:mm').format(e.date)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                '${e.score}',
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
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'MONTHLY BEST',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.yellow,
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder<int>(
              future: ScoreService().getMonthlyHighScore(
                widget.gameState.currentDifficulty,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                return Text(
                  '${snapshot.data}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showHighScores = false;
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
            Flexible(
              child: FutureBuilder<List<dynamic>>(
                future: Future.wait([
                  ScoreService().getHighScores(
                    widget.gameState.currentDifficulty,
                  ),
                  ScoreService().getMonthlyHighScore(
                    widget.gameState.currentDifficulty,
                  ),
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
                          'Monthly Best (${widget.gameState.currentDifficulty.displayName}): $monthlyHigh',
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
                                : topScores.length,
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
