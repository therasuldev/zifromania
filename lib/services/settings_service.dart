import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _soundKey = 'sound_enabled';
  static const String _musicKey = 'music_enabled';
  static const String _vibrationKey = 'vibration_enabled';
  static const String _languageKey = 'language';

  // Default values
  static const bool defaultSoundEnabled = true;
  static const bool defaultMusicEnabled = true;
  static const bool defaultVibrationEnabled = true;
  static const String defaultLanguage = 'en';

  late SharedPreferences _prefs;
  bool _initialized = false;

  // Initialize the service
  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  // Sound settings
  Future<bool> setSoundEnabled(bool value) async {
    await _ensureInitialized();
    return _prefs.setBool(_soundKey, value);
  }

  bool getSoundEnabled() {
    _ensureInitializedSync();
    return _prefs.getBool(_soundKey) ?? defaultSoundEnabled;
  }

  // Music settings
  Future<bool> setMusicEnabled(bool value) async {
    await _ensureInitialized();
    return _prefs.setBool(_musicKey, value);
  }

  bool getMusicEnabled() {
    _ensureInitializedSync();
    return _prefs.getBool(_musicKey) ?? defaultMusicEnabled;
  }

  // Vibration settings
  Future<bool> setVibrationEnabled(bool value) async {
    await _ensureInitialized();
    return _prefs.setBool(_vibrationKey, value);
  }

  bool getVibrationEnabled() {
    _ensureInitializedSync();
    return _prefs.getBool(_vibrationKey) ?? defaultVibrationEnabled;
  }

  // Language settings
  Future<bool> setLanguage(String language) async {
    await _ensureInitialized();
    return _prefs.setString(_languageKey, language);
  }
  String getLanguage() {
    _ensureInitializedSync();
    return _prefs.getString(_languageKey) ?? defaultLanguage;
  }

  // Helper methods to ensure the service is initialized
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
  }

  void _ensureInitializedSync() {
    if (!_initialized) {
      throw StateError('SettingsService must be initialized before use. Call init() first.');
    }
  }

  // For testing and reset purposes
  Future<void> resetToDefaults() async {
    await _ensureInitialized();
    await _prefs.setBool(_soundKey, defaultSoundEnabled);
    await _prefs.setBool(_musicKey, defaultMusicEnabled);
    await _prefs.setBool(_vibrationKey, defaultVibrationEnabled);
  }
}
