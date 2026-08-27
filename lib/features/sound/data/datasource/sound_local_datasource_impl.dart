import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:zifromania/core/enum/haptic_feedback_type.dart';

import 'sound_local_datasource.dart';

final class SoundLocalDataSourceImpl implements SoundLocalDataSource {
  SoundLocalDataSourceImpl({
    AudioPlayer? effectPlayer,
    AudioPlayer? musicPlayer,
  })  : _effectPlayer = effectPlayer ?? AudioPlayer(),
        _musicPlayer = musicPlayer ?? AudioPlayer();

  final AudioPlayer _effectPlayer;
  final AudioPlayer _musicPlayer;

  String? _currentBackgroundMusic;

  @override
  Future<void> init() async {
    await _effectPlayer.setReleaseMode(ReleaseMode.release);
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(0.5);
  }

  @override
  Future<void> playSoundEffect(String assetPath) async {
    await _effectPlayer.play(AssetSource(assetPath));
  }

  @override
  Future<void> playBackgroundMusic(String assetPath) async {
    if (_currentBackgroundMusic != assetPath) {
      _currentBackgroundMusic = assetPath;

      await _musicPlayer.setSource(AssetSource(assetPath));
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    }

    await _musicPlayer.resume();
  }

  @override
  Future<void> stopBackgroundMusic() async {
    await _musicPlayer.stop();
    _currentBackgroundMusic = null;
  }

  @override
  Future<void> pauseBackgroundMusic() async {
    await _musicPlayer.pause();
  }

  @override
  Future<void> resumeBackgroundMusic() async {
    await _musicPlayer.resume();
  }

  @override
  Future<void> vibrate(int durationInMilliseconds) async {
    final hasVibrator = await Vibration.hasVibrator();

    if (!hasVibrator) {
      return;
    }

    await Vibration.vibrate(duration: durationInMilliseconds);
  }

  @override
  Future<void> hapticFeedback(HapticFeedbackType type) async {
    switch (type) {
      case HapticFeedbackType.light:
        await HapticFeedback.lightImpact();

      case HapticFeedbackType.medium:
        await HapticFeedback.mediumImpact();

      case HapticFeedbackType.heavy:
        await HapticFeedback.heavyImpact();

      case HapticFeedbackType.selection:
        await HapticFeedback.selectionClick();
    }
  }

  @override
  Future<void> dispose() async {
    await _effectPlayer.dispose();
    await _musicPlayer.dispose();
  }
}
