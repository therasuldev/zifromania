import 'package:zifromania/features/settings/domain/repositories/settings_repository.dart';

class GetLanguageUseCase {
  final SettingsRepository _repository;

  GetLanguageUseCase(this._repository);

  String call() => _repository.getLanguage();
}
