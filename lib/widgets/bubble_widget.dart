import 'package:flutter/material.dart';
import '../models/bubble.dart';

class BubbleWidget extends StatelessWidget {
  final Bubble bubble;

  const BubbleWidget({super.key, required this.bubble});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: bubble.position.dx - bubble.radius,
      top: bubble.position.dy - bubble.radius,
      child: SizedBox(
        width: bubble.radius * 2,
        height: bubble.radius * 2,
        child: CustomPaint(
          painter: _BubblePainter(
            color: bubble.color,
            opacity: bubble.opacity,
            type: bubble.type,
          ),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  final Color color;
  final double opacity;
  final BubbleType type;

  _BubblePainter({
    required this.color,
    required this.opacity,
    required this.type,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    
    final paint = Paint()
      ..color = color.withValues(alpha: (opacity * 0.7).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);

    
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.6),
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.1),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, gradientPaint);

    
    final borderPaint = Paint()
      ..color = color.withValues(alpha: opacity.clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius, borderPaint);

    
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: (opacity * 0.8).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;

    final highlightOffset = Offset(
      center.dx - radius * 0.3,
      center.dy - radius * 0.3,
    );

    canvas.drawCircle(highlightOffset, radius * 0.2, highlightPaint);

    
    _drawIcon(canvas, center, radius);
  }

  void _drawIcon(Canvas canvas, Offset center, double radius) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    String icon;
    Color iconColor;

    switch (type) {
      case BubbleType.oxygen:
        icon = 'O₂';
        iconColor = Colors.white;
        break;
      case BubbleType.toxic:
        icon = '☠';
        iconColor = Colors.white;
        break;
      case BubbleType.neutral:
        icon = '○';
        iconColor = Colors.white70;
        break;
    }

    textPainter.text = TextSpan(
      text: icon,
      style: TextStyle(
        color: iconColor.withValues(alpha: opacity.clamp(0.0, 1.0)),
        fontSize: radius * 0.8,
        fontWeight: FontWeight.bold,
      ),
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(_BubblePainter oldDelegate) {
    return oldDelegate.opacity != opacity ||
        oldDelegate.color != color ||
        oldDelegate.type != type;
  }
}
