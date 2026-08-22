import 'package:zifromania/features/sound/domain/repositories/sound_repository.dart';

class PlayBackgroundMusicUseCase {
  final SoundRepository _soundRepository;

  PlayBackgroundMusicUseCase(this._soundRepository);

  Future<void> call(String assetPath) async {
    await _soundRepository.playBackgroundMusic(assetPath);
  }
}
