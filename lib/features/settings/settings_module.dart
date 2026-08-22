import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zifromania/core/storage/shared_prefs_provider.dart';

import 'data/datasource/settings_local_datasource.dart';
import 'data/datasource/settings_local_datasource_impl.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/usecases/get_language.dart';
import 'domain/usecases/get_music_enabled.dart';
import 'domain/usecases/get_sound_enabled.dart';
import 'domain/usecases/get_vibration_enabled.dart';
import 'domain/usecases/reset_to_defaults_use_case.dart';
import 'domain/usecases/set_language.dart';
import 'domain/usecases/set_music_enabled.dart';
import 'domain/usecases/set_sound_enabled.dart';
import 'domain/usecases/set_vibration_enabled.dart';

final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>(
  (ref) => SettingsLocalDataSourceImpl(sharedPreferences: ref.read(sharedPreferencesProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(localDatasource: ref.read(settingsLocalDataSourceProvider)),
);

final getLanguageUseCaseProvider = Provider<GetLanguageUseCase>(
  (ref) => GetLanguageUseCase(ref.read(settingsRepositoryProvider)),
);

final setLanguageUseCaseProvider = Provider<SetLanguageUseCase>(
  (ref) => SetLanguageUseCase(ref.read(settingsRepositoryProvider)),
);

final getMusicEnabledUseCaseProvider = Provider<GetMusicEnabledUseCase>(
  (ref) => GetMusicEnabledUseCase(ref.read(settingsRepositoryProvider)),
);

final setMusicEnabledUseCaseProvider = Provider<SetMusicEnabledUseCase>(
  (ref) => SetMusicEnabledUseCase(ref.read(settingsRepositoryProvider)),
);

final getSoundEnabledUseCaseProvider = Provider<GetSoundEnabledUseCase>((ref) {
  return GetSoundEnabledUseCase(ref.read(settingsRepositoryProvider));
});

final setSoundEnabledUseCaseProvider = Provider<SetSoundEnabledUseCase>((ref) {
  return SetSoundEnabledUseCase(ref.read(settingsRepositoryProvider));
});

final getVibrationEnabledUseCaseProvider = Provider<GetVibrationEnabledUseCase>((ref) {
  return GetVibrationEnabledUseCase(ref.read(settingsRepositoryProvider));
});

final setVibrationEnabledUseCaseProvider = Provider<SetVibrationEnabledUseCase>((ref) {
  return SetVibrationEnabledUseCase(ref.read(settingsRepositoryProvider));
});

final resetToDefaultsUseCaseProvider = Provider<ResetToDefaultsUseCase>((ref) {
  return ResetToDefaultsUseCase(ref.read(settingsRepositoryProvider));
});
