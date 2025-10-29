import 'package:flutter/material.dart';

BoxDecoration buildBackgroundDecoration(Color baseColor) {
  final hsl = HSLColor.fromColor(baseColor);
  final darker = hsl
      .withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0))
      .toColor();
  final lighter = hsl
      .withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0))
      .toColor();

  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [darker, baseColor, lighter],
    ),
  );
}
