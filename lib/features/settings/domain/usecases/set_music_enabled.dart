import 'package:zifromania/features/settings/domain/repositories/settings_repository.dart';

class SetMusicEnabledUseCase {
  final SettingsRepository _repository;

  SetMusicEnabledUseCase(this._repository);

  Future<bool> call(bool enabled) {
    return _repository.setMusicEnabled(enabled);
  }
}
