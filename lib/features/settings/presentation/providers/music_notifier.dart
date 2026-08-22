import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zifromania/features/settings/settings_module.dart';

class MusicNotifier extends Notifier<bool> {
  @override
  bool build() {
    return ref.read(getMusicEnabledUseCaseProvider).call();
  }

  Future<void> setMusicEnabled(bool enabled) async {
    await ref.read(setMusicEnabledUseCaseProvider).call(enabled);
    state = enabled;
  }
}

final musicNotifierProvider = NotifierProvider<MusicNotifier, bool>(
  MusicNotifier.new,
);
