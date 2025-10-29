import 'dart:math';
import 'package:flutter/material.dart';
import '../models/bubble.dart';
import '../models/game_state.dart';
import '../models/hazard.dart';

class GameEngine extends ChangeNotifier {
  GameState _state = const GameState();
  List<Bubble> _bubbles = [];
  List<Hazard> _hazards = [];
  Size _screenSize = const Size(400, 800);

  double _timeSinceLastSpawn = 0;
  double _spawnInterval = 1.0;
  double _difficultyTimer = 0;
  int _bubbleIdCounter = 0;
  int _hazardIdCounter = 0;

  bool _turbulenceActive = false;
  double _gravityPulse = 0.0;
  double _timeSinceLastSprint = 0;

  Random _random = Random();

  GameState get state => _state;
  List<Bubble> get bubbles => _bubbles;
  List<Hazard> get hazards => _hazards;

  void setScreenSize(Size size) {
    _screenSize = size;
  }

  void startGame(GameMode mode, {int? seed}) {
    if (seed != null) {
      _random = Random(seed);
    } else {
      _random = Random();
    }

    _state = GameState(
      mode: mode,
      status: GameStatus.playing,
      timeRemaining: mode == GameMode.timeAttack ? 90.0 : 0.0,
    );
    _bubbles.clear();
    _hazards.clear();
    _timeSinceLastSpawn = 0;
    _spawnInterval = 1.0;
    _difficultyTimer = 0;
    _bubbleIdCounter = 0;
    _hazardIdCounter = 0;
    _turbulenceActive = false;
    _gravityPulse = 0.0;
    _timeSinceLastSprint = 0;

    notifyListeners();
  }

  void pauseGame() {
    if (_state.status == GameStatus.playing) {
      _state = _state.copyWith(status: GameStatus.paused);
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_state.status == GameStatus.paused) {
      _state = _state.copyWith(status: GameStatus.playing);
      notifyListeners();
    }
  }

  void update(double dt) {
    if (_state.status != GameStatus.playing) return;

    
    if (_state.mode == GameMode.timeAttack) {
      final newTime = (_state.timeRemaining - dt).clamp(0.0, double.infinity);
      _state = _state.copyWith(timeRemaining: newTime);

      if (newTime <= 0) {
        endGame();
        return;
      }
    }

    
    _difficultyTimer += dt;
    _updateDifficulty();

    
    _updateSprint(dt);

    
    _timeSinceLastSpawn += dt;
    if (_timeSinceLastSpawn >= _spawnInterval) {
      _spawnBubble();
      _timeSinceLastSpawn = 0;
    }

    
    final bubblesToRemove = <Bubble>[];
    for (final bubble in _bubbles) {
      bubble.update(
        dt,
        _screenSize,
        turbulence: _turbulenceActive,
        gravityPulse: _gravityPulse,
      );

      
      if (bubble.position.dy > _screenSize.height + 100 ||
          bubble.position.dy < -100 ||
          bubble.position.dx > _screenSize.width + 100 ||
          bubble.position.dx < -100) {
        bubblesToRemove.add(bubble);
      }

      
      for (final hazard in _hazards) {
        if (hazard.intersects(bubble.position, bubble.radius)) {
          if (bubble.type == BubbleType.oxygen && !bubble.isPopped) {
            
            bubble.isPopped = true;
            _resetCombo();
          }
        }
      }
    }

    _bubbles.removeWhere((b) => bubblesToRemove.contains(b) || b.isPopped);

    
    for (final hazard in _hazards) {
      hazard.update(dt, _screenSize);
    }

    
    _gravityPulse = 0;

    notifyListeners();
  }

  void _updateDifficulty() {
    
    final turbulenceCycle = _difficultyTimer % 20;
    _turbulenceActive = turbulenceCycle >= 15 && turbulenceCycle < 20;

    
    if (_difficultyTimer % 10 < 0.1 && _difficultyTimer > 1) {
      _gravityPulse = _random.nextBool() ? 1.0 : -1.0;
    }

    
    final wave = (_difficultyTimer / 30).floor();
    _spawnInterval = (1.0 - wave * 0.1).clamp(0.3, 1.0);

    
    if (_difficultyTimer > 30 && _hazards.length < 3) {
      if (_random.nextDouble() < 0.01) {
        _spawnHazard();
      }
    }
  }

  void _updateSprint(double dt) {
    if (_state.isSprintActive) {
      final newTime = (_state.sprintTimeRemaining - dt).clamp(
        0.0,
        double.infinity,
      );
      _state = _state.copyWith(sprintTimeRemaining: newTime);

      if (newTime <= 0 || _state.sprintProgress >= _state.sprintTarget) {
        
        if (_state.sprintProgress >= _state.sprintTarget) {
          
          _state = _state.copyWith(
            capsules: _state.capsules + _state.sprintReward,
          );
        }
        _state = _state.copyWith(
          isSprintActive: false,
          sprintTimeRemaining: 0,
          sprintTarget: 0,
          sprintProgress: 0,
        );
        _timeSinceLastSprint = 0;
      }
    } else {
      _timeSinceLastSprint += dt;
      
      if (_timeSinceLastSprint >= 30 + _random.nextDouble() * 15) {
        _startNewSprint();
      }
    }
  }

  void _startNewSprint() {
    final target = 500 + _random.nextInt(500); 
    final reward = (target / 10).round(); 

    _state = _state.copyWith(
      isSprintActive: true,
      sprintTimeRemaining: 20.0,
      sprintTarget: target,
      sprintProgress: 0,
      sprintReward: reward,
    );
  }

  void _spawnBubble() {
    
    double rand = _random.nextDouble();
    BubbleType type;

    if (rand < 0.7) {
      type = BubbleType.oxygen;
    } else if (rand < 0.85) {
      type = BubbleType.neutral;
    } else {
      type = BubbleType.toxic;
    }

    
    if (_difficultyTimer > 60 && _random.nextDouble() < 0.05) {
      type = BubbleType.toxic;
    }

    
    if (_state.combo == 0 &&
        _state.currentStreak == 0 &&
        type == BubbleType.toxic) {
      type = BubbleType.oxygen;
    }

    final x = _random.nextDouble() * _screenSize.width;
    final y = -50.0;

    final velocityX = (_random.nextDouble() - 0.5) * 100;
    final velocityY = 50 + _random.nextDouble() * 100;

    final bubble = Bubble(
      id: 'bubble_${_bubbleIdCounter++}',
      type: type,
      position: Offset(x, y),
      velocity: Offset(velocityX, velocityY),
      radius: 25 + _random.nextDouble() * 15,
    );

    _bubbles.add(bubble);
  }

  void _spawnHazard() {
    final type = _random.nextBool() ? HazardType.jellyfish : HazardType.blade;
    final x = _random.nextDouble() * _screenSize.width;
    final y = _random.nextDouble() * _screenSize.height;

    final velocityX = (_random.nextDouble() - 0.5) * 50;
    final velocityY = (_random.nextDouble() - 0.5) * 50;

    final hazard = Hazard(
      id: 'hazard_${_hazardIdCounter++}',
      type: type,
      position: Offset(x, y),
      velocity: Offset(velocityX, velocityY),
      size: 40 + _random.nextDouble() * 20,
    );

    _hazards.add(hazard);
  }

  void onTap(Offset position) {
    if (_state.status != GameStatus.playing) return;

    
    for (final bubble in _bubbles) {
      if (!bubble.isPopped && bubble.contains(position)) {
        _popBubble(bubble);
        return;
      }
    }
  }

  void _popBubble(Bubble bubble) {
    bubble.isPopped = true;

    switch (bubble.type) {
      case BubbleType.oxygen:
        _handleOxygenPop(bubble);
        break;
      case BubbleType.toxic:
        _handleToxicPop();
        break;
      case BubbleType.neutral:
        _handleNeutralPop(bubble);
        break;
    }

    notifyListeners();
  }

  void _handleOxygenPop(Bubble bubble) {
    final newCombo = _state.combo + 1;
    final newMultiplier = _getMultiplierForCombo(newCombo);
    final points = (bubble.points * newMultiplier).round();
    final newScore = _state.score + points;
    final newStreak = _state.currentStreak + 1;
    final newOxygenPopped = _state.oxygenPopped + 1;

    _state = _state.copyWith(
      score: newScore,
      combo: newCombo,
      multiplier: newMultiplier,
      currentStreak: newStreak,
      longestStreak: max(_state.longestStreak, newStreak),
      oxygenPopped: newOxygenPopped,
    );

    
    if (_state.isSprintActive) {
      _state = _state.copyWith(
        sprintProgress: _state.sprintProgress + bubble.points,
      );
    }

    
    if (newStreak > 0 && newStreak % 10 == 0) {
      final bonus = (100 * newMultiplier).round();
      _state = _state.copyWith(
        score: _state.score + bonus,
        perfectStreaks: _state.perfectStreaks + 1,
        capsules: _state.capsules + 5,
      );
    }
  }

  void _handleToxicPop() {
    _state = _state.copyWith(toxicHit: _state.toxicHit + 1);
    _resetCombo();
  }

  void _handleNeutralPop(Bubble bubble) {
    final points = (bubble.points * _state.multiplier).round();
    _state = _state.copyWith(score: _state.score + points);
  }

  void _resetCombo() {
    _state = _state.copyWith(combo: 0, multiplier: 1.0, currentStreak: 0);
  }

  double _getMultiplierForCombo(int combo) {
    if (combo < 5) return 1.0;
    if (combo < 10) return 1.5;
    if (combo < 20) return 2.0;
    if (combo < 30) return 2.5;
    if (combo < 50) return 3.0;
    return 4.0;
  }

  void activatePowerup(String powerupId) {
    _state = _state.copyWith(
      hasPowerup: true,
      activePowerup: powerupId,
      powerupTimeRemaining: _getPowerupDuration(powerupId),
    );

    switch (powerupId) {
      case 'clean_filter':
        _removeAllToxic();
        break;
      case 'slow_motion':
        
        break;
    }

    notifyListeners();
  }

  double _getPowerupDuration(String powerupId) {
    switch (powerupId) {
      case 'clean_filter':
        return 5.0;
      case 'slow_motion':
        return 3.0;
      default:
        return 0.0;
    }
  }

  void _removeAllToxic() {
    _bubbles.removeWhere((b) => b.type == BubbleType.toxic);
  }

  void endGame() {
    _state = _state.copyWith(status: GameStatus.gameOver);
    notifyListeners();
  }

  void returnToMenu() {
    _state = _state.copyWith(status: GameStatus.menu);
    _bubbles.clear();
    _hazards.clear();
    notifyListeners();
  }
}
