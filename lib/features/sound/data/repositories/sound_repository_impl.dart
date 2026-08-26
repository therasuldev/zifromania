import 'package:zifromania/core/enum/haptic_feedback_type.dart';
import 'package:zifromania/features/sound/data/datasource/sound_local_datasource.dart';
import 'package:zifromania/features/sound/domain/repositories/sound_repository.dart';

final class SoundRepositoryImpl implements SoundRepository {
  final SoundLocalDataSource localDataSource;

  SoundRepositoryImpl({required this.localDataSource});

  @override
  Future<void> init() async {
    await localDataSource.init();
  }

  @override
  Future<void> pauseBackgroundMusic() async {
    await localDataSource.pauseBackgroundMusic();
  }

  @override
  Future<void> playBackgroundMusic(String assetPath) async {
    await localDataSource.playBackgroundMusic(assetPath);
  }

  @override
  Future<void> playSoundEffect(String assetPath) async {
    await localDataSource.playSoundEffect(assetPath);
  }

  @override
  Future<void> resumeBackgroundMusic() async {
    await localDataSource.resumeBackgroundMusic();
  }

  @override
  Future<void> stopBackgroundMusic() async {
    await localDataSource.stopBackgroundMusic();
  }

  @override
  Future<void> vibrate(int durationInMilliseconds) async {
    await localDataSource.vibrate(durationInMilliseconds);
  }

  @override
  Future<void> dispose() async {
    await localDataSource.dispose();
  }

  @override
  Future<void> hapticFeedback(HapticFeedbackType type) async {
    await localDataSource.hapticFeedback(type);
  }
}
