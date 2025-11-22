import 'package:flutter/material.dart';
import '../models/game_state.dart';

class GameOverlays extends StatelessWidget {
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
  Widget build(BuildContext context) {
    switch (gameState.status) {
      case GameStatus.initial:
        return _buildOverlay(
          context,
          title: '2 CARS',
          buttonText: 'PLAY',
          onPressed: onStart,
        );
      case GameStatus.paused:
        return _buildOverlay(
          context,
          title: 'PAUSED',
          buttonText: 'RESUME',
          onPressed: onResume,
        );
      case GameStatus.gameOver:
        return _buildOverlay(
          context,
          title: 'GAME OVER',
          subtitle:
              'Score: ${gameState.score}\nHigh Score: ${gameState.highScore}',
          buttonText: 'RETRY',
          onPressed: onStart,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOverlay(
    BuildContext context, {
    required String title,
    String? subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      color: Colors.black.withOpacity(0.7),
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
          ],
        ),
      ),
    );
  }
}
