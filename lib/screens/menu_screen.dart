import 'package:flutter/material.dart';
import '../controllers/settings_controller.dart';
import '../models/game_state.dart';
import '../models/player_data.dart';
import '../services/storage_service.dart';
import '../utils/background_utils.dart';
import '../utils/page_route_utils.dart';
import '../widgets/menu_bubbles_background.dart';
import 'achievements_screen.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, required this.settingsController});

  final SettingsController settingsController;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  final StorageService _storageService = StorageService();
  PlayerData? _playerData;
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _loadPlayerData();
    widget.settingsController.addListener(_onSettingsChanged);

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _loadPlayerData() async {
    final data = await _storageService.loadPlayerData();
    if (!mounted) return;
    setState(() {
      _playerData = data;
    });
  }

  @override
  void dispose() {
    widget.settingsController.removeListener(_onSettingsChanged);
    _floatingController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MenuScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settingsController != widget.settingsController) {
      oldWidget.settingsController.removeListener(_onSettingsChanged);
      widget.settingsController.addListener(_onSettingsChanged);
    }
  }

  int _getDailySeed() {
    final now = DateTime.now();
    return now.year * 10000 + now.month * 100 + now.day;
  }

  bool _canPlayDaily() {
    if (_playerData == null) return true;

    final lastPlayed = _playerData!.lastDailyPlayed;
    if (lastPlayed == null) return true;

    final now = DateTime.now();
    return lastPlayed.year != now.year ||
        lastPlayed.month != now.month ||
        lastPlayed.day != now.day;
  }

  Future<void> _updateDailyPlayed() async {
    if (_playerData == null) return;

    final updated = _playerData!.copyWith(
      lastDailyPlayed: DateTime.now(),
      dailySeed: _getDailySeed(),
    );

    await _storageService.savePlayerData(updated);
    if (!mounted) return;
    setState(() {
      _playerData = updated;
    });
  }

  void _startGame(GameMode mode) async {
    int? seed;
    if (mode == GameMode.daily) {
      if (!_canPlayDaily()) {
        _showDailyAlreadyPlayedDialog();
        return;
      }
      seed = _getDailySeed();
      await _updateDailyPlayed();
    }

    if (!mounted) return;

    Navigator.of(context)
        .push(
          createAppPageRoute(
            GameScreen(
              mode: mode,
              dailySeed: seed,
              settingsController: widget.settingsController,
            ),
          ),
        )
        .then((_) => _loadPlayerData());
  }

  void _onSettingsChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _showDailyAlreadyPlayedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.settingsController.backgroundColor.withValues(
          alpha: 0.85,
        ),
        title: const Text('Daily Test', style: TextStyle(color: Colors.white)),
        content: const Text(
          'You have already completed today\'s test! Come back tomorrow.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.settingsController.backgroundColor;

    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: buildBackgroundDecoration(themeColor)),
          MenuBubblesBackground(color: themeColor),
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _GlassIconButton(
                                icon: Icons.settings,
                                onTap: () {
                                  Navigator.of(context)
                                      .push(
                                        createAppPageRoute(
                                          SettingsScreen(
                                            settingsController:
                                                widget.settingsController,
                                          ),
                                        ),
                                      )
                                      .then((_) => _loadPlayerData());
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          AnimatedBuilder(
                            animation: _floatingController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                  0,
                                  _floatingController.value * 10 - 5,
                                ),
                                child: child,
                              );
                            },
                            child: Column(
                              children: const [
                                Text(
                                  'Bubble Pop Lab',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 44,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 20,
                                        color: Colors.black45,
                                        offset: Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'O₂ Bubbles Training Facility',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 26),
                          if (_playerData != null) _buildStatsRow(_playerData!),
                          const SizedBox(height: 24),
                          _MenuModeButton(
                            title: 'Arcade',
                            subtitle: 'Endless oxygen harvesting',
                            icon: Icons.all_inclusive,
                            gradientColors: [
                              Colors.lightBlueAccent.withValues(alpha: 0.9),
                              Colors.blueAccent.withValues(alpha: 0.95),
                            ],
                            onTap: () => _startGame(GameMode.arcade),
                          ),
                          const SizedBox(height: 18),
                          _MenuModeButton(
                            title: 'Time Attack',
                            subtitle: '90 seconds – race the lab timer',
                            icon: Icons.timer,
                            gradientColors: [
                              Colors.orangeAccent.withValues(alpha: 0.92),
                              Colors.deepOrangeAccent.withValues(alpha: 0.95),
                            ],
                            onTap: () => _startGame(GameMode.timeAttack),
                          ),
                          const SizedBox(height: 18),
                          _MenuModeButton(
                            title: 'Daily Lab Test',
                            subtitle: _canPlayDaily()
                                ? 'Fresh challenge every sunrise'
                                : 'Already calibrated today',
                            icon: Icons.calendar_month,
                            gradientColors: _canPlayDaily()
                                ? [
                                    Colors.purpleAccent.withValues(alpha: 0.9),
                                    Colors.deepPurple.withValues(alpha: 0.95),
                                  ]
                                : [
                                    Colors.blueGrey.withValues(alpha: 0.55),
                                    Colors.blueGrey.withValues(alpha: 0.7),
                                  ],
                            onTap: () => _startGame(GameMode.daily),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _GlassIconButton(
                                icon: Icons.shopping_bag,
                                label: 'Shop',
                                onTap: () {
                                  Navigator.of(context)
                                      .push(
                                        createAppPageRoute(
                                          ShopScreen(
                                            settingsController:
                                                widget.settingsController,
                                          ),
                                        ),
                                      )
                                      .then((_) => _loadPlayerData());
                                },
                              ),
                              const SizedBox(width: 16),
                              _GlassIconButton(
                                icon: Icons.emoji_events,
                                label: 'Achievements',
                                onTap: () {
                                  Navigator.of(context).push(
                                    createAppPageRoute(
                                      AchievementsScreen(
                                        settingsController:
                                            widget.settingsController,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(PlayerData data) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildStatCard(
          label: 'Capsules',
          value: '${data.totalCapsules}',
          icon: Icons.bubble_chart,
        ),
        _buildStatCard(
          label: 'Best Arcade',
          value: '${data.highScoreArcade}',
          icon: Icons.emoji_events,
        ),
        _buildStatCard(
          label: 'Total O₂',
          value: '${data.totalOxygenPopped}',
          icon: Icons.blur_on,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return SizedBox(
      width: 150,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuModeButton extends StatefulWidget {
  const _MenuModeButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  @override
  State<_MenuModeButton> createState() => _MenuModeButtonState();
}

class _MenuModeButtonState extends State<_MenuModeButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.gradientColors;
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) {
        _setPressed(false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: colors.last.withValues(alpha: 0.5),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, required this.onTap, this.label});

  final IconData icon;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final bool compact = label == null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: compact
            ? const EdgeInsets.all(14)
            : const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: compact
                ? [
                    Colors.white.withValues(alpha: 0.28),
                    Colors.white.withValues(alpha: 0.12),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.1),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(compact ? 24 : 18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: compact ? 24 : 22),
            if (!compact) ...[
              const SizedBox(width: 10),
              Text(
                label!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
