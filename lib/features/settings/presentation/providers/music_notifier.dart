import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zifromania/features/sound/sound_module.dart';
import 'package:zifromania/features/settings/settings_module.dart';
import 'package:zifromania/shared/constants/app_constants.dart';

class MusicNotifier extends Notifier<bool> {
  @override
  bool build() {
    return ref.read(getMusicEnabledUseCaseProvider).call();
  }

  Future<void> setMusicEnabled(bool enabled) async {
    await ref.read(setMusicEnabledUseCaseProvider).call(enabled);

    final soundRepository = ref.read(soundRepositoryProvider);
    if (enabled) {
      await soundRepository.playBackgroundMusic(backgroundMusicAsset);
    } else {
      await soundRepository.stopBackgroundMusic();
    }

    state = enabled;
  }
}

final musicNotifierProvider = NotifierProvider<MusicNotifier, bool>(
  MusicNotifier.new,
);
