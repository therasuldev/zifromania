import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zifromania/features/settings/settings_module.dart';

class SoundNotifier extends Notifier<bool> {
  @override
  bool build() {
    return ref.read(getSoundEnabledUseCaseProvider).call();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await ref.read(setSoundEnabledUseCaseProvider).call(enabled);
    state = enabled;
  }
}

final soundNotifierProvider = NotifierProvider<SoundNotifier, bool>(
  SoundNotifier.new,
);
