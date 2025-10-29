import 'package:flutter/material.dart';
import '../models/hazard.dart';
import 'dart:math' as math;

class HazardWidget extends StatelessWidget {
  final Hazard hazard;

  const HazardWidget({super.key, required this.hazard});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: hazard.position.dx - hazard.size / 2,
      top: hazard.position.dy - hazard.size / 2,
      child: Transform.rotate(
        angle: hazard.rotation,
        child: SizedBox(
          width: hazard.size,
          height: hazard.size,
          child: CustomPaint(painter: _HazardPainter(type: hazard.type)),
        ),
      ),
    );
  }
}

class _HazardPainter extends CustomPainter {
  final HazardType type;

  _HazardPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case HazardType.jellyfish:
        _drawJellyfish(canvas, size);
        break;
      case HazardType.blade:
        _drawBlade(canvas, size);
        break;
    }
  }

  void _drawJellyfish(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    
    final bodyPaint = Paint()
      ..color = const Color(0xFFFF6B9D)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, bodyPaint);

    
    final tentaclePaint = Paint()
      ..color = const Color(0xFFFF6B9D).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * math.pi;
      final startX = center.dx + math.cos(angle) * radius;
      final startY = center.dy + math.sin(angle) * radius;

      final path = Path();
      path.moveTo(startX, startY);

      
      for (int j = 0; j < 3; j++) {
        final controlX =
            startX +
            math.cos(angle) * (j * 10 + 10) +
            math.sin(angle) * (j % 2 == 0 ? 5 : -5);
        final controlY = startY + math.sin(angle) * (j * 10 + 10);
        final endX = startX + math.cos(angle) * ((j + 1) * 10);
        final endY = startY + math.sin(angle) * ((j + 1) * 10);
        path.quadraticBezierTo(controlX, controlY, endX, endY);
      }

      canvas.drawPath(path, tentaclePaint);
    }

    
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx - radius / 3, center.dy - radius / 4),
      radius / 6,
      eyePaint,
    );

    canvas.drawCircle(
      Offset(center.dx + radius / 3, center.dy - radius / 4),
      radius / 6,
      eyePaint,
    );
  }

  void _drawBlade(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    
    final bladePaint = Paint()
      ..color = const Color(0xFF607D8B)
      ..style = PaintingStyle.fill;

    final bladePath = Path();

    
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi;
      final outerRadius = i % 2 == 0 ? radius : radius * 0.6;
      final x = center.dx + math.cos(angle) * outerRadius;
      final y = center.dy + math.sin(angle) * outerRadius;

      if (i == 0) {
        bladePath.moveTo(x, y);
      } else {
        bladePath.lineTo(x, y);
      }
    }

    bladePath.close();
    canvas.drawPath(bladePath, bladePaint);

    
    final centerPaint = Paint()
      ..color = const Color(0xFF455A64)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.3, centerPaint);

    
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius * 0.3, shinePaint);
  }

  @override
  bool shouldRepaint(_HazardPainter oldDelegate) {
    return oldDelegate.type != type;
  }
}
