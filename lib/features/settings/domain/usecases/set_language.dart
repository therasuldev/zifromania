import 'package:zifromania/features/settings/domain/repositories/settings_repository.dart';

class SetLanguageUseCase {
  final SettingsRepository _repository;

  SetLanguageUseCase(this._repository);

  Future<bool> call(String language) {
    return _repository.setLanguage(language);
  }
}
