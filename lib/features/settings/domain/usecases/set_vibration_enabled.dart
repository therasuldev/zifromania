import 'package:zifromania/features/settings/domain/repositories/settings_repository.dart';

class SetVibrationEnabledUseCase {
  final SettingsRepository _repository;

  SetVibrationEnabledUseCase(this._repository);

  Future<bool> call(bool enabled) {
    return _repository.setVibrationEnabled(enabled);
  }
}
