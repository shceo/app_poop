import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _backgroundColorKey = 'background_color';
  static const int _defaultBackgroundColorValue = 0xFF0D47A1;
  static const String _musicEnabledKey = 'music_enabled';
  static const bool _defaultMusicEnabled = true;

  Future<Color> loadBackgroundColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_backgroundColorKey);
    return Color(colorValue ?? _defaultBackgroundColorValue);
  }

  Future<void> saveBackgroundColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_backgroundColorKey, color.toARGB32());
  }

  Color get defaultBackgroundColor => const Color(_defaultBackgroundColorValue);

  Future<bool> loadMusicEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_musicEnabledKey) ?? _defaultMusicEnabled;
  }

  Future<void> saveMusicEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_musicEnabledKey, enabled);
  }

  bool get defaultMusicEnabled => _defaultMusicEnabled;
}
