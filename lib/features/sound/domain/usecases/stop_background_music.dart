import 'package:zifromania/features/sound/domain/repositories/sound_repository.dart';

class StopBackgroundMusicUseCase {
  final SoundRepository _soundRepository;

  StopBackgroundMusicUseCase(this._soundRepository);

  Future<void> call() async {
    await _soundRepository.stopBackgroundMusic();
  }
}
