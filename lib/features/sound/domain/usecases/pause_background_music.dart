import 'package:zifromania/features/sound/domain/repositories/sound_repository.dart';

class PauseBackgroundMusicUseCase {
  final SoundRepository _soundRepository;

  PauseBackgroundMusicUseCase(this._soundRepository);

  Future<void> call() async {
    await _soundRepository.pauseBackgroundMusic();
  }
}