import 'package:zifromania/core/enum/haptic_feedback_type.dart';
import 'package:zifromania/features/sound/data/datasource/sound_local_datasource.dart';
import 'package:zifromania/features/sound/domain/repositories/sound_repository.dart';

class SoundRepositoryImpl implements SoundRepository {
  final SoundLocalDataSource localDataSource;

  SoundRepositoryImpl({required this.localDataSource});

  @override
  Future<void> init() {
    return localDataSource.init();
  }

  @override
  Future<void> pauseBackgroundMusic() {
    return localDataSource.pauseBackgroundMusic();
  }

  @override
  Future<void> playBackgroundMusic(String assetPath) {
    return localDataSource.playBackgroundMusic(assetPath);
  }

  @override
  Future<void> playSoundEffect(String assetPath) {
    return localDataSource.playSoundEffect(assetPath);
  }

  @override
  Future<void> resumeBackgroundMusic() {
    return localDataSource.resumeBackgroundMusic();
  }

  @override
  Future<void> stopBackgroundMusic() {
    return localDataSource.stopBackgroundMusic();
  }

  @override
  Future<void> vibrate(int durationInMilliseconds) {
    return localDataSource.vibrate(durationInMilliseconds);
  }

  @override
  Future<void> dispose() {
    return localDataSource.dispose();
  }

  @override
  Future<void> hapticFeedback(HapticFeedbackType type) {
    return localDataSource.hapticFeedback(type);
  }
}
