// settings_event.dart
part of 'settings_bloc.dart';

enum SettingsEvents {
  loadSettings,
  toggleSound,
  toggleMusic,
  toggleVibration,
  resetSettings,
  playBackgroundMusic,
  stopBackgroundMusic,
  playClickSound,
  vibrate,

  setLanguage,
  getLanguage
}

class SettingsEvent {
  SettingsEvents type;
  dynamic payload;

  SettingsEvent.loadSettings()
      : type = SettingsEvents.loadSettings,
        payload = null;

  SettingsEvent.toggleSound({required bool enabled})
      : type = SettingsEvents.toggleSound,
        payload = enabled;

  SettingsEvent.toggleMusic({required bool enabled})
      : type = SettingsEvents.toggleMusic,
        payload = enabled;

  SettingsEvent.toggleVibration({required bool enabled})
      : type = SettingsEvents.toggleVibration,
        payload = enabled;

  SettingsEvent.resetSettings()
      : type = SettingsEvents.resetSettings,
        payload = null;

  SettingsEvent.playBackgroundMusic({required String assetPath})
      : type = SettingsEvents.playBackgroundMusic,
        payload = assetPath;

  SettingsEvent.stopBackgroundMusic()
      : type = SettingsEvents.stopBackgroundMusic,
        payload = null;

  SettingsEvent.playClickSound({required String assetPath})
      : type = SettingsEvents.playClickSound,
        payload = assetPath;

  SettingsEvent.vibrate({required int duration})
      : type = SettingsEvents.vibrate,
        payload = duration;

  SettingsEvent.setLanguage({required String language})
      : type = SettingsEvents.setLanguage,
        payload = language;

  SettingsEvent.getLanguage()
      : type = SettingsEvents.getLanguage,
        payload = null;
}
