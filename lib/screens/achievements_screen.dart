import 'package:flutter/material.dart';
import '../controllers/settings_controller.dart';
import '../models/player_data.dart';
import '../services/storage_service.dart';
import '../utils/background_utils.dart';
import '../widgets/menu_bubbles_background.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key, required this.settingsController});

  final SettingsController settingsController;

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final StorageService _storageService = StorageService();
  PlayerData? _playerData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    widget.settingsController.addListener(_onSettingsChanged);
    _loadPlayerData();
  }

  Future<void> _loadPlayerData() async {
    final data = await _storageService.loadPlayerData();
    setState(() {
      _playerData = data;
      _isLoading = false;
    });
  }

  void _onSettingsChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    widget.settingsController.removeListener(_onSettingsChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AchievementsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settingsController != widget.settingsController) {
      oldWidget.settingsController.removeListener(_onSettingsChanged);
      widget.settingsController.addListener(_onSettingsChanged);
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.settingsController.backgroundColor;
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: buildBackgroundDecoration(backgroundColor)),
          MenuBubblesBackground(color: backgroundColor),
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Text(
                          'Achievements',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  
                  if (_playerData != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'Unlocked',
                              '${_playerData!.achievements.where((a) => a.unlocked).length}/${_playerData!.achievements.length}',
                              Icons.emoji_events,
                            ),
                            _buildStatItem(
                              'Games',
                              '${_playerData!.totalGamesPlayed}',
                              Icons.gamepad,
                            ),
                            _buildStatItem(
                              'Total O₂',
                              '${_playerData!.totalOxygenPopped}',
                              Icons.bubble_chart,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _playerData?.achievements.length ?? 0,
                            itemBuilder: (context, index) {
                              final achievement =
                                  _playerData!.achievements[index];
                              return _buildAchievementCard(achievement);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achievement.unlocked
            ? Colors.amber.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: achievement.unlocked
              ? Colors.amber.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: achievement.unlocked
                  ? Colors.amber.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.unlocked ? Icons.emoji_events : Icons.lock,
              color: achievement.unlocked ? Colors.amber : Colors.white70,
              size: 32,
            ),
          ),

          const SizedBox(width: 16),

          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.name,
                  style: TextStyle(
                    color: achievement.unlocked ? Colors.white : Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: achievement.unlocked
                        ? Colors.white70
                        : Colors.white54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.bubble_chart,
                      size: 16,
                      color: achievement.unlocked
                          ? Colors.amber
                          : Colors.white54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Reward: ${achievement.reward} capsules',
                      style: TextStyle(
                        color: achievement.unlocked
                            ? Colors.amber
                            : Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          
          if (achievement.unlocked)
            const Icon(Icons.check_circle, color: Colors.green, size: 32)
          else
            Icon(
              Icons.radio_button_unchecked,
              color: Colors.white.withValues(alpha: 0.3),
              size: 32,
            ),
        ],
      ),
    );
  }
}
