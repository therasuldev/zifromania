import 'package:zifromania/core/enum/haptic_feedback_type.dart';

abstract class SoundRepository {
  Future<void> init();

  Future<void> playSoundEffect(String assetPath);

  Future<void> playBackgroundMusic(String assetPath);

  Future<void> stopBackgroundMusic();

  Future<void> pauseBackgroundMusic();

  Future<void> resumeBackgroundMusic();

  Future<void> vibrate(int durationInMilliseconds);

  Future<void> hapticFeedback(HapticFeedbackType type);

  Future<void> dispose();
}