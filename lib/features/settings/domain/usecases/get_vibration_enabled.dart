import 'package:zifromania/features/settings/domain/repositories/settings_repository.dart';

class GetVibrationEnabledUseCase {
  final SettingsRepository _repository;

  GetVibrationEnabledUseCase(this._repository);

  bool call() => _repository.getVibrationEnabled();
}
