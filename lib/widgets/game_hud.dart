import 'package:flutter/material.dart';
import '../models/game_state.dart';

class GameHUD extends StatelessWidget {
  const GameHUD({super.key, required this.state, required this.onPause});

  final GameState state;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _TopStatusPanel(state: state, onPause: onPause),
            if (state.currentStreak >= 10) ...[
              const SizedBox(height: 12),
              _StreakIndicator(streak: state.currentStreak),
            ],
            const Spacer(),
            if (state.isSprintActive) _SprintCard(state: state),
          ],
        ),
      ),
    );
  }
}

class _TopStatusPanel extends StatelessWidget {
  const _TopStatusPanel({required this.state, required this.onPause});

  final GameState state;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ScoreColumn(state: state),
          const Spacer(),
          _PauseBlock(state: state, onPause: onPause),
        ],
      ),
    );
  }
}

class _ScoreColumn extends StatelessWidget {
  const _ScoreColumn({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.score.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _pill(
              label: 'Combo',
              value: 'x${state.combo}',
              color: _comboColor(state.combo),
            ),
            const SizedBox(width: 8),
            _pill(
              label: 'Caps',
              value: '+${state.capsules}',
              color: Colors.amberAccent,
            ),
          ],
        ),
        if (state.multiplier > 1.0) ...[
          const SizedBox(height: 6),
          Text(
            'Multiplier x${state.multiplier.toStringAsFixed(1)}',
            style: const TextStyle(
              color: Colors.amberAccent,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _pill({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static Color _comboColor(int combo) {
    if (combo >= 40) return Colors.purpleAccent;
    if (combo >= 25) return Colors.redAccent;
    if (combo >= 15) return Colors.orangeAccent;
    if (combo >= 8) return Colors.lightGreenAccent;
    return Colors.blueAccent;
  }
}

class _PauseBlock extends StatelessWidget {
  const _PauseBlock({required this.state, required this.onPause});

  final GameState state;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    final displayTimer = state.mode == GameMode.timeAttack;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: onPause,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(220, 255, 255, 255),
                  Color.fromARGB(160, 255, 255, 255),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.pause_rounded,
                color: Color(0xFF0D1B4C),
                size: 28,
              ),
            ),
          ),
        ),
        if (displayTimer) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '${state.timeRemaining.toInt()} s',
              style: TextStyle(
                color: state.timeRemaining < 10
                    ? Colors.redAccent
                    : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StreakIndicator extends StatelessWidget {
  const _StreakIndicator({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Colors.deepOrangeAccent.withValues(alpha: 0.85),
            Colors.redAccent.withValues(alpha: 0.85),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withValues(alpha: 0.4),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            'Streak $streak',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SprintCard extends StatelessWidget {
  const _SprintCard({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final progress = state.sprintTarget == 0
        ? 0.0
        : state.sprintProgress / state.sprintTarget;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sprint Challenge',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Collect ${state.sprintTarget} O₂ in ${state.sprintTimeRemaining.toInt()}s',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.orangeAccent.withValues(alpha: 0.85),
              ),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.sprintProgress} / ${state.sprintTarget}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                '+${state.sprintReward} capsules',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
