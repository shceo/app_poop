class Achievement {
  final String id;
  final String name;
  final String description;
  final int requirement;
  final bool unlocked;
  final int reward; 

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.requirement,
    this.unlocked = false,
    this.reward = 50,
  });

  Achievement copyWith({bool? unlocked}) {
    return Achievement(
      id: id,
      name: name,
      description: description,
      requirement: requirement,
      unlocked: unlocked ?? this.unlocked,
      reward: reward,
    );
  }
}

class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final bool purchased;
  final int level; 
  final int maxLevel;

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.purchased = false,
    this.level = 0,
    this.maxLevel = 3,
  });

  ShopItem copyWith({bool? purchased, int? level}) {
    return ShopItem(
      id: id,
      name: name,
      description: description,
      price: price,
      purchased: purchased ?? this.purchased,
      level: level ?? this.level,
      maxLevel: maxLevel,
    );
  }

  int getNextPrice() {
    return price * (level + 1);
  }
}

class PlayerData {
  final int totalCapsules;
  final int highScoreArcade;
  final int highScoreTimeAttack;
  final int highScoreDaily;
  final int totalOxygenPopped;
  final int totalGamesPlayed;
  final int longestStreak;
  final List<Achievement> achievements;
  final List<ShopItem> shopItems;
  final String currentSkin;
  final DateTime? lastDailyPlayed;
  final int dailySeed;

  const PlayerData({
    this.totalCapsules = 0,
    this.highScoreArcade = 0,
    this.highScoreTimeAttack = 0,
    this.highScoreDaily = 0,
    this.totalOxygenPopped = 0,
    this.totalGamesPlayed = 0,
    this.longestStreak = 0,
    this.achievements = const [],
    this.shopItems = const [],
    this.currentSkin = 'default',
    this.lastDailyPlayed,
    this.dailySeed = 0,
  });

  PlayerData copyWith({
    int? totalCapsules,
    int? highScoreArcade,
    int? highScoreTimeAttack,
    int? highScoreDaily,
    int? totalOxygenPopped,
    int? totalGamesPlayed,
    int? longestStreak,
    List<Achievement>? achievements,
    List<ShopItem>? shopItems,
    String? currentSkin,
    DateTime? lastDailyPlayed,
    int? dailySeed,
  }) {
    return PlayerData(
      totalCapsules: totalCapsules ?? this.totalCapsules,
      highScoreArcade: highScoreArcade ?? this.highScoreArcade,
      highScoreTimeAttack: highScoreTimeAttack ?? this.highScoreTimeAttack,
      highScoreDaily: highScoreDaily ?? this.highScoreDaily,
      totalOxygenPopped: totalOxygenPopped ?? this.totalOxygenPopped,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      longestStreak: longestStreak ?? this.longestStreak,
      achievements: achievements ?? this.achievements,
      shopItems: shopItems ?? this.shopItems,
      currentSkin: currentSkin ?? this.currentSkin,
      lastDailyPlayed: lastDailyPlayed ?? this.lastDailyPlayed,
      dailySeed: dailySeed ?? this.dailySeed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCapsules': totalCapsules,
      'highScoreArcade': highScoreArcade,
      'highScoreTimeAttack': highScoreTimeAttack,
      'highScoreDaily': highScoreDaily,
      'totalOxygenPopped': totalOxygenPopped,
      'totalGamesPlayed': totalGamesPlayed,
      'longestStreak': longestStreak,
      'achievements': achievements
          .map((a) => {'id': a.id, 'unlocked': a.unlocked})
          .toList(),
      'shopItems': shopItems
          .map((s) => {'id': s.id, 'purchased': s.purchased, 'level': s.level})
          .toList(),
      'currentSkin': currentSkin,
      'lastDailyPlayed': lastDailyPlayed?.toIso8601String(),
      'dailySeed': dailySeed,
    };
  }

  factory PlayerData.fromJson(
    Map<String, dynamic> json, {
    required List<Achievement> defaultAchievements,
    required List<ShopItem> defaultShopItems,
  }) {
    final achievementMap = {for (var a in defaultAchievements) a.id: a};
    final shopItemMap = {for (var s in defaultShopItems) s.id: s};

    final loadedAchievements =
        (json['achievements'] as List?)?.map((a) {
          final id = a['id'] as String;
          final unlocked = a['unlocked'] as bool;
          return achievementMap[id]?.copyWith(unlocked: unlocked) ??
              achievementMap[id]!;
        }).toList() ??
        defaultAchievements;

    final loadedShopItems =
        (json['shopItems'] as List?)?.map((s) {
          final id = s['id'] as String;
          final purchased = s['purchased'] as bool;
          final level = s['level'] as int;
          return shopItemMap[id]?.copyWith(
                purchased: purchased,
                level: level,
              ) ??
              shopItemMap[id]!;
        }).toList() ??
        defaultShopItems;

    return PlayerData(
      totalCapsules: json['totalCapsules'] as int? ?? 0,
      highScoreArcade: json['highScoreArcade'] as int? ?? 0,
      highScoreTimeAttack: json['highScoreTimeAttack'] as int? ?? 0,
      highScoreDaily: json['highScoreDaily'] as int? ?? 0,
      totalOxygenPopped: json['totalOxygenPopped'] as int? ?? 0,
      totalGamesPlayed: json['totalGamesPlayed'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      achievements: loadedAchievements,
      shopItems: loadedShopItems,
      currentSkin: json['currentSkin'] as String? ?? 'default',
      lastDailyPlayed: json['lastDailyPlayed'] != null
          ? DateTime.parse(json['lastDailyPlayed'] as String)
          : null,
      dailySeed: json['dailySeed'] as int? ?? 0,
    );
  }
}
