import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_data.dart';

class StorageService {
  static const String _playerDataKey = 'player_data';

  
  static final List<Achievement> defaultAchievements = [
    const Achievement(
      id: 'pure_air',
      name: 'Pure Air',
      description: 'Reach a streak of 50 O₂ bubbles',
      requirement: 50,
      reward: 100,
    ),
    const Achievement(
      id: 'lab_hero',
      name: 'Lab Hero',
      description: 'Complete 3 sprints in a row',
      requirement: 3,
      reward: 150,
    ),
    const Achievement(
      id: 'toxic_free',
      name: 'Toxic-Free',
      description: 'Don\'t pop any toxic bubbles in a game',
      requirement: 1,
      reward: 200,
    ),
    const Achievement(
      id: 'oxygen_master',
      name: 'Oxygen Master',
      description: 'Pop 1000 O₂ bubbles in total',
      requirement: 1000,
      reward: 250,
    ),
    const Achievement(
      id: 'score_legend',
      name: 'Score Legend',
      description: 'Score 10000 points in one game',
      requirement: 10000,
      reward: 300,
    ),
  ];

  
  static final List<ShopItem> defaultShopItems = [
    const ShopItem(
      id: 'clean_filter',
      name: 'Clean Filter',
      description: 'Removes all toxic bubbles for 5 seconds',
      price: 100,
      maxLevel: 3,
    ),
    const ShopItem(
      id: 'tap_radius',
      name: 'Zone Expansion',
      description: 'Increases tap radius',
      price: 150,
      maxLevel: 5,
    ),
    const ShopItem(
      id: 'slow_motion',
      name: 'Slow Motion',
      description: 'Slows down time for 3 seconds',
      price: 120,
      maxLevel: 3,
    ),
    const ShopItem(
      id: 'skin_blue',
      name: 'Blue Laboratory',
      description: 'Laboratory skin',
      price: 200,
      maxLevel: 1,
    ),
    const ShopItem(
      id: 'skin_green',
      name: 'Green Laboratory',
      description: 'Laboratory skin',
      price: 250,
      maxLevel: 1,
    ),
  ];

  Future<PlayerData> loadPlayerData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_playerDataKey);

      if (jsonString == null) {
        return PlayerData(
          achievements: defaultAchievements,
          shopItems: defaultShopItems,
        );
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return PlayerData.fromJson(
        json,
        defaultAchievements: defaultAchievements,
        defaultShopItems: defaultShopItems,
      );
    } catch (e) {
      
      return PlayerData(
        achievements: defaultAchievements,
        shopItems: defaultShopItems,
      );
    }
  }

  Future<void> savePlayerData(PlayerData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(data.toJson());
      await prefs.setString(_playerDataKey, jsonString);
    } catch (e) {
      
      print('Error saving player data: $e');
    }
  }

  Future<void> clearPlayerData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_playerDataKey);
  }

  Future<PlayerData> updateHighScore(
    PlayerData data,
    int score,
    String mode,
  ) async {
    PlayerData updated = data;

    switch (mode) {
      case 'arcade':
        if (score > data.highScoreArcade) {
          updated = data.copyWith(highScoreArcade: score);
        }
        break;
      case 'timeAttack':
        if (score > data.highScoreTimeAttack) {
          updated = data.copyWith(highScoreTimeAttack: score);
        }
        break;
      case 'daily':
        if (score > data.highScoreDaily) {
          updated = data.copyWith(highScoreDaily: score);
        }
        break;
    }

    await savePlayerData(updated);
    return updated;
  }

  Future<PlayerData> unlockAchievement(
    PlayerData data,
    String achievementId,
  ) async {
    final achievements = data.achievements.map((a) {
      if (a.id == achievementId && !a.unlocked) {
        return a.copyWith(unlocked: true);
      }
      return a;
    }).toList();

    final achievement = achievements.firstWhere((a) => a.id == achievementId);
    final newCapsules = achievement.unlocked
        ? data.totalCapsules + achievement.reward
        : data.totalCapsules;

    final updated = data.copyWith(
      achievements: achievements,
      totalCapsules: newCapsules,
    );

    await savePlayerData(updated);
    return updated;
  }

  Future<PlayerData> purchaseItem(PlayerData data, String itemId) async {
    final item = data.shopItems.firstWhere((s) => s.id == itemId);

    if (data.totalCapsules < item.getNextPrice()) {
      return data; 
    }

    final shopItems = data.shopItems.map((s) {
      if (s.id == itemId && s.level < s.maxLevel) {
        return s.copyWith(level: s.level + 1, purchased: true);
      }
      return s;
    }).toList();

    final updated = data.copyWith(
      shopItems: shopItems,
      totalCapsules: data.totalCapsules - item.getNextPrice(),
    );

    await savePlayerData(updated);
    return updated;
  }
}
