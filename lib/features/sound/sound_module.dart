import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/datasource/sound_local_datasource.dart';
import 'data/datasource/sound_local_datasource_impl.dart';
import 'data/repositories/sound_repository_impl.dart';
import 'domain/usecases/haptic_feedback.dart';
import 'domain/usecases/pause_background_music.dart';
import 'domain/usecases/play_background_music.dart';
import 'domain/usecases/play_sound_effect.dart';
import 'domain/usecases/resume_background_music.dart';
import 'domain/usecases/stop_background_music.dart';
import 'domain/usecases/vibration.dart';

final soundDataSourceProvider = Provider<SoundLocalDataSource>((ref) {
  final dataSource = SoundLocalDataSourceImpl();

  dataSource.init();
  ref.onDispose(dataSource.dispose);

  return dataSource;
});

final soundRepositoryProvider = Provider<SoundRepositoryImpl>(
  (ref) => SoundRepositoryImpl(localDataSource: ref.read(soundDataSourceProvider)),
);

final hapticFeedbackUseCaseProvider = Provider<HapticFeedbackUseCase>((ref) {
  return HapticFeedbackUseCase(ref.read(soundRepositoryProvider));
});

final pauseBackgroundMusicUseCaseProvider = Provider<PauseBackgroundMusicUseCase>((ref) {
  return PauseBackgroundMusicUseCase(ref.read(soundRepositoryProvider));
});

final playBackgroundMusicUseCaseProvider = Provider<PlayBackgroundMusicUseCase>((ref) {
  return PlayBackgroundMusicUseCase(ref.read(soundRepositoryProvider));
});

final playSoundEffectUseCaseProvider = Provider<PlaySoundEffectUseCase>((ref) {
  return PlaySoundEffectUseCase(ref.read(soundRepositoryProvider));
});

final resumeBackgroundMusicUseCaseProvider = Provider<ResumeBackgroundMusicUseCase>((ref) {
  return ResumeBackgroundMusicUseCase(ref.read(soundRepositoryProvider));
});

final stopBackgroundMusicUseCaseProvider = Provider<StopBackgroundMusicUseCase>((ref) {
  return StopBackgroundMusicUseCase(ref.read(soundRepositoryProvider));
});

final vibrationUseCaseProvider = Provider<VibrationUseCase>((ref) {
  return VibrationUseCase(ref.read(soundRepositoryProvider));
});

final soundEffectProvider = Provider<PlaySoundEffectUseCase>((ref) {
  return ref.read(playSoundEffectUseCaseProvider);
});
