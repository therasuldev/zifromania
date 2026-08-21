import 'package:zifromania/features/settings/data/datasource/settings_local_datasource.dart';
import 'package:zifromania/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDatasource localDatasource;

  SettingsRepositoryImpl({required this.localDatasource});

  @override
  Future<bool> setSoundEnabled(bool enabled) {
    return localDatasource.setSoundEnabled(enabled);
  }

  @override
  Future<bool> setMusicEnabled(bool enabled) {
    return localDatasource.setMusicEnabled(enabled);
  }

  @override
  Future<bool> setVibrationEnabled(bool enabled) {
    return localDatasource.setVibrationEnabled(enabled);
  }

  @override
  Future<bool> setLanguage(String language) {
    return localDatasource.setLanguage(language);
  }

  @override
  bool getSoundEnabled() {
    return localDatasource.getSoundEnabled();
  }

  @override
  bool getMusicEnabled() {
    return localDatasource.getMusicEnabled();
  }

  @override
  bool getVibrationEnabled() {
    return localDatasource.getVibrationEnabled();
  }

  @override
  String getLanguage() {
    return localDatasource.getLanguage();
  }

  @override
  Future<void> resetToDefaults() {
    return localDatasource.resetToDefaults();
  }
}
