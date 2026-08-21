import 'package:shared_preferences/shared_preferences.dart';

import 'settings_local_datasource.dart';

class SettingsLocalDatasourceImpl implements SettingsLocalDatasource {
  SettingsLocalDatasourceImpl({required this.sharedPreferences});

  final SharedPreferences sharedPreferences;

  // Keys for SharedPreferences
  static const String _soundKey = 'sound_enabled';
  static const String _musicKey = 'music_enabled';
  static const String _vibrationKey = 'vibration_enabled';
  static const String _languageKey = 'language';

  // Default values
  static const bool _defaultSoundEnabled = true;
  static const bool _defaultMusicEnabled = true;
  static const bool _defaultVibrationEnabled = true;
  static const String _defaultLanguage = 'en';

  @override
  Future<bool> setLanguage(String language) {
    return sharedPreferences.setString(_languageKey, language);
  }

  @override
  String getLanguage() {
    return sharedPreferences.getString(_languageKey) ?? _defaultLanguage;
  }

  @override
  bool getMusicEnabled() {
    return sharedPreferences.getBool(_musicKey) ?? _defaultMusicEnabled;
  }

  @override
  bool getSoundEnabled() {
    return sharedPreferences.getBool(_soundKey) ?? _defaultSoundEnabled;
  }

  @override
  bool getVibrationEnabled() {
    return sharedPreferences.getBool(_vibrationKey) ?? _defaultVibrationEnabled;
  }

  @override
  Future<void> resetToDefaults() {
    return Future.wait([
      sharedPreferences.setBool(_soundKey, _defaultSoundEnabled),
      sharedPreferences.setBool(_musicKey, _defaultMusicEnabled),
      sharedPreferences.setBool(_vibrationKey, _defaultVibrationEnabled),
      sharedPreferences.setString(_languageKey, _defaultLanguage),
    ]);
  }

  @override
  Future<bool> setMusicEnabled(bool enabled) {
    return sharedPreferences.setBool(_musicKey, enabled);
  }

  @override
  Future<bool> setSoundEnabled(bool enabled) {
    return sharedPreferences.setBool(_soundKey, enabled);
  }

  @override
  Future<bool> setVibrationEnabled(bool enabled) {
    return sharedPreferences.setBool(_vibrationKey, enabled);
  }
}
