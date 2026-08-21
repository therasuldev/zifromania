abstract interface class SettingsLocalDatasource {
  Future<bool> setSoundEnabled(bool enabled);
  bool getSoundEnabled();

  Future<bool> setMusicEnabled(bool enabled);
  bool getMusicEnabled();

  Future<bool> setVibrationEnabled(bool enabled);
  bool getVibrationEnabled();

  Future<bool> setLanguage(String language);
  String getLanguage();

  Future<void> resetToDefaults();
}
