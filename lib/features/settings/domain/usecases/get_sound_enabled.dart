import 'package:zifromania/features/settings/domain/repositories/settings_repository.dart';

class GetSoundEnabledUseCase {
  final SettingsRepository _repository;

  GetSoundEnabledUseCase(this._repository);

  bool call() => _repository.getSoundEnabled();
}