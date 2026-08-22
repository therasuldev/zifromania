import 'package:zifromania/features/settings/domain/repositories/settings_repository.dart';

class SetSoundEnabledUseCase {
  final SettingsRepository _repository;

  SetSoundEnabledUseCase(this._repository);

  Future<bool> call(bool enabled) {
    return _repository.setSoundEnabled(enabled);
  }
}
