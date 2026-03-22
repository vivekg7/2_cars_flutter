import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/game_theme.dart';
import '../models/score_service.dart';
import 'package:intl/intl.dart';
import 'game_shapes.dart';
import '../models/game_difficulty.dart';

class GameOverlays extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onStart;
  final VoidCallback onResume;
  final VoidCallback onMainMenu;

  const GameOverlays({
    super.key,
    required this.gameState,
    required this.onStart,
    required this.onResume,
    required this.onMainMenu,
  });

  @override
  State<GameOverlays> createState() => _GameOverlaysState();
}

class _GameOverlaysState extends State<GameOverlays> {
  bool _showHighScores = false;
  bool _showInstructions = false;

  GameTheme get _theme => widget.gameState.currentTheme;

  // ── Themed text helpers ──

  TextStyle _titleStyle() {
    return TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.bold,
      color: _theme.titleColor,
      letterSpacing: _theme.titleLetterSpacing,
      shadows: _theme.titleHasGlow
          ? [
              Shadow(color: _theme.titleColor, blurRadius: 20),
              Shadow(color: _theme.titleColor, blurRadius: 40),
            ]
          : null,
    );
  }

  TextStyle _subtitleStyle() {
    return TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: _theme.titleColor,
      letterSpacing: _theme.titleLetterSpacing * 0.5,
      shadows: _theme.titleHasGlow
          ? [Shadow(color: _theme.titleColor, blurRadius: 15)]
          : null,
    );
  }

  TextStyle _bodyStyle({double fontSize = 18, Color? color}) {
    final c = color ?? _theme.scoreTextColor;
    return TextStyle(
      fontSize: fontSize,
      color: c,
      fontWeight: FontWeight.w500,
    );
  }

  TextStyle _buttonTextStyle() {
    return TextStyle(fontSize: 24, color: _theme.buttonTextColor);
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      backgroundColor: _theme.buttonBackgroundColor,
      foregroundColor: _theme.buttonTextColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_theme.buttonBorderRadius),
        side: _theme.buttonBorderWidth > 0
            ? BorderSide(
                color: _theme.buttonBorderColor,
                width: _theme.buttonBorderWidth,
              )
            : BorderSide.none,
      ),
      elevation: 0,
    );
  }

  TextStyle _textButtonStyle() {
    return TextStyle(fontSize: 18, color: _theme.secondaryTextColor);
  }

  // ── Themed overlay background ──

  Widget _overlayBackground({required Widget child}) {
    final bg = _theme.overlayHasGradient && _theme.overlayGradientColor != null
        ? BoxDecoration(
            gradient: RadialGradient(
              colors: [
                _theme.overlayGradientColor!.withValues(alpha: _theme.overlayOpacity),
                _theme.overlayBackgroundColor.withValues(alpha: _theme.overlayOpacity),
              ],
              radius: 1.2,
            ),
          )
        : BoxDecoration(
            color: _theme.overlayBackgroundColor.withValues(alpha: _theme.overlayOpacity),
          );
    return Container(decoration: bg, child: child);
  }

  // ── Themed title widget (handles outline for retro) ──

  Widget _titleWidget(String text, {TextStyle? style}) {
    final s = style ?? _titleStyle();
    if (_theme.titleHasOutline && _theme.titleOutlineColor != null) {
      return Stack(
        children: [
          // Outline
          Text(
            _theme.textIsUppercase ? text.toUpperCase() : text,
            style: s.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 4
                ..color = _theme.titleOutlineColor!,
            ),
          ),
          // Fill
          Text(
            _theme.textIsUppercase ? text.toUpperCase() : text,
            style: s,
          ),
        ],
      );
    }
    return Text(
      _theme.textIsUppercase ? text.toUpperCase() : text,
      style: s,
    );
  }

  String _t(String text) => _theme.textIsUppercase ? text.toUpperCase() : text;

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
    return _overlayBackground(
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity == null) return;
          // Require a deliberate swipe — ignore slow/accidental drags
          if (details.primaryVelocity!.abs() < 300) return;
          final themes = GameTheme.all;
          final currentIndex = themes.indexWhere((t) => t.id == _theme.id);
          int nextIndex;
          if (details.primaryVelocity! < 0) {
            // Swipe left → next theme
            nextIndex = (currentIndex + 1) % themes.length;
          } else {
            // Swipe right → previous theme
            nextIndex = (currentIndex - 1 + themes.length) % themes.length;
          }
          widget.gameState.setTheme(themes[nextIndex]);
          setState(() {});
        },
        behavior: HitTestBehavior.translucent,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _titleWidget('2 CARS'),
              const SizedBox(height: 24),
              _buildThemeSelector(),
              const SizedBox(height: 16),
              _buildDifficultySelector(),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: widget.onStart,
                style: _primaryButtonStyle(),
                child: Text(_t('PLAY'), style: _buttonTextStyle()),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showHighScores = true;
                  });
                },
                child: Text(_t('HIGH SCORES'), style: _textButtonStyle()),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showInstructions = true;
                  });
                },
                child: Text(_t('HOW TO PLAY'), style: _textButtonStyle()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: GameTheme.all.map((theme) {
        final isSelected = _theme.id == theme.id;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ChoiceChip(
            label: Text(theme.name),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                widget.gameState.setTheme(theme);
                setState(() {});
              }
            },
            selectedColor: _theme.chipSelectedColor,
            backgroundColor: _theme.chipUnselectedColor,
            labelStyle: TextStyle(
              color: isSelected
                  ? _theme.chipSelectedTextColor
                  : _theme.chipUnselectedTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_theme.chipBorderRadius),
              side: BorderSide(
                color: _theme.chipBorderColor,
                width: _theme.chipBorderWidth,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          ),
        );
      }).toList(),
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
            label: Text(_t(difficulty.displayName)),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                widget.gameState.setDifficulty(difficulty);
              }
            },
            selectedColor: _theme.chipSelectedColor,
            backgroundColor: _theme.chipUnselectedColor,
            labelStyle: TextStyle(
              color: isSelected
                  ? _theme.chipSelectedTextColor
                  : _theme.chipUnselectedTextColor,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_theme.chipBorderRadius),
              side: BorderSide(
                color: _theme.chipBorderColor,
                width: _theme.chipBorderWidth,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPauseOverlay(BuildContext context) {
    return _overlayBackground(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _titleWidget('PAUSED'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: widget.onResume,
              style: _primaryButtonStyle(),
              child: Text(_t('RESUME'), style: _buttonTextStyle()),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: widget.onMainMenu,
              child: Text(_t('MAIN MENU'), style: _textButtonStyle()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsOverlay(BuildContext context) {
    return _overlayBackground(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _titleWidget('HOW TO PLAY', style: _subtitleStyle()),
              const SizedBox(height: 30),
              _buildInstructionItem(
                icon: Icons.touch_app,
                text: _t('Tap Left/Right to switch lanes'),
                color: _theme.scoreTextColor,
              ),
              const SizedBox(height: 15),
              _buildInstructionItem(
                shapeType: GameShapeType.circle,
                text: _t('Collect Circles'),
              ),
              const SizedBox(height: 15),
              _buildInstructionItem(
                shapeType: GameShapeType.square,
                text: _t('Avoid Squares'),
              ),
              const SizedBox(height: 15),
              _buildInstructionItem(
                icon: Icons.warning_amber_rounded,
                text: _t("Don't miss any Circles!"),
                color: _theme.highScoreAccentColor,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showInstructions = false;
                  });
                },
                style: _primaryButtonStyle(),
                child: Text(_t('BACK'), style: _buttonTextStyle()),
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
        Text(text, style: _bodyStyle()),
      ],
    );
  }

  Widget _buildHighScoresOverlay(BuildContext context) {
    return _overlayBackground(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _titleWidget(
              'HIGH SCORES (${widget.gameState.currentDifficulty.displayName})',
              style: _subtitleStyle(),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: FutureBuilder<List<ScoreEntry>>(
                future: ScoreService().getHighScores(
                  widget.gameState.currentDifficulty,
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator(
                      color: _theme.highScoreAccentColor,
                    );
                  }
                  final scores = snapshot.data!;
                  if (scores.isEmpty) {
                    return Text(
                      _t('No scores yet'),
                      style: _bodyStyle(),
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
                                style: _bodyStyle(
                                    color: _theme.secondaryTextColor),
                              ),
                              Text(
                                '${e.score}',
                                style: _bodyStyle().copyWith(
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
            Text(
              _t('MONTHLY BEST'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _theme.highScoreAccentColor,
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
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: _theme.scoreTextColor,
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
              style: _primaryButtonStyle(),
              child: Text(_t('BACK'), style: _buttonTextStyle()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay(BuildContext context) {
    return _overlayBackground(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _titleWidget('GAME OVER', style: _titleStyle().copyWith(fontSize: 50, letterSpacing: 5)),
            const SizedBox(height: 20),
            Text(
              '${_t('Score')}: ${widget.gameState.score}',
              style: TextStyle(
                fontSize: 32,
                color: _theme.scoreTextColor,
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
                    return CircularProgressIndicator(
                      color: _theme.highScoreAccentColor,
                    );
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
                          '${_t('Monthly Best')} (${widget.gameState.currentDifficulty.displayName}): $monthlyHigh',
                          style: TextStyle(
                            color: _theme.highScoreAccentColor,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _t('Top Scores'),
                          style: TextStyle(
                            color: _theme.scoreTextColor,
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
                                      style: _bodyStyle(
                                        fontSize: 16,
                                        color: _theme.secondaryTextColor,
                                      ),
                                    ),
                                    Text(
                                      '${entry.score}',
                                      style: _bodyStyle(fontSize: 16)
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
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
              style: _primaryButtonStyle().copyWith(
                padding: WidgetStatePropertyAll(
                  const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
              ),
              child: Text(_t('RETRY'), style: _buttonTextStyle()),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: widget.onMainMenu,
              child: Text(_t('MAIN MENU'),
                  style: _textButtonStyle().copyWith(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
