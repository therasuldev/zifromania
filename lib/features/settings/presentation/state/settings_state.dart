final class SettingsState {
  final bool soundEnabled;
  final bool musicEnabled;
  final bool vibrationEnabled;
  final String language;

  const SettingsState({
    required this.soundEnabled,
    required this.musicEnabled,
    required this.vibrationEnabled,
    required this.language,
  });

  factory SettingsState.defaults() {
    return const SettingsState(
      soundEnabled: true,
      musicEnabled: true,
      vibrationEnabled: true,
      language: 'en',
    );
  }
}
