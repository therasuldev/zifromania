import 'package:zifromania/features/sound/domain/repositories/sound_repository.dart';

class VibrationUseCase {
  final SoundRepository soundRepository;
  VibrationUseCase(this.soundRepository);

  Future<void> call(int durationInMilliseconds) async {
    await soundRepository.vibrate(durationInMilliseconds);
  }
}
