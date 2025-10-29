import 'dart:math';
import 'package:flutter/material.dart';

class MenuBubblesBackground extends StatefulWidget {
  const MenuBubblesBackground({super.key, required this.color});

  final Color color;

  @override
  State<MenuBubblesBackground> createState() => _MenuBubblesBackgroundState();
}

class _MenuBubblesBackgroundState extends State<MenuBubblesBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Bubble> _bubbles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _bubbles = List.generate(24, (_) => _createBubble());
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 14))
          ..addListener(_update)
          ..repeat();
  }

  _Bubble _createBubble() {
    final size = _random.nextDouble() * 30 + 24;
    return _Bubble(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: size,
      speed: _random.nextDouble() * 0.25 + 0.08,
      drift: _random.nextDouble() * 0.4 + 0.1,
      phase: _random.nextDouble() * 2 * pi,
    );
  }

  void _resetBubble(_Bubble bubble) {
    bubble.x = _random.nextDouble();
    bubble.y = 1.2;
    bubble.size = _random.nextDouble() * 30 + 24;
    bubble.speed = _random.nextDouble() * 0.25 + 0.08;
    bubble.drift = _random.nextDouble() * 0.4 + 0.1;
    bubble.phase = _random.nextDouble() * 2 * pi;
  }

  void _update() {
    const dt = 1 / 60;
    for (final bubble in _bubbles) {
      bubble.y -= bubble.speed * dt;
      bubble.x +=
          sin(_controller.value * 2 * pi + bubble.phase) * bubble.drift * dt;
      if (bubble.y + (bubble.size / 800) < -0.1) {
        _resetBubble(bubble);
      }
      if (bubble.x < -0.2 || bubble.x > 1.2) {
        bubble.x = _random.nextDouble();
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_update);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _BubblePainter(bubbles: _bubbles, baseColor: widget.color),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _Bubble {
  _Bubble({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.drift,
    required this.phase,
  });

  double x;
  double y;
  double size;
  double speed;
  double drift;
  double phase;
}

class _BubblePainter extends CustomPainter {
  _BubblePainter({required this.bubbles, required this.baseColor});

  final List<_Bubble> bubbles;
  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    final highlight = Colors.white.withValues(alpha: 0.45);
    final glowColor = Color.lerp(
      baseColor,
      Colors.white,
      0.4,
    )!.withValues(alpha: 0.12);
    final bubblePaint = Paint()..style = PaintingStyle.fill;
    final glowPaint = Paint()..style = PaintingStyle.fill;

    for (final bubble in bubbles) {
      final center = Offset(bubble.x * size.width, bubble.y * size.height);
      final radius = bubble.size;

      glowPaint.shader = RadialGradient(
        colors: [
          highlight.withValues(alpha: 0.26),
          glowColor,
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.8));
      canvas.drawCircle(center, radius * 1.8, glowPaint);

      bubblePaint.shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        colors: [
          highlight,
          Color.lerp(baseColor, Colors.white, 0.2)!.withValues(alpha: 0.4),
          Colors.white.withValues(alpha: 0.08),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, bubblePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) => true;
}
