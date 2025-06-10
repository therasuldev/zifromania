// settings_state.dart
part of 'settings_bloc.dart';

class SettingsState {
  final bool soundEnabled;
  final bool musicEnabled;
  final bool vibrationEnabled;
  final bool isLoading;
  final String language;

  SettingsState({
    required this.soundEnabled,
    required this.musicEnabled,
    required this.vibrationEnabled,
    this.isLoading = false,
    this.language = 'en',
  });

  factory SettingsState.initial() => SettingsState(
        soundEnabled: SettingsService.defaultSoundEnabled,
        musicEnabled: SettingsService.defaultMusicEnabled,
        vibrationEnabled: SettingsService.defaultVibrationEnabled,
        isLoading: true,
        language: 'en',
      );

  SettingsState copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? vibrationEnabled,
    bool? isLoading,
    String? language, 
  }) {
    return SettingsState(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      isLoading: isLoading ?? this.isLoading,
      language: language ?? this.language,
    );
  }
}