import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:zifromania/services/settings_service.dart';

class SoundService {
  // Singleton pattern
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final SettingsService _settingsService = SettingsService();
  final AudioPlayer _effectPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  // Background music control
  String? _currentBackgroundMusic;
  bool _isMusicPlaying = false;

  // Initialize the service
  Future<void> init() async {
    await _settingsService.init();

    // Set up audio player configurations
    await _effectPlayer.setReleaseMode(ReleaseMode.release);
    await _musicPlayer.setReleaseMode(ReleaseMode.loop); // Loop background music
    await _musicPlayer.setVolume(0.5); // Lower volume for background music
  }

  // Play a sound effect
  Future<void> playSoundEffect(String assetPath) async {
    if (_settingsService.getSoundEnabled()) {
      try {
        await _effectPlayer.play(AssetSource(assetPath));
      } catch (e) {
        print('Error playing sound effect: $e');
      }
    }
  }

  // Play background music
  Future<void> playBackgroundMusic(String assetPath) async {
    if (_settingsService.getMusicEnabled()) {
      try {
        if (_currentBackgroundMusic != assetPath || !_isMusicPlaying) {
          _currentBackgroundMusic = assetPath;
          await _musicPlayer.stop();
          await _musicPlayer.play(AssetSource(assetPath));
          _isMusicPlaying = true;
        }
      } catch (e) {
        print('Error playing background music: $e');
      }
    }
  }

  // Stop background music
  Future<void> stopBackgroundMusic() async {
    try {
      await _musicPlayer.stop();
      _isMusicPlaying = false;
    } catch (e) {
      print('Error stopping background music: $e');
    }
  }

  // Pause background music
  Future<void> pauseBackgroundMusic() async {
    try {
      await _musicPlayer.pause();
      _isMusicPlaying = false;
    } catch (e) {
      print('Error pausing background music: $e');
    }
  }

  // Resume background music
  Future<void> resumeBackgroundMusic() async {
    if (_settingsService.getMusicEnabled() && _currentBackgroundMusic != null) {
      try {
        await _musicPlayer.resume();
        _isMusicPlaying = true;
      } catch (e) {
        print('Error resuming background music: $e');
      }
    }
  }

  // Perform vibration
  Future<void> vibrate({int duration = 300}) async {
    if (_settingsService.getVibrationEnabled()) {
      if (await Vibration.hasVibrator()) {
        try {
          Vibration.vibrate(duration: duration);
        } catch (e) {
          print('Error during vibration: $e');
        }
      }
    }
  }

  // Perform haptic feedback
  Future<void> hapticFeedback(HapticFeedbackType type) async {
    if (_settingsService.getVibrationEnabled()) {
      try {
        switch (type) {
          case HapticFeedbackType.light:
            await HapticFeedback.lightImpact();
            break;
          case HapticFeedbackType.medium:
            await HapticFeedback.mediumImpact();
            break;
          case HapticFeedbackType.heavy:
            await HapticFeedback.heavyImpact();
            break;
          case HapticFeedbackType.selection:
            await HapticFeedback.selectionClick();
            break;
        }
      } catch (e) {
        print('Error during haptic feedback: $e');
      }
    }
  }

  // Dispose resources
  Future<void> dispose() async {
    await _effectPlayer.dispose();
    await _musicPlayer.dispose();
  }
}

enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
}
