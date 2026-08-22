import 'package:zifromania/features/sound/domain/repositories/sound_repository.dart';

class PlaySoundEffectUseCase {
   final SoundRepository _soundRepository;

   PlaySoundEffectUseCase(this._soundRepository);

   Future<void> call(String assetPath) async {
     await _soundRepository.playSoundEffect(assetPath);
   }
 }