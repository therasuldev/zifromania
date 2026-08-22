import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zifromania/features/settings/presentation/state/settings_state.dart';
import 'package:zifromania/features/settings/settings_module.dart';

final class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    return SettingsState(
      soundEnabled: ref.read(getSoundEnabledUseCaseProvider).call(),
      musicEnabled: ref.read(getMusicEnabledUseCaseProvider).call(),
      vibrationEnabled: ref.read(getVibrationEnabledUseCaseProvider).call(),
      language: ref.read(getLanguageUseCaseProvider).call(),
    );
  }

  Future<void> resetToDefaults() async {
    await ref.read(resetToDefaultsUseCaseProvider).call();
    state = SettingsState.defaults();
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
