import 'package:audioplayers/audioplayers.dart';

class BackgroundAudioService {
  BackgroundAudioService() {
    _player.setReleaseMode(ReleaseMode.loop);
    _player.setVolume(_volume);
  }

  final AudioPlayer _player = AudioPlayer();
  final String _assetPath = 'audio/background.wav';
  double _volume = 0.3;
  bool _isPlaying = false;

  Future<void> play() async {
    if (_isPlaying) return;
    try {
      await _player.play(AssetSource(_assetPath));
      _isPlaying = true;
    } catch (_) {
      _isPlaying = false;
    }
  }

  Future<void> stop() async {
    if (!_isPlaying) return;
    await _player.stop();
    _isPlaying = false;
  }

  Future<void> setPlaying(bool enabled) async {
    if (enabled) {
      await play();
    } else {
      await stop();
    }
  }

  Future<void> pause() async {
    if (!_isPlaying) return;
    await _player.pause();
    _isPlaying = false;
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
  }

  void dispose() {
    _player.dispose();
  }
}
