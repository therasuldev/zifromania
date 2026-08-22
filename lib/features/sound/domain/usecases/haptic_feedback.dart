import 'package:zifromania/core/enum/haptic_feedback_type.dart';
import 'package:zifromania/features/sound/domain/repositories/sound_repository.dart';

class HapticFeedbackUseCase {
  final SoundRepository soundRepository;
  HapticFeedbackUseCase(this.soundRepository);

  Future<void> call(HapticFeedbackType type) async {
    await soundRepository.hapticFeedback(type);
  }
}
