import 'package:zifromania/features/sound/domain/repositories/sound_repository.dart';

class ResumeBackgroundMusicUseCase {
  final SoundRepository _soundRepository;

  ResumeBackgroundMusicUseCase(this._soundRepository);

  Future<void> call() async {
    await _soundRepository.resumeBackgroundMusic();
  }
}
