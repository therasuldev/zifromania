// settings_state.dart
part of 'settings_bloc.dart';

class SettingsState {
  final bool soundEnabled;
  final bool musicEnabled;
  final bool vibrationEnabled;
  final bool isLoading;

  SettingsState({
    required this.soundEnabled,
    required this.musicEnabled,
    required this.vibrationEnabled,
    this.isLoading = false,
  });

  factory SettingsState.initial() => SettingsState(
        soundEnabled: SettingsService.defaultSoundEnabled,
        musicEnabled: SettingsService.defaultMusicEnabled,
        vibrationEnabled: SettingsService.defaultVibrationEnabled,
        isLoading: true,
      );

  SettingsState copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? vibrationEnabled,
    bool? isLoading,
  }) {
    return SettingsState(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}