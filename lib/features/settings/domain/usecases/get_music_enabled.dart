import 'package:zifromania/features/settings/domain/repositories/settings_repository.dart';

class GetMusicEnabledUseCase {
  final SettingsRepository _repository;

  GetMusicEnabledUseCase(this._repository);

  bool call() => _repository.getMusicEnabled();
}
