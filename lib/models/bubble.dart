import 'dart:math';
import 'package:flutter/material.dart';

enum BubbleType {
  oxygen, 
  toxic, 
  neutral, 
}

class Bubble {
  String id;
  BubbleType type;
  Offset position;
  Offset velocity;
  double radius;
  bool isPopped;
  Color color;
  double opacity;
  int points;

  Bubble({
    required this.id,
    required this.type,
    required this.position,
    required this.velocity,
    this.radius = 30.0,
    this.isPopped = false,
    this.opacity = 1.0,
    int? points,
  }) : color = _getColorForType(type),
       points = points ?? _getPointsForType(type);

  static Color _getColorForType(BubbleType type) {
    switch (type) {
      case BubbleType.oxygen:
        return const Color(0xFF4FC3F7); 
      case BubbleType.toxic:
        return const Color(0xFFE53935); 
      case BubbleType.neutral:
        return const Color(0xFFBDBDBD); 
    }
  }

  static int _getPointsForType(BubbleType type) {
    switch (type) {
      case BubbleType.oxygen:
        return 10;
      case BubbleType.toxic:
        return -50;
      case BubbleType.neutral:
        return 5;
    }
  }

  void update(
    double dt,
    Size screenSize, {
    bool turbulence = false,
    double gravityPulse = 0.0,
  }) {
    
    if (turbulence) {
      final random = Random();
      velocity = Offset(
        velocity.dx + (random.nextDouble() - 0.5) * 50 * dt,
        velocity.dy + (random.nextDouble() - 0.5) * 50 * dt,
      );
    }

    
    if (gravityPulse != 0.0) {
      velocity = Offset(
        velocity.dx + gravityPulse * 100 * dt,
        velocity.dy + gravityPulse * 100 * dt,
      );
    }

    
    position = Offset(
      position.dx + velocity.dx * dt,
      position.dy + velocity.dy * dt,
    );

    
    if (position.dx - radius < 0 || position.dx + radius > screenSize.width) {
      velocity = Offset(-velocity.dx * 0.8, velocity.dy);
      position = Offset(
        position.dx.clamp(radius, screenSize.width - radius),
        position.dy,
      );
    }

    if (position.dy - radius < 0 || position.dy + radius > screenSize.height) {
      velocity = Offset(velocity.dx, -velocity.dy * 0.8);
      position = Offset(
        position.dx,
        position.dy.clamp(radius, screenSize.height - radius),
      );
    }
  }

  bool contains(Offset point) {
    final distance = (position - point).distance;
    return distance <= radius;
  }

  Bubble copyWith({
    String? id,
    BubbleType? type,
    Offset? position,
    Offset? velocity,
    double? radius,
    bool? isPopped,
    double? opacity,
  }) {
    return Bubble(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      velocity: velocity ?? this.velocity,
      radius: radius ?? this.radius,
      isPopped: isPopped ?? this.isPopped,
      opacity: opacity ?? this.opacity,
    );
  }
}
