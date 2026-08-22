import 'package:zifromania/features/settings/domain/repositories/settings_repository.dart';

class ResetToDefaultsUseCase {
  final SettingsRepository _repository;

  ResetToDefaultsUseCase(this._repository);

  Future<void> call() async {
    await _repository.resetToDefaults();
  }
}
