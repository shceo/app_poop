import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../controllers/settings_controller.dart';
import '../models/game_state.dart';
import '../models/player_data.dart';
import '../services/achievement_service.dart';
import '../services/game_engine.dart';
import '../services/storage_service.dart';
import '../utils/background_utils.dart';
import '../widgets/bubble_widget.dart';
import '../widgets/game_hud.dart';
import '../widgets/hazard_widget.dart';

class GameScreen extends StatefulWidget {
  final GameMode mode;
  final int? dailySeed;
  final SettingsController settingsController;

  const GameScreen({
    super.key,
    required this.mode,
    this.dailySeed,
    required this.settingsController,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late GameEngine _gameEngine;
  late Ticker _ticker;
  late StorageService _storageService;
  late AchievementService _achievementService;

  Duration _lastElapsed = Duration.zero;
  PlayerData? _playerData;

  @override
  void initState() {
    super.initState();

    _storageService = StorageService();
    _achievementService = AchievementService(_storageService);
    _gameEngine = GameEngine();

    _loadPlayerData();
    widget.settingsController.addListener(_onSettingsChanged);
    widget.settingsController.refreshMusicState();

    
    _ticker = createTicker(_onTick);

    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      _gameEngine.setScreenSize(size);
      _gameEngine.startGame(widget.mode, seed: widget.dailySeed);
      _ticker.start();
      widget.settingsController.refreshMusicState();
    });

    _gameEngine.addListener(_onGameStateChanged);
  }

  Future<void> _loadPlayerData() async {
    final data = await _storageService.loadPlayerData();
    setState(() {
      _playerData = data;
    });
  }

  void _onSettingsChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _onTick(Duration elapsed) {
    if (_gameEngine.state.status != GameStatus.playing) return;

    final dt = (elapsed - _lastElapsed).inMilliseconds / 1000.0;
    _lastElapsed = elapsed;

    if (dt > 0 && dt < 0.1) {
      
      _gameEngine.update(dt);
    }
  }

  void _onGameStateChanged() {
    if (_gameEngine.state.status == GameStatus.gameOver) {
      _handleGameOver();
    }
    setState(() {});
  }

  Future<void> _handleGameOver() async {
    if (_playerData == null) return;

    
    String modeStr = 'arcade';
    if (widget.mode == GameMode.timeAttack) modeStr = 'timeAttack';
    if (widget.mode == GameMode.daily) modeStr = 'daily';

    var updatedData = await _storageService.updateHighScore(
      _playerData!,
      _gameEngine.state.score,
      modeStr,
    );

    
    updatedData = await _achievementService.checkAchievements(
      updatedData,
      _gameEngine.state,
    );

    
    updatedData = updatedData.copyWith(
      totalOxygenPopped:
          updatedData.totalOxygenPopped + _gameEngine.state.oxygenPopped,
      totalGamesPlayed: updatedData.totalGamesPlayed + 1,
      longestStreak: updatedData.longestStreak > _gameEngine.state.longestStreak
          ? updatedData.longestStreak
          : _gameEngine.state.longestStreak,
      totalCapsules: updatedData.totalCapsules + _gameEngine.state.capsules,
    );

    await _storageService.savePlayerData(updatedData);

    setState(() {
      _playerData = updatedData;
    });

    
    if (mounted) {
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final baseColor = widget.settingsController.backgroundColor;
        final top = _tint(baseColor, 0.12).withValues(alpha: 0.95);
        final bottom = _tint(baseColor, -0.08).withValues(alpha: 0.9);

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 24,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [top, bottom],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flag_circle, color: Colors.white, size: 58),
                const SizedBox(height: 14),
                const Text(
                  'Mission Complete',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                _DialogStatRow(
                  label: 'Score',
                  value: '${_gameEngine.state.score}',
                ),
                _DialogStatRow(
                  label: 'Best Streak',
                  value: '${_gameEngine.state.longestStreak}',
                ),
                _DialogStatRow(
                  label: 'O₂ Collected',
                  value: '${_gameEngine.state.oxygenPopped}',
                ),
                const SizedBox(height: 12),
                Text(
                  '+${_gameEngine.state.capsules} capsules',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          foregroundColor: Colors.white70,
                        ),
                        child: const Text('Main Menu'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _restartGame();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.88),
                          foregroundColor: bottom,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: const Text('Play Again'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _restartGame() {
    _lastElapsed = Duration.zero;
    _gameEngine.startGame(widget.mode, seed: widget.dailySeed);
    _ticker.start();
    widget.settingsController.refreshMusicState();
  }

  void _pauseGame() {
    _gameEngine.pauseGame();
    _showPauseDialog();
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final baseColor = widget.settingsController.backgroundColor;
        final top = _tint(baseColor, 0.16).withValues(alpha: 0.95);
        final bottom = _tint(baseColor, -0.04).withValues(alpha: 0.9);

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 28,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [top, bottom],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 28,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.pause_circle_filled,
                  color: Colors.white,
                  size: 56,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Paused',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Score: ${_gameEngine.state.score}',
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          _gameEngine.returnToMenu();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          foregroundColor: Colors.white70,
                        ),
                        child: const Text('Exit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.settingsController.refreshMusicState();
                          _gameEngine.resumeGame();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.88),
                          foregroundColor: bottom,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: const Text('Continue'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    widget.settingsController.removeListener(_onSettingsChanged);
    _ticker.dispose();
    _gameEngine.removeListener(_onGameStateChanged);
    _gameEngine.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settingsController != widget.settingsController) {
      oldWidget.settingsController.removeListener(_onSettingsChanged);
      widget.settingsController.addListener(_onSettingsChanged);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTapDown: (details) {
          _gameEngine.onTap(details.localPosition);
        },
        child: Container(
          decoration: buildBackgroundDecoration(
            widget.settingsController.backgroundColor,
          ),
          child: Stack(
            children: [
              
              ..._buildBackgroundParticles(),

              
              ..._gameEngine.bubbles.map((bubble) {
                return BubbleWidget(bubble: bubble);
              }),

              
              ..._gameEngine.hazards.map((hazard) {
                return HazardWidget(hazard: hazard);
              }),

              
              GameHUD(state: _gameEngine.state, onPause: _pauseGame),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundParticles() {
    
    return List.generate(10, (index) {
      return Positioned(
        left: (index * 50.0) % MediaQuery.of(context).size.width,
        top: (index * 80.0) % MediaQuery.of(context).size.height,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      );
    });
  }
}

Color _tint(Color base, double delta) {
  final hsl = HSLColor.fromColor(base);
  final lightness = (hsl.lightness + delta).clamp(0.0, 1.0);
  return hsl.withLightness(lightness).toColor();
}

class _DialogStatRow extends StatelessWidget {
  const _DialogStatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
