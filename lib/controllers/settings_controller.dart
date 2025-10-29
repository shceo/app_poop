import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/settings_service.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._service, this._audioService)
    : _backgroundColor = _service.defaultBackgroundColor,
      _musicEnabled = _service.defaultMusicEnabled;

  final SettingsService _service;
  final BackgroundAudioService _audioService;

  Color _backgroundColor;
  bool _musicEnabled;

  Color get backgroundColor => _backgroundColor;
  bool get isMusicEnabled => _musicEnabled;

  Future<void> loadSettings() async {
    _backgroundColor = await _service.loadBackgroundColor();
    _musicEnabled = await _service.loadMusicEnabled();
    await _audioService.setPlaying(_musicEnabled);
    notifyListeners();
  }

  Future<void> updateBackgroundColor(Color color) async {
    if (color == _backgroundColor) return;
    _backgroundColor = color;
    notifyListeners();
    await _service.saveBackgroundColor(color);
  }

  Future<void> setMusicEnabled(bool enabled) async {
    if (_musicEnabled == enabled) return;
    _musicEnabled = enabled;
    notifyListeners();
    await _service.saveMusicEnabled(enabled);
    await _audioService.setPlaying(enabled);
  }

  Future<void> refreshMusicState() async {
    await _audioService.setPlaying(_musicEnabled);
  }

  Future<void> pauseMusic() async {
    await _audioService.pause();
  }

  Color get defaultBackgroundColor => _service.defaultBackgroundColor;
}
