import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game/two_cars_game.dart';
import 'models/game_state.dart';
import 'ui/overlays.dart';

void main() {
  runApp(const TwoCarsApp());
}

class TwoCarsApp extends StatelessWidget {
  const TwoCarsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2 Cars',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF2C3E50),
        textTheme: GoogleFonts.outfitTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: Colors.white, displayColor: Colors.white),
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late TwoCarsGame _game;
  final GameState _gameState = GameState();

  @override
  void initState() {
    super.initState();
    _game = TwoCarsGame(
      gameState: _gameState,
      onGameOver: () {
        setState(() {}); // Rebuild to show game over overlay
      },
    );
    _gameState.addListener(_onGameStateChanged);
  }

  @override
  void dispose() {
    _gameState.removeListener(_onGameStateChanged);
    super.dispose();
  }

  void _onGameStateChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = _gameState.currentTheme;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: Stack(
        children: [
          // Game Widget (with screen shake offset)
          AnimatedBuilder(
            animation: _gameState,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_game.shakeOffsetX, _game.shakeOffsetY),
                child: GameWidget(game: _game),
              );
            },
          ),

          // Score Display
          if (_gameState.status == GameStatus.playing)
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _gameState,
                  builder: (context, child) {
                    return Text(
                      '${_gameState.score}',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: theme.scoreTextColor,
                        shadows: theme.titleHasGlow
                            ? [
                                Shadow(
                                    color: theme.scoreTextColor,
                                    blurRadius: 15),
                              ]
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),

          // Overlays
          if (_gameState.status != GameStatus.playing)
            AnimatedBuilder(
              animation: _gameState,
              builder: (context, child) {
                return GameOverlays(
                  gameState: _gameState,
                  onStart: () {
                    _game.resetGame();
                    setState(() {});
                  },
                  onResume: () {
                    _game.resumeEngine();
                    _gameState.resumeGame();
                    setState(() {});
                  },
                  onMainMenu: () async {
                    await _gameState.quitGame();
                    _game.clearGame();
                    _game.pauseEngine();
                    setState(() {});
                  },
                );
              },
            ),

          // Pause Button
          if (_gameState.status == GameStatus.playing)
            Positioned(
              top: 50,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.pause,
                    color: theme.scoreTextColor, size: 30),
                onPressed: () {
                  _game.pauseEngine();
                  _gameState.pauseGame();
                  setState(() {});
                },
              ),
            ),
        ],
      ),
    );
  }
}
