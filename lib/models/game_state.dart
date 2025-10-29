enum GameMode {
  arcade, 
  timeAttack, 
  daily, 
}

enum GameStatus { menu, playing, paused, gameOver }

class GameState {
  final int score;
  final int combo;
  final double multiplier;
  final int capsules; 
  final GameMode mode;
  final GameStatus status;
  final double timeRemaining; 
  final int perfectStreaks; 
  final bool hasPowerup; 
  final String? activePowerup;
  final double powerupTimeRemaining;
  final int oxygenPopped; 
  final int toxicHit; 
  final int currentStreak; 
  final int longestStreak; 
  final bool isSprintActive;
  final double sprintTimeRemaining;
  final int sprintTarget;
  final int sprintProgress;
  final int sprintReward;

  const GameState({
    this.score = 0,
    this.combo = 0,
    this.multiplier = 1.0,
    this.capsules = 0,
    this.mode = GameMode.arcade,
    this.status = GameStatus.menu,
    this.timeRemaining = 90.0,
    this.perfectStreaks = 0,
    this.hasPowerup = false,
    this.activePowerup,
    this.powerupTimeRemaining = 0.0,
    this.oxygenPopped = 0,
    this.toxicHit = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.isSprintActive = false,
    this.sprintTimeRemaining = 0.0,
    this.sprintTarget = 0,
    this.sprintProgress = 0,
    this.sprintReward = 0,
  });

  GameState copyWith({
    int? score,
    int? combo,
    double? multiplier,
    int? capsules,
    GameMode? mode,
    GameStatus? status,
    double? timeRemaining,
    int? perfectStreaks,
    bool? hasPowerup,
    String? activePowerup,
    double? powerupTimeRemaining,
    int? oxygenPopped,
    int? toxicHit,
    int? currentStreak,
    int? longestStreak,
    bool? isSprintActive,
    double? sprintTimeRemaining,
    int? sprintTarget,
    int? sprintProgress,
    int? sprintReward,
  }) {
    return GameState(
      score: score ?? this.score,
      combo: combo ?? this.combo,
      multiplier: multiplier ?? this.multiplier,
      capsules: capsules ?? this.capsules,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      perfectStreaks: perfectStreaks ?? this.perfectStreaks,
      hasPowerup: hasPowerup ?? this.hasPowerup,
      activePowerup: activePowerup ?? this.activePowerup,
      powerupTimeRemaining: powerupTimeRemaining ?? this.powerupTimeRemaining,
      oxygenPopped: oxygenPopped ?? this.oxygenPopped,
      toxicHit: toxicHit ?? this.toxicHit,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      isSprintActive: isSprintActive ?? this.isSprintActive,
      sprintTimeRemaining: sprintTimeRemaining ?? this.sprintTimeRemaining,
      sprintTarget: sprintTarget ?? this.sprintTarget,
      sprintProgress: sprintProgress ?? this.sprintProgress,
      sprintReward: sprintReward ?? this.sprintReward,
    );
  }

  int calculatePoints(int basePoints) {
    return (basePoints * multiplier).round();
  }

  double getNextMultiplier() {
    
    if (combo < 5) return 1.0;
    if (combo < 10) return 1.5;
    if (combo < 20) return 2.0;
    if (combo < 30) return 2.5;
    if (combo < 50) return 3.0;
    return 4.0;
  }

  bool isPerfectStreak() {
    return currentStreak >= 10 && toxicHit == 0;
  }
}
